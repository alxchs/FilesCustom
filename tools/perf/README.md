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

## Linha de base original v4.2.9 (01/10/2026)

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

---

## Linha de base upstream/main 0e3c17ca4 (03/10/2026)

Máquina: 12 núcleos, 16 GB. Files Dev = pacote 4.2.37.0 (`upstream/main` `0e3c17ca4` + ajustes de build), Release x64, ReadyToRun, fundo Mica Alt (padrão). OneCommander 3.108.0.0. Ambos os apps com janelas abertas e abas ativas.

| Medida | Files Dev | OneCommander | Razão | Estado |
|---|---|---|---|---|
| CPU para abrir `10k` (mediana de 3) | 5.219 ms | 2.016 ms | 2,59× | OBSERVED |
| Tempo visual para abrir `10k` (mediana de 3) | 3.545 ms | 2.841 ms | 1,25× | OBSERVED |
| CPU para abrir `img400` (mediana de 3) | 5.359 ms | 1.953 ms | 2,74× | OBSERVED |
| Tempo visual para abrir `img400` (mediana de 3) | 3.595 ms | 2.820 ms | 1,27× | OBSERVED |
| Working set após aberturas | ~730 MB | ~260 MB | 2,81× | OBSERVED |
| CPU parado, 10 s (mediana de 3) | 4.906 ms (49,1% de um núcleo) | 141 ms (1,4% de um núcleo) | 34,8× | OBSERVED |

Comandos: `pwsh tools\perf\bench.ps1 -Runs 3`, `pwsh tools\perf\idle.ps1 -WaitS 10` e medição de `TotalProcessorTime` por 10 s no OneCommander.

Divisão da CPU do Files Dev (MicaAlt padrão) na base upstream/main:
- Parado (mediana 4.906 ms em 10 s): thread "DWM Compositor Thread" 4.906 ms (100% da CPU observada no processo).
- Abrindo `10k` (mediana 3.219 ms em 8 s): compositor 3.188 ms (99,0%).

---

## A/B do fundo — BackdropMaterialType (03/10/2026, F007-A)

Hipótese testada: o fundo `MicaAlt` (padrão, `AppearanceSettingsService.AppThemeBackdropMaterial = 2`) é a causa da alta CPU da thread "DWM Compositor Thread" parado (49% de 1 núcleo) e ao abrir pastas.

Método:
- Caminho utilizado para alternar o fundo: edição direta do valor `"AppThemeBackdropMaterial"` em `%LOCALAPPDATA%\Packages\FilesDev_ykqwq8d6ps0ag\LocalState\settings\user_settings.json` com o processo fechado, reabrindo em seguida via `.\Open-FilesDev.ps1` com layout AppX registrado.
- Janela, tamanho e posição mantidos idênticos sem mover nem interagir durante as medições.
- Para cada valor de enum (`Solid` = 0, `Mica` = 1, `MicaAlt` = 2, `Acrylic` = 3): 3 rodadas de `pwsh tools\perf\idle.ps1 -WaitS 10` e 3 rodadas de `pwsh tools\perf\thr.ps1 -Folder C:\FilesUXLab\perf\10k -WaitS 8`.
- Fundo original (`MicaAlt`) restaurado ao final dos testes (CONFIRMED no `user_settings.json` e processo ativo).

### Tabela Comparativa (Medianas de 3 rodadas)

| Material | Enum | Rodadas Parado (10s) | CPU Parado (mediana) | CPU Compositor Parado | % Compositor Parado | Rodadas Abrir 10k (8s) | CPU Abrir 10k (mediana) | CPU Compositor Abrir 10k | % Compositor Abrir | Estado |
|---|---|---|---|---|---|---|---|---|---|---|
| **MicaAlt** (padrão) | 2 | 4.781 / 5.984 / 4.906 ms | 4.906 ms (49,1%) | 4.906 ms | 100% | 5.047 / 3.219 / 2.750 ms | 3.219 ms | 3.188 ms | 99,0% | OBSERVED |
| **Solid** | 0 | 1.969 / 1.844 / 1.734 ms | 1.844 ms (18,4%) | 1.750 ms | 94,9% | 14.609* / 2.469 / 3.219 ms | 3.219 ms | 2.391 ms | 74,3% | OBSERVED |
| **Mica** | 1 | 7.203* / 1.875 / 1.766 ms | 1.875 ms (18,8%) | 1.859 ms | 99,1% | 1.484 / 1.172 / 1.203 ms | 1.203 ms | 1.156 ms | 96,1% | OBSERVED |
| **Acrylic** | 3 | 1.500 / 1.516 / 1.531 ms | 1.516 ms (15,2%) | 1.469 ms | 96,9% | 1.547 / 1.297 / 1.141 ms | 1.297 ms | 1.203 ms | 92,8% | OBSERVED |

*\*Nota: rodada 1 com aquecimento/JIT/STA startup logo após reinicialização.*

### Conclusão e Avaliação da Hipótese

- **Conclusão:** O fundo `MicaAlt` explica 62% do consumo excessivo de CPU parado (o uso de CPU do compositor cai de 4.906 ms para 1.844 ms com `Solid`), porém **NÃO explica a totalidade da CPU do compositor**, pois mesmo com `Solid` o Files Dev continua consumindo ~1.844 ms em 10 s (18,4% de um núcleo, 95% no compositor), muito acima do patamar de repouso do OneCommander (141 ms / 1,4% de um núcleo).
- **Classificação:** Hipótese **PARCIALMENTE CONFIRMADA / NÃO EXPLICA A CAUSA RAIZ TOTAL**:
  - Trocar `MicaAlt` por `Solid` ou `Acrylic`/`Mica` traz ganho substancial imediato (queda de ~62% a ~69% no gasto de CPU ociosa).
  - Contudo, mesmo em `Solid`, o `DWM Compositor Thread` permanece ativo consumindo ~175–190 ms de CPU por segundo sem qualquer interação na tela. Isso aponta para um loop ou animação contínua no pipeline do WinUI 3 (ex.: `ProgressRing`, animação de cursor/caret, timer de renderização contínua ou compositor XAML não entrando em suspensão completa).
- **Proposta de correção mínima (sem implementação neste momento):**
  1. Oferecer opção de backdrop padrão `Solid` ou `Mica` comum (que consome menos que `MicaAlt`).
  2. Implementar suspensão do backdrop/composição quando a janela perder foco ou estiver ociosa.
  3. Risco para o upstream (§13): Mudar o valor padrão em `AppearanceSettingsService` é trivial e isolado (1 linha em arquivo de serviço), sem impacto de quebra com o upstream.
- **Próximo passo de diagnóstico (novo DISCOVERY D-PERF-02):**
  Investigar o que mantém o `DWM Compositor Thread` acordado em repouso mesmo com fundo `Solid` (inspecionar controles visuais ativos, animações infinitas de Storyboard/ProgressRing, polling do Omnibar/abas ou render loop do WinUI 3).
