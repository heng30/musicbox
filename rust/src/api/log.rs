pub fn init() {
    init_logger();
}

#[cfg(not(target_os = "android"))]
pub fn init_logger() {}

#[cfg(target_os = "android")]
#[flutter_rust_bridge::frb(sync)]
pub fn init_logger() {
    android_logger::init_once(
        android_logger::Config::default()
            .with_max_level(log::LevelFilter::Trace)
            .with_filter(
                android_logger::FilterBuilder::new()
                    .filter_level(log::LevelFilter::Debug)
                    .build(),
            ),
    );
}
