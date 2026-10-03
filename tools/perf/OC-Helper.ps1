# tools/perf/OC-Helper.ps1
. "$PSScriptRoot\SmokeTest-Helper.ps1"

$runnerScript = @'
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes, System.Drawing, System.Windows.Forms

$code = @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Collections.Generic;

public static class OCInterop {
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll", CharSet = CharSet.Auto)] public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);
    [DllImport("user32.dll", CharSet = CharSet.Auto)] public static extern int GetClassName(IntPtr hWnd, System.Text.StringBuilder lpClassName, int nMaxCount);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);
    [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr hwnd, IntPtr hdcBlt, uint nFlags);
    [DllImport("user32.dll", SetLastError = true)] public static extern bool SetProcessDpiAwarenessContext(IntPtr dpiContext);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

    public struct RECT { public int L, T, R, B; }

    public struct WinInfo {
        public IntPtr Hwnd;
        public bool Visible;
        public string ClassName;
        public string Title;
        public RECT Rect;
    }

    public static List<WinInfo> FindWindows(uint targetPid) {
        var list = new List<WinInfo>();
        EnumWindows((hwnd, lparam) => {
            uint pid;
            GetWindowThreadProcessId(hwnd, out pid);
            if (pid == targetPid) {
                var sbTitle = new System.Text.StringBuilder(256);
                GetWindowText(hwnd, sbTitle, 256);
                var sbClass = new System.Text.StringBuilder(256);
                GetClassName(hwnd, sbClass, 256);
                bool vis = IsWindowVisible(hwnd);
                RECT r;
                GetWindowRect(hwnd, out r);
                list.Add(new WinInfo {
                    Hwnd = hwnd,
                    Visible = vis,
                    ClassName = sbClass.ToString(),
                    Title = sbTitle.ToString(),
                    Rect = r
                });
            }
            return true;
        }, IntPtr.Zero);
        return list;
    }

    public static void Focus(IntPtr hwnd) {
        IntPtr curFore = GetForegroundWindow();
        uint curPid;
        uint foreThread = GetWindowThreadProcessId(curFore, out curPid);
        uint appThread = GetCurrentThreadId();

        AttachThreadInput(appThread, foreThread, true);
        if (IsIconic(hwnd)) ShowWindow(hwnd, 9); // SW_RESTORE
        ShowWindow(hwnd, 5); // SW_SHOW
        BringWindowToTop(hwnd);
        SetForegroundWindow(hwnd);
        AttachThreadInput(appThread, foreThread, false);
        System.Threading.Thread.Sleep(200);
    }
}
"@

if (-not ([System.Management.Automation.PSTypeName]'OCInterop').Type) {
    Add-Type -TypeDefinition $code
}

try { [OCInterop]::SetProcessDpiAwarenessContext([IntPtr](-4)) | Out-Null } catch {}

Write-Output "Starting OneCommander with C:\FilesUXLab..."
Start-Process "C:\Program Files\OneCommander\OneCommander.exe" -ArgumentList '"C:\FilesUXLab"'
Start-Sleep -Seconds 3

$p = Get-Process OneCommander -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $p) {
    Write-Output "OneCommander process not found"
    return
}
Write-Output "OneCommander PID: $($p.Id)"

$wins = [OCInterop]::FindWindows($p.Id)
foreach ($w in $wins) {
    Write-Output "HWND: $($w.Hwnd) | Vis: $($w.Visible) | Class: $($w.ClassName) | Title: '$($w.Title)' | Rect: ($($w.Rect.L),$($w.Rect.T))-($($w.Rect.R),$($w.Rect.B))"
}

$mainWin = $wins | Where-Object { 
    $_.ClassName -match "^HwndWrapper\[OneCommander\.exe" -and 
    $_.Title -notmatch "(MediaContext|Manager|Hidden|SystemResource)" -and
    ($_.Rect.R - $_.Rect.L) -gt 300
} | Select-Object -First 1

if (-not $mainWin) {
    $mainWin = $wins | Where-Object { 
        $_.ClassName -match "^HwndWrapper" -and 
        $_.Title -ne "" -and 
        $_.Title -notmatch "(MediaContext|Manager|Hidden|SystemResource)" 
    } | Select-Object -First 1
}

if (-not $mainWin) {
    Write-Output "Main window not found"
    return
}

Write-Output "Selected MainWin: HWND=$($mainWin.Hwnd) Title='$($mainWin.Title)'"

# Restore & set position on screen: (40, 40, 1920, 1080)
[OCInterop]::ShowWindow($mainWin.Hwnd, 9)
[OCInterop]::SetWindowPos($mainWin.Hwnd, [IntPtr]::Zero, 40, 40, 1920, 1080, 0x0040)
[OCInterop]::Focus($mainWin.Hwnd)
Start-Sleep -Milliseconds 800

# Re-read rect
$rect = New-Object OCInterop+RECT
[OCInterop]::GetWindowRect($mainWin.Hwnd, [ref]$rect) | Out-Null
$w = $rect.R - $rect.L
$h = $rect.B - $rect.T
Write-Output "Window Bounds: ($($rect.L),$($rect.T))-($($rect.R),$($rect.B)) Size: ${w}x${h}"

# Capture via CopyFromScreen
$outPath = "C:\desenv\utils\FilesApp\docs\ux-reference\onecommander\evidence\rename\01_oc_opened_lab.png"
$bmp = New-Object System.Drawing.Bitmap $w, $h
$gfx = [System.Drawing.Graphics]::FromImage($bmp)
$gfx.CopyFromScreen($rect.L, $rect.T, 0, 0, (New-Object System.Drawing.Size($w, $h)))
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$gfx.Dispose()
$bmp.Dispose()
Write-Output "Saved capture to $outPath"

# Check UI Automation
$el = [System.Windows.Automation.AutomationElement]::FromHandle($mainWin.Hwnd)
if ($el) {
    Write-Output "UIA Root: Name='$($el.Current.Name)' Class='$($el.Current.ClassName)'"
    $all = $el.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
    Write-Output "UIA Descendants: $($all.Count)"
}
'@

$res = Invoke-OnDefault $runnerScript
Write-Output $res
