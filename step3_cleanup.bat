@echo off
chcp 65001 > nul

REM ==== Paths ====
set ROOT=%~dp0
set LIB=%ROOT%lib\
set BIN=%ROOT%bin\
call "%LIB%log_lib.bat" init step3_cleanup
cd /d "%ROOT%.."
set WORK_DIR=%CD%
set PHOTOS=%WORK_DIR%\Photos
set MOVIES=%WORK_DIR%\Movies
set UNSORTED=%WORK_DIR%\Unsorted

REM ==== Checks ====
if not exist "%PHOTOS%" call "%LIB%log_lib.bat" put "Warning: Photos folder not found"
if not exist "%MOVIES%" call "%LIB%log_lib.bat" put "Warning: Movies folder not found"
if not exist "%UNSORTED%" call "%LIB%log_lib.bat" put "Warning: Unsorted folder not found"

if not exist "%PHOTOS%" if not exist "%MOVIES%" if not exist "%UNSORTED%" (
    call "%LIB%log_lib.bat" fail "Error: none of the target folders exist"
    exit /b 1
)

REM ==== Header ====
call "%LIB%log_lib.bat" put ""
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "   Step 3: Remove empty folders"
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "Work folder: %WORK_DIR%"
call "%LIB%log_lib.bat" put "Start: %DATE% %TIME%"
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put ""

if exist "%PHOTOS%"   call :cleanup_folder "%PHOTOS%"   "Photos"
if exist "%MOVIES%"   call :cleanup_folder "%MOVIES%"   "Movies"
if exist "%UNSORTED%" call :cleanup_folder "%UNSORTED%" "Unsorted"

REM ==== Footer ====
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "   Step 3: Cleanup complete"
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "End: %DATE% %TIME%"
call "%LIB%log_lib.bat" put "Log: %LOG_FILE%"
call "%LIB%log_lib.bat" put ""
if not defined CHAINED pause
exit /b 0


REM ============================================================
REM Subroutine: :cleanup_folder <folder path> <label>
REM ============================================================
:cleanup_folder
set "_TARGET=%~1"
set "_LABEL=%~2"

call "%LIB%log_lib.bat" put "[%_LABEL%] Removing empty folders"
set LOG_CMD=powershell -NoProfile -ExecutionPolicy Bypass -File "%LIB%cleanup_folder.ps1" -Target "%_TARGET%"
call "%LIB%log_lib.bat" exec
call "%LIB%log_lib.bat" put "[%_LABEL%] Done"
call "%LIB%log_lib.bat" put ""
exit /b 0
