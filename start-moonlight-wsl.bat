@echo off
REM Moonlight Web Stream Auto-Startup Script for Windows
REM Place this file in your Windows startup folder or use Task Scheduler

echo Starting Moonlight Web Stream Service...

REM Start WSL and ensure the service is running
wsl -d Ubuntu -- sudo systemctl start moonlight-web.service

REM Optional: Check if service started successfully
wsl -d Ubuntu -- sudo systemctl is-active --quiet moonlight-web.service
if %ERRORLEVEL% == 0 (
    echo Moonlight Web Stream Service started successfully!
    echo Server is available at: http://localhost:8080
) else (
    echo Failed to start Moonlight Web Stream Service
    pause
)

REM Keep WSL running in background (optional, remove if you don't want this)
REM wsl -d Ubuntu -- tail -f /dev/null