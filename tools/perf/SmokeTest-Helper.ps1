# SmokeTest-Helper.ps1
# Automates interaction and visual verification of Files Dev on the Default desktop.

$code = @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public static class DesktopLauncher {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct STARTUPINFO {
        public int cb;
        public string lpReserved;
        public string lpDesktop;
        public string lpTitle;
        public int dwX;
        public int dwY;
        public int dwXSize;
        public int dwYSize;
        public int dwXCountChars;
        public int dwYCountChars;
        public int dwFillAttribute;
        public int dwFlags;
        public short wShowWindow;
        public short cbReserved2;
        public IntPtr lpReserved2;
        public IntPtr hStdInput;
        public IntPtr hStdOutput;
        public IntPtr hStdError;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct PROCESS_INFORMATION {
        public IntPtr hProcess;
        public IntPtr hThread;
        public int dwProcessId;
        public int dwThreadId;
    }

    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool CreateProcess(
        string lpApplicationName,
        string lpCommandLine,
        IntPtr lpProcessAttributes,
        IntPtr lpThreadAttributes,
        bool bInheritHandles,
        uint dwCreationFlags,
        IntPtr lpEnvironment,
        string lpCurrentDirectory,
        ref STARTUPINFO lpStartupInfo,
        out PROCESS_INFORMATION lpProcessInformation
    );

    [DllImport("kernel32.dll")] public static extern bool CloseHandle(IntPtr handle);
    [DllImport("kernel32.dll")] public static extern uint WaitForSingleObject(IntPtr hHandle, uint dwMilliseconds);

    public static int Run(string cmdLine, uint timeoutMs = 15000) {
        STARTUPINFO si = new STARTUPINFO();
        si.cb = Marshal.SizeOf(si);
        si.lpDesktop = "WinSta0\\Default";
        PROCESS_INFORMATION pi;
        bool ok = CreateProcess(null, cmdLine, IntPtr.Zero, IntPtr.Zero, false, 0, IntPtr.Zero, null, ref si, out pi);
        if (!ok) return -Marshal.GetLastWin32Error();
        WaitForSingleObject(pi.hProcess, timeoutMs);
        CloseHandle(pi.hProcess);
        CloseHandle(pi.hThread);
        return 0;
    }
}

public static class WindowCapturer {
    [DllImport("user32.dll", SetLastError = true)] public static extern bool SetProcessDpiAwarenessContext(IntPtr dpiContext);
    [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr hwnd, IntPtr hdcBlt, uint nFlags);
    [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
    public struct RECT { public int L, T, R, B; }
}
"@

if (-not ([System.Management.Automation.PSTypeName]'DesktopLauncher').Type) {
    Add-Type -TypeDefinition $code
}

Add-Type -Path (Join-Path $PSScriptRoot "vc.cs")
Add-Type -AssemblyName System.Drawing

function Invoke-OnDefault {
    param([Parameter(Mandatory=$true)][string]$PowerShellScript)
    $tmpPs1 = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetRandomFileName() + ".ps1")
    $tmpLog = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetRandomFileName() + ".log")
    $wrapped = @"
`$ProgressPreference = 'SilentlyContinue'
$PowerShellScript
"@
    [System.IO.File]::WriteAllText($tmpPs1, $wrapped, [System.Text.Encoding]::UTF8)
    $cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$tmpPs1`" > `"$tmpLog`" 2>&1"
    [DesktopLauncher]::Run("cmd.exe /c $cmd") | Out-Null
    $res = ""
    if (Test-Path $tmpLog) {
        $res = Get-Content -Raw $tmpLog
        Remove-Item $tmpLog -Force -ErrorAction SilentlyContinue
    }
    Remove-Item $tmpPs1 -Force -ErrorAction SilentlyContinue
    return $res
}

function Send-KeyToFiles {
    param(
        [Parameter(Mandatory=$true)][uint16]$Key,
        [uint16]$Mod1 = 0,
        [uint16]$Mod2 = 0,
        [int]$WaitAfterMs = 500
    )
    $script = @"
`$code = @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
public static class ForceSend {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);

    [StructLayout(LayoutKind.Sequential)] public struct INPUT { public uint type; public MOUSEKEYBDHARDWAREINPUT mkhi; }
    [StructLayout(LayoutKind.Explicit)] public struct MOUSEKEYBDHARDWAREINPUT { [FieldOffset(0)] public KEYBDINPUT ki; }
    [StructLayout(LayoutKind.Sequential)] public struct KEYBDINPUT { public ushort wVk; public ushort wScan; public uint dwFlags; public uint time; public IntPtr dwExtraInfo; }
    [DllImport("user32.dll")] public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);
    [DllImport("user32.dll")] public static extern uint MapVirtualKey(uint uCode, uint uMapType);

    public static void Focus(IntPtr hwnd) {
        IntPtr curFore = GetForegroundWindow();
        uint curPid;
        uint foreThread = GetWindowThreadProcessId(curFore, out curPid);
        uint appThread = GetCurrentThreadId();

        AttachThreadInput(appThread, foreThread, true);
        BringWindowToTop(hwnd);
        ShowWindow(hwnd, 5);
        SetForegroundWindow(hwnd);
        AttachThreadInput(appThread, foreThread, false);
        System.Threading.Thread.Sleep(200);
    }

    public static void Send(IntPtr hwnd, ushort key, ushort m1, ushort m2) {
        Focus(hwnd);
        if (m1 == 0 && m2 == 0) {
            INPUT[] inp = new INPUT[2];
            ushort s = (ushort)MapVirtualKey(key, 0);
            inp[0].type = 1; inp[0].mkhi.ki.wVk = key; inp[0].mkhi.ki.wScan = s;
            inp[1].type = 1; inp[1].mkhi.ki.wVk = key; inp[1].mkhi.ki.wScan = s; inp[1].mkhi.ki.dwFlags = 2;
            SendInput(2, inp, Marshal.SizeOf(typeof(INPUT)));
        } else if (m2 == 0) {
            INPUT[] inp = new INPUT[4];
            ushort smod = (ushort)MapVirtualKey(m1, 0);
            ushort skey = (ushort)MapVirtualKey(key, 0);
            inp[0].type = 1; inp[0].mkhi.ki.wVk = m1; inp[0].mkhi.ki.wScan = smod;
            inp[1].type = 1; inp[1].mkhi.ki.wVk = key; inp[1].mkhi.ki.wScan = skey;
            inp[2].type = 1; inp[2].mkhi.ki.wVk = key; inp[2].mkhi.ki.wScan = skey; inp[2].mkhi.ki.dwFlags = 2;
            inp[3].type = 1; inp[3].mkhi.ki.wVk = m1; inp[3].mkhi.ki.wScan = smod; inp[3].mkhi.ki.dwFlags = 2;
            SendInput(4, inp, Marshal.SizeOf(typeof(INPUT)));
        } else {
            INPUT[] inp = new INPUT[6];
            ushort s1 = (ushort)MapVirtualKey(m1, 0);
            ushort s2 = (ushort)MapVirtualKey(m2, 0);
            ushort sk = (ushort)MapVirtualKey(key, 0);
            inp[0].type = 1; inp[0].mkhi.ki.wVk = m1; inp[0].mkhi.ki.wScan = s1;
            inp[1].type = 1; inp[1].mkhi.ki.wVk = m2; inp[1].mkhi.ki.wScan = s2;
            inp[2].type = 1; inp[2].mkhi.ki.wVk = key; inp[2].mkhi.ki.wScan = sk;
            inp[3].type = 1; inp[3].mkhi.ki.wVk = key; inp[3].mkhi.ki.wScan = sk; inp[3].mkhi.ki.dwFlags = 2;
            inp[4].type = 1; inp[4].mkhi.ki.wVk = m2; inp[4].mkhi.ki.wScan = s2; inp[4].mkhi.ki.dwFlags = 2;
            inp[5].type = 1; inp[5].mkhi.ki.wVk = m1; inp[5].mkhi.ki.wScan = s1; inp[5].mkhi.ki.dwFlags = 2;
            SendInput(6, inp, Marshal.SizeOf(typeof(INPUT)));
        }
    }
}
'@
Add-Type -TypeDefinition `$code
`$p = Get-Process Files | Select-Object -First 1
`$hwnd = `$p.MainWindowHandle
if (`$hwnd -eq [IntPtr]::Zero) {
    # Enum windows on default
    `$codeEnum = @'
    using System; using System.Runtime.InteropServices;
    public class EnumW {
        [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc lpfn, IntPtr lp);
        public delegate bool EnumProc(IntPtr h, IntPtr lp);
        [DllImport("user32.dll")] public static extern int GetWindowThreadProcessId(IntPtr h, out int pid);
        [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
        [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr h, System.Text.StringBuilder s, int n);
        public static IntPtr Find(int targetPid) {
            IntPtr found = IntPtr.Zero;
            EnumWindows((h, lp) => {
                int pid; GetWindowThreadProcessId(h, out pid);
                if (pid == targetPid && IsWindowVisible(h)) {
                    var sb = new System.Text.StringBuilder(256);
                    GetWindowText(h, sb, 256);
                    if (sb.Length > 0) { found = h; return false; }
                }
                return true;
            }, IntPtr.Zero);
            return found;
        }
    }
'@
    Add-Type -TypeDefinition `$codeEnum
    `$hwnd = [EnumW]::Find(`$p.Id)
}
[ForceSend]::Send(`$hwnd, $Key, $Mod1, $Mod2)
Start-Sleep -Milliseconds $WaitAfterMs
"@
    Invoke-OnDefault -PowerShellScript $script
}

function Capture-FilesWindow {
    param(
        [Parameter(Mandatory=$true)][string]$OutFile
    )
    $p = Get-Process Files -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $p) { throw "Process Files not found" }
    $hwnd = [VC]::FindMainWindow($p.Id)
    if ($hwnd -eq [IntPtr]::Zero) { throw "Files MainWindow not found" }
    [WindowCapturer]::SetProcessDpiAwarenessContext([IntPtr](-4))
    if ([WindowCapturer]::IsIconic($hwnd)) {
        [WindowCapturer]::ShowWindow($hwnd, 9)
        Start-Sleep -Milliseconds 200
    }
    $r = New-Object WindowCapturer+RECT
    [WindowCapturer]::GetClientRect($hwnd, [ref]$r)
    $w = $r.R - $r.L
    $h = $r.B - $r.T
    if ($w -le 0 -or $h -le 0) { throw "Invalid window size: $w x $h" }

    $bmp = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $hdc = $g.GetHdc()
    [WindowCapturer]::PrintWindow($hwnd, $hdc, 2) | Out-Null
    $g.ReleaseHdc($hdc)
    $g.Dispose()

    $dir = Split-Path $OutFile
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
    $bmp.Save($OutFile, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    return $OutFile
}
