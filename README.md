# MediaOrganizer

A Windows batch tool to automatically organize photos and videos by date and device model using [exiftool](https://exiftool.org/) and [czkawka](https://github.com/qarmin/czkawka).

[日本語版 README はこちら](README.ja.md)

## Features

- **Duplicate removal** — exact hash matching + optional similar image detection (czkawka)
- **Metadata-based sorting** — organizes files into `Photos/` and `Movies/` by date and device name
- **Priority rules** — falls back gracefully: `DateTimeOriginal` → `CreateDate` → `FileModifyDate` → `NoDate`
- **Safe lowercase rename** — works correctly on NTFS via temporary name (avoids the silent no-op bug)
- **Empty folder cleanup** — removes leftover empty directories after sorting
- **Run all at once** — single `run_all.bat` to execute all steps in order

## Directory Layout

Place the `MediaOrganizer/` folder next to your data folders:

```
(work folder)/
├── Unsorted/          ← put your unsorted media here
├── Photos/            ← created automatically
├── Movies/            ← created automatically
└── MediaOrganizer/
    ├── run_all.bat
    ├── step1_dedupe.bat
    ├── step2_organize.bat
    ├── step3_cleanup.bat
    ├── step4_lowercase.bat
    ├── czkawka_cli.exe    ← place here
    ├── exiftool.exe       ← place here
    └── rules/
        ├── photo/
        └── video/
```

## Requirements

- Windows 10 or later
- [exiftool.exe](https://exiftool.org/) — place in `MediaOrganizer/`
- [czkawka_cli.exe](https://github.com/qarmin/czkawka/releases) — place in `MediaOrganizer/`

## Usage

1. Place unsorted media files into `Unsorted/`
2. Run `run_all.bat` to execute all steps, or run each step individually:

| Script | Description |
|--------|-------------|
| `step1_dedupe.bat` | Remove duplicate files |
| `step2_organize.bat` | Sort photos and videos by metadata |
| `step3_cleanup.bat` | Remove empty folders |
| `step4_lowercase.bat` | Lowercase all filenames |

## Output Structure

```
Photos/
└── 2024-03/
    └── iPhone 15 Pro/
        └── 20240315_143022.jpg

Movies/
└── 2024-03/
    └── Apple/
        └── 20240315_150000.mp4

Photos/NoDate/Unknown/
    └── 00000000_000000_1.jpg
```

## License

[MIT](LICENSE)
