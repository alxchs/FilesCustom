# tools/perf/OC-TestAaAndMulti.ps1
. "$PSScriptRoot\SmokeTest-Helper.ps1"

$runnerScript = @'
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes, System.Drawing
Add-Type -Path "C:\desenv\utils\FilesApp\tools\perf\OCInput.cs"

$hwnd = [IntPtr]1445996
[OCInput]::Focus($hwnd)
Start-Sleep -Milliseconds 200

function CleanPopup {
    [OCInput]::SendKey(0x1B); Start-Sleep -Milliseconds 100
    [OCInput]::SendKey(0x1B); Start-Sleep -Milliseconds 150
}

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

function OpenRenameOn($idx) {
    CleanPopup
    $root = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
    $all = $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, 
        (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ClassNameProperty, "ListBoxItem")))
    $items = @($all | Where-Object { $_.Current.BoundingRectangle.X -ge 600 -and $_.Current.BoundingRectangle.Y -ge 200 })
    $t = $items[$idx]
    $r = $t.Current.BoundingRectangle
    [OCInput]::MouseClick($r.X + 80, $r.Y + 16, $false)
    Start-Sleep -Milliseconds 200
    [OCInput]::SendKey(0x71) # F2
    Start-Sleep -Milliseconds 400
}

# --- TEST 1: The [A|a] button ---
Write-Output "=== TEST 1: Case Conversion Button [A|a] ==="
OpenRenameOn 12 # arquivo.txt
$focus = [System.Windows.Automation.AutomationElement]::FocusedElement
$tp = $focus.GetCurrentPattern([System.Windows.Automation.TextPattern]::Pattern) -as [System.Windows.Automation.TextPattern]
Write-Output "Before Aa click: '$($tp.DocumentRange.GetText(-1))'"

# The [A|a] button is immediately to the left of the TextBox (TextBox.X is around 648; [A|a] is around 625, Y=645)
# Let's find all buttons near the TextBox
$rectBox = $focus.Current.BoundingRectangle
$btnX = $rectBox.X - 25
$btnY = $rectBox.Y + ($rectBox.Height / 2)
Write-Output "Clicking [A|a] at ($btnX, $btnY)..."
[OCInput]::MouseClick([int]$btnX, [int]$btnY, $false)
Start-Sleep -Milliseconds 300
Write-Output "After 1st Aa click: '$($tp.DocumentRange.GetText(-1))'"
Capture-OCWin "10_rename_aa_click1"

# Click 2nd time
[OCInput]::MouseClick([int]$btnX, [int]$btnY, $false)
Start-Sleep -Milliseconds 300
Write-Output "After 2nd Aa click: '$($tp.DocumentRange.GetText(-1))'"
Capture-OCWin "11_rename_aa_click2"

# Click 3rd time
[OCInput]::MouseClick([int]$btnX, [int]$btnY, $false)
Start-Sleep -Milliseconds 300
Write-Output "After 3rd Aa click: '$($tp.DocumentRange.GetText(-1))'"
Capture-OCWin "12_rename_aa_click3"

CleanPopup

# --- TEST 2: Multiple Selection Rename ---
Write-Output "=== TEST 2: Multiple Selection ==="
# In OneCommander, select file_001.txt and file_002.txt
# We can select item 13, then send Shift+Down to expand selection!
$root = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
$all = $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, 
    (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ClassNameProperty, "ListBoxItem")))
$items = @($all | Where-Object { $_.Current.BoundingRectangle.X -ge 600 -and $_.Current.BoundingRectangle.Y -ge 200 })

$r13 = $items[13].Current.BoundingRectangle
[OCInput]::MouseClick($r13.X + 80, $r13.Y + 16, $false)
Start-Sleep -Milliseconds 200

# Send Shift + Down (VK_SHIFT = 0x10, VK_DOWN = 0x28)
Write-Output "Sending Shift + Down to select multiple items..."
[OCInput]::SendModifiedKey(0x10, 0x28)
Start-Sleep -Milliseconds 300

# Press F2
Write-Output "Sending F2 on multiple items..."
[OCInput]::SendKey(0x71)
Start-Sleep -Milliseconds 500

Capture-OCWin "13_rename_multiselection"
CleanPopup
'@

$res = Invoke-OnDefault $runnerScript
Write-Output $res
