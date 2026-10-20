@echo off
setlocal enabledelayedexpansion
title WIN-TWEAKS SETUP

:: VARs and Settings
cd /d "%~dp0"
set "ver=1.0.0"
set "repo=Kaldarix/WinTweaks"

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
if not exist "main.cfg" (
    echo [ERROR] main.cfg is missing! Please reinstall WinTweaks.
    pause
    exit
)

echo [SUCCESS] All core files present.
timeout /t 1 >nul
goto :eof

:check_version
cls
echo [INFO] Checking for updates against GitHub...
for /f "delims=" %%i in ('curl -s "https://api.github.com/repos/%repo%/releases/latest" ^| findstr "tag_name"') do (
    set "raw_tag=%%i"
)

for /f "delims=" %%i in ('powershell -Command "$raw = '%raw_tag%'; if ($raw -match 'v?(\d+\.\d+\.\d+)') { $matches[1] } else { '0.0.0' }"') do (
    set "latest_ver=%%i"
)
echo [INFO] Installed Version: v%ver%
echo [INFO] Latest Version:    v%latest_ver%

:: Compare versions using PowerShell
powershell -Command "$local = [Version]'%ver%'; $remote = [Version]'%latest_ver%'; if ($remote -gt $local) { exit 0 } else { exit 1 }"

if %errorLevel% equ 0 (
    echo [INFO] A newer version is available on GitHub!
    timeout /t 1 >nul
    call :version_prompt
) else (
    echo [SUCCESS] You are running the latest version or newer.
    timeout /t 1 >nul
)
timeout /t 1 >nul
goto :eof

:version_prompt
:: extra delay for dramatic effect
cls
echo ===================================================
ping localhost -n 1 >nul
echo  WARNING: WinTweaks is Outdated!
ping localhost -n 1 >nul
echo ===================================================
ping localhost -n 1 >nul
echo  Installed Version : v%ver%
ping localhost -n 1 >nul
echo  Latest Version    : v%latest_ver%
ping localhost -n 2 >nul
echo.
ping localhost -n 1 >nul
echo  [U] Update
ping localhost -n 1 >nul
echo  [P] Proceed anyway
ping localhost -n 1 >nul
echo  [C] Cancel setup
ping localhost -n 2 >nul
echo.
ping localhost -n 1 >nul
choice /c UPC /n /m "Select an option [U/P/C]: "

if errorlevel 3 (
    echo [INFO] Setup canceled by user.
    timeout /t 1 >nul
    exit
)
if errorlevel 2 (
    goto confirm_proceed
)
if errorlevel 1 (
    start https://github.com/%repo%/releases/latest
    exit
)

:confirm_proceed
cls
echo ===================================================
echo  WARNING: Proceed with Outdated Version?
echo ===================================================
echo  Are you sure you want to proceed? 
echo  There might be existing bugs in your outdated version.
echo.
echo  [Y] Yes, proceed anyway
echo  [N] No, update
echo.
choice /c YN /n /m "Are you sure? [Y/N]: "

if errorlevel 2 (
    start https://github.com/%repo%/releases/latest
    exit /b
)
if errorlevel 1 (
    goto check_python
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
python ../main.py
pause
exit /b