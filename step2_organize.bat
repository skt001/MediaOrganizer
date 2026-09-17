@echo off
chcp 65001 > nul

REM ==== Paths ====
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%.."
set WORK_DIR=%CD%
set UNSORTED=%WORK_DIR%\Unsorted
set EXIFTOOL=%SCRIPT_DIR%exiftool.exe
set RULES_PHOTO=%SCRIPT_DIR%rules\photo
set RULES_VIDEO=%SCRIPT_DIR%rules\video

REM ==== Checks ====
if not exist "%UNSORTED%" (
    echo Error: Unsorted folder not found: %UNSORTED%
    pause & exit /b 1
)
if not exist "%EXIFTOOL%" (
    echo Error: exiftool.exe not found: %EXIFTOOL%
    pause & exit /b 1
)
if not exist "%RULES_PHOTO%" (
    echo Error: rules\photo folder not found
    pause & exit /b 1
)
if not exist "%RULES_VIDEO%" (
    echo Error: rules\video folder not found
    pause & exit /b 1
)

REM ==== Header ====
echo.
echo ====================================
echo    Step 2: Organize media
echo ====================================
echo Work folder: %WORK_DIR%
echo Start: %DATE% %TIME%
echo ====================================
echo.

REM ==== Photos (DateTimeOriginal > CreateDate > FileModifyDate > NoDate) ====
REM GPS present: country/region/city. Else: NoLocation/Unknown/Unknown
echo --- Organize photos ---
echo.

echo [1/8] DateTimeOriginal + Model
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -@ "%RULES_PHOTO%\p1_datetime_model.args" -r "%UNSORTED%"
echo.

echo [2/8] DateTimeOriginal + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -@ "%RULES_PHOTO%\p2_datetime_unknown.args" -r "%UNSORTED%"
echo.

echo [3/8] CreateDate + Model
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -@ "%RULES_PHOTO%\p3_createdate_model.args" -r "%UNSORTED%"
echo.

echo [4/8] CreateDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -@ "%RULES_PHOTO%\p4_createdate_unknown.args" -r "%UNSORTED%"
echo.

echo [5/8] FileModifyDate + Model
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -@ "%RULES_PHOTO%\p5_filemod_model.args" -r "%UNSORTED%"
echo.

echo [6/8] FileModifyDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -@ "%RULES_PHOTO%\p6_filemod_unknown.args" -r "%UNSORTED%"
echo.

echo [7/8] NoDate + Model
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -@ "%RULES_PHOTO%\p7_nodate_model.args" -r "%UNSORTED%"
echo.

echo [8/8] NoDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -@ "%RULES_PHOTO%\p8_nodate_unknown.args" -r "%UNSORTED%"
echo.

REM ==== Videos (CreateDate > FileModifyDate > NoDate) ====
echo --- Organize videos ---
echo.

echo [1/6] CreateDate + Make
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -@ "%RULES_VIDEO%\v1_createdate_make.args" -r "%UNSORTED%"
echo.

echo [2/6] CreateDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -@ "%RULES_VIDEO%\v2_createdate_unknown.args" -r "%UNSORTED%"
echo.

echo [3/6] FileModifyDate + Make
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -@ "%RULES_VIDEO%\v3_filemod_make.args" -r "%UNSORTED%"
echo.

echo [4/6] FileModifyDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -@ "%RULES_VIDEO%\v4_filemod_unknown.args" -r "%UNSORTED%"
echo.

echo [5/6] NoDate + Make
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -@ "%RULES_VIDEO%\v5_nodate_make.args" -r "%UNSORTED%"
echo.

echo [6/6] NoDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -@ "%RULES_VIDEO%\v6_nodate_unknown.args" -r "%UNSORTED%"
echo.

REM ==== Footer ====
echo ====================================
echo    Step 2: Organize complete
echo ====================================
echo End: %DATE% %TIME%
echo.
pause
