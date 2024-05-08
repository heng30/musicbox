pub fn init() {
    init_logger();
}

#[cfg(not(any(target_os = "android", target_os = "ios")))]
pub fn init_logger() {
    use chrono::Local;
    use env_logger::fmt::Color;
    use std::io::Write;
    use std::sync::Once;

    static INIT: Once = Once::new();

    INIT.call_once(|| {
        env_logger::builder()
            .format(|buf, record| {
                let ts = Local::now().format("%Y-%m-%d %H:%M:%S");
                let mut level_style = buf.style();
                match record.level() {
                    log::Level::Warn | log::Level::Error => {
                        level_style.set_color(Color::Red).set_bold(true)
                    }
                    _ => level_style.set_color(Color::Blue).set_bold(true),
                };

                writeln!(
                    buf,
                    "[{} {} {} {}] {}",
                    ts,
                    level_style.value(record.level()),
                    record
                        .file()
                        .unwrap_or("None")
                        .split('/')
                        .last()
                        .unwrap_or("None"),
                    record.line().unwrap_or(0),
                    record.args()
                )
            })
            .init();
    });
}

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

#[cfg(target_os = "ios")]
#[flutter_rust_bridge::frb(sync)]
pub fn init_logger() {
    OsLogger::new("xyz.heng30.musicbox")
        .level_filter(LevelFilter::Debug)
        .init()
        .expect("init logger failed");
}
