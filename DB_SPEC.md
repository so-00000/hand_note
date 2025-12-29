# DB仕様書

## 概要
- DB名: `memos.db`
- DBエンジン: SQLite（`sqflite`）
- バージョン: `25`
- 生成・更新処理: `lib/core/db/database_helper.dart`

## テーブル一覧
- `status`
- `memos`

## テーブル定義

### status
ステータスのマスタテーブル。

| カラム名 | 型 | 制約 | デフォルト | 説明 |
| --- | --- | --- | --- | --- |
| `status_id` | INTEGER | PRIMARY KEY, AUTOINCREMENT |  | ステータスID |
| `sort_no` | INTEGER | NOT NULL |  | 表示順 |
| `status_nm` | TEXT | NOT NULL |  | ステータス名 |
| `status_color` | TEXT | NOT NULL |  | カラーコード |

#### 初期データ
| sort_no | status_nm | status_color |
| --- | --- | --- |
| 1 | 完了 | 1 |
| 2 | 未完了 | 2 |

### memos
メモ本体のテーブル。

| カラム名 | 型 | 制約 | デフォルト | 説明 |
| --- | --- | --- | --- | --- |
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT |  | メモID |
| `content` | TEXT | NOT NULL |  | メモ本文 |
| `status_id` | INTEGER | NOT NULL, FOREIGN KEY(`status_id`) REFERENCES `status`(`status_id`) | 2 | ステータスID |
| `created_at` | TEXT | NOT NULL |  | 作成日時（ISO-8601） |
| `updated_at` | TEXT |  |  | 更新日時（ISO-8601、null可） |

## リレーション
- `memos.status_id` → `status.status_id`

## マイグレーション方針
- バージョンアップ時は `memos` と `status` を削除して再作成。

## 備考
- テーブル作成・初期データ投入は `DatabaseHelper._createDB` に定義。
- テーブル構成は `dbVer` に依存するため、変更時は本書を更新すること。
