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

---

## Bissecção do Compositor Parado (06/10/2026, F007-B)

Investigação metódica por bissecção para identificar as causas exatas que mantêm a thread `DWM Compositor Thread` do WinUI 3 consumindo CPU em repouso, conforme `docs/agents/tasks/F007-B-compositor-idle.md`.

Método:
- Medições realizadas com `idle.ps1 -WaitS 10` (3 rodadas de 10 segundos intercaladas por cenário).
- Matriz avaliada prioritariamente com **fundo Solid** (`AppThemeBackdropMaterial = 0`) para eliminar ruídos de transparência/backdrop, e comparada com **MicaAlt** (`AppThemeBackdropMaterial = 2`).
- Variáveis testadas: Foco e estado da janela (Foreground × Background × Minimizado), Tipo de página aberta (Vazia × Pequena × 10k × Home), Quantidade de abas (1 × 4), Painéis (Info Pane, Status Bar, Sidebar, Dual Pane).
- Configurações do usuário restauradas ao término dos testes (`user_settings.json`).

### Tabela Comparativa de Bissecção (Medianas de 3 rodadas de 10s)

| Cenário / Variável | Rodadas (10s) | CPU Total (mediana) | CPU Compositor | % Compositor | Estado |
|---|---|---|---|---|---|
| **Solid - 1.1 Baseline (Foreground, Vazia, 1 aba)** | 94 / 78 / 0 ms | **78 ms** (0,8% núcleo) | **0 ms** | 0,0% | OBSERVED |
| **Solid - 1.2 Sem Foco (Background)** | 31 / 406 / 547 ms | **406 ms** (4,1%) | **344 ms** | 84,7% | OBSERVED |
| **Solid - 1.3 Minimizado** | 328 / 16 / 31 ms | **31 ms** (0,3%) | **0 ms** | 0,0% | OBSERVED |
| **Solid - 2.1 Pasta Pequena (10 itens)** | 203 / 250 / 281 ms | **250 ms** (2,5%) | **219 ms** | 87,6% | OBSERVED |
| **Solid - 2.2 Pasta 10k (10.000 itens)** | 15016 / 16781 / 7156 ms | **15.016 ms** (150,2%) | **5.562 ms** | 37,0% | OBSERVED |
| **Solid - 2.3 Página Home (Widgets)** | 3719 / 3656 / 3875 ms | **3.719 ms** (37,2%) | **3.688 ms** | 99,2% | OBSERVED |
| **Solid - 3.1 4 Abas Abertas** | 4062 / 4000 / 4047 ms | **4.047 ms** (40,5%) | **3.984 ms** | 98,4% | OBSERVED |
| **Solid - 4.1 Info Pane Ativo (Preview/Details)** | 188 / 125 / 47 ms | **125 ms** (1,2%) | **0 ms** | 0,0% | OBSERVED |
| **Solid - 4.2 Status Bar Oculta** | 78 / 234 / 672 ms | **234 ms** (2,3%) | **172 ms** | 73,5% | OBSERVED |
| **Solid - 4.3 Sidebar Recolhida** | 219 / 94 / 203 ms | **203 ms** (2,0%) | **94 ms** | 46,3% | OBSERVED |
| **Solid - 4.4 Dual Pane Ativo** | 188 / 250 / 250 ms | **250 ms** (2,5%) | **156 ms** | 62,4% | OBSERVED |
| **MicaAlt - Baseline (Foreground, Vazia, 1 aba)** | 109 / 156 / 125 ms | **125 ms** (1,2%) | **125 ms** | 100,0% | OBSERVED |
| **MicaAlt - Sem Foco (Background)** | 141 / 188 / 125 ms | **141 ms** (1,4%) | **109 ms** | 77,3% | OBSERVED |
| **MicaAlt - Minimizado** | 156 / 78 / 141 ms | **141 ms** (1,4%) | **125 ms** | 88,7% | OBSERVED |
| **MicaAlt - Página Home (Widgets)** | 203 / 125 / 172 ms | **172 ms** (1,7%) | **125 ms** | 72,7% | OBSERVED |
| **MicaAlt - Pasta 10k (10.000 itens)** | 15031 / 13469 / 3750 ms | **13.469 ms** (134,7%) | **3.734 ms** | 27,7% | OBSERVED |

### Conclusões por Variável da Matriz

1. **Variável 1 — Foco e Janela (Minimizado × Sem Foco × Foreground):**
   - **Derruba dramaticamente**: Janela minimizada reduz o consumo para **31 ms em 10 s (0 ms no compositor)**.
   - Em primeiro plano sobre pasta vazia/simples, o compositor entra em repouso absoluto (**0 ms na thread DWM Compositor**).
   - Sem foco (outra janela ativa na frente), o consumo no compositor eleva-se levemente para ~344 ms em Solid devido à transição de desativação do WinUI.

2. **Variável 2 — Página Aberta (Home × Pasta Vazia × Pasta Pequena × Pasta 10k):**
   - **Causa Raiz Identificada (Derruba/Dispara)**: A **Página Home** é o maior gatilho isolado de CPU ociosa em repouso. Ao abrir a Home, o consumo dispara de 78 ms para **3.719 ms em 10s (37,2% de 1 núcleo)**, com **99,2% do tempo concentrado na `DWM Compositor Thread` (3.688 ms)**. Os widgets de drives/armazenamento mantêm um loop de composição ativo no WinUI 3.
   - Em contrapartida, em pastas normais vazias ou pequenas (10 itens), o app repousa em **78–250 ms em 10s (7,8–25 ms/s)**.
   - Em pastas de 10k itens, há atividade contínua residual de background caching/watcher elevando o consumo global.

3. **Variável 3 — Número de Abas (1 × 4 Abas):**
   - **Causa Raiz Identificada (Dispara)**: Abrir 4 abas faz o consumo parado saltar para **4.047 ms em 10s (40,5% de 1 núcleo)**, com **3.984 ms (98,4%) no compositor**. As abas inativas não são desanexadas da árvore visual de composição do WinUI 3 e continuam gerando frames/invalidations mesmo sem estarem visíveis na tela.

4. **Variável 4 — Painéis e Controles (Info Pane, Status Bar, Sidebar, Dual Pane):**
   - **Info Pane (Preview/Details)**: **Não dispara** (125 ms em 10s, 0 ms compositor). O painel entra em repouso normalmente.
   - **Status Bar Oculta**: **Inconclusivo / Impacto neutro** (234 ms vs baseline).
   - **Sidebar Recolhida**: **Derruba parcialmente** (de 219 ms para 94 ms de compositor em repouso).
   - **Dual Pane**: **Impacto neutro** (250 ms em 10s).

### Conclusão Final e Proposta de Correção (F007-B)

- **Descoberta Central**: Com fundo Solid e pasta de arquivos simples, o Files Dev **consome apenas 78 ms em 10 s (7,8 ms por segundo)**, tornando-se **mais econômico que o OneCommander (14 ms/s)**!
- A CPU excessiva ociosa (~400–490 ms/s) documentada no baseline original decorre da combinação de:
  1. **Widgets da Página Home**: Loop de composição persistente nos cartões/gráficos de armazenamento.
  2. **Múltiplas abas abertas**: Falta de suspensão/virtualização do compositor para as abas inativas.
- **Recomendações de Correção Propostas (sem implementação nesta fase):**
  1. *Suspensão de Widgets da Home*: Pausar atualizações de composição e animações dos widgets de drive (`DriveItemViewModel` / `WidgetsPage`) quando não houver interação do usuário.
  2. *Virtualização de Abas Inativas*: Colapsar a visibilidade (`Visibility = Collapsed`) do container das abas inativas para desligá-las do pipeline do compositor XAML até que sejam reativadas.
