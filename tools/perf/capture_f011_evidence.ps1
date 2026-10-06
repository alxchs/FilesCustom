# Capture F011 Evidence
Stop-Process -Name Files -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

Write-Host "Iniciando Files Dev..."
$p = Start-Process "files-dev:" -PassThru
Start-Sleep -Seconds 5

$filesProc = Get-Process -Name Files -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1

if (-not $filesProc) {
    Write-Host "Tentando localizar janela de Files..."
    Start-Sleep -Seconds 3
    $filesProc = Get-Process -Name Files -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
}

if ($filesProc) {
    $hwnd = $filesProc.MainWindowHandle
    Write-Host "Janela localizada. HWND: $hwnd"

    Add-Type @'
    using System;
    using System.Runtime.InteropServices;
    using System.Drawing;
    using System.Drawing.Imaging;

    public class WindowCapturer {
        [DllImport("user32.dll")]
        public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

        [DllImport("user32.dll")]
        public static extern bool PrintWindow(IntPtr hWnd, IntPtr hdcBlt, uint nFlags);

        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        [StructLayout(LayoutKind.Sequential)]
        public struct RECT {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;
        }

        public static void Capture(IntPtr hwnd, string path) {
            ShowWindow(hwnd, 9); // SW_RESTORE
            RECT rc;
            GetWindowRect(hwnd, out rc);
            int width = Math.Max(rc.Right - rc.Left, 800);
            int height = Math.Max(rc.Bottom - rc.Top, 600);

            using (var bmp = new Bitmap(width, height)) {
                using (var g = Graphics.FromImage(bmp)) {
                    IntPtr hdc = g.GetHdc();
                    PrintWindow(hwnd, hdc, 2); // PW_RENDERFULLCONTENT
                    g.ReleaseHdc(hdc);
                }
                bmp.Save(path, ImageFormat.Png);
            }
        }
    }
'@

    $evidencePath = "C:\desenv\utils\FilesApp\docs\agents\evidence\f011\f011_files_running.png"
    [WindowCapturer]::Capture($hwnd, $evidencePath)
    Write-Host "Captura salva em: $evidencePath"
} else {
    Write-Host "Processo Files nao encontrou MainWindowHandle."
}
