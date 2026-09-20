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

REM LOG_CMD must be set by the caller. Do not pass the command through
REM `call` arguments — cmd treats & and = as separators.
:cmd_exec
if not defined LOG_CMD (
    call "%~f0" put "Error: LOG_CMD is not set"
    exit /b 1
)
call "%~f0" put "Running: %LOG_CMD%"
set "_OUTFILE=%TEMP%\MediaOrganizer_%RANDOM%%RANDOM%.txt"
%LOG_CMD% >"%_OUTFILE%" 2>&1
set "_ERR=%ERRORLEVEL%"
if exist "%_OUTFILE%" type "%_OUTFILE%"
if exist "%_OUTFILE%" if defined LOG_FILE type "%_OUTFILE%" >>"%LOG_FILE%"
if exist "%_OUTFILE%" del "%_OUTFILE%"
call "%~f0" put "Exit: %_ERR%"
if %_ERR% LSS 0 (
    call "%~f0" put "Error: negative exit %_ERR% treated as 1"
    set LOG_CMD=
    exit /b 1
)
set LOG_CMD=
exit /b %_ERR%
