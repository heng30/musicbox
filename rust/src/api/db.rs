use anyhow::Result;
use std::collections::HashMap;
use tokio::{fs, sync::Mutex};

#[cfg(not(any(target_os = "android", target_os = "ios")))]
use serde::{Deserialize, Serialize};

#[cfg(not(any(target_os = "android", target_os = "ios")))]
use sqlx::{
    migrate::MigrateDatabase,
    sqlite::{Sqlite, SqlitePoolOptions},
    Pool,
};

const MAX_CONNECTIONS: u32 = 3;

#[cfg(not(any(target_os = "android", target_os = "ios")))]
#[derive(Serialize, Deserialize, Debug, Clone, sqlx::FromRow)]
pub struct ComEntry {
    pub id: i64,
    pub uuid: String,
    pub data: String,
}

#[cfg(not(any(target_os = "android", target_os = "ios")))]
lazy_static! {
    static ref POOL: Mutex<Option<Pool<Sqlite>>> = Mutex::new(None);
}

#[cfg(not(any(target_os = "android", target_os = "ios")))]
async fn pool() -> Pool<Sqlite> {
    POOL.lock().await.clone().unwrap()
}

pub async fn create_db(db_path: String) -> Result<()> {
    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    {
        Sqlite::create_database(&db_path).await?;

        let pool = SqlitePoolOptions::new()
            .max_connections(MAX_CONNECTIONS)
            .connect(&format!("sqlite:{}", db_path))
            .await?;

        *POOL.lock().await = Some(pool);
    }

    Ok(())
}

pub async fn delete_db(db_path: String) -> Result<()> {
    fs::remove_file(db_path).await?;
    Ok(())
}

pub async fn close_db() {
    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    POOL.lock().await.take();
}

pub async fn create_table(sql: String) -> Result<()> {
    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    sqlx::query(&sql).execute(&pool().await).await?;

    Ok(())
}

pub async fn insert(sql: String) -> Result<()> {
    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    sqlx::query(&sql).execute(&pool().await).await?;

    Ok(())
}

pub async fn update(sql: String) -> Result<()> {
    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    sqlx::query(&sql).execute(&pool().await).await?;

    Ok(())
}

pub async fn delete(sql: String) -> Result<()> {
    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    sqlx::query(&sql).execute(&pool().await).await?;

    Ok(())
}

pub async fn delete_all(sql: String) -> Result<()> {
    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    sqlx::query(&sql).execute(&pool().await).await?;

    Ok(())
}

pub async fn select(sql: String) -> Result<Vec<HashMap<String, String>>> {
    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    {
        let entrys = sqlx::query_as::<_, ComEntry>(&sql)
            .fetch_all(&pool().await)
            .await?
            .into_iter()
            .map(|item| {
                let mut m = HashMap::new();
                m.insert("uuid".to_string(), item.uuid);
                m.insert("data".to_string(), item.data);
                m
            })
            .collect::<Vec<HashMap<String, String>>>();

        Ok(entrys)
    }

    #[cfg(any(target_os = "android", target_os = "ios"))]
    Ok(vec![])
}

pub async fn select_all(sql: String) -> Result<Vec<HashMap<String, String>>> {
    select(sql).await
}

pub async fn drop_table(sql: String) -> Result<()> {
    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    sqlx::query(&sql).execute(&pool().await).await?;

    Ok(())
}

pub async fn row_count(sql: String) -> Result<i64> {
    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    {
        let count: (i64,) = sqlx::query_as(&sql).fetch_one(&pool().await).await?;
        Ok(count.0)
    }

    #[cfg(any(target_os = "android", target_os = "ios"))]
    Ok(0)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::Mutex;

    static MTX: Mutex<()> = Mutex::new(());
    const DB_PATH: &str = "/tmp/musicbox-test.db";
    const DELETE_ALL_SQL: &str = "DELETE FROM test";
    const INSERT_SQL_1: &str = "INSERT INTO test (uuid, data) VALUES('uuid-1', 'data-1')";
    const INSERT_SQL_2: &str = "INSERT INTO test (uuid, data) VALUES('uuid-2', 'data-2')";
    const UPDATE_SQL_1: &str = "UPDATE test SET data='data-3' WHERE uuid='uuid-1'";
    const SELECT_SQL_1: &str = "SELECT * FROM test WHERE uuid='uuid-1'";
    const DELETE_SQL_1: &str = "DELETE FROM test WHERE uuid='uuid-1'";
    const ROW_COUNT_SQL: &str = "SELECT COUNT(*) FROM test";
    const SELECT_ALL_SQL: &str = "SELECT * FROM test";
    const DROP_TABLE_SQL: &str = "DROP TABLE IF EXISTS test";

    async fn init() -> Result<()> {
        let sql =
        "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, uuid TEXT NOT NULL UNIQUE, data TEXT NOT NULL)";
        create_db(DB_PATH.to_string()).await?;
        create_table(sql.to_string()).await?;
        Ok(())
    }

    #[tokio::test]
    async fn test_create_close_delete_db() -> Result<()> {
        let _mtx = MTX.lock().unwrap();
        create_db(DB_PATH.to_string()).await?;
        close_db().await;
        delete_db(DB_PATH.to_string()).await?;
        Ok(())
    }

    #[tokio::test]
    async fn test_insert() -> Result<()> {
        let _mtx = MTX.lock().unwrap();
        init().await?;
        delete_all(DELETE_ALL_SQL.to_string()).await?;
        insert(INSERT_SQL_1.to_string()).await?;
        insert(INSERT_SQL_2.to_string()).await?;

        Ok(())
    }

    #[tokio::test]
    async fn test_update() -> Result<()> {
        let _mtx = MTX.lock().unwrap();
        init().await?;
        delete_all(DELETE_ALL_SQL.to_string()).await?;

        insert(INSERT_SQL_1.to_string()).await?;
        update(UPDATE_SQL_1.to_string()).await?;

        select(SELECT_SQL_1.to_string())
            .await?
            .first()
            .unwrap()
            .get("uuid")
            .unwrap();
        Ok(())
    }

    #[tokio::test]
    async fn test_delete() -> Result<()> {
        let _mtx = MTX.lock().unwrap();
        init().await?;
        delete_all(DELETE_ALL_SQL.to_string()).await?;
        insert(INSERT_SQL_1.to_string()).await?;
        delete(DELETE_SQL_1.to_string()).await?;
        assert_eq!(row_count(ROW_COUNT_SQL.to_string()).await?, 0);
        Ok(())
    }

    #[tokio::test]
    async fn test_select_one() -> Result<()> {
        let _mtx = MTX.lock().unwrap();
        init().await?;
        delete_all(DELETE_ALL_SQL.to_string()).await?;
        assert_eq!(select(SELECT_SQL_1.to_string()).await?.len(), 0);

        insert(INSERT_SQL_1.to_string()).await?;
        let items = select(SELECT_SQL_1.to_string()).await?;
        assert_eq!(items.len(), 1);
        Ok(())
    }

    #[tokio::test]
    async fn test_select_all() -> Result<()> {
        let _mtx = MTX.lock().unwrap();

        init().await?;
        delete_all(DELETE_ALL_SQL.to_string()).await?;
        insert(INSERT_SQL_1.to_string()).await?;
        insert(INSERT_SQL_2.to_string()).await?;
        let items = select_all(SELECT_ALL_SQL.to_string()).await?;
        assert_eq!(items.len(), 2);

        Ok(())
    }

    #[tokio::test]
    async fn test_drop_table() -> Result<()> {
        let _mtx = MTX.lock().unwrap();
        init().await?;
        assert!(drop_table(DROP_TABLE_SQL.to_string()).await.is_ok());
        Ok(())
    }
}
