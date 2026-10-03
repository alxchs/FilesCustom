# tools/perf/OC-Test2.ps1
. "$PSScriptRoot\SmokeTest-Helper.ps1"

$runnerScript = @'
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes, System.Drawing

$p = Get-Process OneCommander | Select-Object -First 1
$hwnd = [IntPtr]1445996
$root = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)

# Find all ListBoxItem elements
$items = $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, 
    (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ClassNameProperty, "ListBoxItem")))


Write-Output "Total DataItems: $($items.Count)"
$targetItem = $null
$idx = 0
foreach ($it in $items) {
    if ($it.Current.ItemType -match "File" -or $it.Current.ClassName -match "ListBoxItem" -or $it.Current.BoundingRectangle.X -gt 500) {
        $idx++
        Write-Output "[$idx] Rect: $($it.Current.BoundingRectangle) Class: $($it.Current.ClassName)"
        # Check patterns
        $pats = $it.GetSupportedPatterns()
        $patNames = @()
        foreach ($pat in $pats) { $patNames += $pat.ProgrammaticName }
        Write-Output "    Patterns: $($patNames -join ', ')"
        if ($idx -eq 13) {
            $targetItem = $it
        }
    }
}

if ($targetItem) {
    Write-Output "Targeting item 13..."
    $selPat = $targetItem.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern) -as [System.Windows.Automation.SelectionItemPattern]
    if ($selPat) {
        Write-Output "Invoking SelectionItemPattern.Select()..."
        $selPat.Select()
    } else {
        Write-Output "No SelectionItemPattern"
    }
}
'@

$res = Invoke-OnDefault $runnerScript
Write-Output $res
