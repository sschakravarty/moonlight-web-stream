# Moonlight Web Stream Auto-Startup Script for Windows (PowerShell)
# Run this with: powershell -ExecutionPolicy Bypass -File start-moonlight-wsl.ps1

Write-Host "Starting Moonlight Web Stream Service..." -ForegroundColor Green
Write-Host "Script location: $PSScriptRoot" -ForegroundColor Gray
Write-Host "Current directory: $(Get-Location)" -ForegroundColor Gray

# Create log file for debugging
$logFile = "$env:TEMP\moonlight-startup.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Starting moonlight startup script" | Add-Content -Path $logFile

# Check if WSL is available
try {
    Write-Host "Checking WSL availability..." -ForegroundColor Cyan
    $wslCheck = wsl --status 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ WSL is not available or not running" -ForegroundColor Red
        Write-Host "Trying to start WSL..." -ForegroundColor Yellow
        wsl --list --quiet >$null 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "WSL is not installed or configured"
        }
    }
    Write-Host "✅ WSL is available" -ForegroundColor Green
} catch {
    Write-Host "❌ WSL Error: $($_.Exception.Message)" -ForegroundColor Red
    "[$timestamp] WSL Error: $($_.Exception.Message)" | Add-Content -Path $logFile
    Write-Host "Please install WSL: https://aka.ms/wsl" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Get list of WSL distributions
try {
    Write-Host "Getting WSL distributions..." -ForegroundColor Cyan
    $wslOutput = wsl --list --quiet 2>&1
    "[$timestamp] WSL list output: $wslOutput" | Add-Content -Path $logFile
    
    # Filter and clean the distribution names
    $wslDistros = $wslOutput | Where-Object { 
        $_ -ne "" -and $_ -notmatch "Windows Subsystem" -and $_ -notmatch "distribution" 
    } | ForEach-Object { $_.Trim() }
    
    if ($wslDistros.Count -eq 0) {
        Write-Host "❌ No WSL distributions found!" -ForegroundColor Red
        Write-Host "Available WSL distributions:" -ForegroundColor Yellow
        wsl --list --verbose
        Write-Host "Please install Ubuntu: wsl --install -d Ubuntu" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    Write-Host "Found WSL distributions: $($wslDistros -join ', ')" -ForegroundColor Yellow
    "[$timestamp] Found distributions: $($wslDistros -join ', ')" | Add-Content -Path $logFile
    
    # Try default distribution first
    Write-Host "Trying default WSL distribution..." -ForegroundColor Cyan
    $serviceStarted = $false
    
    try {
        wsl -- sudo systemctl start moonlight-web.service 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Start-Sleep -Seconds 2
            wsl -- sudo systemctl is-active --quiet moonlight-web.service 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Service started on default distribution!" -ForegroundColor Green
                Write-Host "🌐 Server is available at: http://localhost:8080" -ForegroundColor Green
                "[$timestamp] Service started successfully on default distribution" | Add-Content -Path $logFile
                $serviceStarted = $true
            }
        }
    } catch {
        Write-Host "Default distribution failed: $($_.Exception.Message)" -ForegroundColor Yellow
        "[$timestamp] Default distribution error: $($_.Exception.Message)" | Add-Content -Path $logFile
    }
    
    # If default failed, try each named distribution
    if (-not $serviceStarted) {
        foreach ($distro in $wslDistros) {
            Write-Host "Trying distribution: $distro" -ForegroundColor Cyan
            "[$timestamp] Trying distribution: $distro" | Add-Content -Path $logFile
            
            try {
                # Try to start the service
                wsl -d $distro -- sudo systemctl start moonlight-web.service 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Start-Sleep -Seconds 2
                    # Check if service is actually running
                    wsl -d $distro -- sudo systemctl is-active --quiet moonlight-web.service 2>&1 | Out-Null
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "✅ Moonlight Service started successfully on $distro!" -ForegroundColor Green
                        Write-Host "🌐 Server is available at: http://localhost:8080" -ForegroundColor Green
                        "[$timestamp] Service started successfully on $distro" | Add-Content -Path $logFile
                        $serviceStarted = $true
                        break
                    } else {
                        Write-Host "⚠️ Service started but not active on $distro" -ForegroundColor Yellow
                        "[$timestamp] Service started but not active on $distro" | Add-Content -Path $logFile
                    }
                } else {
                    Write-Host "❌ Failed to start service on $distro" -ForegroundColor Red
                    "[$timestamp] Failed to start service on $distro" | Add-Content -Path $logFile
                }
            } catch {
                Write-Host "Error with $distro : $($_.Exception.Message)" -ForegroundColor Red
                "[$timestamp] Error with $distro : $($_.Exception.Message)" | Add-Content -Path $logFile
            }
        }
    }
    
    if (-not $serviceStarted) {
        Write-Host "❌ Failed to start Moonlight Web Stream Service on any distribution." -ForegroundColor Red
        "[$timestamp] Failed to start service on any distribution" | Add-Content -Path $logFile
        Write-Host ""
        Write-Host "Troubleshooting steps:" -ForegroundColor Yellow
        Write-Host "1. Check if moonlight-web.service exists:" -ForegroundColor White
        Write-Host "   wsl -- sudo systemctl status moonlight-web.service" -ForegroundColor Gray
        Write-Host ""
        Write-Host "2. Check if you have passwordless sudo in WSL:" -ForegroundColor White
        Write-Host "   wsl -- sudo whoami" -ForegroundColor Gray
        Write-Host ""
        Write-Host "3. Manually start service in WSL:" -ForegroundColor White
        Write-Host "   wsl -- cd /home/`$USER/moonlight-web-stream && sudo systemctl start moonlight-web.service" -ForegroundColor Gray
        Write-Host ""
        Write-Host "4. Check log file: $logFile" -ForegroundColor White
        
        if (-not $env:GITHUB_ACTIONS) {
            Read-Host "Press Enter to exit"
        }
        exit 1
    } else {
        Write-Host ""
        Write-Host "🎉 Moonlight Web Stream is now running!" -ForegroundColor Green
        Write-Host "📋 Log file: $logFile" -ForegroundColor Gray
        "[$timestamp] Script completed successfully" | Add-Content -Path $logFile
    }
    
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    "[$timestamp] Script error: $($_.Exception.Message)" | Add-Content -Path $logFile
    Write-Host "Make sure WSL is installed and Ubuntu distribution is available."
    Write-Host "Log file: $logFile" -ForegroundColor Gray
    if (-not $env:GITHUB_ACTIONS) {
        Read-Host "Press Enter to exit"
    }
    exit 1
}