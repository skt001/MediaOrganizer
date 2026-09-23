@echo off
chcp 65001 > nul

REM ==== Paths ====
set ROOT=%~dp0
set LIB=%ROOT%lib\
set BIN=%ROOT%bin\
call "%LIB%log_lib.bat" init step4_lowercase
cd /d "%ROOT%.."
set WORK_DIR=%CD%
set PHOTOS=%WORK_DIR%\Photos
set MOVIES=%WORK_DIR%\Movies
set UNSORTED=%WORK_DIR%\Unsorted

REM ==== Checks ====
if not exist "%PHOTOS%"   call "%LIB%log_lib.bat" put "Warning: Photos folder not found"
if not exist "%MOVIES%"   call "%LIB%log_lib.bat" put "Warning: Movies folder not found"
if not exist "%UNSORTED%" call "%LIB%log_lib.bat" put "Warning: Unsorted folder not found"

if not exist "%PHOTOS%" if not exist "%MOVIES%" if not exist "%UNSORTED%" (
    call "%LIB%log_lib.bat" fail "Error: none of the target folders exist"
    exit /b 1
)

REM ==== Header ====
call "%LIB%log_lib.bat" put ""
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "   Step 4: Lowercase filenames"
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "Work folder: %WORK_DIR%"
call "%LIB%log_lib.bat" put "Start: %DATE% %TIME%"
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put ""

REM NTFS is case-insensitive, so a direct rename is a no-op.
REM Rename via a temp name so the case actually changes.
REM  ABC.jpg -> ABC.jpg.__tmp__ -> abc.jpg

if exist "%PHOTOS%" (
    call "%LIB%log_lib.bat" put "[1/3] Photos"
    call :lowercase_folder "%PHOTOS%" "Photos"
    if errorlevel 1 exit /b 1
    call "%LIB%log_lib.bat" put ""
)

if exist "%MOVIES%" (
    call "%LIB%log_lib.bat" put "[2/3] Movies"
    call :lowercase_folder "%MOVIES%" "Movies"
    if errorlevel 1 exit /b 1
    call "%LIB%log_lib.bat" put ""
)

if exist "%UNSORTED%" (
    call "%LIB%log_lib.bat" put "[3/3] Unsorted"
    call :lowercase_folder "%UNSORTED%" "Unsorted"
    if errorlevel 1 exit /b 1
    call "%LIB%log_lib.bat" put ""
)

REM ==== Footer ====
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "   Step 4: Lowercase complete"
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "End: %DATE% %TIME%"
call "%LIB%log_lib.bat" put "Log: %LOG_FILE%"
call "%LIB%log_lib.bat" put ""
if not defined CHAINED pause
exit /b 0


REM ============================================================
REM Subroutine: :lowercase_folder <folder path> <label>
REM ============================================================
:lowercase_folder
set "_TARGET=%~1"
set "_LABEL=%~2"

set LOG_CMD=powershell -NoProfile -ExecutionPolicy Bypass -File "%LIB%lowercase_folder.ps1" -Target "%_TARGET%"
call "%LIB%log_lib.bat" exec
if errorlevel 1 (
    call "%LIB%log_lib.bat" fail "Error: Failed to lowercase filenames in %_LABEL%."
    exit /b 1
)
exit /b 0
