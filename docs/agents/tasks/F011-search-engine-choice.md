# F011 — Motor de busca escolhido pelo usuário (F3 / Ctrl+F)

Status: BRIEF EM RASCUNHO, **sem pré-aprovação de implementação** (Claude, 03/10/2026). Executa depois da fase 1 e do desenho da F006 (`F006-search-provider.md`), que é a infraestrutura. A AGY faz agora **apenas a investigação dos dois motores externos**. Branch: `feature/search-engine-choice`. Spec: `MASTER_SPEC.md` §46.

## ESTADO ATUAL (lido no código e na máquina, 03/10/2026)

- `F3` e `Ctrl+F` já estão ligados ao `SearchAction` (`Actions/Global/SearchAction.cs`: `Ctrl+F` e `F3`). O motor é o `FolderSearch` (AQS do Windows + Win32). Pontos de chamada: `NavigationToolbarViewModel` (~l.1217), `BaseShellPage` (~l.599), `ShellViewModel.SearchAsync` (~l.3434).
- **Everything** está instalado e em execução: versão **1.4.1.1032**, `C:\Program Files\Everything\Everything.exe` (OBSERVED; 2 processos `Everything`). Na pasta dele **não há** `es.exe` nem `Everything64.dll` (busca limitada a essa pasta; a AGY deve procurar no resto da máquina e citar o comando).
- **Agent Ransack** está instalado: versão **9.2.3425.1**, `C:\Program Files\Mythicsoft\Agent Ransack\` com `AgentRansack.exe`, **`flpsearch.exe`**, `flpidx.exe`, `SearchTask.exe`, `IndexManager.exe`, e pastas `Sample Scripts/`, `config/`, `help/`.

## TASK — fase 1: provar que dá para usar os motores SEM abrir a tela deles

### Everything (IPC)
1. Confirmar como consultar sem janela: (a) SDK `Everything64.dll` (baixar do site do fabricante só com autorização do Alexandre) ou (b) falar o protocolo IPC direto (janela oculta de mensagens `EVERYTHING_TASKBAR_NOTIFICATION`, `WM_COPYDATA` com `EVERYTHING_IPC_QUERY`). Escrever um protótipo **fora de `src/`** (script ou projeto em `tools/search/`) que devolva 50 resultados de uma consulta por nome e por caminho, com tempo medido.
2. Registrar: precisa do serviço? funciona com o Everything minimizado/na bandeja? requisitos de elevação? licença do SDK (MIT, a confirmar no texto do SDK) e se a DLL é compatível com NativeAOT do Files (`P/Invoke` via CsWin32).

### Agent Ransack (`flpsearch.exe`)
1. Descobrir os parâmetros: `flpsearch.exe /?` e a pasta `help/` e `Sample Scripts/` (somente leitura). **Atenção**: rodar com `/?` pode abrir janela; fazer isso em um desktop sem trabalho aberto e fechar em seguida. Registrar o que o executável realmente faz.
2. Provar (ou refutar) que há um modo **sem interface** que devolve resultados em texto/CSV/XML (nome, caminho, tamanho, data; e, se possível, trecho de conteúdo). Se existir só via janela, registrar e propor a alternativa: usar a API/linha de comando do `SearchTask.exe` ou limitar a integração à busca de conteúdo.
3. Protótipo fora de `src/`: buscar um texto em `C:\FilesUXLab` e devolver os arquivos, medindo o tempo.

### Resultado
`docs/architecture/search-engines.md` com, para cada motor: como é chamado, o que devolve, tempo medido, o que não consegue fazer (regex? conteúdo? filtros de tamanho/data?), riscos e **recomendação**. Parar e registrar `PENDING DECISION` para o Claude aprovar o desenho.

## DESENHO PROVISÓRIO (INFERRED, Claude aprova)

- Setting `SearchEngine` = `Native | AgentRansack | Everything` (padrão `Native`), em Settings; mostra a disponibilidade de cada um (instalado, versão, respondendo).
- `ISearchProvider` (F006) com três implementações; o `SearchAction` e os 3 pontos de chamada passam por uma fábrica que lê a setting. Motor indisponível: cai na nativa com aviso discreto, nunca erro.
- Resultados voltam como `ListedItem` na lista do Files (sem abrir a janela do outro programa), com rótulo do motor ativo na caixa de busca. Busca incremental, cancelável, fora da UI thread.

## ACCEPTANCE (fases seguintes)

Troca de motor nas configurações; F3 e Ctrl+F usam o motor escolhido; nenhuma janela externa abre; nativo idêntico ao atual; indisponibilidade tratada; desempenho medido contra a busca nativa na pasta de 10 mil e numa árvore grande.

## DO NOT CHANGE

`FolderSearch` (comportamento). Não incluir binários dos outros programas no repositório sem revisar licença (§35).

## FORA DE ESCOPO

Indexador próprio; instalar Everything/Agent Ransack.

## ENTREGA

`docs/architecture/search-engines.md`, protótipos em `tools/search/`, handoff, commit local, sem push.
