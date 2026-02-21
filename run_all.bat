@echo off
chcp 65001 > nul

set SCRIPT_DIR=%~dp0

echo.
echo ====================================
echo    MediaOrganizer - 全工程実行
echo ====================================
echo 開始時刻: %DATE% %TIME%
echo ====================================
echo.
echo 実行順序:
echo   Step 1: 重複ファイル削除  (step1_dedupe.bat)
echo   Step 2: メディア整理      (step2_organize.bat)
echo   Step 3: 空フォルダ削除    (step3_cleanup.bat)
echo   Step 4: ファイル名小文字化 (step4_lowercase.bat)
echo.
echo 続行しますか？ (Y/N)
set /p CONFIRM=": "
if /i not "%CONFIRM%"=="Y" (
    echo キャンセルしました。
    pause & exit /b 0
)

echo.
echo ---- Step 1 開始 ----
call "%SCRIPT_DIR%step1_dedupe.bat"
if errorlevel 1 (
    echo Step 1 でエラーが発生しました。中断します。
    pause & exit /b 1
)

echo.
echo ---- Step 2 開始 ----
call "%SCRIPT_DIR%step2_organize.bat"
if errorlevel 1 (
    echo Step 2 でエラーが発生しました。中断します。
    pause & exit /b 1
)

echo.
echo ---- Step 3 開始 ----
call "%SCRIPT_DIR%step3_cleanup.bat"
if errorlevel 1 (
    echo Step 3 でエラーが発生しました。中断します。
    pause & exit /b 1
)

echo.
echo ---- Step 4 開始 ----
call "%SCRIPT_DIR%step4_lowercase.bat"
if errorlevel 1 (
    echo Step 4 でエラーが発生しました。中断します。
    pause & exit /b 1
)

echo.
echo ====================================
echo    全工程 完了
echo ====================================
echo 終了時刻: %DATE% %TIME%
echo.
pause
