# Deploy and verify F011
Stop-Process -Name Files -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

$manifest = "C:\desenv\utils\FilesApp\src\Files.App\bin\x64\Release\net10.0-windows10.0.26100.0\win-x64\AppxManifest.xml"
Write-Host "Registrando pacote dev..."
Add-AppxPackage -Register $manifest

Write-Host "Pacote registrado com sucesso!"
