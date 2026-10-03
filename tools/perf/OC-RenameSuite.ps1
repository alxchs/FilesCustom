# tools/perf/OC-RenameSuite.ps1
. "$PSScriptRoot\SmokeTest-Helper.ps1"

$runnerScript = @'
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes, System.Drawing

$code = @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public static class OCWin32 {
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [StructLayout(LayoutKind.Sequential)] public struct INPUT { public uint type; public MOUSEKEYBDHARDWAREINPUT mkhi; }
    [StructLayout(LayoutKind.Explicit)] public struct MOUSEKEYBDHARDWAREINPUT { [FieldOffset(0)] public KEYBDINPUT ki; }
    [StructLayout(LayoutKind.Sequential)] public struct KEYBDINPUT { public ushort wVk; public ushort wScan; public uint dwFlags; public uint time; public IntPtr dwExtraInfo; }
    [DllImport("user32.dll")] public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);
    [DllImport("user32.dll")] public static extern uint MapVirtualKey(uint uCode, uint uMapType);

    public struct RECT { public int L, T, R, B; }

    public static void Focus(IntPtr hwnd) {
        IntPtr curFore = GetForegroundWindow();
        uint curPid;
        uint foreThread = GetWindowThreadProcessId(curFore, out curPid);
        uint appThread = GetCurrentThreadId();
        AttachThreadInput(appThread, foreThread, true);
        if (IsIconic(hwnd)) ShowWindow(hwnd, 9);
        ShowWindow(hwnd, 5);
        BringWindowToTop(hwnd);
        SetForegroundWindow(hwnd);
        AttachThreadInput(appThread, foreThread, false);
        System.Threading.Thread.Sleep(100);
    }

    public static void SendKey(ushort vk, uint flags = 0) {
        INPUT[] inp = new INPUT[2];
        ushort scan = (ushort)MapVirtualKey(vk, 0);
        inp[0].type = 1; inp[0].mkhi.ki.wVk = vk; inp[0].mkhi.ki.wScan = scan; inp[0].mkhi.ki.dwFlags = flags;
        inp[1].type = 1; inp[1].mkhi.ki.wVk = vk; inp[1].mkhi.ki.wScan = scan; inp[1].mkhi.ki.dwFlags = flags | 2; // KEYEVENTF_KEYUP
        SendInput(2, inp, Marshal.SizeOf(typeof(INPUT)));
    }
}
"@

if (-not ([System.Management.Automation.PSTypeName]'OCWin32').Type) {
    Add-Type -TypeDefinition $code
}

$hwnd = [IntPtr]1445996
[OCWin32]::Focus($hwnd)

$root = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
$items = $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, 
    (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ClassNameProperty, "ListBoxItem")))

$fileItems = @($items | Where-Object { $_.Current.BoundingRectangle.X -ge 600 -and $_.Current.BoundingRectangle.Y -ge 200 })
Write-Output "File items count: $($fileItems.Count)"

# Item 12 (0-indexed) is arquivo.txt
$target = $fileItems[12]
Write-Output "Target Rect: $($target.Current.BoundingRectangle)"

# Select target
$selPat = $target.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern) -as [System.Windows.Automation.SelectionItemPattern]
$selPat.Select()
Start-Sleep -Milliseconds 300

# Set focus to target element
try { $target.SetFocus() } catch {}
Start-Sleep -Milliseconds 200

# Send F2
Write-Output "Sending F2 to target..."
[OCWin32]::SendKey(0x71)
Start-Sleep -Milliseconds 500

# Capture screenshot
$rect = New-Object OCWin32+RECT
[OCWin32]::GetWindowRect($hwnd, [ref]$rect) | Out-Null
$w = $rect.R - $rect.L
$h = $rect.B - $rect.T
$outPath = "C:\desenv\utils\FilesApp\docs\ux-reference\onecommander\evidence\rename\02_rename_f2_arquivo_txt.png"
$bmp = New-Object System.Drawing.Bitmap $w, $h
$gfx = [System.Drawing.Graphics]::FromImage($bmp)
$gfx.CopyFromScreen($rect.L, $rect.T, 0, 0, (New-Object System.Drawing.Size($w, $h)))
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$gfx.Dispose()
$bmp.Dispose()
Write-Output "Saved capture to $outPath"

# Check focused element and inspect target children
$focused = [System.Windows.Automation.AutomationElement]::FocusedElement
Write-Output "Focused: Name='$($focused.Current.Name)' Class='$($focused.Current.ClassName)' ControlType='$($focused.Current.ControlType.ProgrammaticName)' Rect=$($focused.Current.BoundingRectangle)"

$targetChildren = $target.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
Write-Output "Target children count: $($targetChildren.Count)"
foreach ($tc in $targetChildren) {
    Write-Output "  [$($tc.Current.ControlType.ProgrammaticName)] Name='$($tc.Current.Name)' Class='$($tc.Current.ClassName)' Rect=$($tc.Current.BoundingRectangle)"
    $vp = $tc.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern) -as [System.Windows.Automation.ValuePattern]
    if ($vp) { Write-Output "    ValuePattern: '$($vp.Current.Value)'" }
    try {
        $tp = $tc.GetCurrentPattern([System.Windows.Automation.TextPattern]::Pattern) -as [System.Windows.Automation.TextPattern]
        if ($tp) {
            $sel = $tp.GetSelection()
            if ($sel.Length -gt 0) {
                Write-Output "    TextPattern Selection: '$($sel[0].GetText(-1))'"
            }
        }
    } catch {}
}
'@

$res = Invoke-OnDefault $runnerScript
Write-Output $res
