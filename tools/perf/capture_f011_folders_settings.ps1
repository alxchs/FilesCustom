# capture_f011_folders_settings.ps1
# Captura de tela para F011 comprovando o seletor de Search Engine

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

$evidenceDir = "c:\desenv\utils\FilesApp\docs\agents\evidence\f011"
if (!(Test-Path $evidenceDir)) {
    New-Item -ItemType Directory -Path $evidenceDir -Force | Out-Null
}

# Inicia o app se não estiver aberto
$proc = Get-Process "Files" -ErrorAction SilentlyContinue
if (!$proc) {
    $pkg = Get-AppxPackage -Name "FilesDev"
    Start-Process "shell:AppsFolder\$($pkg.PackageFamilyName)!App"
    Start-Sleep -Seconds 5
    $proc = Get-Process "Files" -ErrorAction SilentlyContinue
}

$element = $null
foreach ($p in $proc) {
    $cond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ProcessIdProperty, $p.Id)
    $w = [System.Windows.Automation.AutomationElement]::RootElement.FindFirst([System.Windows.Automation.TreeScope]::Children, $cond)
    if ($w) {
        $element = $w
        break
    }
}

if (!$element) {
    Write-Host "Falha ao encontrar janela do Files via UIAutomation"
    exit 1
}

# Procura botão de configurações
$settingsBtn = $element.FindFirst(
    [System.Windows.Automation.TreeScope]::Descendants,
    (New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::AutomationIdProperty, "SettingsButton"))
)
if ($settingsBtn) {
    $invPattern = $settingsBtn.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
    $invPattern.Invoke()
    Start-Sleep -Seconds 2
}

# Procura aba Pastas / Folders
$foldersItem = $element.FindFirst(
    [System.Windows.Automation.TreeScope]::Descendants,
    (New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::NameProperty, "Pastas"))
)
if (!$foldersItem) {
    $foldersItem = $element.FindFirst(
        [System.Windows.Automation.TreeScope]::Descendants,
        (New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::NameProperty, "Folders"))
    )
}

if ($foldersItem) {
    $selectPattern = $foldersItem.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern)
    if ($selectPattern) {
        $selectPattern.Select()
    } else {
        $invPattern = $foldersItem.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
        if ($invPattern) { $invPattern.Invoke() }
    }
    Start-Sleep -Seconds 2
}

# Captura a janela do Files
$rect = $element.Current.BoundingRectangle
if ($rect.Width -gt 100 -and $rect.Height -gt 100) {
    $bmp = New-Object System.Drawing.Bitmap ([int]$rect.Width), ([int]$rect.Height)
    $gfx = [System.Drawing.Graphics]::FromImage($bmp)
    $gfx.CopyFromScreen([int]$rect.X, [int]$rect.Y, 0, 0, $bmp.Size)
    $capturePath = Join-Path $evidenceDir "f011_settings_search_engine.png"
    $bmp.Save($capturePath, [System.Drawing.Imaging.ImageFormat]::Png)
    $gfx.Dispose()
    $bmp.Dispose()
    Write-Host "Evidencia salva em: $capturePath"
}
