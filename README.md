# MediaOrganizer

A Windows batch tool to automatically organize photos and videos by date, shooting location, and device model using [exiftool](https://exiftool.org/) and [czkawka](https://github.com/qarmin/czkawka).

[Japanese README](README.ja.md)

## Features

- **Duplicate removal** — exact hash matching + optional similar image detection (czkawka)
- **Metadata-based sorting** — organizes files into `Photos/` and `Movies/` by date, location, and device name
- **Priority rules** — falls back gracefully: `DateTimeOriginal` → `CreateDate` → `FileModifyDate` → `NoDate`
- **Location folders** — when GPS is present, ExifTool Geolocation adds `country/region/city` (missing region/city levels are skipped); otherwise a single `NoLocation` folder (nearest city, not a street address). Names come from the standard ExifTool database (English, e.g. `Japan/Tokyo/Shibuya`)
- **Device folders** — photos use `Model`, videos use `Make`; missing values become `Unknown`
- **Safe lowercase rename** — works correctly on NTFS via temporary name (avoids the silent no-op bug)
- **Empty folder cleanup** — removes leftover empty directories after sorting
- **Run all at once** — single `run_all.bat` to execute all steps in order
- **Console logs** — every run writes UTF-8 logs to `MediaOrganizer/logs/`

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
    ├── README.md
    ├── LICENSE
    ├── bin/               ← place executables here
    │   ├── PUT_EXECUTABLES_HERE.txt
    │   ├── czkawka_cli.exe
    │   └── exiftool.exe
    ├── lib/               ← rules, config, helpers
    │   ├── exiftool.config
    │   ├── log_lib.bat
    │   ├── cleanup_folder.ps1
    │   ├── lowercase_folder.ps1
    │   └── rules/
    │       ├── photo/
    │       └── video/
    └── logs/              ← created automatically
```

## Requirements

- Windows 10 or later
- [exiftool.exe](https://exiftool.org/) 12.82 or later — place in `MediaOrganizer/bin/` (Geolocation support required)
- [czkawka_cli.exe](https://github.com/qarmin/czkawka/releases) — place in `MediaOrganizer/bin/`

## Usage

1. Place unsorted media files into `Unsorted/`
2. Run `run_all.bat` to execute all steps, or run each step individually:

| Script | Description |
|--------|-------------|
| `step1_dedupe.bat` | Remove duplicate files (exact hash keeps oldest; similar-image prompt is skipped by `run_all.bat`) |
| `step2_organize.bat` | Sort photos and videos by metadata |
| `step3_cleanup.bat` | Remove empty folders |
| `step4_lowercase.bat` | Lowercase all filenames |

Logs are saved under `MediaOrganizer/logs/` as `yyyyMMdd_HHmmss_<script>.log`. `run_all.bat` writes one file for the whole run. Logs are not committed.

## Output Structure

Path segments are English, including geolocation names from the standard database:

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

Without GPS:

```
Photos/2024-03/NoLocation/iPhone 15 Pro/
    └── 20240315_143022.jpg

Photos/NoDate/NoLocation/Unknown/
    └── 00000000_000000_1.jpg
```

Location folders come from the nearest city in ExifTool's geolocation database, so the approximate place remains in the path. ExifTool does not write the address back into metadata.

## License

[MIT](LICENSE)
