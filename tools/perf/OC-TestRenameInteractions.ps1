# tools/perf/OC-TestRenameInteractions.ps1
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

function OpenRenameOn($idx) {
    CleanPopup
    $root = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
    $all = $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, 
        (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ClassNameProperty, "ListBoxItem")))
    $items = @($all | Where-Object { $_.Current.BoundingRectangle.X -ge 600 -and $_.Current.BoundingRectangle.Y -ge 200 })
    $t = $items[$idx]
    $selPat = $t.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern) -as [System.Windows.Automation.SelectionItemPattern]
    $selPat.Select()
    Start-Sleep -Milliseconds 150
    $r = $t.Current.BoundingRectangle
    [OCInput]::MouseClick($r.X + 80, $r.Y + 16, $false)
    Start-Sleep -Milliseconds 200
    [OCInput]::SendKey(0x71) # F2
    Start-Sleep -Milliseconds 400
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

# --- TEST A: Tab key in rename mode ---
Write-Output "=== TEST A: Tab key ==="
OpenRenameOn 12 # arquivo.txt
$focus1 = [System.Windows.Automation.AutomationElement]::FocusedElement
Write-Output "Before Tab - Focus: Class='$($focus1.Current.ClassName)' ControlType='$($focus1.Current.ControlType.ProgrammaticName)'"

# Send Tab (VK_TAB = 0x09)
Write-Output "Sending Tab..."
[OCInput]::SendKey(0x09)
Start-Sleep -Milliseconds 300
$focus2 = [System.Windows.Automation.AutomationElement]::FocusedElement
Write-Output "After Tab - Focus: Name='$($focus2.Current.Name)' Class='$($focus2.Current.ClassName)' ControlType='$($focus2.Current.ControlType.ProgrammaticName)'"
Capture-OCWin "04_rename_after_tab"

# --- TEST B: Caret navigation and Extension change ---
Write-Output "=== TEST B: Caret & Extension Editing ==="
OpenRenameOn 5 # activate_test.txt
$focusB = [System.Windows.Automation.AutomationElement]::FocusedElement
$tpB = $focusB.GetCurrentPattern([System.Windows.Automation.TextPattern]::Pattern) -as [System.Windows.Automation.TextPattern]
Write-Output "Initial Text: '$($tpB.DocumentRange.GetText(-1))' | Selected: '$($tpB.GetSelection()[0].GetText(-1))'"

# Press Right Arrow (VK_RIGHT = 0x27)
Write-Output "Sending VK_RIGHT..."
[OCInput]::SendKey(0x27)
Start-Sleep -Milliseconds 150
Write-Output "Selection after Right Arrow: '$($tpB.GetSelection()[0].GetText(-1))'"

# Press Right Arrow again
[OCInput]::SendKey(0x27)
Start-Sleep -Milliseconds 150
Write-Output "Selection after 2nd Right Arrow: '$($tpB.GetSelection()[0].GetText(-1))'"

# Press End key
[OCInput]::SendKey(0x23)
Start-Sleep -Milliseconds 150
Write-Output "Selection after End: '$($tpB.GetSelection()[0].GetText(-1))'"

# Backspace 4 times to delete .txt
[OCInput]::SendKey(0x08); Start-Sleep -Milliseconds 50
[OCInput]::SendKey(0x08); Start-Sleep -Milliseconds 50
[OCInput]::SendKey(0x08); Start-Sleep -Milliseconds 50
[OCInput]::SendKey(0x08); Start-Sleep -Milliseconds 50
Write-Output "Text after 4 Backspaces: '$($tpB.DocumentRange.GetText(-1))'"

# Type '.log'
[OCInput]::SendKey(0xBE) # .
Start-Sleep -Milliseconds 50
[OCInput]::SendKey(0x4C) # L
Start-Sleep -Milliseconds 50
[OCInput]::SendKey(0x4F) # O
Start-Sleep -Milliseconds 50
[OCInput]::SendKey(0x47) # G
Start-Sleep -Milliseconds 200
Write-Output "Text after typing .log: '$($tpB.DocumentRange.GetText(-1))'"
Capture-OCWin "05_rename_ext_changed_to_log"

# Press Enter to commit extension change
Write-Output "Sending Enter (VK_RETURN = 0x0D)..."
[OCInput]::SendKey(0x0D)
Start-Sleep -Milliseconds 500

Capture-OCWin "06_rename_after_enter_extension"

# Check if a dialog appeared or if it renamed
$dialog = [System.Windows.Automation.AutomationElement]::RootElement.FindFirst([System.Windows.Automation.TreeScope]::Children,
    (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::Window)))
Write-Output "Top Window after rename: '$($dialog.Current.Name)' Class='$($dialog.Current.ClassName)'"

CleanPopup
'@

$res = Invoke-OnDefault $runnerScript
Write-Output $res
