# tools/perf/OC-TestTarget.ps1
param([int]$ItemIndex, [string]$CaptureName)

. "$PSScriptRoot\SmokeTest-Helper.ps1"

$runnerScript = @"
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes, System.Drawing
Add-Type -Path "C:\desenv\utils\FilesApp\tools\perf\OCInput.cs"

`$hwnd = [IntPtr]1445996
[OCInput]::Focus(`$hwnd)
Start-Sleep -Milliseconds 200

# Close any open rename popup first (2x Esc)
[OCInput]::SendKey(0x1B)
Start-Sleep -Milliseconds 100
[OCInput]::SendKey(0x1B)
Start-Sleep -Milliseconds 200

`$root = [System.Windows.Automation.AutomationElement]::FromHandle(`$hwnd)
`$allListItems = `$root.FindAll([System.Windows.Automation.TreeScope]::Descendants, 
    (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ClassNameProperty, "ListBoxItem")))

`$fileItems = @(`$allListItems | Where-Object { `$_.Current.BoundingRectangle.X -ge 600 -and `$_.Current.BoundingRectangle.Y -ge 200 })

`$target = `$fileItems[$ItemIndex]
`$selPat = `$target.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern) -as [System.Windows.Automation.SelectionItemPattern]
`$selPat.Select()
Start-Sleep -Milliseconds 200

# Click on it to ensure WPF focus
`$r = `$target.Current.BoundingRectangle
[OCInput]::MouseClick(`$r.X + 80, `$r.Y + 16, `$false)
Start-Sleep -Milliseconds 250

# Press F2
[OCInput]::SendKey(0x71)
Start-Sleep -Milliseconds 400

# Inspect focused element
`$focus = [System.Windows.Automation.AutomationElement]::FocusedElement
`$docText = ""
`$selText = ""
`$val = ""

try {
    `$vp = `$focus.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern) -as [System.Windows.Automation.ValuePattern]
    if (`$vp) { `$val = `$vp.Current.Value }
} catch {}

try {
    `$tp = `$focus.GetCurrentPattern([System.Windows.Automation.TextPattern]::Pattern) -as [System.Windows.Automation.TextPattern]
    if (`$tp) {
        `$docText = `$tp.DocumentRange.GetText(-1)
        `$sel = `$tp.GetSelection()
        if (`$sel.Length -gt 0) { `$selText = `$sel[0].GetText(-1) }
    }
} catch {}

# Capture
`$rect = New-Object OCInput+RECT
[OCInput]::GetWindowRect(`$hwnd, [ref]`$rect) | Out-Null
`$w = `$rect.R - `$rect.L
`$h = `$rect.B - `$rect.T
`$outPath = "C:\desenv\utils\FilesApp\docs\ux-reference\onecommander\evidence\rename\$CaptureName.png"
`$bmp = New-Object System.Drawing.Bitmap `$w, `$h
`$gfx = [System.Drawing.Graphics]::FromImage(`$bmp)
`$gfx.CopyFromScreen(`$rect.L, `$rect.T, 0, 0, (New-Object System.Drawing.Size(`$w, `$h)))
`$bmp.Save(`$outPath, [System.Drawing.Imaging.ImageFormat]::Png)
`$gfx.Dispose()
`$bmp.Dispose()

Write-Output "RESULT|$CaptureName|Doc:`$docText|Sel:`$selText|Val:`$val"

# Clean up (close popup)
[OCInput]::SendKey(0x1B)
Start-Sleep -Milliseconds 100
[OCInput]::SendKey(0x1B)
Start-Sleep -Milliseconds 100
"@

$res = Invoke-OnDefault $runnerScript
Write-Output $res
