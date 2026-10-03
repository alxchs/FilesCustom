# tools/perf/OC-RunEdgeCases.ps1
. "$PSScriptRoot\SmokeTest-Helper.ps1"

$runnerScript = @'
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes, System.Drawing
Add-Type -Path "C:\desenv\utils\FilesApp\tools\perf\OCInput.cs"

$hwnd = [IntPtr]1445996
[OCInput]::Focus($hwnd)
Start-Sleep -Milliseconds 400

$root = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
$allListItems = $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, 
    (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ClassNameProperty, "ListBoxItem")))

$fileItems = @($allListItems | Where-Object { $_.Current.BoundingRectangle.X -ge 600 -and $_.Current.BoundingRectangle.Y -ge 200 })

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
    return $outPath
}

$tests = @(
    @{ Index = 0;  Name = "Folder A";              File = "edge_folder_a" },
    @{ Index = 4;  Name = ".gitignore";            File = "edge_gitignore" },
    @{ Index = 6;  Name = "arquivo (no ext)";      File = "edge_arquivo_noext" },
    @{ Index = 7;  Name = "arquivo final 01.txt";  File = "edge_spaces" },
    @{ Index = 8;  Name = "arquivo.";              File = "edge_dot_end" },
    @{ Index = 9;  Name = "arquivo.final.txt";     File = "edge_dot_middle" },
    @{ Index = 10; Name = "arquivo.md";            File = "edge_arquivo_md" },
    @{ Index = 11; Name = "arquivo.tar.gz";        File = "edge_tar_gz" },
    @{ Index = 12; Name = "arquivo.txt";           File = "edge_arquivo_txt" }
)

$results = @()

foreach ($t in $tests) {
    $item = $fileItems[$t.Index]
    $r = $item.Current.BoundingRectangle
    $clickX = $r.X + 80
    $clickY = $r.Y + 16

    Write-Output "--- Testing $($t.Name) at ($clickX, $clickY) ---"
    [OCInput]::MouseClick($clickX, $clickY, $false)
    Start-Sleep -Milliseconds 250

    # Send F2
    [OCInput]::SendKey(0x71)
    Start-Sleep -Milliseconds 400

    # Inspect focused element
    $focus = [System.Windows.Automation.AutomationElement]::FocusedElement
    $val = ""
    $selText = ""
    $docText = ""
    try {
        $vp = $focus.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern) -as [System.Windows.Automation.ValuePattern]
        if ($vp) { $val = $vp.Current.Value }
    } catch {}

    try {
        $tp = $focus.GetCurrentPattern([System.Windows.Automation.TextPattern]::Pattern) -as [System.Windows.Automation.TextPattern]
        if ($tp) {
            $docText = $tp.DocumentRange.GetText(-1)
            $sel = $tp.GetSelection()
            if ($sel.Length -gt 0) { $selText = $sel[0].GetText(-1) }
        }
    } catch {}

    $cap = Capture-OCWin $t.File
    Write-Output "Captured to $cap"
    Write-Output "  DocText:  '$docText'"
    Write-Output "  Selected: '$selText'"
    Write-Output "  Value:    '$val'"

    $results += [PSCustomObject]@{
        TargetName = $t.Name
        DocText    = $docText
        Selected   = $selText
        Value      = $val
        Capture    = $t.File
    }

    # Cancel rename with Esc
    [OCInput]::SendKey(0x1B) # VK_ESCAPE
    Start-Sleep -Milliseconds 300
}

Write-Output "=== SUMMARY RESULTS ==="
$results | Format-Table -AutoSize
'@

$res = Invoke-OnDefault $runnerScript
Write-Output $res
