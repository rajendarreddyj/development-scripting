param($hours= 8)
$pshost = Get-Host

$psWindow = $pshost.UI.RawUI

$newSize = $psWindow.BufferSize

$newSize = $psWindow.WindowSize
$newSize.Height = 10
$newSize.width = 27

$psWindow.WindowSize = $newSize

echo "Time remaining: ${Hours}:00:00"

$cycleLength = 295
$myshell = New-Object -com "Wscript.Shell"
$time = [int]$hours *60 * 60

$cycles = $time / $cycleLength

for ($i = 0; $i -lt $cycles; $i++) {
   Start-Sleep -Seconds $cycleLength
   $myshell.sendkeys("{SCROLLLOCK}")
   $myshell.sendkeys("{SCROLLLOCK}")
   
   $time = $time - $cycleLength
   [int]$hoursLeft = [System.Math]::Floor($time/ 3600)
   $ml = ([System.Math]::Floor(($time % 3600) / 60)).ToString("00")
   $sl = (($time % 3600) % 60).ToString("00")
   echo "Time remaining: ${hoursLeft}:${ml}:${sl}"
}
