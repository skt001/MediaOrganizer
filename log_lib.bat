@echo off
if "%~1"=="" exit /b 1
goto :cmd_%~1

:cmd_init
if defined LOG_FILE (
    call "%~f0" put ""
    call "%~f0" put "---- %~2 ----"
    exit /b 0
)
set "LOG_DIR=%~dp0logs"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
for /f %%I in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "LOG_STAMP=%%I"
set "LOG_FILE=%LOG_DIR%\%LOG_STAMP%_%~2.log"
set "LOG_SCRIPT=%~2"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$p=$env:LOG_FILE; $n=$env:LOG_SCRIPT; $t=Get-Date -Format 'yyyy-MM-dd HH:mm:ss';" ^
    "$h='MediaOrganizer log'+[char]13+[char]10+'script: '+$n+[char]13+[char]10+'start:  '+$t+[char]13+[char]10;" ^
    "[IO.File]::WriteAllText($p,$h,(New-Object System.Text.UTF8Encoding $true))"
call "%~f0" put "Log: %LOG_FILE%"
exit /b 0

:cmd_put
echo(%~2
if defined LOG_FILE >>"%LOG_FILE%" echo(%~2
exit /b 0

:cmd_fail
call "%~f0" put "%~2"
if defined LOG_FILE call "%~f0" put "Log: %LOG_FILE%"
pause
exit /b 1

:cmd_run
set "LOG_EXE=%~2"
set "_ARGFILE=%TEMP%\MediaOrganizer_args.txt"
set "_OUTFILE=%TEMP%\MediaOrganizer_out.txt"
type nul >"%_ARGFILE%"
shift
shift
:cmd_run_args
if "%~1"=="" goto :cmd_run_go
>>"%_ARGFILE%" echo(%~1
shift
goto :cmd_run_args
:cmd_run_go
setlocal EnableDelayedExpansion
set "ARGS="
for /f "usebackq delims=" %%A in ("%_ARGFILE%") do set "ARGS=!ARGS! "%%A""
call "%~f0" put "Running: %LOG_EXE%"
"%LOG_EXE%" !ARGS! >"%_OUTFILE%" 2>&1
set "_ERR=!ERRORLEVEL!"
if exist "%_OUTFILE%" (
    type "%_OUTFILE%"
    if defined LOG_FILE type "%_OUTFILE%" >>"%LOG_FILE%"
)
if exist "%_ARGFILE%" del "%_ARGFILE%"
if exist "%_OUTFILE%" del "%_OUTFILE%"
if !_ERR! lss 0 (
    call "%~f0" put "Error: command failed with exit !_ERR! - treated as 1"
    set "_ERR=1"
)
for %%E in (!_ERR!) do (
    endlocal
    exit /b %%E
)
