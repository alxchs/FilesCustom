# tools/perf/OC-TestSpecialCases.ps1
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

# --- TEST 1: Invalid Characters ---
Write-Output "=== TEST 1: Invalid Characters ==="
OpenRenameOn 13 # file_001.txt
$focus = [System.Windows.Automation.AutomationElement]::FocusedElement
# Try typing '?' (Shift + / on US or ?)
# In VK: VK_OEM_2 with Shift, or send '?'
Write-Output "Typing invalid character '?'..."
[OCInput]::SendModifiedKey(0x10, 0xBF) # Shift + / (?)
Start-Sleep -Milliseconds 200

# Try typing '*'
Write-Output "Typing invalid character '*'..."
[OCInput]::SendModifiedKey(0x10, 0x38) # Shift + 8 (*)
Start-Sleep -Milliseconds 200

# Try typing '|'
[OCInput]::SendModifiedKey(0x10, 0xDC) # Shift + \ (|)
Start-Sleep -Milliseconds 200

# Try typing ':'
[OCInput]::SendModifiedKey(0x10, 0xBA) # Shift + ; (:)
Start-Sleep -Milliseconds 300

try {
    $tp = $focus.GetCurrentPattern([System.Windows.Automation.TextPattern]::Pattern) -as [System.Windows.Automation.TextPattern]
    Write-Output "Text in box after invalid chars: '$($tp.DocumentRange.GetText(-1))'"
} catch {}

Capture-OCWin "07_rename_invalid_characters"
CleanPopup

# --- TEST 2: Name Conflict (file_001.txt -> file_002.txt) ---
Write-Output "=== TEST 2: Name Conflict ==="
OpenRenameOn 13 # file_001.txt
$focus2 = [System.Windows.Automation.AutomationElement]::FocusedElement
# The box has 'file_001' selected. Let's type 'file_002'
# 'file_002' replaces the selected 'file_001' so text becomes 'file_002.txt'
Write-Output "Typing 'file_002'..."
# Send 'f', 'i', 'l', 'e', '_', '0', '0', '2'
$chars = @(0x46, 0x49, 0x4C, 0x45, 0xBD, 0x30, 0x30, 0x32) # file-002 or let's use arrows
# Even simpler: press End, backspace 5 times (.txt is 4 + 1 char), type '2.txt'
[OCInput]::SendKey(0x23) # End
Start-Sleep -Milliseconds 50
[OCInput]::SendKey(0x08) # Backspace 't'
[OCInput]::SendKey(0x08) # Backspace 'x'
[OCInput]::SendKey(0x08) # Backspace 't'
[OCInput]::SendKey(0x08) # Backspace '.'
[OCInput]::SendKey(0x08) # Backspace '1'
Start-Sleep -Milliseconds 50
# Type '2.txt'
[OCInput]::SendKey(0x32) # '2'
[OCInput]::SendKey(0xBE) # '.'
[OCInput]::SendKey(0x54) # 't'
[OCInput]::SendKey(0x58) # 'x'
[OCInput]::SendKey(0x54) # 't'
Start-Sleep -Milliseconds 200

try {
    $tp2 = $focus2.GetCurrentPattern([System.Windows.Automation.TextPattern]::Pattern) -as [System.Windows.Automation.TextPattern]
    Write-Output "Text in box before Enter: '$($tp2.DocumentRange.GetText(-1))'"
} catch {}

Write-Output "Sending Enter to commit conflict..."
[OCInput]::SendKey(0x0D) # Enter
Start-Sleep -Milliseconds 500

Capture-OCWin "08_rename_name_conflict"
CleanPopup

# --- TEST 3: Multiple Selection Rename ---
Write-Output "=== TEST 3: Multiple Selection ==="
# Click on file_001.txt (item 13)
$root = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
$all = $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, 
    (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ClassNameProperty, "ListBoxItem")))
$items = @($all | Where-Object { $_.Current.BoundingRectangle.X -ge 600 -and $_.Current.BoundingRectangle.Y -ge 200 })

$r13 = $items[13].Current.BoundingRectangle
$r14 = $items[14].Current.BoundingRectangle

# Click item 13
[OCInput]::MouseClick($r13.X + 80, $r13.Y + 16, $false)
Start-Sleep -Milliseconds 200

# Shift + Click item 14 to select both
Write-Output "Shift-clicking item 14..."
# Press Shift down
$scanShift = [OCInput]::MapVirtualKey(0x10, 0)
$inpDown = New-Object OCInput+INPUT
$inpDown.type = 1; $inpDown.mkhi.ki.wVk = 0x10; $inpDown.mkhi.ki.wScan = [ushort]$scanShift
[OCInput]::SendInput(1, [OCInput+INPUT[]]@($inpDown), [System.Runtime.InteropServices.Marshal]::SizeOf([Type][OCInput+INPUT]))

[OCInput]::MouseClick($r14.X + 80, $r14.Y + 16, $false)
Start-Sleep -Milliseconds 200

# Release Shift
$inpUp = New-Object OCInput+INPUT
$inpUp.type = 1; $inpUp.mkhi.ki.wVk = 0x10; $inpUp.mkhi.ki.wScan = [ushort]$scanShift; $inpUp.mkhi.ki.dwFlags = 2
[OCInput]::SendInput(1, [OCInput+INPUT[]]@($inpUp), [System.Runtime.InteropServices.Marshal]::SizeOf([Type][OCInput+INPUT]))
Start-Sleep -Milliseconds 300

# Now press F2
Write-Output "Pressing F2 on multi-selection..."
[OCInput]::SendKey(0x71)
Start-Sleep -Milliseconds 500

Capture-OCWin "09_rename_multiselection"
CleanPopup
'@

$res = Invoke-OnDefault $runnerScript
Write-Output $res
