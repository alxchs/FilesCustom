# F006 — Busca de alto desempenho (Search Provider)

Status: BRIEF EM RASCUNHO, **sem pré-aprovação de implementação** (Claude, 03/10/2026). É a fase de maior impacto arquitetural (§29): a AGY faz só a fase 1 (medição) até o Claude aprovar o desenho. Branch: `feature/search-provider`.

## ARQUITETURA ATUAL (lida no código em 03/10/2026; nada executado)

- Motor nativo: `src/Files.App/Utils/Storage/Search/FolderSearch.cs` (`FolderSearch`, propriedades `Query`, `Folder`, `MaxItemCount`, `SearchTick`).
  - `SearchAsync(IList<ListedItem>, CancellationToken)` decide por pasta: biblioteca (`AddItemsForLibraryAsync`), `Home` (`AddItemsForHomeAsync`) ou pasta comum (`AddItemsAsync`).
  - Consulta: `AQSQuery` — se começa com `$`, é AQS (Advanced Query Syntax do Windows Search) puro; se tem `:`, usa como está; senão vira `System.FileName:<termo>*`. Há um caminho Win32 (`FindFirstFile`, `SearchWithWin32Async`) para pastas fora do índice / ocultos, e busca por tag (`SearchTagsAsync`, `TagQueryExpression`).
  - Não há regex, filtro de tamanho/data na UI, nem busca por conteúdo própria (só o que o AQS entregar).
- Quem chama: `ViewModels/UserControls/NavigationToolbarViewModel.cs` (~l.1217, caixa de busca do Omnibar), `Views/Shells/BaseShellPage.cs` (~l.599) e `ShellViewModel.SearchAsync(FolderSearch)` (~l.3434), que enche a lista de resultados.
- **Everything está instalado nesta máquina** (OBSERVED: `ls "/c/Program Files/Everything*"` lista `Everything.exe`, `Everything.db`, `Changes.txt`). Não verificado: versão, se está em execução, se há `es.exe` ou o SDK (`Everything64.dll`); a AGY confirma com busca exaustiva citando o comando (regra global de ausência).

## FASES

### Fase 1 — Benchmark (autorizada à AGY, sem código de produto)
Cumprir §10 "Primeiro investigar: Files Search × Everything × Agent Ransack". Medir, de fora, com scripts em `tools/perf/` ou `tools/search/`, num conjunto controlado (ex.: `C:\FilesUXLab\perf\10k` e uma árvore de ~500 mil arquivos como `C:\Windows`/`D:\`):

- latência até o 1º resultado e até o fim; consulta por nome, extensão (`*.json`), caminho, wildcard, regex (onde existir), tamanho, data, subpastas, conteúdo (Agent Ransack);
- custo de indexação / atualização (Everything é instantâneo via NTFS/USN; o índice do Windows Search depende da pasta estar indexada);
- uso de CPU/memória do Files durante a busca (`tools/perf`).
Resultados em `docs/test-plans/search-benchmark.md`, cada número `OBSERVED` com o comando. Agent Ransack: só se estiver instalado; senão registrar "não encontrado em <locais pesquisados>" e seguir (nunca "não existe").

### Fase 2 — Desenho (Claude aprova; AGY propõe em `docs/architecture/search-provider.md`)
- Interface `ISearchProvider` (nome, disponibilidade, capacidades: regex/conteúdo/tamanho/data, `SearchAsync(SearchRequest, IProgress, CancellationToken)`), com `NativeFilesSearchProvider` (envolve `FolderSearch` sem mudar seu comportamento) e `EverythingSearchProvider` opcional (§10).
- Everything **nunca obrigatório**: sem ele, a busca nativa segue idêntica e a interface não quebra; indicar qual motor está em uso (rótulo discreto) quando relevante.
- Integração com Everything: avaliar (a) SDK `Everything64.dll` por IPC, (b) `es.exe`. Critérios: licença/redistribuição (§35), requer o serviço rodando, AOT/trimming do Files (NativeAOT está ligado no upstream: `Enabled NativeAOT`), custo de P/Invoke via CsWin32 (regra do AGENTS.md: sem P/Invoke ad hoc).
- Mudança mínima nos 3 pontos de chamada: trocar `new FolderSearch{...}` por uma fábrica de provider; manter `ShellViewModel.SearchAsync` como destino dos resultados.
- Registrar `DECISIONS.md` D-009 (Context/Problem/Options/Decision/Reason/Trade-offs/Consequences).

### Fase 3 — Implementação (só após aprovação da fase 2)
Abstração + provider nativo (sem mudança de comportamento, com testes) primeiro, commit separado; depois o provider Everything; depois a UI de escolha/rótulo.

## ACCEPTANCE (§10, §30, §31)

Busca nativa idêntica sem Everything; com Everything, resultados corretos e mais rápidos nos casos medidos; cancelamento ao digitar de novo; nada pesado na UI thread; sem polling; resultados incrementais; diretório com milhares de arquivos sem travar; acessibilidade da caixa de busca preservada; licenças revisadas.

## DO NOT CHANGE

`FolderSearch` (comportamento), formato de consulta AQS existente (`$...`), busca por tag, outros chamadores.

## FORA DE ESCOPO

Indexador próprio, busca de conteúdo própria, redesenho da UI de busca.

## ENTREGA

Fase 1: `docs/test-plans/search-benchmark.md` + scripts, handoff, commit local, sem push. Pare ao fim da fase 1 e registre `PENDING DECISION` pedindo a aprovação do desenho.

> Atualização 03/10/2026: esta fase é a infraestrutura de busca. A escolha do motor pelo usuário (Native / Agent Ransack / Everything no F3) está em `F011-search-engine-choice.md` (MASTER_SPEC §46).
