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

        uint downFlag = right ? 0x0008u : 0x0002u;
        uint upFlag   = right ? 0x0010u : 0x0004u;

        INPUT[] inp = new INPUT[3];
        inp[0].type = 0;
        inp[0].mkhi.mi.dx = absX;
        inp[0].mkhi.mi.dy = absY;
        inp[0].mkhi.mi.dwFlags = 0x0001 | 0x8000;

        inp[1].type = 0;
        inp[1].mkhi.mi.dx = absX;
        inp[1].mkhi.mi.dy = absY;
        inp[1].mkhi.mi.dwFlags = 0x0001 | 0x8000 | downFlag;

        inp[2].type = 0;
        inp[2].mkhi.mi.dx = absX;
        inp[2].mkhi.mi.dy = absY;
        inp[2].mkhi.mi.dwFlags = 0x0001 | 0x8000 | upFlag;

        SendInput(3, inp, Marshal.SizeOf(typeof(INPUT)));
    }

    public static void SendKey(ushort vk, uint flags = 0) {
        ushort scan = (ushort)MapVirtualKey(vk, 0);
        INPUT[] inp = new INPUT[2];
        inp[0].type = 1; inp[0].mkhi.ki.wVk = vk; inp[0].mkhi.ki.wScan = scan; inp[0].mkhi.ki.dwFlags = flags;
        inp[1].type = 1; inp[1].mkhi.ki.wVk = vk; inp[1].mkhi.ki.wScan = scan; inp[1].mkhi.ki.dwFlags = flags | 2;
        SendInput(2, inp, Marshal.SizeOf(typeof(INPUT)));
    }

    public static void SendModifiedKey(ushort modVk, ushort vk) {
        ushort modScan = (ushort)MapVirtualKey(modVk, 0);
        ushort scan = (ushort)MapVirtualKey(vk, 0);
        INPUT[] inp = new INPUT[4];
        inp[0].type = 1; inp[0].mkhi.ki.wVk = modVk; inp[0].mkhi.ki.wScan = modScan;
        inp[1].type = 1; inp[1].mkhi.ki.wVk = vk; inp[1].mkhi.ki.wScan = scan;
        inp[2].type = 1; inp[2].mkhi.ki.wVk = vk; inp[2].mkhi.ki.wScan = scan; inp[2].mkhi.ki.dwFlags = 2;
        inp[3].type = 1; inp[3].mkhi.ki.wVk = modVk; inp[3].mkhi.ki.wScan = modScan; inp[3].mkhi.ki.dwFlags = 2;
        SendInput(4, inp, Marshal.SizeOf(typeof(INPUT)));
    }
}
