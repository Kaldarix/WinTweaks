@echo off
setlocal enabledelayedexpansion
title WIN-TWEAKS SETUP

:: VARs and Settings
cd /d "%~dp0"
set "ver=1.0.0"
set "repo=Kaldarix/WinTweaks"
set "scr=assets\scripts\"
set "asset=assets\"

echo [INFO] Initializing WinTweaks First Run...
timeout /t 2 >nul

:calls
call :check_admin
call :check_files
call :check_version
call :check_python
call :finalize_setup

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

:check_files
cls
echo [INFO] Verifying project files and directory structure...

:: Check required configuration file
if not exist "%asset%main.cfg" (
    echo [ERROR] main.cfg is missing! Please reinstall WinTweaks.
    pause
    exit /b
)

:: Check external VBS scripts exist
if not exist "%scr%update_prompt.vbs" (
    echo [ERROR] Missing scripts\update_prompt.vbs!
    pause
    exit /b
)
if not exist "%scr%\confirm_proceed.vbs" (
    echo [ERROR] Missing scripts\confirm_proceed.vbs!
    pause
    exit /b
)
echo [SUCCESS] All core files present.
timeout /t 1 >nul
goto :eof

:check_version
cls
echo [INFO] Checking for updates against GitHub...
for /f "delims=" %%i in ('curl -s "https://api.github.com/repos/%repo%/releases/latest" ^| findstr "tag_name"') do (
    set "latest_tag=%%i"
)

echo [INFO] Installed Version: v%ver%
echo [INFO] Latest Version:    v%latest_tag%
call :vbs_outdated_prompt
timeout /t 1 >nul
goto :eof

:vbs_outdated_prompt
for /f "delims=" %%a in ('cscript //nologo "%scr%update_prompt.vbs"') do set "vbs_result=%%a"

if "%vbs_result%"=="6" (
    start https://github.com/%repo%/releases/latest
    exit /b
) else if "%vbs_result%"=="7" (
	call :confirm_proceed
) else (
    echo [INFO] Setup canceled by user.
    exit
)
timeout /t 1 >nul
goto :eof

:confirm_proceed
for /f "delims=" %%a in ('cscript //nologo "%scr%confirm_proceed.vbs"') do set "conf_result=%%a"

if "%conf_result%"=="NO" (
    start https://github.com/%repo%/releases/latest
    exit /b
)
goto :eof

:check_python
cls
echo [INFO] Checking for Python runtime environment...
python --version >nul 2>&1
if %errorLevel% neq 0 (
    py --version >nul 2>&1
    if %errorLevel% neq 0 (
        echo [WARNING] Python is not installed on this system!
        echo [INFO] WinTweaks requires Python to execute the main application scripts.
        echo [INFO] Attempting automated installation via Winget...
		timeout /t 1 >nul
        
        winget install Python.Python.3.11 --accept-source-agreements --accept-package-agreements
		timeout /t 2 >nul
        
        if %errorLevel% neq 0 (
            echo [ERROR] Automatic Python installation failed. 
            echo [ERROR] Please install Python manually from https://www.python.org/ and restart WinTweaks.
            pause
            exit
        )
        echo [SUCCESS] Python installed successfully!
    )
)
echo [SUCCESS] Python environment verified.
timeout /t 1 >nul
goto :eof

:finalize_setup
cls
echo [INFO] Finalizing setup and updating configuration...

:: Verify and update assets\main.cfg: replace firstrun=true with firstrun=false
powershell -Command "(Get-Content '%asset%main.cfg') -replace 'firstrun=true', 'firstrun=false' | Set-Content '%asset%main.cfg'"

:: Verification check
findstr /i "firstrun=false" "%asset%ain.cfg" >nul 2>&1
if %errorLevel% equ 0 (
    echo [SUCCESS] Config updated: firstrun set to false.
) else (
    echo [WARNING] Config update could not be verified!
)

echo [SUCCESS] First-run setup completed successfully!
timeout /t 2 >nul

:: Launch your main Python script here once ready!
:: python main.py
pause
exit /b