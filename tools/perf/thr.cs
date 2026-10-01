using System; using System.Collections.Generic; using System.Diagnostics; using System.Runtime.InteropServices; using System.Text;
public static class Thr {
  [DllImport("kernel32.dll")] static extern IntPtr OpenThread(int acc, bool inh, int id);
  [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr h);
  [DllImport("kernel32.dll")] static extern bool GetThreadTimes(IntPtr h, out long c, out long e, out long k, out long u);
  [DllImport("kernel32.dll", CharSet=CharSet.Unicode)] static extern int GetThreadDescription(IntPtr h, out IntPtr d);
  [DllImport("kernel32.dll")] static extern IntPtr LocalFree(IntPtr p);
  [DllImport("ntdll.dll")] static extern int NtQueryInformationThread(IntPtr h, int cls, out IntPtr info, int len, IntPtr ret);
  [DllImport("user32.dll")] static extern int GetWindowThreadProcessId(IntPtr h, out int pid);
  public static int UiThread(IntPtr hwnd) { return GetWindowThreadProcessId(hwnd, out _); }
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
