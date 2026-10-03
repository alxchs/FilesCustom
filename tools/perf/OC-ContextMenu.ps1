# tools/perf/OC-ContextMenu.ps1
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

    public const uint MOUSEEVENTF_RIGHTDOWN = 0x0008;
    public const uint MOUSEEVENTF_RIGHTUP   = 0x0010;

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

    public static void RightClickAt(int x, int y) {
        SetCursorPos(x, y);
        System.Threading.Thread.Sleep(50);
        mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, UIntPtr.Zero);
        System.Threading.Thread.Sleep(50);
        mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, UIntPtr.Zero);
    }
}
"@

if (-not ([System.Management.Automation.PSTypeName]'OCWin32').Type) {
    Add-Type -TypeDefinition $code
}

$hwnd = [IntPtr]1445996
[OCWin32]::Focus($hwnd)

# Right click on arquivo.txt (X=650, Y=645)
Write-Output "Right clicking on arquivo.txt..."
[OCWin32]::RightClickAt(650, 645)
Start-Sleep -Milliseconds 600

# Capture screenshot with context menu
$rect = New-Object OCWin32+RECT
[OCWin32]::GetWindowRect($hwnd, [ref]$rect) | Out-Null
$w = $rect.R - $rect.L
$h = $rect.B - $rect.T
$outPath = "C:\desenv\utils\FilesApp\docs\ux-reference\onecommander\evidence\rename\02_context_menu.png"
$bmp = New-Object System.Drawing.Bitmap $w, $h
$gfx = [System.Drawing.Graphics]::FromImage($bmp)
$gfx.CopyFromScreen($rect.L, $rect.T, 0, 0, (New-Object System.Drawing.Size($w, $h)))
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$gfx.Dispose()
$bmp.Dispose()
Write-Output "Saved context menu capture to $outPath"

# Find context menu items
$menu = [System.Windows.Automation.AutomationElement]::RootElement.FindFirst([System.Windows.Automation.TreeScope]::Children,
    (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::Menu)))

if (-not $menu) {
    # Check Window with Menu
    $menu = [System.Windows.Automation.AutomationElement]::RootElement.FindFirst([System.Windows.Automation.TreeScope]::Children,
        (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ClassNameProperty, "ContextMenu")))
}

if ($menu) {
    Write-Output "Context menu found: $($menu.Current.Name)"
    $mis = $menu.FindAll([System.Windows.Automation.TreeScope]::Descendants, 
        (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::MenuItem)))
    foreach ($m in $mis) {
        Write-Output "MenuItem: '$($m.Current.Name)' | AccessKey: '$($m.Current.AccessKey)' | Accelerator: '$($m.Current.AcceleratorKey)'"
    }
}
'@

$res = Invoke-OnDefault $runnerScript
Write-Output $res
