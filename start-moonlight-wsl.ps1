# Moonlight Web Stream Auto-Startup Script for Windows (PowerShell)
# Run this with: powershell -ExecutionPolicy Bypass -File start-moonlight-wsl.ps1

Write-Host "Starting Moonlight Web Stream Service..." -ForegroundColor Green

# Get list of WSL distributions
try {
    $wslDistros = wsl -l -q | Where-Object { $_ -ne "" }
    
    if ($wslDistros.Count -eq 0) {
        Write-Host "Error: No WSL distributions found!" -ForegroundColor Red
        Write-Host "Please install Ubuntu or another Linux distribution in WSL."
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    Write-Host "Found WSL distributions: $($wslDistros -join ', ')" -ForegroundColor Yellow
    
    # Try each distribution until we find one that works
    $serviceStarted = $false
    foreach ($distro in $wslDistros) {
        Write-Host "Trying distribution: $distro" -ForegroundColor Cyan
        
        # Try to start the service
        $result = wsl -d $distro -- sudo systemctl start moonlight-web.service 2>$null
        if ($LASTEXITCODE -eq 0) {
            # Check if service is actually running
            $isActive = wsl -d $distro -- sudo systemctl is-active --quiet moonlight-web.service 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Moonlight Web Stream Service started successfully on $distro!" -ForegroundColor Green
                Write-Host "🌐 Server is available at: http://localhost:8080" -ForegroundColor Green
                $serviceStarted = $true
                break
            }
        }
    }
    
    if (-not $serviceStarted) {
        Write-Host "❌ Failed to start Moonlight Web Stream Service on any distribution." -ForegroundColor Red
        Write-Host ""
        Write-Host "Troubleshooting steps:" -ForegroundColor Yellow
        Write-Host "1. Check if moonlight-web.service is installed in WSL:"
        Write-Host "   wsl -- sudo systemctl status moonlight-web.service"
        Write-Host ""
        Write-Host "2. If not installed, run in WSL:"
        Write-Host "   sudo systemctl enable /home/`$USER/moonlight-web-stream/moonlight-web.service"
        Write-Host ""
        Write-Host "3. Check if you have sudo permissions in WSL"
        
        Read-Host "Press Enter to exit"
        exit 1
    }
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure WSL is installed and configured properly."
    Read-Host "Press Enter to exit"
    exit 1
}