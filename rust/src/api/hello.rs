use anyhow::Result;
use std::collections::HashMap;

// can call it from flutter with `await` prefixed keyword
pub fn hello(a: String) -> String {
    log::debug!("hello fn arg: a = {a}");
    println!("print: hello fn arg: a = {a}");
    a.repeat(4)
}

#[tokio::main]
pub async fn get_ip() -> Result<String> {
    let resp = reqwest::get("https://httpbin.org/ip")
        .await?
        .json::<HashMap<String, String>>()
        .await?;
    Ok(format!("{resp:#?}"))
}
