# tools/perf/OC-RenameSuite2.ps1
. "$PSScriptRoot\SmokeTest-Helper.ps1"

$runnerScript = @'
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes, System.Drawing
Add-Type -Path "C:\desenv\utils\FilesApp\tools\perf\OCInput.cs"

# Ensure OneCommander is on C:\FilesUXLab
Start-Process "C:\Program Files\OneCommander\OneCommander.exe" -ArgumentList '"C:\FilesUXLab"'
Start-Sleep -Seconds 2

$hwnd = [IntPtr]1445996
[OCInput]::Focus($hwnd)
Start-Sleep -Milliseconds 400

$root = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
$allListItems = $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, 
    (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ClassNameProperty, "ListBoxItem")))

$fileItems = @($allListItems | Where-Object { $_.Current.BoundingRectangle.X -ge 600 -and $_.Current.BoundingRectangle.Y -ge 200 })
Write-Output "Found $($fileItems.Count) file items in list"

for ($i = 0; $i -lt $fileItems.Count; $i++) {
    $rect = $fileItems[$i].Current.BoundingRectangle
    Write-Output "Index $($i): Rect=($($rect.X),$($rect.Y),$($rect.Width),$($rect.Height))"
}

'@

$res = Invoke-OnDefault $runnerScript
Write-Output $res
