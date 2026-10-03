# tools/perf/OC-TestRenameBehavior.ps1
. "$PSScriptRoot\SmokeTest-Helper.ps1"

$runnerScript = @'
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes, System.Drawing
Add-Type -Path "C:\desenv\utils\FilesApp\tools\perf\OCInput.cs"

$hwnd = [IntPtr]1445996
[OCInput]::Focus($hwnd)

# Check what happens with Right Arrow, End, Backspace, Tab
# Let's inspect the focused TextBox
$focus = [System.Windows.Automation.AutomationElement]::FocusedElement
Write-Output "Initial Focused: Name='$($focus.Current.Name)' Class='$($focus.Current.ClassName)'"
$tp = $focus.GetCurrentPattern([System.Windows.Automation.TextPattern]::Pattern) -as [System.Windows.Automation.TextPattern]
if ($tp) {
    $sel0 = $tp.GetSelection()
    Write-Output "Initial Text: '$($tp.DocumentRange.GetText(-1))' | Selected: '$($sel0[0].GetText(-1))'"
}

# Press Right Arrow (VK_RIGHT = 0x27)
Write-Output "Sending VK_RIGHT..."
[OCInput]::SendKey(0x27)
Start-Sleep -Milliseconds 200
if ($tp) {
    $sel = $tp.GetSelection()
    Write-Output "After RIGHT Arrow: Selected: '$($sel[0].GetText(-1))'"
}

# Press End (VK_END = 0x23)
Write-Output "Sending VK_END..."
[OCInput]::SendKey(0x23)
Start-Sleep -Milliseconds 200
if ($tp) {
    $sel = $tp.GetSelection()
    Write-Output "After END key: Selected: '$($sel[0].GetText(-1))'"
}

# Now press Backspace 4 times (deleting .txt)
Write-Output "Sending 4x Backspace..."
for ($i=0; $i -lt 4; $i++) {
    [OCInput]::SendKey(0x08) # VK_BACK
    Start-Sleep -Milliseconds 100
}
if ($tp) {
    Write-Output "Text after 4 Backspaces: '$($tp.DocumentRange.GetText(-1))'"
}

# Type '.md'
Write-Output "Typing '.md'..."
[OCInput]::SendKey(0xBE) # VK_OEM_PERIOD
Start-Sleep -Milliseconds 50
[OCInput]::SendKey(0x4D) # 'M'
Start-Sleep -Milliseconds 50
[OCInput]::SendKey(0x44) # 'D'
Start-Sleep -Milliseconds 200
if ($tp) {
    Write-Output "Text after typing .md: '$($tp.DocumentRange.GetText(-1))'"
}

# Capture screenshot
$rect = New-Object OCInput+RECT
[OCInput]::GetWindowRect($hwnd, [ref]$rect) | Out-Null
$w = $rect.R - $rect.L
$h = $rect.B - $rect.T
$outPath = "C:\desenv\utils\FilesApp\docs\ux-reference\onecommander\evidence\rename\03_rename_edited_extension.png"
$bmp = New-Object System.Drawing.Bitmap $w, $h
$gfx = [System.Drawing.Graphics]::FromImage($bmp)
$gfx.CopyFromScreen($rect.L, $rect.T, 0, 0, (New-Object System.Drawing.Size($w, $h)))
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$gfx.Dispose()
$bmp.Dispose()
Write-Output "Saved capture to $outPath"

# Cancel with Esc so we don't commit yet
Write-Output "Sending Esc (VK_ESCAPE = 0x1B)..."
[OCInput]::SendKey(0x1B)
Start-Sleep -Milliseconds 300

$focusAfter = [System.Windows.Automation.AutomationElement]::FocusedElement
Write-Output "After Esc - Focused: Name='$($focusAfter.Current.Name)' Class='$($focusAfter.Current.ClassName)'"
'@

$res = Invoke-OnDefault $runnerScript
Write-Output $res
