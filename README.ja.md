# MediaOrganizer

[exiftool](https://exiftool.org/) と [czkawka](https://github.com/qarmin/czkawka) を使って、写真・動画を日付・撮影地・機種名で自動整理する Windows バッチツールです。

## 機能

- **重複削除** — ハッシュ完全一致による重複削除 + 視覚的類似画像の削除（czkawka）
- **メタデータ整理** — EXIF 情報をもとに `Photos/` / `Movies/` へ日付・撮影地・機種名で振り分け
- **優先度ルール** — `DateTimeOriginal` → `CreateDate` → `FileModifyDate` → `NoDate` の順にフォールバック
- **撮影地フォルダ** — GPS があるファイルは ExifTool Geolocation で `country/region/city` を追加（欠けた階層は飛ばす）。無い場合は `NoLocation` の1階層（番地までの住所にはならない）。地名は標準の ExifTool データベースの英語名（例: `Japan/Tokyo/Shibuya`）
- **機種フォルダ** — 写真は `Model`、動画は `Make`。無い場合は `Unknown`
- **小文字化** — NTFS の無音スキップ問題を一時名経由方式で回避して確実に小文字化
- **空フォルダ削除** — 整理後に残った空フォルダを再帰削除
- **一括実行** — `run_all.bat` 1本で全工程を順に実行
- **コンソールログ** — 実行内容を `MediaOrganizer/logs/` に UTF-8 で保存

## フォルダ構成

`MediaOrganizer/` フォルダをデータフォルダの隣に配置します：

```
(作業フォルダ)/
├── Unsorted/          ← 未整理のメディアをここに入れる
├── Photos/            ← 自動生成
├── Movies/            ← 自動生成
└── MediaOrganizer/
    ├── run_all.bat
    ├── step1_dedupe.bat
    ├── step2_organize.bat
    ├── step3_cleanup.bat
    ├── step4_lowercase.bat
    ├── README.md
    ├── LICENSE
    ├── bin/               ← exe をここに置く
    │   ├── PUT_EXECUTABLES_HERE.txt
    │   ├── czkawka_cli.exe
    │   └── exiftool.exe
    ├── lib/               ← ルール・設定・ヘルパー
    │   ├── exiftool.config
    │   ├── log_lib.bat
    │   ├── cleanup_folder.ps1
    │   ├── lowercase_folder.ps1
    │   └── rules/
    │       ├── photo/
    │       └── video/
    └── logs/              ← 自動生成
```

## 必要なもの

- Windows 10 以降
- [exiftool.exe](https://exiftool.org/) 12.82 以降 — `MediaOrganizer/bin/` に配置（Geolocation 機能が必要）
- [czkawka_cli.exe](https://github.com/qarmin/czkawka/releases) — `MediaOrganizer/bin/` に配置

## 使い方

1. 未整理のメディアを `Unsorted/` に入れる
2. `run_all.bat` を実行して全工程を一括処理、または各ステップを個別に実行：

| スクリプト | 内容 |
|-----------|------|
| `step1_dedupe.bat` | 重複削除（完全一致は最古を残す。類似画像の確認は `run_all.bat` ではスキップ） |
| `step2_organize.bat` | 写真・動画をメタデータで振り分け |
| `step3_cleanup.bat` | 空フォルダ削除 |
| `step4_lowercase.bat` | ファイル名を小文字化 |

ログは `MediaOrganizer/logs/` に `yyyyMMdd_HHmmss_<スクリプト>.log` として保存されます。`run_all.bat` は一連の実行で1ファイルです。ログはコミットしません。

## 整理後の構造

パスは英語です。Geolocation の地名も標準データベースの英語名です：

```
Photos/
└── 2024-03/
    └── Japan/
        └── Tokyo/
            └── Shibuya/
                └── iPhone 15 Pro/
                    └── 20240315_143022.jpg

Movies/
└── 2024-03/
    └── Japan/
        └── Tokyo/
            └── Shibuya/
                └── Apple/
                    └── 20240315_150000.mp4
```

GPS が無い場合:

```
Photos/2024-03/NoLocation/iPhone 15 Pro/
    └── 20240315_143022.jpg

Photos/NoDate/NoLocation/Unknown/
    └── 00000000_000000_1.jpg
```

撮影地フォルダは GPS 座標から最寄り都市を引いたもので、フォルダ名に位置が残ります。ExifTool はメタデータへ住所を書き込みません。

## ライセンス

[MIT](LICENSE)
