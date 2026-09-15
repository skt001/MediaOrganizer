@echo off
chcp 65001 > nul

REM ==== パス設定 ====
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%.."
set WORK_DIR=%CD%
set UNSORTED=%WORK_DIR%\Unsorted
set EXIFTOOL=%SCRIPT_DIR%exiftool.exe
set RULES_PHOTO=%SCRIPT_DIR%rules\photo
set RULES_VIDEO=%SCRIPT_DIR%rules\video

REM ==== 環境チェック ====
if not exist "%UNSORTED%" (
    echo エラー: Unsortedフォルダが見つかりません: %UNSORTED%
    pause & exit /b 1
)
if not exist "%EXIFTOOL%" (
    echo エラー: exiftool.exe が見つかりません: %EXIFTOOL%
    pause & exit /b 1
)
if not exist "%RULES_PHOTO%" (
    echo エラー: rules\photo フォルダが見つかりません
    pause & exit /b 1
)
if not exist "%RULES_VIDEO%" (
    echo エラー: rules\video フォルダが見つかりません
    pause & exit /b 1
)

REM ==== ヘッダー表示 ====
echo.
echo ====================================
echo    Step 2: メディア整理
echo ====================================
echo 作業フォルダ: %WORK_DIR%
echo 開始時刻: %DATE% %TIME%
echo ====================================
echo.

REM ==== 画像整理 (優先度順: DateTimeOriginal > CreateDate > FileModifyDate > NoDate) ====
REM GPS がある場合は Geolocation で 国/地域/市区 フォルダを追加（無ければ NoLocation）
echo --- 画像ファイル整理 ---
echo.

echo [1/8] DateTimeOriginal + Model
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=ja -@ "%RULES_PHOTO%\p1_datetime_model.args" -r "%UNSORTED%"
echo.

echo [2/8] DateTimeOriginal + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=ja -@ "%RULES_PHOTO%\p2_datetime_unknown.args" -r "%UNSORTED%"
echo.

echo [3/8] CreateDate + Model
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=ja -@ "%RULES_PHOTO%\p3_createdate_model.args" -r "%UNSORTED%"
echo.

echo [4/8] CreateDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=ja -@ "%RULES_PHOTO%\p4_createdate_unknown.args" -r "%UNSORTED%"
echo.

echo [5/8] FileModifyDate + Model
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=ja -@ "%RULES_PHOTO%\p5_filemod_model.args" -r "%UNSORTED%"
echo.

echo [6/8] FileModifyDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=ja -@ "%RULES_PHOTO%\p6_filemod_unknown.args" -r "%UNSORTED%"
echo.

echo [7/8] NoDate + Model
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=ja -@ "%RULES_PHOTO%\p7_nodate_model.args" -r "%UNSORTED%"
echo.

echo [8/8] NoDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=ja -@ "%RULES_PHOTO%\p8_nodate_unknown.args" -r "%UNSORTED%"
echo.

REM ==== 動画整理 (優先度順: CreateDate > FileModifyDate > NoDate) ====
echo --- 動画ファイル整理 ---
echo.

echo [1/6] CreateDate + Make
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=ja -@ "%RULES_VIDEO%\v1_createdate_make.args" -r "%UNSORTED%"
echo.

echo [2/6] CreateDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=ja -@ "%RULES_VIDEO%\v2_createdate_unknown.args" -r "%UNSORTED%"
echo.

echo [3/6] FileModifyDate + Make
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=ja -@ "%RULES_VIDEO%\v3_filemod_make.args" -r "%UNSORTED%"
echo.

echo [4/6] FileModifyDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=ja -@ "%RULES_VIDEO%\v4_filemod_unknown.args" -r "%UNSORTED%"
echo.

echo [5/6] NoDate + Make
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=ja -@ "%RULES_VIDEO%\v5_nodate_make.args" -r "%UNSORTED%"
echo.

echo [6/6] NoDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=ja -@ "%RULES_VIDEO%\v6_nodate_unknown.args" -r "%UNSORTED%"
echo.

REM ==== フッター表示 ====
echo ====================================
echo    Step 2: メディア整理 完了
echo ====================================
echo 終了時刻: %DATE% %TIME%
echo.
pause
