#[derive(Debug, Clone)]
pub struct InfoData {
    pub title: String,
    pub author: String,
    pub video_id: String,
    pub short_description: String,
    pub view_count: u64,
    pub length_seconds: u64,
}

#[derive(Debug, Clone, Default)]
pub struct ProgressData {
    pub current_size: u64,
    pub total_size: Option<u64>,
}

