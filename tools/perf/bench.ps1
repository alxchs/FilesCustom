param([int]$Runs = 3, [int]$TimeoutMs = 10000, [int]$QuietMs = 1500)
$ErrorActionPreference = "Stop"
Add-Type -Path (Join-Path $PSScriptRoot "vc.cs")
$apps = @(
  @{ Name='Files'; Proc='Files'; Exe='files-dev.exe' },
  @{ Name='OneCommander'; Proc='OneCommander'; Exe='C:\Program Files\OneCommander\OneCommander.exe' })
$folders = 'C:\FilesUXLab\perf\10k', 'C:\FilesUXLab\perf\img400'
$res = foreach ($run in 0..$Runs) { foreach ($f in $folders) { foreach ($a in $apps) {
  $p = Get-Process $a.Proc | Where-Object MainWindowHandle -ne 0 | Select-Object -First 1
  $cpu0 = $p.TotalProcessorTime
  $sw = [Diagnostics.Stopwatch]::StartNew()
  Start-Process $a.Exe -ArgumentList ('"' + $f + '"')
  $t = [VC]::Watch($p.MainWindowHandle, $sw, $TimeoutMs, $QuietMs)
  $p.Refresh()
  [pscustomobject]@{ Run=$run; App=$a.Name; Folder=(Split-Path $f -Leaf); FirstChangeMs=[int]$t[0]; VisuallyCompleteMs=[int]$t[1]; CpuMs=[int]($p.TotalProcessorTime-$cpu0).TotalMilliseconds; WS_MB=[int]($p.WorkingSet64/1MB) }
  Start-Sleep 2 } } }
$res | Format-Table -AutoSize
"--- mediana (runs 1..$Runs; run 0 = aquecimento)"
$res | Where-Object Run -gt 0 | Group-Object App, Folder | ForEach-Object {
  $v = $_.Group.VisuallyCompleteMs | Sort-Object; $c = $_.Group.CpuMs | Sort-Object
  "{0,-28} visual={1,6} ms  cpu={2,6} ms" -f $_.Name, $v[[int][math]::Floor($v.Count/2)], $c[[int][math]::Floor($c.Count/2)] }
