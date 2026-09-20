@echo off
chcp 65001 > nul

set SCRIPT_DIR=%~dp0
call "%SCRIPT_DIR%log_lib.bat" init run_all

call "%SCRIPT_DIR%log_lib.bat" put ""
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "   MediaOrganizer - Run all steps"
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "Start: %DATE% %TIME%"
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put ""
call "%SCRIPT_DIR%log_lib.bat" put "Order:"
call "%SCRIPT_DIR%log_lib.bat" put "  Step 1: Remove duplicates     (step1_dedupe.bat)"
call "%SCRIPT_DIR%log_lib.bat" put "  Step 2: Organize media        (step2_organize.bat)"
call "%SCRIPT_DIR%log_lib.bat" put "  Step 3: Remove empty folders  (step3_cleanup.bat)"
call "%SCRIPT_DIR%log_lib.bat" put "  Step 4: Lowercase filenames   (step4_lowercase.bat)"
call "%SCRIPT_DIR%log_lib.bat" put ""
call "%SCRIPT_DIR%log_lib.bat" put "Continue? (Y/N)"
set /p CONFIRM=": "
call "%SCRIPT_DIR%log_lib.bat" put "Continue: %CONFIRM%"
if /i not "%CONFIRM%"=="Y" (
    call "%SCRIPT_DIR%log_lib.bat" put "Cancelled."
    pause & exit /b 0
)

call "%SCRIPT_DIR%log_lib.bat" put ""
call "%SCRIPT_DIR%log_lib.bat" put "---- Step 1 start ----"
call "%SCRIPT_DIR%step1_dedupe.bat"
if errorlevel 1 (
    call "%SCRIPT_DIR%log_lib.bat" fail "Step 1 failed. Aborting."
    exit /b 1
)

call "%SCRIPT_DIR%log_lib.bat" put ""
call "%SCRIPT_DIR%log_lib.bat" put "---- Step 2 start ----"
call "%SCRIPT_DIR%step2_organize.bat"
if errorlevel 1 (
    call "%SCRIPT_DIR%log_lib.bat" fail "Step 2 failed. Aborting."
    exit /b 1
)

call "%SCRIPT_DIR%log_lib.bat" put ""
call "%SCRIPT_DIR%log_lib.bat" put "---- Step 3 start ----"
call "%SCRIPT_DIR%step3_cleanup.bat"
if errorlevel 1 (
    call "%SCRIPT_DIR%log_lib.bat" fail "Step 3 failed. Aborting."
    exit /b 1
)

call "%SCRIPT_DIR%log_lib.bat" put ""
call "%SCRIPT_DIR%log_lib.bat" put "---- Step 4 start ----"
call "%SCRIPT_DIR%step4_lowercase.bat"
if errorlevel 1 (
    call "%SCRIPT_DIR%log_lib.bat" fail "Step 4 failed. Aborting."
    exit /b 1
)

call "%SCRIPT_DIR%log_lib.bat" put ""
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "   All steps complete"
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "End: %DATE% %TIME%"
call "%SCRIPT_DIR%log_lib.bat" put "Log: %LOG_FILE%"
call "%SCRIPT_DIR%log_lib.bat" put ""
pause
exit /b 0
