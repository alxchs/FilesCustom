# Medição de desempenho: Files Dev × OneCommander

Scripts para medir o Files Dev contra o OneCommander nas mesmas ações. Medem só o que é observável de fora: tempo de tela, CPU e memória do processo. Nada de inspecionar a implementação do OneCommander (MASTER_SPEC §3.1).

Pré-requisitos: os dois apps abertos, o Files Dev registrado por `Open-FilesDev.ps1` e o laboratório criado por `New-PerfLab.ps1` (10 mil arquivos em `C:\FilesUXLab\perf\10k`, 400 JPGs em `C:\FilesUXLab\perf\img400`). Use `pwsh` (PowerShell 7) e não mexa nas janelas durante a medição.

| Script | Mede |
|---|---|
| `bench.ps1` | Abre cada pasta nos dois apps pela linha de comando, 1 rodada de aquecimento + `-Runs`. Registra a primeira e a última mudança visível na janela (captura por `PrintWindow`, resolução de ~0,15 s), a CPU do processo e o working set. |
| `thr.ps1` | CPU por thread do Files ao abrir uma pasta (`-Folder`). Separa UI, compositor e pool do .NET. |
| `idle.ps1` | CPU por thread do Files parado (`-WaitS`). |

Limitações conhecidas:

- O tempo visual do `bench.ps1` inclui a criação do processo lançador (`files-dev.exe` ou `OneCommander.exe`), que domina o número. Use-o para CPU e memória. Para tempo de navegação dentro do app, falta um gatilho dentro do app (barra de endereço por teclado).
- A captura por `PrintWindow` custa de 100 a 160 ms por quadro em janelas de ~2900×1600.
- O OneCommander não expõe nomes de arquivo por UI Automation (os itens aparecem como `Rapidrive.PathData`), por isso a métrica é visual e não por item.

## Linha de base (01/10/2026)

Máquina: 12 núcleos, 16 GB. Files Dev = upstream v4.2.9, Release x64, ReadyToRun, fundo Mica Alt (padrão). Os dois apps estavam em uso real, com abas abertas.

| Medida | Files Dev | OneCommander | Razão |
|---|---|---|---|
| CPU para abrir `10k` (mediana de 3) | 2.781 ms | 1.453 ms | 1,9× |
| CPU para abrir `img400` (mediana de 3) | 2.984 ms | 1.766 ms | 1,7× |
| Working set depois das aberturas | ~610 MB | ~180 MB | 3,4× |
| CPU parado, 10 s | 3.422 ms (34% de um núcleo) | 188 ms (1,9%) | 18× |

Comandos: `bench.ps1 -Runs 3`, `idle.ps1 -WaitS 10` e, para o OneCommander parado, `TotalProcessorTime` antes e depois de 10 s.

Divisão da CPU do Files (`thr.ps1`, `idle.ps1`):

- Abrindo `10k` (3.594 ms em 8 s): thread "DWM Compositor Thread" 2.109 ms (59%), thread de UI 1.234 ms (34%), pool do .NET ~140 ms.
- Parado (3.422 ms em 10 s): compositor 2.516 ms, pool do .NET ~700 ms, thread de UI 16 ms.

Leitura: OBSERVED que a maior parte do custo é composição/renderização, não acesso a disco nem lógica do app. INFERRED, NOT TESTED: o compositor gastando CPU com a UI parada indica algo animando continuamente. Suspeito número 1: o fundo Mica Alt (`MicaController` em `src/Files.App/Helpers/UI/AppSystemBackdrop.cs`). Confirmar por A/B antes de mudar código.
