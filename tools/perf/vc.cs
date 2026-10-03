using System; using System.Diagnostics; using System.Runtime.InteropServices; using System.Text; using System.Threading;
public static class VC {
  [DllImport("user32.dll", SetLastError = true)] static extern IntPtr OpenDesktop(string lpszDesktop, uint dwFlags, bool fInherit, uint dwDesiredAccess);
  [DllImport("user32.dll", SetLastError = true)] static extern bool SetThreadDesktop(IntPtr hDesktop);
  [DllImport("user32.dll", SetLastError = true)] static extern bool CloseDesktop(IntPtr hDesktop);
  [DllImport("user32.dll")] static extern bool EnumDesktopWindows(IntPtr hDesktop, EnumWindowsProc lpfn, IntPtr lParam);
  delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
  [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr hWnd);
  [DllImport("user32.dll")] static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
  [DllImport("user32.dll")] static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);
  [DllImport("user32.dll")] static extern int GetWindowThreadProcessId(IntPtr hWnd, out int pid);
  [DllImport("user32.dll")] static extern bool GetClientRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] static extern bool PrintWindow(IntPtr h, IntPtr dc, uint f);
  [DllImport("user32.dll")] static extern IntPtr GetDC(IntPtr h);
  [DllImport("user32.dll")] static extern int ReleaseDC(IntPtr h, IntPtr dc);
  [DllImport("gdi32.dll")] static extern IntPtr CreateCompatibleDC(IntPtr dc);
  [DllImport("gdi32.dll")] static extern IntPtr CreateCompatibleBitmap(IntPtr dc, int w, int h);
  [DllImport("gdi32.dll")] static extern IntPtr SelectObject(IntPtr dc, IntPtr o);
  [DllImport("gdi32.dll")] static extern bool DeleteObject(IntPtr o);
  [DllImport("gdi32.dll")] static extern bool DeleteDC(IntPtr dc);
  [DllImport("gdi32.dll")] static extern bool StretchBlt(IntPtr d, int x, int y, int w, int h, IntPtr s, int sx, int sy, int sw, int sh, int rop);
  [DllImport("gdi32.dll")] static extern int SetStretchBltMode(IntPtr dc, int m);
  [DllImport("gdi32.dll")] static extern int GetDIBits(IntPtr dc, IntPtr bmp, uint start, uint lines, byte[] bits, ref BITMAPINFOHEADER bi, uint usage);
  public struct RECT { public int L,T,R,B; }
  [StructLayout(LayoutKind.Sequential)] public struct BITMAPINFOHEADER { public int biSize, biWidth, biHeight; public short biPlanes, biBitCount; public int biCompression, biSizeImage, biXPelsPerMeter, biYPelsPerMeter, biClrUsed, biClrImportant; }

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
            var sbc = new StringBuilder(256);
            GetClassName(hwnd, sbc, 256);
            if (sbc.ToString() == "WinUIDesktopWin32WindowClass") {
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

  static byte[] Grab(IntPtr h, int w, int ht) {
    int sw = w / 6, sh = ht / 6;
    IntPtr screen = GetDC(IntPtr.Zero), big = CreateCompatibleDC(screen), small = CreateCompatibleDC(screen);
    IntPtr bigBmp = CreateCompatibleBitmap(screen, w, ht), smallBmp = CreateCompatibleBitmap(screen, sw, sh);
    IntPtr ob = SelectObject(big, bigBmp), os = SelectObject(small, smallBmp);
    PrintWindow(h, big, 3);
    SetStretchBltMode(small, 4); StretchBlt(small, 0, 0, sw, sh, big, 0, 0, w, ht, 0x00CC0020);
    SelectObject(small, os);
    var bi = new BITMAPINFOHEADER { biSize = 40, biWidth = sw, biHeight = -sh, biPlanes = 1, biBitCount = 32 };
    var buf = new byte[sw * sh * 4]; GetDIBits(small, smallBmp, 0, (uint)sh, buf, ref bi, 0);
    SelectObject(big, ob); DeleteObject(bigBmp); DeleteObject(smallBmp); DeleteDC(big); DeleteDC(small); ReleaseDC(IntPtr.Zero, screen);
    return buf; }
  static double Diff(byte[] a, byte[] b) { long s = 0; for (int i = 0; i < a.Length; i++) s += Math.Abs(a[i] - b[i]); return (double)s / a.Length; }
  public static int[] Size(IntPtr h) {
    int[] s = null;
    var t = new Thread(() => {
      IntPtr hDesk = OpenDesktop("Default", 0, false, 0x01FF);
      if (hDesk != IntPtr.Zero) SetThreadDesktop(hDesk);
      RECT r; GetClientRect(h, out r);
      if (hDesk != IntPtr.Zero) CloseDesktop(hDesk);
      s = new[] { r.R - r.L, r.B - r.T };
    });
    t.Start();
    t.Join();
    return s;
  }
  // Returns [first change ms, last change ms] after the caller's stopwatch start.
  public static double[] Watch(IntPtr h, Stopwatch sw, int timeoutMs, int quietMs) {
    double[] res = null;
    var t = new Thread(() => {
      IntPtr hDesk = OpenDesktop("Default", 0, false, 0x01FF);
      if (hDesk != IntPtr.Zero) SetThreadDesktop(hDesk);
      RECT r; GetClientRect(h, out r); int w = r.R - r.L, ht = r.B - r.T;
      var prev = Grab(h, w, ht); double last = 0, first = -1;
      while (sw.ElapsedMilliseconds < timeoutMs) {
        var cur = Grab(h, w, ht); double elapsed = sw.Elapsed.TotalMilliseconds;
        if (Diff(prev, cur) > 0.15) { last = elapsed; if (first < 0) first = elapsed; }
        prev = cur;
        if (last > 0 && elapsed - last > quietMs) break;
      }
      if (hDesk != IntPtr.Zero) CloseDesktop(hDesk);
      res = new[] { first, last };
    });
    t.SetApartmentState(ApartmentState.STA);
    t.Start();
    t.Join();
    return res;
  }
  public static double GrabCostMs(IntPtr h) {
    double cost = 0;
    var t = new Thread(() => {
      IntPtr hDesk = OpenDesktop("Default", 0, false, 0x01FF);
      if (hDesk != IntPtr.Zero) SetThreadDesktop(hDesk);
      RECT r; GetClientRect(h, out r); int w = r.R - r.L, ht = r.B - r.T;
      var s = Stopwatch.StartNew();
      for (int i = 0; i < 10; i++) Grab(h, w, ht);
      cost = s.Elapsed.TotalMilliseconds / 10;
      if (hDesk != IntPtr.Zero) CloseDesktop(hDesk);
    });
    t.SetApartmentState(ApartmentState.STA);
    t.Start();
    t.Join();
    return cost;
  }
}
