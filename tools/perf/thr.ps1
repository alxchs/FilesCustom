param([string]$Folder = 'C:\FilesUXLab\perf\10k', [int]$WaitS = 8)
$ErrorActionPreference = 'Stop'; Add-Type -Path (Join-Path $PSScriptRoot 'thr.cs')
$p = Get-Process Files | Select-Object -First 1
$hwnd = if ($p.MainWindowHandle -ne 0) { $p.MainWindowHandle } else { [Thr]::FindMainWindow($p.Id) }
$ui = [Thr]::UiThread($hwnd)
$a = [Thr]::Snap($p.Id); $c0 = $p.TotalProcessorTime
Start-Process files-dev.exe -ArgumentList ('"' + $Folder + '"'); Start-Sleep $WaitS
$b = [Thr]::Snap($p.Id); $p.Refresh(); $tot = ($p.TotalProcessorTime - $c0).TotalMilliseconds
"Processo: {0:N0} ms de CPU em {1}s" -f $tot, $WaitS
$rows = foreach ($k in $b.Keys) { $o = if ($a.ContainsKey($k)) { $a[$k].Cpu100ns } else { 0 }
  $ms = ($b[$k].Cpu100ns - $o) / 10000; if ($ms -ge 20) { [pscustomobject]@{ Tid=$k; CpuMs=[int]$ms; Pct=[math]::Round(100*$ms/$tot,1); UI=($k -eq $ui); Desc=$b[$k].Desc; Start=[Thr]::ModuleOf($p.Id, $b[$k].Start); New=-not $a.ContainsKey($k) } } }
$rows | Sort-Object CpuMs -Descending | Format-Table -AutoSize
"Threads: antes {0}, depois {1}" -f $a.Count, $b.Count
