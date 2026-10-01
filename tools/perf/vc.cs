using System; using System.Diagnostics; using System.Runtime.InteropServices;
public static class VC {
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
  public static int[] Size(IntPtr h) { GetClientRect(h, out var r); return new[] { r.R - r.L, r.B - r.T }; }
  // Returns [first change ms, last change ms] after the caller's stopwatch start.
  public static double[] Watch(IntPtr h, Stopwatch sw, int timeoutMs, int quietMs) {
    GetClientRect(h, out var r); int w = r.R - r.L, ht = r.B - r.T;
    var prev = Grab(h, w, ht); double last = 0, first = -1;
    while (sw.ElapsedMilliseconds < timeoutMs) {
      var cur = Grab(h, w, ht); double t = sw.Elapsed.TotalMilliseconds;
      if (Diff(prev, cur) > 0.15) { last = t; if (first < 0) first = t; }
      prev = cur;
      if (last > 0 && t - last > quietMs) break;
    }
    return new[] { first, last }; }
  public static double GrabCostMs(IntPtr h) { var s = Stopwatch.StartNew(); var z = Size(h); for (int i = 0; i < 10; i++) Grab(h, z[0], z[1]); return s.Elapsed.TotalMilliseconds / 10; }
}
