# Abre o Files Dev com contexto de pacote correto
# Uso: .\Open-FilesDev.ps1
Remove-AppxPackage "FilesDev_4.2.9.0_x64__ykqwq8d6ps0ag" -ErrorAction SilentlyContinue
Add-AppxPackage -Register "C:\desenv\utils\FilesApp\src\Files.App\bin\x64\Release\net10.0-windows10.0.26100.0\win-x64\AppxManifest.xml"
Invoke-CommandInDesktopPackage `
    -PackageFamilyName "FilesDev_ykqwq8d6ps0ag" `
    -AppId "App" `
    -Command "Files.exe" `
    -PreventBreakaway
