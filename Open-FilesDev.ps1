# Monta o layout do pacote (AppX), registra e abre o Files Dev.
#
# O Files é um app empacotado (MSIX): o Files.exe de bin\ aberto direto não tem
# identidade de pacote e morre com REGDB_E_CLASSNOTREG. O `dotnet build` só gera a
# receita do layout (Files.App.build.appxrecipe); quem copia os arquivos para AppX\
# é o deploy do Visual Studio. Este script faz essa etapa.
#
# Uso: .\Open-FilesDev.ps1 [-Configuration Release|Debug] [-NoLaunch]

param(
    [ValidateSet('Release', 'Debug')]
    [string]$Configuration = 'Release',
    [switch]$NoLaunch
)

$ErrorActionPreference = 'Stop'

$tfm = 'net10.0-windows10.0.26100.0'
$appBin = Join-Path $PSScriptRoot "src\Files.App\bin\x64\$Configuration\$tfm\win-x64"
$serverBin = Join-Path $PSScriptRoot "src\Files.App.Server\bin\x64\$Configuration\$tfm\win-x64"
$recipePath = Join-Path $appBin 'Files.App.build.appxrecipe'

if (-not (Test-Path $recipePath)) {
    throw "Receita não encontrada: $recipePath. Compile antes: mkfile $($Configuration.Substring(0,1).ToLower()) src\Files.App\Files.App.csproj"
}

[xml]$recipe = Get-Content $recipePath -Raw
$ns = @{ m = 'http://schemas.microsoft.com/developer/msbuild/2003' }
$layoutDir = (Select-Xml -Xml $recipe -Namespace $ns -XPath '//m:LayoutDir').Node.InnerText
$items = Select-Xml -Xml $recipe -Namespace $ns -XPath '//m:AppxPackagedFile | //m:AppXManifest' | ForEach-Object Node

[xml]$manifest = Get-Content (Join-Path $appBin 'AppxManifest.xml') -Raw
$identity = $manifest.Package.Identity
$appId = $manifest.Package.Applications.Application.Id

# Arquivos em uso impedem a cópia
Get-Process Files, Files.App.Server -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -and $_.Path.StartsWith($layoutDir, [StringComparison]::OrdinalIgnoreCase) } |
    Stop-Process -Force

function Copy-IfChanged([string]$source, [string]$target) {
    $dst = Get-Item -LiteralPath $target -ErrorAction SilentlyContinue
    $src = Get-Item -LiteralPath $source
    if ($dst -and $dst.Length -eq $src.Length -and $dst.LastWriteTimeUtc -eq $src.LastWriteTimeUtc) { return 0 }
    New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
    Copy-Item -LiteralPath $source -Destination $target -Force
    return 1
}

$copied = 0
$missing = @()
foreach ($item in $items) {
    if (-not (Test-Path -LiteralPath $item.Include)) { $missing += $item.Include; continue }
    $copied += Copy-IfChanged $item.Include (Join-Path $layoutDir $item.PackagePath)
}
if ($missing) { throw "Arquivos da receita ausentes ($($missing.Count)), recompile. Primeiro: $($missing[0])" }

# Servidor COM fora de processo declarado no manifesto (Files.App.Server\Files.App.Server.exe);
# não é ProjectReference, então não entra na receita.
if (-not (Test-Path (Join-Path $serverBin 'Files.App.Server.exe'))) { throw "Files.App.Server não compilado: $serverBin" }
Get-ChildItem $serverBin -File -Recurse | ForEach-Object {
    $copied += Copy-IfChanged $_.FullName (Join-Path $layoutDir ('Files.App.Server' + $_.FullName.Substring($serverBin.Length)))
}
Write-Host "Layout: $layoutDir ($($items.Count) itens da receita, $copied copiados)"

# Registro de desenvolvimento (pasta solta). Precisa do Modo de Desenvolvedor do Windows.
$layoutManifest = Join-Path $layoutDir 'AppxManifest.xml'
$installed = Get-AppxPackage -Name $identity.Name
if ($installed -and $installed.InstallLocation -ne $layoutDir) {
    Remove-AppxPackage $installed.PackageFullName -PreserveApplicationData
}
Add-AppxPackage -Register $layoutManifest -ForceApplicationShutdown -ForceUpdateFromAnyVersion
$package = Get-AppxPackage -Name $identity.Name
Write-Host "Registrado: $($package.PackageFullName) -> $($package.InstallLocation)"

if (-not $NoLaunch) {
    Start-Process "shell:AppsFolder\$($package.PackageFamilyName)!$appId"
}
