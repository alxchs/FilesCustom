# tools/perf/OC-TestClickPause.ps1
. "$PSScriptRoot\SmokeTest-Helper.ps1"

$runnerScript = @'
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes, System.Drawing
Add-Type -Path "C:\desenv\utils\FilesApp\tools\perf\OCInput.cs"

$hwnd = [IntPtr]1445996
[OCInput]::Focus($hwnd)
Start-Sleep -Milliseconds 200

# Close any open rename popup (2x Esc)
[OCInput]::SendKey(0x1B)
Start-Sleep -Milliseconds 100
[OCInput]::SendKey(0x1B)
Start-Sleep -Milliseconds 200

$root = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
$allListItems = $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, 
    (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ClassNameProperty, "ListBoxItem")))

$fileItems = @($allListItems | Where-Object { $_.Current.BoundingRectangle.X -ge 600 -and $_.Current.BoundingRectangle.Y -ge 200 })

# Item 12: arquivo.txt
$target = $fileItems[12]
$r = $target.Current.BoundingRectangle

# Step 1: Click once to select
Write-Output "Clicking to select arquivo.txt..."
[OCInput]::MouseClick($r.X + 80, $r.Y + 16, $false)

# Step 2: Pause 1200ms
Write-Output "Pausing 1200ms..."
Start-Sleep -Milliseconds 1200

# Step 3: Click again on the name text
Write-Output "Clicking second time (click-pause)..."
[OCInput]::MouseClick($r.X + 80, $r.Y + 16, $false)
Start-Sleep -Milliseconds 600

# Inspect focused element
$focus = [System.Windows.Automation.AutomationElement]::FocusedElement
Write-Output "Focused after click-pause: Class='$($focus.Current.ClassName)' ControlType='$($focus.Current.ControlType.ProgrammaticName)'"

# Capture
$rect = New-Object OCInput+RECT
[OCInput]::GetWindowRect($hwnd, [ref]$rect) | Out-Null
$w = $rect.R - $rect.L
$h = $rect.B - $rect.T
$outPath = "C:\desenv\utils\FilesApp\docs\ux-reference\onecommander\evidence\rename\03_rename_click_pause.png"
$bmp = New-Object System.Drawing.Bitmap $w, $h
$gfx = [System.Drawing.Graphics]::FromImage($bmp)
$gfx.CopyFromScreen($rect.L, $rect.T, 0, 0, (New-Object System.Drawing.Size($w, $h)))
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$gfx.Dispose()
$bmp.Dispose()
Write-Output "Saved capture to $outPath"

# Clean up
[OCInput]::SendKey(0x1B)
Start-Sleep -Milliseconds 100
[OCInput]::SendKey(0x1B)
'@

$res = Invoke-OnDefault $runnerScript
Write-Output $res
