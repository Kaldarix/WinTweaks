@echo off
title WinTweaks - By Kaldarix

cd /d "%~dp0"
set "ver=1.0.0"
set "repo=Kaldarix/WinTweaks"

:calls
call :thankin
call

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
echo.
echo          NAME
echo       WINTWEAKS
echo.