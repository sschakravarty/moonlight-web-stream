@echo off
REM Simple WSL Ubuntu Auto-Start Script
REM Place this in Windows startup folder or Task Scheduler

echo Starting WSL Ubuntu...

REM Start WSL Ubuntu
wsl -d Ubuntu --exec echo "WSL Ubuntu started"

REM Keep WSL running in background
start /b wsl -d Ubuntu --exec sleep infinity

echo WSL Ubuntu is running in background
exit /b 0