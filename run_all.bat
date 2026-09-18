@echo off
chcp 65001 > nul

set SCRIPT_DIR=%~dp0

echo.
echo ====================================
echo    MediaOrganizer - Run all steps
echo ====================================
echo Start: %DATE% %TIME%
echo ====================================
echo.
echo Order:
echo   Step 1: Remove duplicates     (step1_dedupe.bat)
echo   Step 2: Organize media        (step2_organize.bat)
echo   Step 3: Remove empty folders  (step3_cleanup.bat)
echo   Step 4: Lowercase filenames   (step4_lowercase.bat)
echo.
echo Continue? (Y/N)
set /p CONFIRM=": "
if /i not "%CONFIRM%"=="Y" (
    echo Cancelled.
    pause & exit /b 0
)

echo.
echo ---- Step 1 start ----
call "%SCRIPT_DIR%step1_dedupe.bat"
if errorlevel 1 (
    echo Step 1 failed. Aborting.
    pause & exit /b 1
)

echo.
echo ---- Step 2 start ----
call "%SCRIPT_DIR%step2_organize.bat"
if errorlevel 1 (
    echo Step 2 failed. Aborting.
    pause & exit /b 1
)

echo.
echo ---- Step 3 start ----
call "%SCRIPT_DIR%step3_cleanup.bat"
if errorlevel 1 (
    echo Step 3 failed. Aborting.
    pause & exit /b 1
)

echo.
echo ---- Step 4 start ----
call "%SCRIPT_DIR%step4_lowercase.bat"
if errorlevel 1 (
    echo Step 4 failed. Aborting.
    pause & exit /b 1
)

echo.
echo ====================================
echo    All steps complete
echo ====================================
echo End: %DATE% %TIME%
echo.
pause
exit /b 0
