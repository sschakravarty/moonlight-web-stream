@echo off
REM Simple batch file backup for starting Moonlight Web Stream
REM Run this if the PowerShell script isn't working

echo Starting Moonlight Web Stream Service (Simple Version)...
echo.

REM Check if WSL is available
wsl --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: WSL is not installed or available
    echo Install WSL: https://aka.ms/wsl
    pause
    exit /b 1
)

echo WSL is available. Checking distributions...
wsl --list --quiet

echo.
echo Trying to start moonlight service...

REM Try default distribution first
wsl -- sudo systemctl start moonlight-web.service 2>nul
if %errorlevel% == 0 (
    echo Default distribution: SUCCESS
    goto :check_service
)

REM Try Ubuntu specifically
wsl -d Ubuntu -- sudo systemctl start moonlight-web.service 2>nul
if %errorlevel% == 0 (
    echo Ubuntu distribution: SUCCESS
    set DISTRO_NAME=Ubuntu
    goto :check_service
)

REM Try Ubuntu-24.04
wsl -d Ubuntu-24.04 -- sudo systemctl start moonlight-web.service 2>nul
if %errorlevel% == 0 (
    echo Ubuntu-24.04 distribution: SUCCESS
    set DISTRO_NAME=Ubuntu-24.04
    goto :check_service
)

echo.
echo ERROR: Could not start service on any distribution
echo.
echo TROUBLESHOOTING:
echo 1. Make sure you're running as Administrator
echo 2. Check if service exists: wsl -- sudo systemctl status moonlight-web.service
echo 3. Try manually: wsl -- sudo systemctl start moonlight-web.service
echo 4. Check sudo permissions: wsl -- sudo whoami
echo.
pause
exit /b 1

:check_service
timeout /t 3 /nobreak >nul
wsl -- sudo systemctl is-active --quiet moonlight-web.service 2>nul
if %errorlevel% == 0 (
    echo.
    echo SUCCESS! Moonlight Web Stream is now running
    echo Server available at: http://localhost:8080
    echo.
) else (
    echo.
    echo WARNING: Service started but may not be active
    echo Check status: wsl -- sudo systemctl status moonlight-web.service
    echo.
    pause
)

exit /b 0