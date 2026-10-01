# Cria as pastas de medição em C:\FilesUXLab\perf (MASTER_SPEC §17).
param([string]$Base = 'C:\FilesUXLab\perf')

$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force "$Base\10k", "$Base\img400" | Out-Null

$exts = 'txt', 'md', 'json', 'cs', 'log', 'csv', 'xml', 'pdf', 'docx', 'zip'
for ($i = 1; $i -le 10000; $i++) {
    [IO.File]::WriteAllText(("{0}\10k\file_{1:D5}.{2}" -f $Base, $i, $exts[$i % 10]), "item $i")
}

Add-Type -AssemblyName System.Drawing
for ($i = 1; $i -le 400; $i++) {
    $bmp = New-Object Drawing.Bitmap 800, 600
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.Clear([Drawing.Color]::FromArgb(($i * 37) % 256, ($i * 91) % 256, ($i * 53) % 256))
    $g.DrawString("$i", (New-Object Drawing.Font 'Arial', 120), [Drawing.Brushes]::White, 200, 200)
    $bmp.Save(("{0}\img400\img_{1:D3}.jpg" -f $Base, $i), [Drawing.Imaging.ImageFormat]::Jpeg)
    $g.Dispose(); $bmp.Dispose()
}
