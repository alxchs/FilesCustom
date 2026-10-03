# tools/perf/OC-TestLayouts.ps1
. "$PSScriptRoot\SmokeTest-Helper.ps1"

$runnerScript = @'
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes, System.Drawing
Add-Type -Path "C:\desenv\utils\FilesApp\tools\perf\OCInput.cs"

$hwnd = [IntPtr]1445996
[OCInput]::Focus($hwnd)
Start-Sleep -Milliseconds 200

# Clean popup
[OCInput]::SendKey(0x1B); Start-Sleep -Milliseconds 100
[OCInput]::SendKey(0x1B); Start-Sleep -Milliseconds 150

function Capture-OCWin($name) {
    $rect = New-Object OCInput+RECT
    [OCInput]::GetWindowRect($hwnd, [ref]$rect) | Out-Null
    $w = $rect.R - $rect.L
    $h = $rect.B - $rect.T
    $outPath = "C:\desenv\utils\FilesApp\docs\ux-reference\onecommander\evidence\rename\$name.png"
    $bmp = New-Object System.Drawing.Bitmap $w, $h
    $gfx = [System.Drawing.Graphics]::FromImage($bmp)
    $gfx.CopyFromScreen($rect.L, $rect.T, 0, 0, (New-Object System.Drawing.Size($w, $h)))
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $gfx.Dispose()
    $bmp.Dispose()
    Write-Output "Saved capture to $outPath"
}

# Click on Columns layout icon: (650, 180)
Write-Output "Clicking Columns layout at (650, 180)..."
[OCInput]::MouseClick(650, 180, $false)
Start-Sleep -Milliseconds 600

Capture-OCWin "14_layout_columns"

# Click on an item in columns layout (around X=650, Y=350)
[OCInput]::MouseClick(650, 350, $false)
Start-Sleep -Milliseconds 300

# Send F2
Write-Output "Sending F2 in Columns layout..."
[OCInput]::SendKey(0x71)
Start-Sleep -Milliseconds 500

Capture-OCWin "15_rename_columns_layout"

# Cancel rename
[OCInput]::SendKey(0x1B); Start-Sleep -Milliseconds 100
[OCInput]::SendKey(0x1B); Start-Sleep -Milliseconds 150

# Click back on Details layout icon: (620, 180)
Write-Output "Clicking Details layout at (620, 180)..."
[OCInput]::MouseClick(620, 180, $false)
Start-Sleep -Milliseconds 500

Capture-OCWin "16_restored_details_layout"
'@

$res = Invoke-OnDefault $runnerScript
Write-Output $res
