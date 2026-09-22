@echo off
chcp 65001 > nul

REM ==== Paths ====
set SCRIPT_DIR=%~dp0
call "%SCRIPT_DIR%log_lib.bat" init step2_organize
cd /d "%SCRIPT_DIR%.."
set WORK_DIR=%CD%
set UNSORTED=%WORK_DIR%\Unsorted
set EXIFTOOL=%SCRIPT_DIR%exiftool.exe
set RULES_PHOTO=%SCRIPT_DIR%rules\photo
set RULES_VIDEO=%SCRIPT_DIR%rules\video

REM ==== Checks ====
if not exist "%UNSORTED%" (
    call "%SCRIPT_DIR%log_lib.bat" fail "Error: Unsorted folder not found: %UNSORTED%"
    exit /b 1
)
if not exist "%EXIFTOOL%" (
    call "%SCRIPT_DIR%log_lib.bat" fail "Error: exiftool.exe not found: %EXIFTOOL%"
    exit /b 1
)
if not exist "%RULES_PHOTO%" (
    call "%SCRIPT_DIR%log_lib.bat" fail "Error: rules\photo folder not found"
    exit /b 1
)
if not exist "%RULES_VIDEO%" (
    call "%SCRIPT_DIR%log_lib.bat" fail "Error: rules\video folder not found"
    exit /b 1
)
if not exist "%SCRIPT_DIR%exiftool.config" (
    call "%SCRIPT_DIR%log_lib.bat" fail "Error: exiftool.config not found: %SCRIPT_DIR%exiftool.config"
    exit /b 1
)

REM ==== Header ====
call "%SCRIPT_DIR%log_lib.bat" put ""
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "   Step 2: Organize media"
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "Work folder: %WORK_DIR%"
call "%SCRIPT_DIR%log_lib.bat" put "Start: %DATE% %TIME%"
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put ""

REM ==== Photos (DateTimeOriginal > CreateDate > FileModifyDate > NoDate) ====
REM Location: GeolocationCountryNvl (missing -> NoLocation). Region/City omitted if missing.
REM Device: ModelNvl / MakeNvl (missing -> Unknown).
call "%SCRIPT_DIR%log_lib.bat" put "--- Organize photos ---"
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[1/4] DateTimeOriginal"
call :run_exiftool "%RULES_PHOTO%\p1_datetime.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[2/4] CreateDate"
call :run_exiftool "%RULES_PHOTO%\p2_createdate.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[3/4] FileModifyDate"
call :run_exiftool "%RULES_PHOTO%\p3_filemod.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[4/4] NoDate"
call :run_exiftool "%RULES_PHOTO%\p4_nodate.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

REM ==== Videos (CreateDate > FileModifyDate > NoDate) ====
call "%SCRIPT_DIR%log_lib.bat" put "--- Organize videos ---"
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[1/3] CreateDate"
call :run_exiftool "%RULES_VIDEO%\v1_createdate.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[2/3] FileModifyDate"
call :run_exiftool "%RULES_VIDEO%\v2_filemod.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[3/3] NoDate"
call :run_exiftool "%RULES_VIDEO%\v3_nodate.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

REM ==== Footer ====
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "   Step 2: Organize complete"
call "%SCRIPT_DIR%log_lib.bat" put "===================================="
call "%SCRIPT_DIR%log_lib.bat" put "End: %DATE% %TIME%"
call "%SCRIPT_DIR%log_lib.bat" put "Log: %LOG_FILE%"
call "%SCRIPT_DIR%log_lib.bat" put ""
pause
exit /b 0


REM ============================================================
REM Subroutine: :run_exiftool <args-file>
REM ExifTool exit 2 = all files failed -if (expected for fallback)
REM ============================================================
:run_exiftool
set "_ARGS=%~1"
set LOG_CMD="%EXIFTOOL%" -config "%SCRIPT_DIR%exiftool.config" -api QuickTimeUTC=1 -api geolocation -@ "%_ARGS%" -r "%UNSORTED%"
call "%SCRIPT_DIR%log_lib.bat" exec
set "_ERR=%ERRORLEVEL%"
if "%_ERR%"=="2" set "_ERR=0"
if not "%_ERR%"=="0" (
    call "%SCRIPT_DIR%log_lib.bat" fail "Error: ExifTool failed: %_ARGS%  [exit %_ERR%]"
    exit /b 1
)
exit /b 0
