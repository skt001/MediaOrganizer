@echo off
chcp 65001 > nul

REM ==== パス設定 ====
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%.."
set WORK_DIR=%CD%
set PHOTOS=%WORK_DIR%\Photos
set MOVIES=%WORK_DIR%\Movies
set UNSORTED=%WORK_DIR%\Unsorted

REM ==== 環境チェック ====
if not exist "%PHOTOS%"   echo 警告: Photosフォルダが見つかりません
if not exist "%MOVIES%"   echo 警告: Moviesフォルダが見つかりません
if not exist "%UNSORTED%" echo 警告: Unsortedフォルダが見つかりません

if not exist "%PHOTOS%" if not exist "%MOVIES%" if not exist "%UNSORTED%" (
    echo エラー: 処理対象フォルダがすべて存在しません
    pause & exit /b 1
)

REM ==== ヘッダー表示 ====
echo.
echo ====================================
echo    Step 4: ファイル名小文字化
echo ====================================
echo 作業フォルダ: %WORK_DIR%
echo 開始時刻: %DATE% %TIME%
echo ====================================
echo.

REM NTFSは大文字小文字を区別しないため、直接リネームは無視される。
REM 一時名を経由することで確実に小文字化する。
REM  ABC.jpg -> ABC.jpg.__tmp__ -> abc.jpg

if exist "%PHOTOS%" (
    echo [1/3] Photosフォルダ処理
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
    echo [2/3] Moviesフォルダ処理
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
    echo [3/3] Unsortedフォルダ処理
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

REM ==== フッター表示 ====
echo ====================================
echo    Step 4: ファイル名小文字化 完了
echo ====================================
echo 終了時刻: %DATE% %TIME%
echo.
pause
