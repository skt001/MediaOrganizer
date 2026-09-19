@echo off
chcp 65001 > nul

REM ==== Paths ====
set SCRIPT_DIR=%~dp0
call "%SCRIPT_DIR%log_lib.bat" init step1_dedupe
cd /d "%SCRIPT_DIR%.."
set WORK_DIR=%CD%
set UNSORTED=%WORK_DIR%\Unsorted
set CZKAWKA=%SCRIPT_DIR%czkawka_cli.exe

REM ==== Checks ====
if not exist "%UNSORTED%" (
    call "%SCRIPT_DIR%log_lib.bat" fail "Error: Unsorted folder not found: %UNSORTED%"
    exit /b 1
)
if not exist "%CZKAWKA%" (
    call "%SCRIPT_DIR%log_lib.bat" fail "Error: czkawka_cli.exe not found: %CZKAWKA%"
    exit /b 1
)

REM ==== Header ====
call "%SCRIPT_DIR%log_lib.bat" put ""
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "   Step 1: Remove duplicates"
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "Work folder: %WORK_DIR%"
call "%SCRIPT_DIR%log_lib.bat" put "Start: %DATE% %TIME%"
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put ""

REM ==== [1/2] Exact-hash duplicates ====
call "%SCRIPT_DIR%log_lib.bat" put "[1/2] Removing exact-hash duplicate files"
set LOG_CMD="%CZKAWKA%" dup --directories "%UNSORTED%" -D AEB -W
call "%SCRIPT_DIR%log_lib.bat" exec
if errorlevel 1 (
    call "%SCRIPT_DIR%log_lib.bat" fail "Error: exact-hash duplicate removal failed."
    exit /b 1
)
call "%SCRIPT_DIR%log_lib.bat" put ""

REM ==== [2/2] Visually similar images (confirm first) ====
call "%SCRIPT_DIR%log_lib.bat" put "[2/2] Remove visually similar images"
call "%SCRIPT_DIR%log_lib.bat" put ""
call "%SCRIPT_DIR%log_lib.bat" put " Warning: This may also match exposure/crop variants."
call "%SCRIPT_DIR%log_lib.bat" put " Review the list before deleting."
call "%SCRIPT_DIR%log_lib.bat" put ""
call "%SCRIPT_DIR%log_lib.bat" put " [D] Dry run (list only, no delete)"
call "%SCRIPT_DIR%log_lib.bat" put " [Y] Delete"
call "%SCRIPT_DIR%log_lib.bat" put " [S] Skip this step"
call "%SCRIPT_DIR%log_lib.bat" put ""
set /p CHOICE="Choose (D/Y/S): "
call "%SCRIPT_DIR%log_lib.bat" put "Choice: %CHOICE%"

if /i "%CHOICE%"=="D" goto :similar_dry
if /i "%CHOICE%"=="Y" goto :similar_delete
if /i "%CHOICE%"=="S" (
    call "%SCRIPT_DIR%log_lib.bat" put "Skipped similar-image deletion."
    goto :similar_done
)
goto :similar_done

:similar_dry
call "%SCRIPT_DIR%log_lib.bat" put "Running dry run (no files deleted)..."
set LOG_CMD="%CZKAWKA%" image --directories "%UNSORTED%" -W
call "%SCRIPT_DIR%log_lib.bat" exec
if errorlevel 1 (
    call "%SCRIPT_DIR%log_lib.bat" fail "Error: similar-image dry run failed."
    exit /b 1
)
call "%SCRIPT_DIR%log_lib.bat" put ""
call "%SCRIPT_DIR%log_lib.bat" put "Dry run done. Review the list, then run again and choose Y."
goto :similar_done

:similar_delete
call "%SCRIPT_DIR%log_lib.bat" put "Deleting similar images..."
set LOG_CMD="%CZKAWKA%" image --directories "%UNSORTED%" -D AEB -W
call "%SCRIPT_DIR%log_lib.bat" exec
if errorlevel 1 (
    call "%SCRIPT_DIR%log_lib.bat" fail "Error: similar-image removal failed."
    exit /b 1
)

:similar_done
call "%SCRIPT_DIR%log_lib.bat" put ""

REM ==== Footer ====
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "   Step 1: Dedupe complete"
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "End: %DATE% %TIME%"
call "%SCRIPT_DIR%log_lib.bat" put "Log: %LOG_FILE%"
call "%SCRIPT_DIR%log_lib.bat" put ""
pause
exit /b 0
