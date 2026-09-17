@echo off
chcp 65001 > nul

REM ==== Paths ====
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%.."
set WORK_DIR=%CD%
set PHOTOS=%WORK_DIR%\Photos
set MOVIES=%WORK_DIR%\Movies
set UNSORTED=%WORK_DIR%\Unsorted

REM ==== Checks ====
if not exist "%PHOTOS%"   echo Warning: Photos folder not found
if not exist "%MOVIES%"   echo Warning: Movies folder not found
if not exist "%UNSORTED%" echo Warning: Unsorted folder not found

if not exist "%PHOTOS%" if not exist "%MOVIES%" if not exist "%UNSORTED%" (
    echo Error: none of the target folders exist
    pause & exit /b 1
)

REM ==== Header ====
echo.
echo ====================================
echo    Step 4: Lowercase filenames
echo ====================================
echo Work folder: %WORK_DIR%
echo Start: %DATE% %TIME%
echo ====================================
echo.

REM NTFS is case-insensitive, so a direct rename is a no-op.
REM Rename via a temp name so the case actually changes.
REM  ABC.jpg -> ABC.jpg.__tmp__ -> abc.jpg

if exist "%PHOTOS%" (
    echo [1/3] Photos
    powershell -NoProfile -Command ^
        "Get-ChildItem -LiteralPath '%PHOTOS%' -Recurse -File | ForEach-Object {" ^
        "  $lower = $_.Name.ToLower();" ^
        "  if ($_.Name -cne $lower) {" ^
        "    $tmp = $_.FullName + '.__tmp__';" ^
        "    Rename-Item -LiteralPath $_.FullName -NewName ($_.Name + '.__tmp__');" ^
        "    Rename-Item -LiteralPath $tmp -NewName $lower;" ^
        "  }" ^
        "}"
    echo.
)

if exist "%MOVIES%" (
    echo [2/3] Movies
    powershell -NoProfile -Command ^
        "Get-ChildItem -LiteralPath '%MOVIES%' -Recurse -File | ForEach-Object {" ^
        "  $lower = $_.Name.ToLower();" ^
        "  if ($_.Name -cne $lower) {" ^
        "    $tmp = $_.FullName + '.__tmp__';" ^
        "    Rename-Item -LiteralPath $_.FullName -NewName ($_.Name + '.__tmp__');" ^
        "    Rename-Item -LiteralPath $tmp -NewName $lower;" ^
        "  }" ^
        "}"
    echo.
)

if exist "%UNSORTED%" (
    echo [3/3] Unsorted
    powershell -NoProfile -Command ^
        "Get-ChildItem -LiteralPath '%UNSORTED%' -Recurse -File | ForEach-Object {" ^
        "  $lower = $_.Name.ToLower();" ^
        "  if ($_.Name -cne $lower) {" ^
        "    $tmp = $_.FullName + '.__tmp__';" ^
        "    Rename-Item -LiteralPath $_.FullName -NewName ($_.Name + '.__tmp__');" ^
        "    Rename-Item -LiteralPath $tmp -NewName $lower;" ^
        "  }" ^
        "}"
    echo.
)

REM ==== Footer ====
echo ====================================
echo    Step 4: Lowercase complete
echo ====================================
echo End: %DATE% %TIME%
echo.
pause
