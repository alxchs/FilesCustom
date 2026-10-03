# tools/perf/OC-InspectRename.ps1
. "$PSScriptRoot\SmokeTest-Helper.ps1"

$res = Invoke-OnDefault @'
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes

$focus = [System.Windows.Automation.AutomationElement]::FocusedElement
Write-Output "Focused element:"
Write-Output "  Name: '$($focus.Current.Name)'"
Write-Output "  Class: '$($focus.Current.ClassName)'"
Write-Output "  ControlType: '$($focus.Current.ControlType.ProgrammaticName)'"
Write-Output "  Rect: $($focus.Current.BoundingRectangle)"

# Check ValuePattern and TextPattern
$vp = $focus.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern) -as [System.Windows.Automation.ValuePattern]
if ($vp) {
    Write-Output "  ValuePattern.Value: '$($vp.Current.Value)'"
}

try {
    $tp = $focus.GetCurrentPattern([System.Windows.Automation.TextPattern]::Pattern) -as [System.Windows.Automation.TextPattern]
    if ($tp) {
        $sel = $tp.GetSelection()
        Write-Output "  TextPattern.DocumentRange: '$($tp.DocumentRange.GetText(-1))'"
        if ($sel.Length -gt 0) {
            Write-Output "  TextPattern.SelectedText: '$($sel[0].GetText(-1))'"
        }
    }
} catch {
    Write-Output "  TextPattern error: $_"
}

# Find all children of the parent of focused element (the rename popup container)
$parent = [System.Windows.Automation.TreeWalker]::ControlViewWalker.GetParent($focus)
if ($parent) {
    Write-Output "Parent element:"
    Write-Output "  Name: '$($parent.Current.Name)' Class: '$($parent.Current.ClassName)' ControlType: '$($parent.Current.ControlType.ProgrammaticName)'"
    $all = $parent.FindAll([System.Windows.Automation.TreeScope]::Children, [System.Windows.Automation.Condition]::TrueCondition)
    Write-Output "  Parent children count: $($all.Count)"
    foreach ($c in $all) {
        Write-Output "    Child: [$($c.Current.ControlType.ProgrammaticName)] Name='$($c.Current.Name)' Class='$($c.Current.ClassName)' Rect=$($c.Current.BoundingRectangle)"
    }
}
'@

Write-Output $res
