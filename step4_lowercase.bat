@echo off
chcp 65001 > nul

REM ==== Paths ====
set SCRIPT_DIR=%~dp0
call "%SCRIPT_DIR%log_lib.bat" init step4_lowercase
cd /d "%SCRIPT_DIR%.."
set WORK_DIR=%CD%
set PHOTOS=%WORK_DIR%\Photos
set MOVIES=%WORK_DIR%\Movies
set UNSORTED=%WORK_DIR%\Unsorted

REM ==== Checks ====
if not exist "%PHOTOS%"   call "%SCRIPT_DIR%log_lib.bat" put "Warning: Photos folder not found"
if not exist "%MOVIES%"   call "%SCRIPT_DIR%log_lib.bat" put "Warning: Movies folder not found"
if not exist "%UNSORTED%" call "%SCRIPT_DIR%log_lib.bat" put "Warning: Unsorted folder not found"

if not exist "%PHOTOS%" if not exist "%MOVIES%" if not exist "%UNSORTED%" (
    call "%SCRIPT_DIR%log_lib.bat" fail "Error: none of the target folders exist"
    exit /b 1
)

REM ==== Header ====
call "%SCRIPT_DIR%log_lib.bat" put ""
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "   Step 4: Lowercase filenames"
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "Work folder: %WORK_DIR%"
call "%SCRIPT_DIR%log_lib.bat" put "Start: %DATE% %TIME%"
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put ""

REM NTFS is case-insensitive, so a direct rename is a no-op.
REM Rename via a temp name so the case actually changes.
REM  ABC.jpg -> ABC.jpg.__tmp__ -> abc.jpg

if exist "%PHOTOS%" (
    call "%SCRIPT_DIR%log_lib.bat" put "[1/3] Photos"
    call :lowercase_folder "%PHOTOS%" "Photos"
    if errorlevel 1 exit /b 1
    call "%SCRIPT_DIR%log_lib.bat" put ""
)

if exist "%MOVIES%" (
    call "%SCRIPT_DIR%log_lib.bat" put "[2/3] Movies"
    call :lowercase_folder "%MOVIES%" "Movies"
    if errorlevel 1 exit /b 1
    call "%SCRIPT_DIR%log_lib.bat" put ""
)

if exist "%UNSORTED%" (
    call "%SCRIPT_DIR%log_lib.bat" put "[3/3] Unsorted"
    call :lowercase_folder "%UNSORTED%" "Unsorted"
    if errorlevel 1 exit /b 1
    call "%SCRIPT_DIR%log_lib.bat" put ""
)

REM ==== Footer ====
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "   Step 4: Lowercase complete"
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "End: %DATE% %TIME%"
call "%SCRIPT_DIR%log_lib.bat" put "Log: %LOG_FILE%"
call "%SCRIPT_DIR%log_lib.bat" put ""
pause
exit /b 0


REM ============================================================
REM Subroutine: :lowercase_folder <folder path> <label>
REM ============================================================
:lowercase_folder
set "_TARGET=%~1"
set "_LABEL=%~2"

call "%SCRIPT_DIR%log_lib.bat" run powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%SCRIPT_DIR%lowercase_folder.ps1' -Target '%_TARGET%'"
if errorlevel 1 (
    call "%SCRIPT_DIR%log_lib.bat" fail "Error: Failed to lowercase filenames in %_LABEL%."
    exit /b 1
)
exit /b 0
