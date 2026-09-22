@echo off
chcp 65001 > nul

REM ==== Paths ====
set ROOT=%~dp0
set LIB=%ROOT%lib\
set BIN=%ROOT%bin\
call "%LIB%log_lib.bat" init step2_organize
cd /d "%ROOT%.."
set WORK_DIR=%CD%
set UNSORTED=%WORK_DIR%\Unsorted
set EXIFTOOL=%BIN%exiftool.exe
set EXIFTOOL_CONFIG=%LIB%exiftool.config
set RULES_PHOTO=%LIB%rules\photo
set RULES_VIDEO=%LIB%rules\video

REM ==== Checks ====
if not exist "%UNSORTED%" (
    call "%LIB%log_lib.bat" fail "Error: Unsorted folder not found: %UNSORTED%"
    exit /b 1
)
if not exist "%EXIFTOOL%" (
    call "%LIB%log_lib.bat" fail "Error: exiftool.exe not found: %EXIFTOOL%"
    exit /b 1
)
if not exist "%RULES_PHOTO%" (
    call "%LIB%log_lib.bat" fail "Error: rules\photo folder not found"
    exit /b 1
)
if not exist "%RULES_VIDEO%" (
    call "%LIB%log_lib.bat" fail "Error: rules\video folder not found"
    exit /b 1
)
if not exist "%EXIFTOOL_CONFIG%" (
    call "%LIB%log_lib.bat" fail "Error: exiftool.config not found: %EXIFTOOL_CONFIG%"
    exit /b 1
)

REM ==== Header ====
call "%LIB%log_lib.bat" put ""
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "   Step 2: Organize media"
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "Work folder: %WORK_DIR%"
call "%LIB%log_lib.bat" put "Start: %DATE% %TIME%"
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put ""

REM ==== Photos (DateTimeOriginal > CreateDate > FileModifyDate > NoDate) ====
REM Location: GeolocationCountryNvl (missing -> NoLocation). Region/City omitted if missing.
REM Device: ModelNvl / MakeNvl (missing -> Unknown).
call "%LIB%log_lib.bat" put "--- Organize photos ---"
call "%LIB%log_lib.bat" put ""

call "%LIB%log_lib.bat" put "[1/4] DateTimeOriginal"
call :run_exiftool "%RULES_PHOTO%\p1_datetime.args"
if errorlevel 1 exit /b 1
call "%LIB%log_lib.bat" put ""

call "%LIB%log_lib.bat" put "[2/4] CreateDate"
call :run_exiftool "%RULES_PHOTO%\p2_createdate.args"
if errorlevel 1 exit /b 1
call "%LIB%log_lib.bat" put ""

call "%LIB%log_lib.bat" put "[3/4] FileModifyDate"
call :run_exiftool "%RULES_PHOTO%\p3_filemod.args"
if errorlevel 1 exit /b 1
call "%LIB%log_lib.bat" put ""

call "%LIB%log_lib.bat" put "[4/4] NoDate"
call :run_exiftool "%RULES_PHOTO%\p4_nodate.args"
if errorlevel 1 exit /b 1
call "%LIB%log_lib.bat" put ""

REM ==== Videos (CreateDate > FileModifyDate > NoDate) ====
call "%LIB%log_lib.bat" put "--- Organize videos ---"
call "%LIB%log_lib.bat" put ""

call "%LIB%log_lib.bat" put "[1/3] CreateDate"
call :run_exiftool "%RULES_VIDEO%\v1_createdate.args"
if errorlevel 1 exit /b 1
call "%LIB%log_lib.bat" put ""

call "%LIB%log_lib.bat" put "[2/3] FileModifyDate"
call :run_exiftool "%RULES_VIDEO%\v2_filemod.args"
if errorlevel 1 exit /b 1
call "%LIB%log_lib.bat" put ""

call "%LIB%log_lib.bat" put "[3/3] NoDate"
call :run_exiftool "%RULES_VIDEO%\v3_nodate.args"
if errorlevel 1 exit /b 1
call "%LIB%log_lib.bat" put ""

REM ==== Footer ====
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "   Step 2: Organize complete"
call "%LIB%log_lib.bat" put "===================================="
call "%LIB%log_lib.bat" put "End: %DATE% %TIME%"
call "%LIB%log_lib.bat" put "Log: %LOG_FILE%"
call "%LIB%log_lib.bat" put ""
pause
exit /b 0


REM ============================================================
REM Subroutine: :run_exiftool <args-file>
REM ExifTool exit 2 = all files failed -if (expected for fallback)
REM ============================================================
:run_exiftool
set "_ARGS=%~1"
set LOG_CMD="%EXIFTOOL%" -config "%EXIFTOOL_CONFIG%" -api QuickTimeUTC=1 -api geolocation -@ "%_ARGS%" -r "%UNSORTED%"
call "%LIB%log_lib.bat" exec
set "_ERR=%ERRORLEVEL%"
if "%_ERR%"=="2" set "_ERR=0"
if not "%_ERR%"=="0" (
    call "%LIB%log_lib.bat" fail "Error: ExifTool failed: %_ARGS%  [exit %_ERR%]"
    exit /b 1
)
exit /b 0
