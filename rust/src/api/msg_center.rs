use super::{data::MsgItem, SINK_CHANNEL_SIZE};
use crate::frb_generated::StreamSink;
use tokio::sync::{mpsc, Mutex};

lazy_static! {
    static ref CHANNEL: Mutex<Option<mpsc::Sender<MsgItem>>> = Mutex::new(None);
}

pub async fn msg_center_init(sink: StreamSink<MsgItem>) {
    let (tx, mut rx) = mpsc::channel(SINK_CHANNEL_SIZE);
    *CHANNEL.lock().await = Some(tx);

    while let Some(item) = rx.recv().await {
        if let Err(e) = sink.add(item) {
            log::warn!("msg_center sink add error: {e:?}");
        }
    }
}

pub async fn send(item: MsgItem) {
    _ = CHANNEL
        .lock()
        .await
        .clone()
        .expect("I know i already set the sender")
        .send(item)
        .await;
}
