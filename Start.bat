@echo off
title WinTweaks - By Kaldarix

cd /d "%~dp0"
set "ver=1.0.0"
set "repo=Kaldarix/WinTweaks"

:calls
call :firstruncheck

:check_admin
cls
echo [INFO] Checking administrative privileges...
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Administrator privileges required. Elevating...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)
echo [SUCCESS] Running with administrative privileges.
timeout /t 1 >nul
goto :eof

:thanking
echo [INFO] Thank you for installing my scirpt.
goto :eof

:firstruncheck
echo [INFO] Checking for first run...
:: Check if firstrun=true exists in the config file
powershell -Command "$content = Get-Content 'assets\main.cfg'; if ($content -match 'firstrun=true') { exit 0 } else { exit 1 }"

if %errorLevel% equ 0 (
    echo [INFO] First run detected as true. Proceeding with setup...
	call assets/firstrun.bat
) else (
    goto :eof
)