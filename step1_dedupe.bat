@echo off
chcp 65001 > nul

REM ==== パス設定 ====
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%.."
set WORK_DIR=%CD%
set UNSORTED=%WORK_DIR%\Unsorted
set CZKAWKA=%SCRIPT_DIR%czkawka_cli.exe

REM ==== 環境チェック ====
if not exist "%UNSORTED%" (
    echo エラー: Unsortedフォルダが見つかりません: %UNSORTED%
    pause & exit /b 1
)
if not exist "%CZKAWKA%" (
    echo エラー: czkawka_cli.exe が見つかりません: %CZKAWKA%
    pause & exit /b 1
)

REM ==== ヘッダー表示 ====
echo.
echo ====================================
echo    Step 1: 重複ファイル削除
echo ====================================
echo 作業フォルダ: %WORK_DIR%
echo 開始時刻: %DATE% %TIME%
echo ====================================
echo.

REM ==== [1/2] ハッシュ完全一致による重複削除 ====
echo [1/2] ハッシュ完全一致の重複ファイルを削除します
"%CZKAWKA%" dup --directories "%UNSORTED%" -D AEB
echo.

REM ==== [2/2] 視覚的類似画像の削除 (要確認) ====
echo [2/2] 視覚的類似画像の削除
echo.
echo  警告: この処理は露出違い・トリミング違いの画像も削除対象になる場合があります。
echo  実行前にリストを確認することを推奨します。
echo.
echo  [D] ドライラン実行（削除リストを表示するだけ）
echo  [Y] 削除を実行
echo  [S] この工程をスキップ
echo.
set /p CHOICE="選択してください (D/Y/S): "

if /i "%CHOICE%"=="D" (
    echo ドライランを実行します（削除は行いません）...
    "%CZKAWKA%" image --directories "%UNSORTED%"
    echo.
    echo ドライラン完了。上記リストを確認後、再度実行して Y を選択してください。
)
if /i "%CHOICE%"=="Y" (
    echo 類似画像の削除を実行します...
    "%CZKAWKA%" image --directories "%UNSORTED%" -D AEB
)
if /i "%CHOICE%"=="S" (
    echo 類似画像削除をスキップしました。
)

echo.

REM ==== フッター表示 ====
echo ====================================
echo    Step 1: 重複削除 完了
echo ====================================
echo 終了時刻: %DATE% %TIME%
echo.
pause
