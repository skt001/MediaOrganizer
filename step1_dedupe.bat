@echo off
chcp 65001 > nul

REM ==== Paths ====
set ROOT=%~dp0
set LIB=%ROOT%lib\
set BIN=%ROOT%bin\
call "%LIB%log_lib.bat" init step1_dedupe
cd /d "%ROOT%.."
set WORK_DIR=%CD%
set UNSORTED=%WORK_DIR%\Unsorted
set CZKAWKA=%BIN%czkawka_cli.exe

REM ==== Checks ====
if not exist "%UNSORTED%" (
    call "%LIB%log_lib.bat" fail "Error: Unsorted folder not found: %UNSORTED%"
    exit /b 1
)
if not exist "%CZKAWKA%" (
    call "%LIB%log_lib.bat" fail "Error: czkawka_cli.exe not found: %CZKAWKA%"
    exit /b 1
)

REM ==== Header ====
call "%LIB%log_lib.bat" put ""
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "   Step 1: Remove duplicates"
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "Work folder: %WORK_DIR%"
call "%LIB%log_lib.bat" put "Start: %DATE% %TIME%"
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put ""

REM ==== [1/2] Exact-hash duplicates ====
call "%LIB%log_lib.bat" put "[1/2] Removing exact-hash duplicate files"
set LOG_CMD="%CZKAWKA%" dup --directories "%UNSORTED%" -D AEB -W
call "%LIB%log_lib.bat" exec
if errorlevel 1 (
    call "%LIB%log_lib.bat" fail "Error: exact-hash duplicate removal failed."
    exit /b 1
)
call "%LIB%log_lib.bat" put ""

REM ==== [2/2] Visually similar images (confirm first) ====
call "%LIB%log_lib.bat" put "[2/2] Remove visually similar images"
call "%LIB%log_lib.bat" put ""
call "%LIB%log_lib.bat" put " Warning: This may also match exposure/crop variants."
call "%LIB%log_lib.bat" put " Review the list before deleting."
call "%LIB%log_lib.bat" put ""
call "%LIB%log_lib.bat" put " [D] Dry run (list only, no delete)"
call "%LIB%log_lib.bat" put " [Y] Delete"
call "%LIB%log_lib.bat" put " [S] Skip this step"
call "%LIB%log_lib.bat" put ""
set /p CHOICE="Choose (D/Y/S): "
call "%LIB%log_lib.bat" put "Choice: %CHOICE%"

if /i "%CHOICE%"=="D" goto :similar_dry
if /i "%CHOICE%"=="Y" goto :similar_delete
if /i "%CHOICE%"=="S" (
    call "%LIB%log_lib.bat" put "Skipped similar-image deletion."
    goto :similar_done
)
goto :similar_done

:similar_dry
call "%LIB%log_lib.bat" put "Running dry run (no files deleted)..."
set LOG_CMD="%CZKAWKA%" image --directories "%UNSORTED%" -W
call "%LIB%log_lib.bat" exec
if errorlevel 1 (
    call "%LIB%log_lib.bat" fail "Error: similar-image dry run failed."
    exit /b 1
)
call "%LIB%log_lib.bat" put ""
call "%LIB%log_lib.bat" put "Dry run done. Review the list, then run again and choose Y."
goto :similar_done

:similar_delete
call "%LIB%log_lib.bat" put "Deleting similar images..."
set LOG_CMD="%CZKAWKA%" image --directories "%UNSORTED%" -D AEB -W
call "%LIB%log_lib.bat" exec
if errorlevel 1 (
    call "%LIB%log_lib.bat" fail "Error: similar-image removal failed."
    exit /b 1
)

:similar_done
call "%LIB%log_lib.bat" put ""

REM ==== Footer ====
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "   Step 1: Dedupe complete"
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "End: %DATE% %TIME%"
call "%LIB%log_lib.bat" put "Log: %LOG_FILE%"
call "%LIB%log_lib.bat" put ""
pause
exit /b 0
