# tools/perf/OC-InspectWarning.ps1
. "$PSScriptRoot\SmokeTest-Helper.ps1"

$res = Invoke-OnDefault @'
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes

$dialog = [System.Windows.Automation.AutomationElement]::RootElement.FindFirst([System.Windows.Automation.TreeScope]::Children,
    (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, "Warning!")))

if (-not $dialog) {
    # Check any window with Warning in title
    $dialog = [System.Windows.Automation.AutomationElement]::RootElement.FindFirst([System.Windows.Automation.TreeScope]::Children,
        (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ClassNameProperty, "Window")))
}

if ($dialog) {
    Write-Output "Dialog: Name='$($dialog.Current.Name)' Class='$($dialog.Current.ClassName)' Rect=$($dialog.Current.BoundingRectangle)"
    $all = $dialog.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
    foreach ($c in $all) {
        if ($c.Current.ControlType.ProgrammaticName -match "(Button|Text|Edit)") {
            Write-Output "  [$($c.Current.ControlType.ProgrammaticName)] Name='$($c.Current.Name)' Class='$($c.Current.ClassName)' Rect=$($c.Current.BoundingRectangle)"
        }
    }
} else {
    Write-Output "Warning window not found"
}
'@

Write-Output $res
