use super::data::{InfoData, ProgressData};
use crate::frb_generated::StreamSink;
use anyhow::Result;
use regex::Regex;
use rustube::{
    fetcher, reqwest, tokio::sync::mpsc, url::Url, Callback, CallbackArguments, Id, VideoFetcher,
};
use std::collections::HashSet;

async fn client(proxy_url: Option<String>) -> Result<reqwest::Client> {
    let client = match proxy_url {
        Some(url) => {
            let cookie_jar = fetcher::recommended_cookies();
            let headers = fetcher::recommended_headers();

            reqwest::Client::builder()
                .default_headers(headers)
                .cookie_provider(std::sync::Arc::new(cookie_jar))
                .proxy(reqwest::Proxy::all(url)?)
                .build()?
        }
        None => reqwest::Client::new(),
    };

    Ok(client)
}

pub async fn fetch_ids(
    keyword: String,
    max_id_count: usize,
    proxy_url: Option<String>,
) -> Result<Vec<String>> {
    let client = client(proxy_url).await?;
    let mut url = Url::parse("https://www.youtube.com/results")?;
    url.query_pairs_mut().append_pair("search_query", &keyword);
    let url = url.to_string();

    let html = client.get(url).send().await?.text().await?;

    let mut ids = HashSet::new();
    let re = Regex::new(r#""videoId":"([^"]*)""#)?;
    for cap in re.captures_iter(&html) {
        if ids.len() >= max_id_count {
            break;
        }

        if let Some(value) = cap.get(1) {
            log::debug!("Found: {}", value.as_str());
            ids.insert(value.as_str().to_string());
        }
    }

    return Ok(ids.into_iter().collect());
}

pub async fn video_info(url: String, proxy_url: Option<String>) -> Result<InfoData> {
    let id = Id::from_raw(&url)?;
    video_info_by_id(id.to_string(), proxy_url).await
}

pub async fn video_info_by_id(id: String, proxy_url: Option<String>) -> Result<InfoData> {
    let id = Id::from_str(&id)?;
    let client = client(proxy_url).await?;

    let descrambler = VideoFetcher::from_id_with_client(id.into_owned(), client)
        .fetch()
        .await?;

    let raw_info = descrambler.video_info();

    Ok(InfoData {
        title: raw_info.player_response.video_details.title.to_string(),
        author: raw_info.player_response.video_details.author.to_string(),
        video_id: raw_info.player_response.video_details.video_id.to_string(),
        short_description: raw_info
            .player_response
            .video_details
            .short_description
            .to_string(),
        view_count: raw_info.player_response.video_details.view_count,
        length_seconds: raw_info.player_response.video_details.length_seconds,
    })
}

pub async fn download_video(
    url: String,
    download_path: String,
    proxy_url: Option<String>,
) -> Result<()> {
    let id = Id::from_raw(&url)?;
    download_video_by_id(id.to_string(), download_path, proxy_url).await
}

pub async fn download_video_by_id(
    id: String,
    download_path: String,
    proxy_url: Option<String>,
) -> Result<()> {
    let id = Id::from_str(&id)?;
    let client = client(proxy_url).await?;

    let video = VideoFetcher::from_id_with_client(id.into_owned(), client)
        .fetch()
        .await?
        .descramble()?;

    match video.best_quality() {
        Some(stream) => stream.download_to(download_path).await?,
        None => match video.worst_video() {
            None => anyhow::bail!("no video"),
            Some(stream) => stream.download_to(download_path).await?,
        },
    };

    Ok(())
}

pub async fn download_video_by_id_with_callback(
    sink: StreamSink<ProgressData>,
    id: String,
    download_path: String,
    proxy_url: Option<String>,
) -> Result<()> {
    let (tx, mut rx) = mpsc::channel(1024);

    tokio::spawn(async move {
        match inner_download_video_by_id_with_callback(id, download_path, proxy_url, tx).await {
            Err(e) => log::warn!("{e:?}"),
            _ => (),
        }
    });

    while let Some(item) = rx.recv().await {
        if let Err(e) = sink.add(ProgressData {
            current_size: item.current_chunk as u64,
            total_size: item.content_length,
        }) {
            log::warn!("sink add error: {e:?}");
        }
    }
    Ok(())
}

async fn inner_download_video_by_id_with_callback(
    id: String,
    download_path: String,
    proxy_url: Option<String>,
    tx: mpsc::Sender<CallbackArguments>,
) -> Result<()> {
    let id = Id::from_str(&id)?;
    let client = client(proxy_url).await?;

    let video = VideoFetcher::from_id_with_client(id.into_owned(), client)
        .fetch()
        .await?
        .descramble()?;

    let cb = Callback::new().connect_on_progress_sender(tx, true);
    match video.best_quality() {
        Some(stream) => stream.download_to_with_callback(download_path, cb).await?,
        None => match video.worst_video() {
            None => anyhow::bail!("no video"),
            Some(stream) => stream.download_to(download_path).await?,
        },
    };

    Ok(())
}

pub async fn download_audio(
    url: String,
    download_path: String,
    proxy_url: Option<String>,
) -> Result<()> {
    let id = Id::from_raw(&url)?;
    download_audio_by_id(id.to_string(), download_path, proxy_url).await
}

pub async fn download_audio_by_id(
    id: String,
    download_path: String,
    proxy_url: Option<String>,
) -> Result<()> {
    let id = Id::from_str(&id)?;
    let client = client(proxy_url).await?;

    let video = VideoFetcher::from_id_with_client(id.into_owned(), client)
        .fetch()
        .await?
        .descramble()?;

    match video.best_audio() {
        Some(stream) => stream.download_to(download_path).await?,
        None => match video.worst_video() {
            None => anyhow::bail!("no audio"),
            Some(stream) => stream.download_to(download_path).await?,
        },
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use tokio::fs;

    const PROXY_URL: &str = "socks5://127.0.0.1:1084";
    const VIDEO_URL: &str = "https://www.youtube.com/watch?v=vdMTIe5ihYg";
    const VIDEO_ID: &str = "vdMTIe5ihYg";

    #[tokio::test]
    async fn test_fetch_ids() -> Result<()> {
        let ids = fetch_ids("泪桥".to_string(), 5, Some(PROXY_URL.to_string())).await?;

        for (index, id) in ids.into_iter().enumerate() {
            println!("id[{index}]: {id}");
        }
        Ok(())
    }

    #[tokio::test]
    async fn test_download_video() -> Result<()> {
        let path = "/tmp/1.mp4";
        _ = fs::remove_file(path).await;
        download_video(
            VIDEO_URL.to_string(),
            path.to_string(),
            Some(PROXY_URL.to_string()),
        )
        .await?;
        assert_eq!(fs::try_exists(path).await?, true);

        Ok(())
    }

    #[tokio::test]
    async fn test_download_video_by_id() -> Result<()> {
        let path = "/tmp/1-id.mp4";
        _ = fs::remove_file(path).await;
        download_video_by_id(
            VIDEO_ID.to_string(),
            path.to_string(),
            Some(PROXY_URL.to_string()),
        )
        .await?;
        assert_eq!(fs::try_exists(path).await?, true);

        Ok(())
    }

    #[tokio::test]
    async fn test_inner_download_video_by_id_with_callback() -> Result<()> {
        let path = "/tmp/1-id-cb.mp4";
        _ = fs::remove_file(path).await;
        let (tx, mut rx) = mpsc::channel(1024);

        tokio::spawn(async move {
            inner_download_video_by_id_with_callback(
                VIDEO_ID.to_string(),
                path.to_string(),
                Some(PROXY_URL.to_string()),
                tx,
            )
            .await
            .expect("inner_download_video_by_id_with_callback error");
        });

        while let Some(item) = rx.recv().await {
            println!(
                "{}/{}",
                item.current_chunk,
                item.content_length.unwrap_or(0)
            );
        }

        assert_eq!(fs::try_exists(path).await?, true);

        Ok(())
    }

    #[tokio::test]
    async fn test_download_audio() -> Result<()> {
        let path = "/tmp/1.webp";
        download_audio(
            VIDEO_URL.to_string(),
            path.to_string(),
            Some(PROXY_URL.to_string()),
        )
        .await?;
        assert_eq!(fs::try_exists(path).await?, true);

        Ok(())
    }

    #[tokio::test]
    async fn test_download_audio_by_id() -> Result<()> {
        let path = "/tmp/1-id.webp";
        download_audio_by_id(
            VIDEO_ID.to_string(),
            path.to_string(),
            Some(PROXY_URL.to_string()),
        )
        .await?;
        assert_eq!(fs::try_exists(path).await?, true);

        Ok(())
    }

    #[tokio::test]
    async fn test_video_info() -> Result<()> {
        let info = video_info(VIDEO_URL.to_string(), Some(PROXY_URL.to_string())).await?;
        println!("{info:?}");
        assert_eq!(info.video_id, VIDEO_ID);

        Ok(())
    }

    #[tokio::test]
    async fn test_video_info_by_id() -> Result<()> {
        let info = video_info_by_id(VIDEO_ID.to_string(), Some(PROXY_URL.to_string())).await?;
        println!("{info:?}");
        assert_eq!(info.video_id, VIDEO_ID);

        Ok(())
    }
}
