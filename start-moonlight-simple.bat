@echo off
REM Simple batch file for starting Moonlight Web Stream
REM Run this as Administrator

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
wsl -- sudo -n systemctl start moonlight-web.service >nul 2>&1
if %errorlevel% == 0 (
    echo Default distribution: SUCCESS
    goto :check_service
)

REM Try Ubuntu specifically
wsl -d Ubuntu -- sudo -n systemctl start moonlight-web.service >nul 2>&1
if %errorlevel% == 0 (
    echo Ubuntu distribution: SUCCESS
    set DISTRO_NAME=Ubuntu
    goto :check_service
)

REM Try Ubuntu-24.04
wsl -d Ubuntu-24.04 -- sudo -n systemctl start moonlight-web.service >nul 2>&1
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
echo 2. Check if passwordless sudo is configured in WSL:
echo    wsl -- sudo -n whoami
echo 3. If sudo asks for password, run in WSL:
echo    echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl start moonlight-web.service, /usr/bin/systemctl stop moonlight-web.service, /usr/bin/systemctl restart moonlight-web.service, /usr/bin/systemctl status moonlight-web.service, /usr/bin/systemctl is-active moonlight-web.service" ^| sudo tee /etc/sudoers.d/moonlight-service
echo.
pause
exit /b 1

:check_service
echo Waiting 3 seconds for service to fully start...
timeout /t 3 /nobreak >nul

REM Use a simpler check that doesn't require sudo
wsl -- systemctl --user is-active moonlight-web.service >nul 2>&1
if %errorlevel% == 0 (
    echo.
    echo SUCCESS! Moonlight Web Stream is now running
    echo Server available at: http://localhost:8080
    echo.
    goto :end
)

REM Fallback: try with sudo but suppress password prompt
wsl -- sudo -n systemctl is-active moonlight-web.service >nul 2>&1
if %errorlevel% == 0 (
    echo.
    echo SUCCESS! Moonlight Web Stream is now running
    echo Server available at: http://localhost:8080
    echo.
    goto :end
)

REM Final fallback: just test if the server responds
echo Testing server response...
wsl -- curl -s --connect-timeout 5 http://localhost:8080 >nul 2>&1
if %errorlevel% == 0 (
    echo.
    echo SUCCESS! Server is responding at http://localhost:8080
    echo.
    goto :end
)

echo.
echo WARNING: Service may have started but status unclear
echo Try accessing: http://localhost:8080
echo Check status manually: wsl -- sudo systemctl status moonlight-web.service
echo.

:end
echo Batch file completed.
exit /b 0