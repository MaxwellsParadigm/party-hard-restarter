# ============================================================
#  Party Hard - auto restarter for the "Clubber" achievement
#  Launches the game via Steam, waits, closes it, repeats.
#  Stop: Ctrl+C  (or just close this PowerShell window)
# ============================================================

# --- Settings ----------------------------------------------------
$AppId        = 356570                                  # Steam App ID of Party Hard
$InstallMatch = '*\steamapps\common\Party Hard\*'       # install path (used to find the game process)
$RunSeconds   = 12      # how long to keep the game open so Steam counts the launch
$PauseSeconds = 5       # pause between launches so Steam notices the game closed
$StartTimeout = 60      # max wait (sec) for the game process to appear
$StopAfter    = 0       # stop after N launches (0 = run forever until you stop it)
# -----------------------------------------------------------------

function Get-GameProcesses {
  Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.ExecutablePath -like $InstallMatch }
}

Write-Host "Party Hard auto-restarter. Press Ctrl+C to stop." -ForegroundColor Cyan

$count = 0
while ($true) {
  $count++
  Write-Host ("[{0}] Launching the game..." -f $count) -ForegroundColor Green
  Start-Process "steam://rungameid/$AppId"
  $waited = 0
  while (-not (Get-GameProcesses) -and $waited -lt $StartTimeout) {
    Start-Sleep -Seconds 1
    $waited++
  }

  if (Get-GameProcesses) {
    Write-Host ("Game started, holding for {0} sec..." -f $RunSeconds)
    Start-Sleep -Seconds $RunSeconds
    Get-GameProcesses | ForEach-Object {
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    }
    Write-Host "Game closed."
  } else {
    Write-Host ("Game process not found within {0} sec. Check App ID / install path." -f $StartTimeout) -ForegroundColor Yellow
  }

  if ($StopAfter -gt 0 -and $count -ge $StopAfter) {
    Write-Host ("Done: {0} launches." -f $count) -ForegroundColor Cyan
    break
  }

  Start-Sleep -Seconds $PauseSeconds
}
