@echo off
chcp 65001 > nul

REM ==== Paths ====
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%.."
set WORK_DIR=%CD%
set UNSORTED=%WORK_DIR%\Unsorted
set CZKAWKA=%SCRIPT_DIR%czkawka_cli.exe

REM ==== Checks ====
if not exist "%UNSORTED%" (
    echo Error: Unsorted folder not found: %UNSORTED%
    pause & exit /b 1
)
if not exist "%CZKAWKA%" (
    echo Error: czkawka_cli.exe not found: %CZKAWKA%
    pause & exit /b 1
)

REM ==== Header ====
echo.
echo ====================================
echo    Step 1: Remove duplicates
echo ====================================
echo Work folder: %WORK_DIR%
echo Start: %DATE% %TIME%
echo ====================================
echo.

REM ==== [1/2] Exact-hash duplicates ====
echo [1/2] Removing exact-hash duplicate files
"%CZKAWKA%" dup --directories "%UNSORTED%" -D AEB
echo.

REM ==== [2/2] Visually similar images (confirm first) ====
echo [2/2] Remove visually similar images
echo.
echo  Warning: This may also match exposure/crop variants.
echo  Review the list before deleting.
echo.
echo  [D] Dry run (list only, no delete)
echo  [Y] Delete
echo  [S] Skip this step
echo.
set /p CHOICE="Choose (D/Y/S): "

if /i "%CHOICE%"=="D" (
    echo Running dry run (no files deleted)...
    "%CZKAWKA%" image --directories "%UNSORTED%"
    echo.
    echo Dry run done. Review the list, then run again and choose Y.
)
if /i "%CHOICE%"=="Y" (
    echo Deleting similar images...
    "%CZKAWKA%" image --directories "%UNSORTED%" -D AEB
)
if /i "%CHOICE%"=="S" (
    echo Skipped similar-image deletion.
)

echo.

REM ==== Footer ====
echo ====================================
echo    Step 1: Dedupe complete
echo ====================================
echo End: %DATE% %TIME%
echo.
pause
