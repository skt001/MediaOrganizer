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
REM GPS present: country/region/city. Else: NoLocation/Unknown/Unknown
call "%SCRIPT_DIR%log_lib.bat" put "--- Organize photos ---"
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[1/8] DateTimeOriginal + Model"
call :run_exiftool "%RULES_PHOTO%\p1_datetime_model.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[2/8] DateTimeOriginal + Unknown"
call :run_exiftool "%RULES_PHOTO%\p2_datetime_unknown.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[3/8] CreateDate + Model"
call :run_exiftool "%RULES_PHOTO%\p3_createdate_model.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[4/8] CreateDate + Unknown"
call :run_exiftool "%RULES_PHOTO%\p4_createdate_unknown.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[5/8] FileModifyDate + Model"
call :run_exiftool "%RULES_PHOTO%\p5_filemod_model.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[6/8] FileModifyDate + Unknown"
call :run_exiftool "%RULES_PHOTO%\p6_filemod_unknown.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[7/8] NoDate + Model"
call :run_exiftool "%RULES_PHOTO%\p7_nodate_model.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[8/8] NoDate + Unknown"
call :run_exiftool "%RULES_PHOTO%\p8_nodate_unknown.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

REM ==== Videos (CreateDate > FileModifyDate > NoDate) ====
call "%SCRIPT_DIR%log_lib.bat" put "--- Organize videos ---"
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[1/6] CreateDate + Make"
call :run_exiftool "%RULES_VIDEO%\v1_createdate_make.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[2/6] CreateDate + Unknown"
call :run_exiftool "%RULES_VIDEO%\v2_createdate_unknown.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[3/6] FileModifyDate + Make"
call :run_exiftool "%RULES_VIDEO%\v3_filemod_make.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[4/6] FileModifyDate + Unknown"
call :run_exiftool "%RULES_VIDEO%\v4_filemod_unknown.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[5/6] NoDate + Make"
call :run_exiftool "%RULES_VIDEO%\v5_nodate_make.args"
if errorlevel 1 exit /b 1
call "%SCRIPT_DIR%log_lib.bat" put ""

call "%SCRIPT_DIR%log_lib.bat" put "[6/6] NoDate + Unknown"
call :run_exiftool "%RULES_VIDEO%\v6_nodate_unknown.args"
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
set LOG_CMD="%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -@ "%_ARGS%" -r "%UNSORTED%"
call "%SCRIPT_DIR%log_lib.bat" exec
set "_ERR=%ERRORLEVEL%"
if "%_ERR%"=="2" set "_ERR=0"
if not "%_ERR%"=="0" (
    call "%SCRIPT_DIR%log_lib.bat" fail "Error: ExifTool failed: %_ARGS%  [exit %_ERR%]"
    exit /b 1
)
exit /b 0
