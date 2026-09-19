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

call "%SCRIPT_DIR%log_lib.bat" put "[%_LABEL%] Removing empty folders"
call "%SCRIPT_DIR%log_lib.bat" run powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%SCRIPT_DIR%cleanup_folder.ps1' -Target '%_TARGET%'"
call "%SCRIPT_DIR%log_lib.bat" put "[%_LABEL%] Done"
call "%SCRIPT_DIR%log_lib.bat" put ""
exit /b 0
