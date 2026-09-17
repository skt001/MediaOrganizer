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

REM ==== GeolocLang ====
REM First subtag of LocaleName (ja-JP -> ja). Missing/invalid -> en.
REM Photos / Movies / NoDate / NoLocation / Unknown stay English.
set "GEO_LANG=en"
set "LOCALE="
set "GEO_CAND="
for /f "tokens=3" %%A in ('reg query "HKCU\Control Panel\International" /v LocaleName 2^>nul ^| find "REG_SZ"') do set "LOCALE=%%A"
if not defined LOCALE goto :geo_done
for /f "tokens=1 delims=-" %%A in ("%LOCALE%") do set "GEO_CAND=%%A"
if not defined GEO_CAND goto :geo_done
if "%GEO_CAND:~1,1%"=="" goto :geo_done
if not "%GEO_CAND:~3,1%"=="" goto :geo_done
echo.%GEO_CAND%| findstr /i /r "^[a-z][a-z]" >nul
if errorlevel 1 goto :geo_done
set "GEO_LANG=%GEO_CAND%"
:geo_done

REM ==== Header ====
echo.
echo ====================================
echo    Step 2: Organize media
echo ====================================
echo Work folder: %WORK_DIR%
echo Start: %DATE% %TIME%
echo GeolocLang: %GEO_LANG%
echo ====================================
echo.

REM ==== Photos (DateTimeOriginal > CreateDate > FileModifyDate > NoDate) ====
REM GPS present: country/region/city. Else: NoLocation/Unknown/Unknown
echo --- Organize photos ---
echo.

echo [1/8] DateTimeOriginal + Model
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=%GEO_LANG% -@ "%RULES_PHOTO%\p1_datetime_model.args" -r "%UNSORTED%"
echo.

echo [2/8] DateTimeOriginal + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=%GEO_LANG% -@ "%RULES_PHOTO%\p2_datetime_unknown.args" -r "%UNSORTED%"
echo.

echo [3/8] CreateDate + Model
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=%GEO_LANG% -@ "%RULES_PHOTO%\p3_createdate_model.args" -r "%UNSORTED%"
echo.

echo [4/8] CreateDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=%GEO_LANG% -@ "%RULES_PHOTO%\p4_createdate_unknown.args" -r "%UNSORTED%"
echo.

echo [5/8] FileModifyDate + Model
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=%GEO_LANG% -@ "%RULES_PHOTO%\p5_filemod_model.args" -r "%UNSORTED%"
echo.

echo [6/8] FileModifyDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=%GEO_LANG% -@ "%RULES_PHOTO%\p6_filemod_unknown.args" -r "%UNSORTED%"
echo.

echo [7/8] NoDate + Model
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=%GEO_LANG% -@ "%RULES_PHOTO%\p7_nodate_model.args" -r "%UNSORTED%"
echo.

echo [8/8] NoDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=%GEO_LANG% -@ "%RULES_PHOTO%\p8_nodate_unknown.args" -r "%UNSORTED%"
echo.

REM ==== Videos (CreateDate > FileModifyDate > NoDate) ====
echo --- Organize videos ---
echo.

echo [1/6] CreateDate + Make
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=%GEO_LANG% -@ "%RULES_VIDEO%\v1_createdate_make.args" -r "%UNSORTED%"
echo.

echo [2/6] CreateDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=%GEO_LANG% -@ "%RULES_VIDEO%\v2_createdate_unknown.args" -r "%UNSORTED%"
echo.

echo [3/6] FileModifyDate + Make
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=%GEO_LANG% -@ "%RULES_VIDEO%\v3_filemod_make.args" -r "%UNSORTED%"
echo.

echo [4/6] FileModifyDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=%GEO_LANG% -@ "%RULES_VIDEO%\v4_filemod_unknown.args" -r "%UNSORTED%"
echo.

echo [5/6] NoDate + Make
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=%GEO_LANG% -@ "%RULES_VIDEO%\v5_nodate_make.args" -r "%UNSORTED%"
echo.

echo [6/6] NoDate + Unknown
"%EXIFTOOL%" -api QuickTimeUTC=1 -api geolocation -api GeolocLang=%GEO_LANG% -@ "%RULES_VIDEO%\v6_nodate_unknown.args" -r "%UNSORTED%"
echo.

REM ==== Footer ====
echo ====================================
echo    Step 2: Organize complete
echo ====================================
echo End: %DATE% %TIME%
echo.
pause
