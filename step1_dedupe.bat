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
call "%LIB%log_lib.bat" put "[1/2] Removing exact-hash duplicate files (keep oldest)"
set LOG_CMD="%CZKAWKA%" dup --directories "%UNSORTED%" -D AEO -W
call "%LIB%log_lib.bat" exec
if errorlevel 1 (
    call "%LIB%log_lib.bat" fail "Error: exact-hash duplicate removal failed."
    exit /b 1
)
call "%LIB%log_lib.bat" put ""

REM ==== [2/2] Visually similar images (confirm first) ====
call "%LIB%log_lib.bat" put "[2/2] Remove visually similar images"
if defined CHAINED (
    call "%LIB%log_lib.bat" put "Skipped (chained run)."
    goto :similar_done
)
call "%LIB%log_lib.bat" put ""
call "%LIB%log_lib.bat" put " Warning: This may also match exposure/crop variants."
call "%LIB%log_lib.bat" put " Review the list before deleting."
call "%LIB%log_lib.bat" put ""
call "%LIB%log_lib.bat" put " [1] List only (no delete)"
call "%LIB%log_lib.bat" put " [2] Keep oldest"
call "%LIB%log_lib.bat" put " [3] Keep newest"
call "%LIB%log_lib.bat" put " [4] Keep biggest"
call "%LIB%log_lib.bat" put " [5] Keep smallest"
call "%LIB%log_lib.bat" put " [6] Skip this step"
call "%LIB%log_lib.bat" put ""
set "CHOICE="
set /p CHOICE="Choose (1/2/3/4/5/6, blank=skip): "
call "%LIB%log_lib.bat" put "Choice: %CHOICE%"

if "%CHOICE%"=="1" goto :similar_dry
if "%CHOICE%"=="2" set "SIM_METHOD=AEO"
if "%CHOICE%"=="2" goto :similar_delete
if "%CHOICE%"=="3" set "SIM_METHOD=AEN"
if "%CHOICE%"=="3" goto :similar_delete
if "%CHOICE%"=="4" set "SIM_METHOD=AEB"
if "%CHOICE%"=="4" goto :similar_delete
if "%CHOICE%"=="5" set "SIM_METHOD=AES"
if "%CHOICE%"=="5" goto :similar_delete
call "%LIB%log_lib.bat" put "Skipped similar-image deletion."
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
call "%LIB%log_lib.bat" put "Dry run done. Review the list, then run again and choose 2-5."
goto :similar_done

:similar_delete
call "%LIB%log_lib.bat" put "Deleting similar images (-D %SIM_METHOD%)..."
set LOG_CMD="%CZKAWKA%" image --directories "%UNSORTED%" -D %SIM_METHOD% -W
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
if not defined CHAINED pause
exit /b 0
