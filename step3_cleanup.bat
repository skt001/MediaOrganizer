@echo off
chcp 65001 > nul

REM ==== Paths ====
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%.."
set WORK_DIR=%CD%
set PHOTOS=%WORK_DIR%\Photos
set MOVIES=%WORK_DIR%\Movies
set UNSORTED=%WORK_DIR%\Unsorted

REM ==== Checks ====
if not exist "%PHOTOS%" echo Warning: Photos folder not found
if not exist "%MOVIES%" echo Warning: Movies folder not found
if not exist "%UNSORTED%" echo Warning: Unsorted folder not found

if not exist "%PHOTOS%" if not exist "%MOVIES%" if not exist "%UNSORTED%" (
    echo Error: none of the target folders exist
    pause & exit /b 1
)

REM ==== Header ====
echo.
echo ====================================
echo    Step 3: Remove empty folders
echo ====================================
echo Work folder: %WORK_DIR%
echo Start: %DATE% %TIME%
echo ====================================
echo.

if exist "%PHOTOS%"   call :cleanup_folder "%PHOTOS%"   "Photos"
if exist "%MOVIES%"   call :cleanup_folder "%MOVIES%"   "Movies"
if exist "%UNSORTED%" call :cleanup_folder "%UNSORTED%" "Unsorted"

REM ==== Footer ====
echo ====================================
echo    Step 3: Cleanup complete
echo ====================================
echo End: %DATE% %TIME%
echo.
pause
exit /b 0


REM ============================================================
REM Subroutine: :cleanup_folder <folder path> <label>
REM ============================================================
:cleanup_folder
set "_TARGET=%~1"
set "_LABEL=%~2"
set "_LIST=%SCRIPT_DIR%_folder_list.tmp"

echo [%_LABEL%] Removing empty folders

dir "%_TARGET%" /ad /b /s > "%_LIST%" 2>nul

REM Skip if the list is empty
for %%A in ("%_LIST%") do set _SIZE=%%~zA
if "%_SIZE%"=="0" (
    echo [%_LABEL%] No empty folders
    if exist "%_LIST%" del "%_LIST%"
    echo.
    exit /b 0
)

REM Reverse-sort so deeper folders are removed first
powershell -NoProfile -Command "$c = Get-Content '%_LIST%' -Encoding UTF8 | Sort-Object -Descending; [System.IO.File]::WriteAllLines('%_LIST%', $c, (New-Object System.Text.UTF8Encoding $false))"

for /f "usebackq delims=" %%d in ("%_LIST%") do (
    rd "%%d" 2>nul && echo Removed: %%d
)

if exist "%_LIST%" del "%_LIST%"
echo [%_LABEL%] Done
echo.
exit /b 0
