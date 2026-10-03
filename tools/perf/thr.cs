using System; using System.Collections.Generic; using System.Diagnostics; using System.Runtime.InteropServices; using System.Text; using System.Threading;
public static class Thr {
  [DllImport("kernel32.dll")] static extern IntPtr OpenThread(int acc, bool inh, int id);
  [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr h);
  [DllImport("kernel32.dll")] static extern bool GetThreadTimes(IntPtr h, out long c, out long e, out long k, out long u);
  [DllImport("kernel32.dll", CharSet=CharSet.Unicode)] static extern int GetThreadDescription(IntPtr h, out IntPtr d);
  [DllImport("kernel32.dll")] static extern IntPtr LocalFree(IntPtr p);
  [DllImport("ntdll.dll")] static extern int NtQueryInformationThread(IntPtr h, int cls, out IntPtr info, int len, IntPtr ret);
  [DllImport("user32.dll")] static extern int GetWindowThreadProcessId(IntPtr h, out int pid);
  [DllImport("user32.dll", SetLastError = true)] static extern IntPtr OpenDesktop(string lpszDesktop, uint dwFlags, bool fInherit, uint dwDesiredAccess);
  [DllImport("user32.dll", SetLastError = true)] static extern bool SetThreadDesktop(IntPtr hDesktop);
  [DllImport("user32.dll", SetLastError = true)] static extern bool CloseDesktop(IntPtr hDesktop);
  [DllImport("user32.dll")] static extern bool EnumDesktopWindows(IntPtr hDesktop, EnumWindowsProc lpfn, IntPtr lParam);
  delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
  [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr hWnd);
  [DllImport("user32.dll")] static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

  public static IntPtr FindMainWindow(int pid) {
    IntPtr result = IntPtr.Zero;
    var t = new Thread(() => {
      IntPtr hDesk = OpenDesktop("Default", 0, false, 0x01FF);
      if (hDesk != IntPtr.Zero) {
        SetThreadDesktop(hDesk);
        EnumDesktopWindows(hDesk, (hwnd, lparam) => {
          int p;
          GetWindowThreadProcessId(hwnd, out p);
          if (p == pid && IsWindowVisible(hwnd)) {
            var sb = new StringBuilder(256);
            GetWindowText(hwnd, sb, 256);
            if (sb.Length > 0) {
              result = hwnd;
              return false;
            }
          }
          return true;
        }, IntPtr.Zero);
        CloseDesktop(hDesk);
      }
    });
    t.Start();
    t.Join();
    return result;
  }

  public static string WindowTitle(IntPtr hwnd) {
    string title = "";
    var t = new Thread(() => {
      IntPtr hDesk = OpenDesktop("Default", 0, false, 0x01FF);
      if (hDesk != IntPtr.Zero) {
        SetThreadDesktop(hDesk);
        var sb = new StringBuilder(256);
        GetWindowText(hwnd, sb, 256);
        title = sb.ToString();
        CloseDesktop(hDesk);
      }
    });
    t.Start();
    t.Join();
    return title;
  }

  public static int UiThread(IntPtr hwnd) {
    int tid = 0;
    var t = new Thread(() => {
      IntPtr hDesk = OpenDesktop("Default", 0, false, 0x01FF);
      if (hDesk != IntPtr.Zero) {
        SetThreadDesktop(hDesk);
        tid = GetWindowThreadProcessId(hwnd, out _);
        CloseDesktop(hDesk);
      }
    });
    t.Start();
    t.Join();
    return tid != 0 ? tid : GetWindowThreadProcessId(hwnd, out _);
  }

  public class Info { public int Id; public long Cpu100ns; public string Desc; public long Start; }
  public static Dictionary<int, Info> Snap(int pid) {
    var d = new Dictionary<int, Info>();
    foreach (ProcessThread t in Process.GetProcessById(pid).Threads) {
      IntPtr h = OpenThread(0x0800 | 0x0040, false, t.Id); if (h == IntPtr.Zero) continue;
      GetThreadTimes(h, out _, out _, out long k, out long u);
      string desc = ""; if (GetThreadDescription(h, out IntPtr p) >= 0 && p != IntPtr.Zero) { desc = Marshal.PtrToStringUni(p); LocalFree(p); }
      NtQueryInformationThread(h, 9, out IntPtr start, IntPtr.Size, IntPtr.Zero);
      d[t.Id] = new Info { Id = t.Id, Cpu100ns = k + u, Desc = desc, Start = start.ToInt64() };
      CloseHandle(h); }
    return d; }
  public static string ModuleOf(int pid, long addr) {
    foreach (ProcessModule m in Process.GetProcessById(pid).Modules) { long b = m.BaseAddress.ToInt64(); if (addr >= b && addr < b + m.ModuleMemorySize) return m.ModuleName; }
    return "?"; }
}
