use super::{
    data::{bilibili::*, DownloadError, InfoData, MsgItem, MsgType, ProgressData},
    msg_center, SINK_CHANNEL_SIZE,
};
use crate::frb_generated::StreamSink;
use anyhow::Result;
use tokio::{
    fs,
    io::AsyncWriteExt,
    sync::mpsc::{self, error::TrySendError},
};

mod bilibili {
    use anyhow::Result;
    use regex::Regex;
    use std::{
        collections::HashSet,
        path::Path,
        sync::atomic::{AtomicU64, Ordering},
    };
    use tokio_stream::StreamExt;
    use url::Url;

    use super::*;

    const API_HOST_URL: &'static str = "https://api.bilibili.com";

    pub struct Client {
        agent: reqwest::Client,
        content_length: AtomicU64,
    }

    fn from_str<T: for<'de> serde::Deserialize<'de>>(json: &str) -> Result<T> {
        Ok(serde_path_to_error::deserialize(
            &mut serde_json::Deserializer::from_str(json),
        )?)
    }

    impl Client {
        pub fn new(proxy_url: Option<String>) -> Result<Self> {
            const AGENT: &str = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36";

            let client = match proxy_url {
                Some(url) => reqwest::Client::builder()
                    .user_agent(AGENT)
                    .proxy(reqwest::Proxy::all(url)?)
                    .build()?,
                None => reqwest::Client::builder().user_agent(AGENT).build()?,
            };

            Ok(Client {
                agent: client,
                content_length: AtomicU64::new(0),
            })
        }

        async fn request_web(&self, url: String) -> Result<String> {
            log::debug!("Request : {}", url);
            let req = self.agent.get(url);
            let rsp = req.send().await?.error_for_status()?.text().await?;
            Ok(rsp)
        }

        async fn request_api<T: for<'de> serde::Deserialize<'de>>(
            &self,
            method: reqwest::Method,
            path: &str,
            query: Option<serde_json::Value>,
        ) -> Result<T> {
            let url = format!("{}{}", API_HOST_URL, path);
            log::debug!("Request : {}", url);
            let request = self.agent.request(method, url.as_str());
            let request = match query {
                None => request,
                Some(query) => request.query(&query),
            };

            let body = request.send().await?.text().await?;
            // println!("{body:?}");
            let response: Response<T> = from_str(&body)?;
            match &(response.code) {
                0 => Ok(response.data.ok_or(anyhow::anyhow!("no content"))?),
                _ => Err(anyhow::anyhow!(response.message)),
            }
        }

        async fn content_length(&self, url: String) -> Result<u64> {
            let cl = self.content_length.load(Ordering::SeqCst);
            if cl != 0 {
                return Ok(cl);
            }

            self.agent
                .get(url)
                .send()
                .await?
                .error_for_status()?
                .headers()
                .get(reqwest::header::CONTENT_LENGTH)
                .and_then(|cl| cl.to_str().ok())
                .and_then(|cl| cl.parse::<u64>().ok())
                .map(|cl| {
                    log::debug!("content length is {}", cl);
                    self.content_length.store(cl, Ordering::SeqCst);
                    cl
                })
                .ok_or_else(|| {
                    anyhow::anyhow!("the response did not contain a valid content-length field")
                })
        }

        pub async fn info(&self, bvid: String) -> Result<BvInfo> {
            Ok(self
                .request_api(
                    reqwest::Method::GET,
                    "/x/web-interface/view",
                    Option::Some(serde_json::json!({ "bvid": bvid })),
                )
                .await?)
        }

        pub async fn video_url(
            &self,
            bvid: String,
            cid: i64,
            fnval: i64,
            video_quality: VideoQuality,
        ) -> Result<VideoUrl> {
            Ok(self
                .request_api(
                    reqwest::Method::GET,
                    "/x/player/playurl",
                    Option::Some(serde_json::json!({
                        "bvid": bvid,
                        "cid":cid,
                        "qn":video_quality.code,
                        "fnval":fnval,
                        "fnver":0,
                        "fourk":1,
                    })),
                )
                .await?)
        }

        pub async fn fetch_ids(&self, keyword: String, max_id_count: usize) -> Result<Vec<String>> {
            let mut url = Url::parse("https://search.bilibili.com/all")?;
            url.query_pairs_mut().extend_pairs([
                ("from_source", "webtop_search"),
                ("keyword", &keyword),
                ("search_source", &format!("{}", max_id_count + 5)),
            ]);

            let html = self.request_web(url.to_string()).await?;

            let mut ids = HashSet::new();
            let re = Regex::new(r#"href="//www.bilibili.com/video/([A-Za-z0-9]*)/""#)?;
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

        pub async fn audio_urls(&self, bvid: String, cid: i64) -> Result<Vec<String>> {
            let audio_urls = self
                .video_url(bvid, cid, FNVAL_DASH, VIDEO_QUALITY_720P)
                .await?
                .dash
                .audio
                .into_iter()
                .map(|item| {
                    let mut l = vec![];
                    l.push(item.base_url.clone());
                    l.extend_from_slice(&item.backup_url[..]);
                    l.extend_from_slice(&item.backup_url2[..]);
                    l
                })
                .flatten()
                .collect::<Vec<String>>();

            Ok(audio_urls)
        }

        pub async fn download(
            &self,
            url: String,
            file_path: String,
            channel: Option<mpsc::Sender<ProgressData>>,
        ) -> Result<()> {
            let total_size = self.content_length(url.clone()).await?;

            let mut stream = self
                .agent
                .get(&url)
                .send()
                .await?
                .error_for_status()?
                .bytes_stream();

            let mut file = fs::File::create(Path::new(&file_path)).await?;
            let mut counter = 0_u64;

            while let Some(chunk) = stream.next().await {
                let chunk = chunk?;
                let len = chunk.len() as u64;

                file.write_all(&chunk).await?;

                if let Some(channel) = &channel {
                    counter += len;
                    if let Err(TrySendError::Closed(e)) = channel.try_send(ProgressData {
                        current_size: counter,
                        total_size: Some(total_size),
                    }) {
                        return Err(anyhow::anyhow!(format!("{e:?}")));
                    }
                }
            }

            Ok(())
        }
    }
}

pub async fn bv_fetch_ids(
    keyword: String,
    max_id_count: usize,
    proxy_url: Option<String>,
) -> Result<Vec<String>> {
    let client = bilibili::Client::new(proxy_url)?;
    client.fetch_ids(keyword, max_id_count).await
}

pub async fn bv_video_info(bvid: String, proxy_url: Option<String>) -> Result<InfoData> {
    let client = bilibili::Client::new(proxy_url)?;
    let info = client.info(bvid).await?;
    Ok(InfoData {
        title: info.title,
        video_id: info.bvid,
        short_description: info.desc,
        length_seconds: info.duration as u64,

        author: match info.desc_v2.first() {
            None => info.owner.name.clone(),
            Some(v) => {
                if v.owner.name.is_empty() {
                    info.owner.name.clone()
                } else {
                    v.owner.name.clone()
                }
            }
        },

        bv_cid: info.cid,
        ..Default::default()
    })
}

pub async fn bv_download_video_by_id_with_callback(
    sink: StreamSink<ProgressData>,
    id: String,
    cid: i64,
    download_path: String,
    proxy_url: Option<String>,
) -> Result<()> {
    let client = bilibili::Client::new(proxy_url)?;
    let audio_urls = client.audio_urls(id.clone(), cid).await?;
    let (tx, mut rx) = mpsc::channel(SINK_CHANNEL_SIZE);

    if audio_urls.is_empty() {
        return Err(anyhow::anyhow!("no find bilibili audio of {id}"));
    }

    // For logging in dart
    msg_center::send(MsgItem {
        ty: MsgType::PlainText,
        data: format!("start downlaod bilibili video: {id}"),
    })
    .await;

    tokio::spawn(async move {
        let mut errs = vec![];
        for url in audio_urls.into_iter() {
            match client
                .download(url, download_path.clone(), Some(tx.clone()))
                .await
            {
                Err(e) => {
                    let de = DownloadError {
                        id: id.clone(),
                        msg: e.to_string(),
                    };

                    errs.push(MsgItem {
                        ty: MsgType::YoutubeDownloadError,
                        data: serde_json::to_string(&de).unwrap_or("{}".to_string()),
                    });
                }
                _ => return,
            }
        }

        if !errs.is_empty() {
            msg_center::send(errs[0].clone()).await;
        }
    });

    while let Some(item) = rx.recv().await {
        if let Err(e) = sink.add(item) {
            log::warn!("sink add error: {e:?}");
            break;
        }
    }

    Ok(())
}

#[flutter_rust_bridge::frb(sync)]
pub fn bv_watch_url(id: String) -> String {
    format!("https://www.bilibili.com/video/{id}")
}

#[cfg(test)]
mod tests {
    use super::*;

    const BV_ID: &str = "BV1RE421M7tr";

    #[tokio::test]
    async fn test_bv_fetch_ids() -> Result<()> {
        let ids = bv_fetch_ids("泪桥".to_string(), 10, None).await?;
        assert!(ids.len() > 0);

        for id in ids.into_iter() {
            println!("{id}");
        }

        Ok(())
    }

    #[tokio::test]
    async fn test_bv_video_info() -> Result<()> {
        let info = bv_video_info(BV_ID.to_string(), None).await?;
        println!("{info:?}");

        Ok(())
    }

    #[tokio::test]
    async fn test_bv_download() -> Result<()> {
        let path = "/tmp/1.m4s";
        _ = fs::remove_file(path).await;

        let (tx, mut rx) = mpsc::channel(SINK_CHANNEL_SIZE);

        tokio::spawn(async move {
            let info = bv_video_info(BV_ID.to_string(), None).await.unwrap();
            let client = bilibili::Client::new(None).unwrap();
            let audio_urls = client
                .audio_urls(BV_ID.to_string(), info.bv_cid)
                .await
                .unwrap();

            assert!(audio_urls.len() > 0);

            client
                .download(
                    audio_urls.first().unwrap().to_string(),
                    path.to_string(),
                    Some(tx),
                )
                .await
                .expect("download bilibili audio error");
        });

        while let Some(item) = rx.recv().await {
            println!("{}/{}", item.current_size, item.total_size.unwrap_or(0));
        }

        assert_eq!(fs::try_exists(path).await?, true);

        Ok(())
    }
}
