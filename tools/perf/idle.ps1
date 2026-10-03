param([int]$WaitS = 10)
$ErrorActionPreference = 'Stop'; Add-Type -Path (Join-Path $PSScriptRoot 'thr.cs')
$p = Get-Process Files | Select-Object -First 1
$hwnd = if ($p.MainWindowHandle -ne 0) { $p.MainWindowHandle } else { [Thr]::FindMainWindow($p.Id) }
$ui = [Thr]::UiThread($hwnd)
$title = if ($p.MainWindowTitle) { $p.MainWindowTitle } else { [Thr]::WindowTitle($hwnd) }
$a = [Thr]::Snap($p.Id); $c0 = $p.TotalProcessorTime; Start-Sleep $WaitS
$b = [Thr]::Snap($p.Id); $p.Refresh(); $tot = ($p.TotalProcessorTime - $c0).TotalMilliseconds
"Parado: {0:N0} ms de CPU em {1}s ({2:N1}% de um núcleo). Título: {3}" -f $tot, $WaitS, ($tot/$WaitS/10), $title
foreach ($k in $b.Keys) { if ($a.ContainsKey($k)) { $ms = ($b[$k].Cpu100ns - $a[$k].Cpu100ns)/10000; if ($ms -ge 10) { "  {0,-24} UI={1,-5} {2,6:N0} ms" -f $b[$k].Desc, ($k -eq $ui), $ms } } }
