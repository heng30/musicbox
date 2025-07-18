use anyhow::Result;
use regex::Regex;
use scraper::{Html, Selector};
use tokio::{fs, io::AsyncWriteExt};
use url::Url;

const LYRIC_BASE_URL: &str = "https://www.toomic.com";

#[derive(Default, Clone, Debug)]
pub struct SearchLyricItem {
    pub name: String,
    pub authors: String,
    pub token: String,
}

fn headers() -> Result<reqwest::header::HeaderMap> {
    const AGENT: &str = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36";
    const ACCEPT: &str = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8";

    let mut headers = reqwest::header::HeaderMap::new();
    headers.insert(reqwest::header::USER_AGENT, AGENT.parse()?);
    headers.insert(reqwest::header::ACCEPT, ACCEPT.parse()?);

    Ok(headers)
}

async fn inner_search(keyword: &str) -> Result<String> {
    let mut url = Url::parse(LYRIC_BASE_URL)?;
    url.query_pairs_mut().append_pair("search", &keyword);

    let client = reqwest::Client::new();
    let html = client
        .get(url.to_string())
        .send()
        .await?
        .error_for_status()?
        .text()
        .await?;

    Ok(html)
}

// <li>
//   <span>[伍佰&nbsp;&&nbsp;China&nbsp;Blue]</span>
//   <a
//     name="a_bank"
//     href="javascript:"
//     dates="9eyJFSUQiOiI1NjEwMjI4MiIsIk5hbWUiOiJcdTZjZWFcdTY4NjUiLCJUYWciOiJcdTRmMGRcdTRmNzAmbmJzcDsmJm5ic3A7Q2hpbmEmbmJzcDtCbHVlIiwiSW1nIjoiIiwiVHlwZSI6Imt3IiwiVmlwIjoiMSJ9"
//     >泪桥</a
//   >
// </li>
fn get_author_and_token(html_content: &str) -> Vec<SearchLyricItem> {
    let fragment = Html::parse_fragment(html_content);
    let li = Selector::parse("li").unwrap();
    let a = Selector::parse("a").unwrap();
    let spans = Selector::parse("span").unwrap();
    let dates = Selector::parse("[dates]").unwrap();

    let mut items = vec![];

    for li in fragment.select(&li) {
        let mut item = SearchLyricItem::default();

        for element in li.select(&a) {
            item.name = element.text().collect::<Vec<_>>().join("");
        }

        for element in li.select(&spans) {
            let span_text = element.text().collect::<Vec<_>>().join("");
            item.authors = span_text.trim_matches(&['[', ']']).to_string();
        }

        for element in li.select(&dates) {
            if let Some(dates_value) = element.value().attr("dates") {
                item.token = dates_value.to_string();
            }
        }

        if !item.name.is_empty() && !item.authors.is_empty() && !item.token.is_empty() {
            items.push(item);
        }
    }

    items
}

async fn lyric_html(token: String) -> Result<String> {
    let mut url = Url::parse(&format!("{LYRIC_BASE_URL}/searchr"))?;
    url.query_pairs_mut().append_pair("token", &token);

    let client = reqwest::Client::new();
    let html = client
        .get(&url.to_string())
        .headers(headers()?)
        .send()
        .await?
        .error_for_status()?
        .text()
        .await?;

    Ok(html)
}

fn extract_lyrics(html_content: &str) -> String {
    let fragment = Html::parse_fragment(html_content);
    let content_selector = Selector::parse(".content").unwrap();

    let mut extracted_text = String::new();
    let re = Regex::new(r"\[\d{2}:\d{2}.\d{3}\]").unwrap();

    if let Some(content_element) = fragment.select(&content_selector).next() {
        for (index, child) in content_element.children().into_iter().enumerate() {
            if index == 0 {
                continue;
            }

            let text = child
                .value()
                .as_text()
                .into_iter()
                .map(|item| item.text.to_string())
                .collect::<String>();

            let text = if re.is_match(&text) {
                text.replace("]", "] ")
            } else {
                text.replace("]", ".500] ")
            };

            extracted_text.push_str(&text);
        }
    }

    let lyric = extracted_text
        .chars()
        .filter(|c| *c != '\n')
        .collect::<String>();

    if lyric.is_empty() || lyric.trim() == "No lyrics" {
        return "".to_string();
    }

    format!("[00:00.000]{lyric}")
        .replace("[", "\n[")
        .trim_start()
        .to_string()
}

pub async fn search_lyric(keyword: String) -> Result<Vec<SearchLyricItem>> {
    let html_content = inner_search(&keyword).await?;
    Ok(get_author_and_token(&html_content))
}

pub async fn get_lyric(token: String) -> Result<String> {
    let html = lyric_html(token).await?;
    let lyric = extract_lyrics(&html);
    Ok(lyric)
}

pub async fn save_lyric(text: String, path: String) -> Result<()> {
    let mut file = fs::File::create(&path).await?;
    file.write(text.as_bytes()).await?;
    file.flush().await?;

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_lyric_all() -> Result<()> {
        let items = search_lyric("泪桥".to_string()).await?;
        assert!(items.len() > 0);

        let lyric = get_lyric(items[0].token.clone()).await?;
        save_lyric(lyric, "/tmp/1.lrc".to_string()).await?;

        Ok(())
    }
}
