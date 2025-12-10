@echo off
REM Simple batch file for starting Moonlight Web Stream
REM Run this as Administrator

echo Starting Moonlight Web Stream Service...

REM Start WSL Ubuntu
wsl -d Ubuntu --exec echo "WSL started"

REM Start moonlight service
wsl -d Ubuntu -- sudo -n systemctl start moonlight-web.service

REM Check if it worked
wsl -d Ubuntu -- curl -s --connect-timeout 5 http://localhost:8080 >nul
if %errorlevel% == 0 (
    echo SUCCESS! Server is running at http://localhost:8080
) else (
    echo ERROR: Service may not have started
    echo Try: wsl -- sudo systemctl status moonlight-web.service
)

exit /b 0