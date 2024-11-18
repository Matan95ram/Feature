# Function to run Disk Cleanup with specific options
function Run-DiskCleanup {
    Write-Host "Starting Disk Cleanup..." -ForegroundColor Cyan
    # Disk Cleanup silent mode with Windows Update Cleanup
    Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -NoNewWindow -Wait
    Write-Host "Disk Cleanup completed." -ForegroundColor Green
}

# Function to delete old Windows Update files using DISM
function Cleanup-WindowsUpdate {
    Write-Host "Cleaning up old Windows Update files..." -ForegroundColor Cyan
    try {
        dism /online /cleanup-image /startcomponentcleanup /resetbase | Out-Null
        Write-Host "Windows Update cleanup completed." -ForegroundColor Green
    } catch {
        Write-Host "Failed to clean up Windows Update files. Ensure you have administrative privileges." -ForegroundColor Red
    }
}

# Function to optimize drives
function Optimize-Drives {
    Write-Host "Optimizing drives..." -ForegroundColor Cyan
    try {
        Get-Volume | ForEach-Object {
            Optimize-Volume -DriveLetter $_.DriveLetter -Defrag -Verbose
        }
        Write-Host "Drives optimized successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to optimize drives. Ensure you have administrative privileges." -ForegroundColor Red
    }
}

# Main script
Write-Host "Starting comprehensive disk cleanup and optimization..." -ForegroundColor Yellow

# 1. Configure Disk Cleanup for silent mode
Write-Host "Configuring Disk Cleanup options..." -ForegroundColor Cyan
$cleanmgrFilePath = "$env:LOCALAPPDATA\Microsoft\Windows\cleanmgr"
if (-Not (Test-Path $cleanmgrFilePath)) {
    mkdir $cleanmgrFilePath
}
"Settings stored for Windows Update Cleanup" | Out-File -FilePath "$cleanmgrFilePath\cleanmgr.ini"

Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sageset:1" -Wait

# 2. Run Disk Cleanup
Run-DiskCleanup

# 3. Clean up Windows Update files
Cleanup-WindowsUpdate

# 4. Optimize drives
Optimize-Drives

Write-Host "All tasks completed successfully." -ForegroundColor Yellow
