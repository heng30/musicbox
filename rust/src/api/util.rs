use anyhow::Result;
use std::path::Path;
use tokio::fs;

pub async fn create_dir_all(dir: String) -> Result<()> {
    if !Path::new(&dir).exists() {
        fs::create_dir_all(&dir).await?;
    }
    Ok(())
}
