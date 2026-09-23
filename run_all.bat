@echo off
chcp 65001 > nul

set ROOT=%~dp0
set LIB=%ROOT%lib\
set BIN=%ROOT%bin\
call "%LIB%log_lib.bat" init run_all

call "%LIB%log_lib.bat" put ""
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "   MediaOrganizer - Run all steps"
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "Start: %DATE% %TIME%"
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put ""
call "%LIB%log_lib.bat" put "Order:"
call "%LIB%log_lib.bat" put "  Step 1: Remove duplicates     (step1_dedupe.bat)"
call "%LIB%log_lib.bat" put "  Step 2: Organize media        (step2_organize.bat)"
call "%LIB%log_lib.bat" put "  Step 3: Remove empty folders  (step3_cleanup.bat)"
call "%LIB%log_lib.bat" put "  Step 4: Lowercase filenames   (step4_lowercase.bat)"
call "%LIB%log_lib.bat" put ""
call "%LIB%log_lib.bat" put "Continue? (Y/N)"
set /p CONFIRM=": "
call "%LIB%log_lib.bat" put "Continue: %CONFIRM%"
if /i not "%CONFIRM%"=="Y" (
    call "%LIB%log_lib.bat" put "Cancelled."
    pause & exit /b 0
)

call "%LIB%log_lib.bat" put ""
set CHAINED=1
call "%LIB%log_lib.bat" put "---- Step 1 start ----"
call "%ROOT%step1_dedupe.bat"
if errorlevel 1 (
    call "%LIB%log_lib.bat" fail "Step 1 failed. Aborting."
    exit /b 1
)

call "%LIB%log_lib.bat" put ""
call "%LIB%log_lib.bat" put "---- Step 2 start ----"
call "%ROOT%step2_organize.bat"
if errorlevel 1 (
    call "%LIB%log_lib.bat" fail "Step 2 failed. Aborting."
    exit /b 1
)

call "%LIB%log_lib.bat" put ""
call "%LIB%log_lib.bat" put "---- Step 3 start ----"
call "%ROOT%step3_cleanup.bat"
if errorlevel 1 (
    call "%LIB%log_lib.bat" fail "Step 3 failed. Aborting."
    exit /b 1
)

call "%LIB%log_lib.bat" put ""
call "%LIB%log_lib.bat" put "---- Step 4 start ----"
call "%ROOT%step4_lowercase.bat"
if errorlevel 1 (
    call "%LIB%log_lib.bat" fail "Step 4 failed. Aborting."
    exit /b 1
)

call "%LIB%log_lib.bat" put ""
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "   All steps complete"
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "End: %DATE% %TIME%"
call "%LIB%log_lib.bat" put "Log: %LOG_FILE%"
call "%LIB%log_lib.bat" put ""
pause
exit /b 0
