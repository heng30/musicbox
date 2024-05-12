pub mod log;
pub mod db;
pub mod data;
pub mod youtube;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
