@echo off
chcp 65001 > nul

REM ==== Paths ====
set SCRIPT_DIR=%~dp0
call "%SCRIPT_DIR%log_lib.bat" init step3_cleanup
cd /d "%SCRIPT_DIR%.."
set WORK_DIR=%CD%
set PHOTOS=%WORK_DIR%\Photos
set MOVIES=%WORK_DIR%\Movies
set UNSORTED=%WORK_DIR%\Unsorted

REM ==== Checks ====
if not exist "%PHOTOS%" call "%SCRIPT_DIR%log_lib.bat" put "Warning: Photos folder not found"
if not exist "%MOVIES%" call "%SCRIPT_DIR%log_lib.bat" put "Warning: Movies folder not found"
if not exist "%UNSORTED%" call "%SCRIPT_DIR%log_lib.bat" put "Warning: Unsorted folder not found"

if not exist "%PHOTOS%" if not exist "%MOVIES%" if not exist "%UNSORTED%" (
    call "%SCRIPT_DIR%log_lib.bat" fail "Error: none of the target folders exist"
    exit /b 1
)

REM ==== Header ====
call "%SCRIPT_DIR%log_lib.bat" put ""
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "   Step 3: Remove empty folders"
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "Work folder: %WORK_DIR%"
call "%SCRIPT_DIR%log_lib.bat" put "Start: %DATE% %TIME%"
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put ""

if exist "%PHOTOS%"   call :cleanup_folder "%PHOTOS%"   "Photos"
if exist "%MOVIES%"   call :cleanup_folder "%MOVIES%"   "Movies"
if exist "%UNSORTED%" call :cleanup_folder "%UNSORTED%" "Unsorted"

REM ==== Footer ====
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "   Step 3: Cleanup complete"
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "End: %DATE% %TIME%"
call "%SCRIPT_DIR%log_lib.bat" put "Log: %LOG_FILE%"
call "%SCRIPT_DIR%log_lib.bat" put ""
pause
exit /b 0


REM ============================================================
REM Subroutine: :cleanup_folder <folder path> <label>
REM ============================================================
:cleanup_folder
set "_TARGET=%~1"
set "_LABEL=%~2"
set "_LIST=%SCRIPT_DIR%_folder_list.tmp"

call "%SCRIPT_DIR%log_lib.bat" put "[%_LABEL%] Removing empty folders"

dir "%_TARGET%" /ad /b /s > "%_LIST%" 2>nul

REM Skip if the list is empty
for %%A in ("%_LIST%") do set _SIZE=%%~zA
if "%_SIZE%"=="0" (
    call "%SCRIPT_DIR%log_lib.bat" put "[%_LABEL%] No empty folders"
    if exist "%_LIST%" del "%_LIST%"
    call "%SCRIPT_DIR%log_lib.bat" put ""
    exit /b 0
)

REM Reverse-sort so deeper folders are removed first
call "%SCRIPT_DIR%log_lib.bat" run powershell -NoProfile -Command "$c = Get-Content '%_LIST%' -Encoding UTF8 | Sort-Object -Descending; [System.IO.File]::WriteAllLines('%_LIST%', $c, (New-Object System.Text.UTF8Encoding $false))"

for /f "usebackq delims=" %%d in ("%_LIST%") do (
    rd "%%d" 2>nul && call "%SCRIPT_DIR%log_lib.bat" put "Removed: %%d"
)

if exist "%_LIST%" del "%_LIST%"
call "%SCRIPT_DIR%log_lib.bat" put "[%_LABEL%] Done"
call "%SCRIPT_DIR%log_lib.bat" put ""
exit /b 0
