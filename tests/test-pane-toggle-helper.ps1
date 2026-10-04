# Test runner for InfoPaneToggleHelper (F005: AC-1 to AC-6)
# Run from repository root: pwsh -File tests/test-pane-toggle-helper.ps1

$helperPath = Join-Path $PSScriptRoot "..\src\Files.App\Helpers\InfoPaneToggleHelper.cs"
if (-not (Test-Path $helperPath)) {
    Write-Error "Helper file not found at $helperPath"
    exit 1
}

$cs = @"
#nullable enable
using System;

$(Get-Content $helperPath -Raw)

public enum MockInfoPaneTabs
{
    Details,
    Preview
}

public class PaneToggleHelperTests
{
    public static int RunAll()
    {
        var cases = new (string id, bool isOpen, MockInfoPaneTabs currentTab, MockInfoPaneTabs requestedTab, bool expOpen, MockInfoPaneTabs expTab)[]
        {
            ("AC-1", false, MockInfoPaneTabs.Details, MockInfoPaneTabs.Preview, true, MockInfoPaneTabs.Preview),
            ("AC-2", false, MockInfoPaneTabs.Preview, MockInfoPaneTabs.Details, true, MockInfoPaneTabs.Details),
            ("AC-3", true,  MockInfoPaneTabs.Details, MockInfoPaneTabs.Preview, true, MockInfoPaneTabs.Preview),
            ("AC-4", true,  MockInfoPaneTabs.Preview, MockInfoPaneTabs.Preview, false, MockInfoPaneTabs.Preview),
            ("AC-5", true,  MockInfoPaneTabs.Preview, MockInfoPaneTabs.Details, true, MockInfoPaneTabs.Details),
            ("AC-6", true,  MockInfoPaneTabs.Details, MockInfoPaneTabs.Details, false, MockInfoPaneTabs.Details)
        };

        int failed = 0;
        foreach (var c in cases)
        {
            var res = Files.App.Helpers.InfoPaneToggleHelper.Toggle(c.isOpen, c.currentTab, c.requestedTab);
            bool pass = (res.IsPaneOpen == c.expOpen) && (res.SelectedTab == c.expTab);
            if (!pass)
            {
                Console.WriteLine($"[FAIL] {c.id}: (Open={c.isOpen}, Current={c.currentTab}, Requested={c.requestedTab}) -> Result=(Open={res.IsPaneOpen}, Tab={res.SelectedTab}), Expected=(Open={c.expOpen}, Tab={c.expTab})");
                failed++;
            }
            else
            {
                Console.WriteLine($"[PASS] {c.id}: (Open={c.isOpen}, Current={c.currentTab}, Requested={c.requestedTab}) -> (Open={res.IsPaneOpen}, Tab={res.SelectedTab})");
            }
        }

        if (failed == 0)
        {
            Console.WriteLine($"\nAll {cases.Length} test cases passed successfully.");
        }
        return failed;
    }
}
"@

Add-Type -TypeDefinition $cs -Language CSharp
$res = [PaneToggleHelperTests]::RunAll()
if ($res -ne 0) {
    Write-Error "Tests failed: $res failures."
    exit 1
} else {
    exit 0
}
