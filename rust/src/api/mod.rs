pub mod log;
pub mod db;
pub mod data;
pub mod util;
pub mod lyric;
pub mod youtube;
pub mod bilibili;
pub mod msg_center;

const SINK_CHANNEL_SIZE: usize = 4096;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
