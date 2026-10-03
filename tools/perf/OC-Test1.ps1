# tools/perf/OC-Test1.ps1
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
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int X, int Y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint dwFlags, int dx, int dy, uint dwData, UIntPtr dwExtraInfo);

    public const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
    public const uint MOUSEEVENTF_LEFTUP = 0x0004;

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
        inp[1].type = 1; inp[1].mkhi.ki.wVk = vk; inp[1].mkhi.ki.wScan = scan; inp[1].mkhi.ki.dwFlags = flags | 2;
        SendInput(2, inp, Marshal.SizeOf(typeof(INPUT)));
    }

    public static void ClickAt(int x, int y) {
        SetCursorPos(x, y);
        System.Threading.Thread.Sleep(50);
        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, UIntPtr.Zero);
        System.Threading.Thread.Sleep(50);
        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, UIntPtr.Zero);
    }
}
"@

if (-not ([System.Management.Automation.PSTypeName]'OCWin32').Type) {
    Add-Type -TypeDefinition $code
}

$hwnd = [IntPtr]1445996
[OCWin32]::Focus($hwnd)
Start-Sleep -Milliseconds 300

# Click on arquivo.txt (X=650, Y=645)
Write-Output "Clicking on arquivo.txt..."
[OCWin32]::ClickAt(650, 645)
Start-Sleep -Milliseconds 400

# Press F2
Write-Output "Pressing F2..."
[OCWin32]::SendKey(0x71) # VK_F2
Start-Sleep -Milliseconds 500

# Capture window
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

# Check focused element and Edit controls
$focus = [System.Windows.Automation.AutomationElement]::FocusedElement
if ($focus) {
    Write-Output "Focused: Name='$($focus.Current.Name)' Class='$($focus.Current.ClassName)' ControlType='$($focus.Current.ControlType.ProgrammaticName)' Rect=$([string]$focus.Current.BoundingRectangle)"
    
    # Try TextPattern or ValuePattern
    $valPat = $focus.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern) -as [System.Windows.Automation.ValuePattern]
    if ($valPat) {
        Write-Output "ValuePattern.Value: '$($valPat.Current.Value)'"
    }
    try {
        $textPat = $focus.GetCurrentPattern([System.Windows.Automation.TextPattern]::Pattern) -as [System.Windows.Automation.TextPattern]
        if ($textPat) {
            $sel = $textPat.GetSelection()
            if ($sel.Length -gt 0) {
                Write-Output "TextPattern.Selection: '$($sel[0].GetText(-1))'"
            }
        }
    } catch {}
}

# Also search all Edit controls in root
$root = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
$edits = $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, 
    (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::Edit)))
Write-Output "Edit controls count: $($edits.Count)"
foreach ($ed in $edits) {
    Write-Output "Edit: Name='$($ed.Current.Name)' Class='$($ed.Current.ClassName)' Rect=$([string]$ed.Current.BoundingRectangle)"
    $vp = $ed.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern) -as [System.Windows.Automation.ValuePattern]
    if ($vp) { Write-Output "  Value: '$($vp.Current.Value)'" }
}
'@

$res = Invoke-OnDefault $runnerScript
Write-Output $res
