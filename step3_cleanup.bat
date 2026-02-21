@echo off
chcp 65001 > nul

REM ==== パス設定 ====
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%.."
set WORK_DIR=%CD%
set PHOTOS=%WORK_DIR%\Photos
set MOVIES=%WORK_DIR%\Movies
set UNSORTED=%WORK_DIR%\Unsorted

REM ==== 環境チェック ====
if not exist "%PHOTOS%" echo 警告: Photosフォルダが見つかりません
if not exist "%MOVIES%" echo 警告: Moviesフォルダが見つかりません
if not exist "%UNSORTED%" echo 警告: Unsortedフォルダが見つかりません

if not exist "%PHOTOS%" if not exist "%MOVIES%" if not exist "%UNSORTED%" (
    echo エラー: 処理対象フォルダがすべて存在しません
    pause & exit /b 1
)

REM ==== ヘッダー表示 ====
echo.
echo ====================================
echo    Step 3: 空フォルダ削除
echo ====================================
echo 作業フォルダ: %WORK_DIR%
echo 開始時刻: %DATE% %TIME%
echo ====================================
echo.

if exist "%PHOTOS%"   call :cleanup_folder "%PHOTOS%"   "Photos"
if exist "%MOVIES%"   call :cleanup_folder "%MOVIES%"   "Movies"
if exist "%UNSORTED%" call :cleanup_folder "%UNSORTED%" "Unsorted"

REM ==== フッター表示 ====
echo ====================================
echo    Step 3: 空フォルダ削除 完了
echo ====================================
echo 終了時刻: %DATE% %TIME%
echo.
pause
exit /b 0


REM ============================================================
REM サブルーチン: :cleanup_folder <フォルダパス> <表示名>
REM ============================================================
:cleanup_folder
set "_TARGET=%~1"
set "_LABEL=%~2"
set "_LIST=%SCRIPT_DIR%_folder_list.tmp"

echo [%_LABEL%] 空フォルダ削除を開始します

dir "%_TARGET%" /ad /b /s > "%_LIST%" 2>nul

REM リストが空かチェック
for %%A in ("%_LIST%") do set _SIZE=%%~zA
if "%_SIZE%"=="0" (
    echo [%_LABEL%] 削除対象の空フォルダはありません
    if exist "%_LIST%" del "%_LIST%"
    echo.
    exit /b 0
)

REM 深い階層から削除するためにリストを逆順ソート
powershell -NoProfile -Command "$c = Get-Content '%_LIST%' -Encoding UTF8 | Sort-Object -Descending; [System.IO.File]::WriteAllLines('%_LIST%', $c, (New-Object System.Text.UTF8Encoding $false))"

for /f "usebackq delims=" %%d in ("%_LIST%") do (
    rd "%%d" 2>nul && echo 削除: %%d
)

if exist "%_LIST%" del "%_LIST%"
echo [%_LABEL%] 完了
echo.
exit /b 0
