use serde::Serialize;

#[derive(Debug, Clone, Default)]
pub struct InfoData {
    pub title: String,
    pub author: String,
    pub video_id: String,
    pub short_description: String,
    pub view_count: u64,
    pub length_seconds: u64,

    // only for bilibili
    pub bv_cid: i64,
}

#[derive(Debug, Clone, Default)]
pub struct ProgressData {
    pub current_size: u64,
    pub total_size: Option<u64>,
}

#[derive(Debug, Clone)]
pub enum MsgType {
    PlainText,
    YoutubeDownloadError,
}

#[derive(Debug, Clone)]
pub struct MsgItem {
    pub ty: MsgType,
    pub data: String,
}

#[derive(Serialize, Debug, Clone)]
pub struct DownloadError {
    pub id: String,
    pub msg: String,
}

pub mod bilibili {
    use serde::{Deserialize, Deserializer, Serialize, Serializer};

    pub const FNVAL_FLV: i64 = 0;
    pub const FNVAL_MP4: i64 = 1;
    pub const FNVAL_DASH: i64 = 16;
    pub const FNVAL_DASH_HDR: i64 = 64;
    pub const FNVAL_DASH_4K: i64 = 128;
    pub const FNVAL_DASH_DB: i64 = 256;
    pub const FNVAL_DASH_VISION: i64 = 512;
    pub const FNVAL_DASH_8K: i64 = 1024;
    pub const FNVAL_DASH_AV1: i64 = 2048;

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    pub struct Response<T> {
        #[serde(default = "default_i64")]
        pub code: i64,
        #[serde(default = "default_string")]
        pub message: String,
        #[serde(default = "default_i64")]
        pub ttl: i64,
        #[serde(default = "default_option")]
        pub data: Option<T>,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    pub struct BvInfo {
        #[serde(default = "default_string")]
        pub bvid: String,
        #[serde(default = "default_i64")]
        pub aid: i64,
        #[serde(default = "default_i64")]
        pub videos: i64,
        #[serde(default = "default_i64")]
        pub tid: i64,
        #[serde(default = "default_i64")]
        pub copyright: i64,
        #[serde(default = "default_string")]
        pub pic: String,
        #[serde(default = "default_string")]
        pub title: String,
        #[serde(default = "default_i64")]
        pub ctime: i64,
        #[serde(default = "default_string")]
        pub desc: String,
        #[serde(default = "default_vec", deserialize_with = "null_vec")]
        pub desc_v2: Vec<DescV2>,
        #[serde(default = "default_rights")]
        pub rights: Rights,
        #[serde(default = "default_owner")]
        pub owner: Owner,
        #[serde(default = "default_stat")]
        pub stat: Stat,
        #[serde(default = "default_i64")]
        pub state: i64,
        #[serde(default = "default_i64")]
        pub duration: i64,
        #[serde(default = "default_string")]
        pub dynamic: String,
        #[serde(default = "default_i64")]
        pub cid: i64,
        #[serde(default = "default_dimension")]
        pub dimension: Dimension,
        #[serde(default = "default_bool")]
        pub no_cache: bool,
        #[serde(default = "default_vec", deserialize_with = "null_vec")]
        pub pages: Vec<Page>,
        // todo subtitle...
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    pub struct DescV2 {
        #[serde(default = "default_string")]
        pub raw_text: String,
        #[serde(default = "default_i64", rename = "type")]
        pub desc_type: i64,
        #[serde(default = "default_i64")]
        pub biz_id: i64,
        #[serde(default = "default_rights")]
        pub rights: Rights,
        #[serde(default = "default_owner")]
        pub owner: Owner,
        #[serde(default = "default_stat")]
        pub stat: Stat,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    pub struct Rights {
        #[serde(default = "default_i64")]
        pub bp: i64,
        #[serde(default = "default_i64")]
        pub elec: i64,
        #[serde(default = "default_i64")]
        pub download: i64,
        #[serde(default = "default_i64")]
        pub movie: i64,
        #[serde(default = "default_i64")]
        pub pay: i64,
        #[serde(default = "default_i64")]
        pub hd5: i64,
        #[serde(default = "default_i64")]
        pub no_reprint: i64,
        #[serde(default = "default_i64")]
        pub autoplay: i64,
        #[serde(default = "default_i64")]
        pub ugc_pay: i64,
        #[serde(default = "default_i64")]
        pub is_cooperation: i64,
        #[serde(default = "default_i64")]
        pub ugc_pay_preview: i64,
        #[serde(default = "default_i64")]
        pub no_background: i64,
        #[serde(default = "default_i64")]
        pub clean_mode: i64,
        #[serde(default = "default_i64")]
        pub is_stein_gate: i64,
        #[serde(default = "default_i64")]
        pub is_360: i64,
        #[serde(default = "default_i64")]
        pub no_share: i64,
    }

    fn default_rights() -> Rights {
        Rights {
            bp: 0,
            elec: 0,
            download: 0,
            movie: 0,
            pay: 0,
            hd5: 0,
            no_reprint: 0,
            autoplay: 0,
            ugc_pay: 0,
            is_cooperation: 0,
            ugc_pay_preview: 0,
            no_background: 0,
            clean_mode: 0,
            is_stein_gate: 0,
            is_360: 0,
            no_share: 0,
        }
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    pub struct Owner {
        #[serde(default = "default_i64", rename = "type")]
        pub mid: i64,
        #[serde(default = "default_string")]
        pub name: String,
        #[serde(default = "default_string")]
        pub face: String,
    }

    fn default_owner() -> Owner {
        Owner {
            mid: 0,
            name: String::default(),
            face: String::default(),
        }
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    pub struct Stat {
        #[serde(default = "default_i64")]
        pub aid: i64,
        #[serde(default = "default_i64")]
        pub view: i64,
        #[serde(default = "default_i64")]
        pub danmaku: i64,
        #[serde(default = "default_i64")]
        pub reply: i64,
        #[serde(default = "default_i64")]
        pub favorite: i64,
        #[serde(default = "default_i64")]
        pub coin: i64,
        #[serde(default = "default_i64")]
        pub share: i64,
        #[serde(default = "default_i64")]
        pub now_rank: i64,
        #[serde(default = "default_i64")]
        pub his_rank: i64,
        #[serde(default = "default_i64")]
        pub like: i64,
        #[serde(default = "default_i64")]
        pub dislike: i64,
        #[serde(default = "default_string")]
        pub evaluation: String,
        #[serde(default = "default_string")]
        pub argue_msg: String,
    }

    fn default_stat() -> Stat {
        Stat {
            aid: 0,
            view: 0,
            danmaku: 0,
            reply: 0,
            favorite: 0,
            coin: 0,
            share: 0,
            now_rank: 0,
            his_rank: 0,
            like: 0,
            dislike: 0,
            evaluation: String::default(),
            argue_msg: String::default(),
        }
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    pub struct Dimension {
        #[serde(default = "default_i64")]
        pub width: i64,
        #[serde(default = "default_i64")]
        pub height: i64,
        #[serde(default = "default_i64")]
        pub rotate: i64,
    }

    fn default_dimension() -> Dimension {
        Dimension {
            width: 0,
            height: 0,
            rotate: 0,
        }
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    pub struct Page {
        #[serde(default = "default_i64")]
        pub cid: i64,
        #[serde(default = "default_i64")]
        pub page: i64,
        #[serde(default = "default_string")]
        pub from: String,
        #[serde(default = "default_string")]
        pub part: String,
        #[serde(default = "default_i64")]
        pub duration: i64,
        #[serde(default = "default_string")]
        pub vid: String,
        #[serde(default = "default_string")]
        pub weblink: String,
        #[serde(default = "default_dimension")]
        pub dimension: Dimension,
        #[serde(default = "default_string")]
        pub first_frame: String,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    pub struct VideoUrl {
        #[serde(default = "default_string")]
        pub from: String,
        #[serde(default = "default_string")]
        pub result: String,
        #[serde(default = "default_string")]
        pub message: String,
        #[serde(default = "default_i64")]
        pub quality: i64,
        #[serde(default = "default_string")]
        pub format: String,
        #[serde(default = "default_i64")]
        pub timelength: i64,
        #[serde(default = "default_string")]
        pub accept_format: String,
        #[serde(default = "default_vec", deserialize_with = "null_vec")]
        pub accept_description: Vec<String>,
        #[serde(default = "default_vec", deserialize_with = "null_vec")]
        pub accept_quality: Vec<i64>,
        #[serde(default = "default_i64")]
        pub video_codecid: i64,
        #[serde(default = "default_string")]
        pub seek_param: String,
        #[serde(default = "default_string")]
        pub seek_type: String,
        #[serde(default = "default_vec", deserialize_with = "null_vec")]
        pub durl: Vec<Durl>,
        #[serde(default = "default_vec", deserialize_with = "null_vec")]
        pub support_formats: Vec<SupportFormat>,
        #[serde(default = "default_dash")]
        pub dash: Dash,
    }

    fn default_dash() -> Dash {
        Dash::default()
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    pub struct Durl {
        #[serde(default = "default_i64")]
        pub order: i64,

        #[serde(default = "default_i64")]
        pub length: i64,

        #[serde(default = "default_i64")]
        pub size: i64,

        #[serde(default = "default_string")]
        pub ahead: String,

        #[serde(default = "default_string")]
        pub vhead: String,

        #[serde(default = "default_string")]
        pub url: String,

        #[serde(default = "default_vec", deserialize_with = "null_vec")]
        pub backup_url: Vec<String>,
        // todo : highFormat
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    pub struct SupportFormat {
        #[serde(default = "default_i64")]
        pub quality: i64,
        #[serde(default = "default_string")]
        pub format: String,
        #[serde(default = "default_string")]
        pub new_description: String,
        #[serde(default = "default_string")]
        pub display_desc: String,
        #[serde(default = "default_string")]
        pub superscript: String,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    pub struct Dash {
        pub duration: i64,
        #[serde(rename = "minBufferTime")]
        pub min_buffer_time: f64,
        #[serde(rename = "min_buffer_time")]
        pub min_buffer_time2: f64,
        pub video: Vec<Video>,
        pub audio: Vec<Audio>,
        // pub dolby: Value,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    pub struct Video {
        pub id: i64,
        pub base_url: String,
        #[serde(
            rename = "backupUrl",
            default = "default_vec",
            deserialize_with = "null_vec"
        )]
        pub backup_url: Vec<String>,
        #[serde(
            rename = "backup_url",
            default = "default_vec",
            deserialize_with = "null_vec"
        )]
        pub backup_url2: Vec<String>,
        pub bandwidth: i64,
        #[serde(rename = "mimeType")]
        pub mime_type: String,
        #[serde(rename = "mime_type")]
        pub mime_type2: String,
        pub codecs: String,
        pub width: i64,
        pub height: i64,
        #[serde(rename = "frameRate")]
        pub frame_rate: String,
        #[serde(rename = "frame_rate")]
        pub frame_rate2: String,
        pub sar: String,
        #[serde(rename = "startWithSap")]
        pub start_with_sap: i64,
        #[serde(rename = "start_with_sap")]
        pub start_with_sap2: i64,
        pub segment_base: SegmentBase,
        pub codecid: i64,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    pub struct Audio {
        pub id: i64,
        pub base_url: String,
        #[serde(
            rename = "backupUrl",
            default = "default_vec",
            deserialize_with = "null_vec"
        )]
        pub backup_url: Vec<String>,
        #[serde(
            rename = "backup_url",
            default = "default_vec",
            deserialize_with = "null_vec"
        )]
        pub backup_url2: Vec<String>,
        pub bandwidth: i64,
        #[serde(rename = "mimeType")]
        pub mime_type: String,
        #[serde(rename = "mime_type")]
        pub mime_type2: String,
        pub codecs: String,
        pub width: i64,
        pub height: i64,
        #[serde(rename = "frameRate")]
        pub frame_rate: String,
        #[serde(rename = "frame_rate")]
        pub frame_rate2: String,
        pub sar: String,
        #[serde(rename = "startWithSap")]
        pub start_with_sap: i64,
        #[serde(rename = "start_with_sap")]
        pub start_with_sap2: i64,
        pub segment_base: SegmentBase,
        pub codecid: i64,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    pub struct SegmentBase {
        pub initialization: String,
        pub index_range: String,
    }

    // 240P 极速 仅mp4方式支持
    pub const VIDEO_QUALITY_240P: VideoQuality = VideoQuality { code: 6 };

    // 360P 流畅
    pub const VIDEO_QUALITY_360P: VideoQuality = VideoQuality { code: 16 };

    // 480P 清晰
    pub const VIDEO_QUALITY_480P: VideoQuality = VideoQuality { code: 32 };

    // 720P 高清 ;
    // web端默认值 , B站前端需要登录才能选择，但是直接发送请求可以不登录就拿到720P的取流地址
    // 无720P时则为720P60
    pub const VIDEO_QUALITY_720P: VideoQuality = VideoQuality { code: 64 };

    // 720P60 高帧率 ; 需要认证登录账号
    pub const VIDEO_QUALITY_720P_60HZ: VideoQuality = VideoQuality { code: 74 };

    // 1080P 高清
    // TV端与APP端默认值, 需要认证登录账号
    pub const VIDEO_QUALITY_1080P: VideoQuality = VideoQuality { code: 80 };

    // 1080P+ 高码率	大多情况需求认证大会员账号
    pub const VIDEO_QUALITY_1080P_HIGH: VideoQuality = VideoQuality { code: 112 };

    // 1080P60 高帧率	大多情况需求认证大会员账号
    pub const VIDEO_QUALITY_1080P_60HZ: VideoQuality = VideoQuality { code: 116 };

    // 4K 超清	需要fnver&128=128且fourk=1  大多情况需求认证大会员账号
    pub const VIDEO_QUALITY_4K: VideoQuality = VideoQuality { code: 120 };

    // HDR 真彩色	仅支持dash方式
    // 需要fnver&64=64
    // 大多情况需求认证大会员账号
    pub const VIDEO_QUALITY_HDR: VideoQuality = VideoQuality { code: 125 };

    // 视频质量
    #[derive(Default, Debug, Clone, PartialEq)]
    pub struct VideoQuality {
        pub code: i64,
    }

    impl Serialize for VideoQuality {
        fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
        where
            S: Serializer,
        {
            serializer.serialize_i64(self.code.clone())
        }
    }

    impl<'de> Deserialize<'de> for VideoQuality {
        fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
        where
            D: Deserializer<'de>,
        {
            Ok(VideoQuality {
                code: Deserialize::deserialize(deserializer)?,
            })
        }
    }

    fn default_string() -> String {
        String::default()
    }

    fn default_i64() -> i64 {
        0
    }

    fn default_bool() -> bool {
        false
    }

    fn default_option<T>() -> Option<T> {
        Option::None
    }

    fn default_vec<T>() -> Vec<T> {
        vec![]
    }

    fn null_vec<'de, D, T: for<'d> serde::Deserialize<'d>>(
        d: D,
    ) -> std::result::Result<Vec<T>, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        let value: serde_json::Value = serde::Deserialize::deserialize(d)?;
        if value.is_null() {
            Ok(vec![])
        } else if value.is_array() {
            let mut vec: Vec<T> = vec![];
            for x in value.as_array().unwrap() {
                vec.push(match serde_json::from_value(x.clone()) {
                    Ok(t) => t,
                    Err(err) => return Err(serde::de::Error::custom(err.to_string())),
                });
            }
            Ok(vec)
        } else {
            Err(serde::de::Error::custom("type error"))
        }
    }
}
