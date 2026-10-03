# tools/perf/Test-Input.ps1
. "$PSScriptRoot\SmokeTest-Helper.ps1"

$res = Invoke-OnDefault @'
$code = @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public static class OCInput {
    [StructLayout(LayoutKind.Sequential)] public struct INPUT { public uint type; public MOUSEKEYBDHARDWAREINPUT mkhi; }
    [StructLayout(LayoutKind.Explicit)] public struct MOUSEKEYBDHARDWAREINPUT { 
        [FieldOffset(0)] public HARDWAREINPUT hi;
        [FieldOffset(0)] public KEYBDINPUT ki;
        [FieldOffset(0)] public MOUSEINPUT mi;
    }
    [StructLayout(LayoutKind.Sequential)] public struct HARDWAREINPUT { public uint uMsg; public ushort wParamL; public ushort wParamH; }
    [StructLayout(LayoutKind.Sequential)] public struct KEYBDINPUT { public ushort wVk; public ushort wScan; public uint dwFlags; public uint time; public IntPtr dwExtraInfo; }
    [StructLayout(LayoutKind.Sequential)] public struct MOUSEINPUT { public int dx; public int dy; public uint mouseData; public uint dwFlags; public uint time; public IntPtr dwExtraInfo; }
    [DllImport("user32.dll", SetLastError = true)] public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);
    [DllImport("user32.dll")] public static extern uint MapVirtualKey(uint uCode, uint uMapType);
    [DllImport("user32.dll")] public static extern int GetSystemMetrics(int nIndex);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

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

    public static void MouseClick(int x, int y, bool right = false) {
        int sw = GetSystemMetrics(0); // SM_CXSCREEN
        int sh = GetSystemMetrics(1); // SM_CYSCREEN
        int absX = (int)((double)x * 65535.0 / (sw - 1));
        int absY = (int)((double)y * 65535.0 / (sh - 1));

        uint downFlag = right ? 0x0008u : 0x0002u; // RIGHTDOWN : LEFTDOWN
        uint upFlag   = right ? 0x0010u : 0x0004u; // RIGHTUP   : LEFTUP

        INPUT[] inp = new INPUT[3];
        // Move
        inp[0].type = 0;
        inp[0].mkhi.mi.dx = absX;
        inp[0].mkhi.mi.dy = absY;
        inp[0].mkhi.mi.dwFlags = 0x0001 | 0x8000; // MOVE | ABSOLUTE

        // Down
        inp[1].type = 0;
        inp[1].mkhi.mi.dx = absX;
        inp[1].mkhi.mi.dy = absY;
        inp[1].mkhi.mi.dwFlags = 0x0001 | 0x8000 | downFlag;

        // Up
        inp[2].type = 0;
        inp[2].mkhi.mi.dx = absX;
        inp[2].mkhi.mi.dy = absY;
        inp[2].mkhi.mi.dwFlags = 0x0001 | 0x8000 | upFlag;

        SendInput(3, inp, Marshal.SizeOf(typeof(INPUT)));
    }

    public static void SendKey(ushort vk) {
        ushort scan = (ushort)MapVirtualKey(vk, 0);
        INPUT[] inp = new INPUT[2];
        inp[0].type = 1; inp[0].mkhi.ki.wVk = vk; inp[0].mkhi.ki.wScan = scan;
        inp[1].type = 1; inp[1].mkhi.ki.wVk = vk; inp[1].mkhi.ki.wScan = scan; inp[1].mkhi.ki.dwFlags = 2; // KEYUP
        SendInput(2, inp, Marshal.SizeOf(typeof(INPUT)));
    }
}
"@
Add-Type -TypeDefinition $code

$hwnd = [IntPtr]1445996
[OCInput]::Focus($hwnd)

# Click on arquivo.txt (X=700, Y=645) to focus it physically
Write-Output "Left-clicking at (700, 645)..."
[OCInput]::MouseClick(700, 645, $false)
Start-Sleep -Milliseconds 400

# Send F2
Write-Output "Sending F2..."
[OCInput]::SendKey(0x71)
Start-Sleep -Milliseconds 500

# Capture window
Add-Type -AssemblyName System.Drawing
$rect = New-Object OCInput+RECT
[OCInput]::GetWindowRect($hwnd, [ref]$rect) | Out-Null
$w = $rect.R - $rect.L
$h = $rect.B - $rect.T
$outPath = "C:\desenv\utils\FilesApp\docs\ux-reference\onecommander\evidence\rename\02_test_f2.png"
$bmp = New-Object System.Drawing.Bitmap $w, $h
$gfx = [System.Drawing.Graphics]::FromImage($bmp)
$gfx.CopyFromScreen($rect.L, $rect.T, 0, 0, (New-Object System.Drawing.Size($w, $h)))
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$gfx.Dispose()
$bmp.Dispose()
Write-Output "Saved capture to $outPath"
'@

Write-Output $res
