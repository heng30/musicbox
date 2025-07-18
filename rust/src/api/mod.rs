pub mod bilibili;
pub mod data;
pub mod log;
pub mod lyric;
pub mod msg_center;
pub mod util;

const SINK_CHANNEL_SIZE: usize = 4096;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
