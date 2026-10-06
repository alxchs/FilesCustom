# Arquitetura da Barra de Menus Tradicional (ClassicMenuBar)

## 1. Visão Geral

A barra de menus tradicional opcional do Files Custom é estruturada em torno de 6 menus canônicos do Windows:

1. **File** (`Alt+F`, `AccessKey="F"`)
2. **Edit** (`Alt+E`, `AccessKey="E"`)
3. **View** (`Alt+V`, `AccessKey="V"`)
4. **Go** (`Alt+G`, `AccessKey="G"`)
5. **Tools** (`Alt+T`, `AccessKey="T"`)
6. **Help** (`Alt+H`, `AccessKey="H"`)

Todos os itens são vinculados diretamente às propriedades correspondentes de `ICommandManager` (`Commands.<Action>`). O estado de ativação (`IsEnabled`) é governado automaticamente pela infraestrutura de `IRichCommand` e `CanExecuteChanged`.

---

## 2. Tabela de Mapeamento de Comandos

### 2.1 Menu File (`Alt+F`)

| Rótulo / Item | Comando (`Commands.*`) | Atalho Padrão | Categoria | Dependência de Contexto |
|---|---|---|---|---|
| Nova Aba | `NewTab` | Ctrl+T | Navigation | Global |
| Nova Janela | `NewWindow` | Ctrl+N | Navigation | Global |
| *Novo (Submenu)* | — | — | Create | — |
| ├─ Pasta | `CreateFolder` | Ctrl+Shift+N | Create | Pasta editável |
| ├─ Arquivo | `CreateFile` | — | Create | Pasta editável |
| ├─ Pasta com Seleção | `CreateFolderWithSelection` | — | Create | Itens selecionados |
| └─ Atalho... | `CreateShortcutFromDialog` | — | Create | Pasta editável |
| *(Separador)* | — | — | — | — |
| Abrir | `OpenItem` | Enter | FileSystem | Item selecionado |
| Abrir em Nova Aba | `OpenInNewTab` | Ctrl+Enter | Navigation | Pasta selecionada |
| Abrir em Nova Janela | `OpenInNewWindow` | — | Navigation | Pasta selecionada |
| Abrir no Painel Secundário | `OpenInNewPane` | — | Navigation | Pasta selecionada |
| Abrir no Terminal | `OpenTerminal` | Ctrl+Shift+T | Open | Pasta ativa |
| Abrir no Terminal (Admin) | `OpenTerminalAsAdmin` | — | Open | Pasta ativa |
| *(Separador)* | — | — | — | — |
| Renomear | `Rename` | F2 | FileSystem | Item selecionado |
| Excluir | `DeleteItem` | Del | FileSystem | Itens selecionados |
| Excluir Permanentemente | `DeleteItemPermanently` | Shift+Del | FileSystem | Itens selecionados |
| *(Separador)* | — | — | — | — |
| Propriedades | `OpenProperties` | Alt+Enter | Open | Item selecionado |
| Propriedades Clássicas | `OpenClassicProperties` | — | Open | Item selecionado |
| *(Separador)* | — | — | — | — |
| Fechar Aba | `CloseSelectedTab` | Ctrl+W | Navigation | Pelo menos 1 aba |

---

### 2.2 Menu Edit (`Alt+E`)

| Rótulo / Item | Comando (`Commands.*`) | Atalho Padrão | Categoria | Dependência de Contexto |
|---|---|---|---|---|
| Desfazer | `Undo` | Ctrl+Z | Global | Histórico de operações |
| Refazer | `Redo` | Ctrl+Y | Global | Histórico de operações |
| *(Separador)* | — | — | — | — |
| Recortar | `CutItem` | Ctrl+X | FileSystem | Itens selecionados |
| Copiar | `CopyItem` | Ctrl+C | FileSystem | Itens selecionados |
| Colar | `PasteItem` | Ctrl+V | FileSystem | Clipboard com arquivo |
| Colar como Atalho | `PasteItemAsShortcut` | — | FileSystem | Clipboard com arquivo |
| *(Separador)* | — | — | — | — |
| Copiar Caminho | `CopyPath` | — | FileSystem | Itens selecionados |
| Copiar Caminho com Aspas | `CopyPathWithQuotes` | — | FileSystem | Itens selecionados |
| *(Separador)* | — | — | — | — |
| Selecionar Tudo | `SelectAll` | Ctrl+A | Selection | Lista não vazia |
| Inverter Seleção | `InvertSelection` | — | Selection | Lista não vazia |
| Limpar Seleção | `ClearSelection` | Escape | Selection | Há seleção ativa |

---

### 2.3 Menu View (`Alt+V`)

| Rótulo / Item | Comando (`Commands.*`) | Atalho Padrão | Categoria | Dependência de Contexto |
|---|---|---|---|---|
| *Layout (Submenu)* | — | — | Layout | — |
| ├─ Detalhes | `LayoutDetails` | Ctrl+Shift+1 | Layout | Aba ativa |
| ├─ Grade Pequena | `LayoutGridSmall` | Ctrl+Shift+2 | Layout | Aba ativa |
| ├─ Grade Média | `LayoutGridMedium` | Ctrl+Shift+3 | Layout | Aba ativa |
| ├─ Grade Grande | `LayoutGridLarge` | Ctrl+Shift+4 | Layout | Aba ativa |
| ├─ Colunas | `LayoutColumns` | Ctrl+Shift+5 | Layout | Aba ativa |
| └─ Adaptativo | `LayoutAdaptive` | Ctrl+Shift+6 | Layout | Aba ativa |
| *Ordenar por (Submenu)* | — | — | Sorting | Aba ativa |
| ├─ Nome | `SortByName` | — | Sorting | Aba ativa |
| ├─ Data de Modificação | `SortByDateModified` | — | Sorting | Aba ativa |
| ├─ Tipo | `SortByType` | — | Sorting | Aba ativa |
| └─ Tamanho | `SortBySize` | — | Sorting | Aba ativa |
| *Agrupar por (Submenu)* | — | — | Grouping | Aba ativa |
| ├─ Nenhum | `GroupByNone` | — | Grouping | Aba ativa |
| ├─ Nome | `GroupByName` | — | Grouping | Aba ativa |
| └─ Data de Modificação | `GroupByDateModified` | — | Grouping | Aba ativa |
| *(Separador)* | — | — | — | — |
| *Painéis (Submenu)* | — | — | Show | — |
| ├─ Painel de Pré-visualização | `TogglePreviewPane` | Alt+P | Show | Toggle |
| ├─ Painel de Detalhes | `ToggleDetailsPane` | Alt+Shift+P | Show | Toggle |
| ├─ Painel de Informações | `ToggleInfoPane` | — | Show | Toggle |
| ├─ Painel Duplo (Dual Pane) | `ToggleDualPane` | Alt+Shift+D | Show | Toggle |
| ├─ Barra Lateral | `ToggleSidebar` | — | Show | Toggle |
| └─ Barra de Ferramentas | `ToggleToolbar` | Ctrl+Shift+B | Show | Toggle |
| *(Separador)* | — | — | — | — |
| Mostrar Itens Ocultos | `ToggleShowHiddenItems` | Ctrl+H | Show | Toggle |
| Mostrar Extensões de Arquivo | `ToggleShowFileExtensions` | — | Show | Toggle |
| Mostrar Arquivos com Ponto | `ToggleDotFilesSetting` | — | Show | Toggle |
| *(Separador)* | — | — | — | — |
| Autoajustar Colunas | `AutoFitColumns` | — | Display | Layout Detalhes ativo |
| Tela Cheia | `ToggleFullScreen` | F11 | Global | Global |
| Modo Compacto (Overlay) | `ToggleCompactOverlay` | — | Global | Global |
| *(Separador)* | — | — | — | — |
| Atualizar | `RefreshItems` | F5 | Content | Aba ativa |

---

### 2.4 Menu Go (`Alt+G`)

| Rótulo / Item | Comando (`Commands.*`) | Atalho Padrão | Categoria | Dependência de Contexto |
|---|---|---|---|---|
| Voltar | `NavigateBack` | Alt+Left | Navigation | Histórico anterior |
| Avançar | `NavigateForward` | Alt+Right | Navigation | Histórico posterior |
| Um Nível Acima | `NavigateUp` | Alt+Up | Navigation | Possui pasta pai |
| Início (Home) | `NavigateHome` | Alt+Home | Navigation | Global |
| *(Separador)* | — | — | — | — |
| Duplicar Aba Atual | `DuplicateSelectedTab` | Ctrl+K | Navigation | Aba ativa |
| Reabrir Aba Fechada | `ReopenClosedTab` | Ctrl+Shift+T | Navigation | Histórico de abas |
| Próxima Aba | `NextTab` | Ctrl+Tab | Navigation | Mais de 1 aba |
| Aba Anterior | `PreviousTab` | Ctrl+Shift+Tab | Navigation | Mais de 1 aba |
| *(Separador)* | — | — | — | — |
| Focar Outro Painel | `FocusOtherPane` | Tab | Navigation | Dual pane ativo |
| Abrir Pasta Atual no Outro Painel | `OpenCurrentFolderInOtherPane` | — | Navigation | Dual pane ativo |
| *(Separador)* | — | — | — | — |
| Editar Caminho | `EditPath` | Ctrl+L | Global | Aba ativa |
| Pesquisar | `Search` | Ctrl+F | Global | Aba ativa |

---

### 2.5 Menu Tools (`Alt+T`)

| Rótulo / Item | Comando (`Commands.*`) | Atalho Padrão | Categoria | Dependência de Contexto |
|---|---|---|---|---|
| Paleta de Comandos | `OpenCommandPalette` | Ctrl+Shift+P | Open | Global |
| *(Separador)* | — | — | — | — |
| *Git (Submenu)* | — | — | Git | Repositório Git |
| ├─ Sincronizar | `GitSync` | — | Git | Repositório Git |
| ├─ Pull | `GitPull` | — | Git | Repositório Git |
| ├─ Push | `GitPush` | — | Git | Repositório Git |
| ├─ Fetch | `GitFetch` | — | Git | Repositório Git |
| ├─ Clonar... | `GitClone` | — | Git | Global |
| └─ Inicializar Repositório | `GitInit` | — | Git | Pasta não-git |
| *(Separador)* | — | — | — | — |
| Abrir no Editor de Código (IDE) | `OpenInIDE` | — | Open | Pasta / item ativo |
| Abrir Repositório no Editor | `OpenRepoInIDE` | — | Open | Repositório Git ativo |
| Editar no Bloco de Notas | `EditInNotepad` | — | Open | Arquivo de texto |
| *(Separador)* | — | — | — | — |
| Personalizar Barra de Ferramentas... | `CustomizeToolbar` | — | Open | Global |
| Configurações... | `OpenSettings` | Ctrl+, | Open | Global |

---

### 2.6 Menu Help (`Alt+H`)

| Rótulo / Item | Comando (`Commands.*`) | Atalho Padrão | Categoria | Dependência de Contexto |
|---|---|---|---|---|
| Documentação e Ajuda | `OpenHelp` | F1 | Global | Global |
| Notas de Lançamento | `OpenReleaseNotes` | — | Open | Global |
| *(Separador)* | — | — | — | — |
| Abrir Arquivo de Log | `OpenLogFile` | — | Open | Global |
| Abrir Pasta de Logs | `OpenLogFileLocation` | — | Open | Global |
| Abrir Arquivo de Configurações | `OpenSettingsFile` | — | Open | Global |

---

## 3. Comportamento de Foco e Restauração

1. Quando o menu é acionado por clique ou via `Alt` + mnemônico, o foco passa para o respectivo menu.
2. Ao selecionar uma opção ou pressionar `Escape`, o WinUI fecha o flyout do menu.
3. O foco do teclado retorna de maneira determinística para o painel de visualização ativo de arquivos (`ShellPage.ActivePane`), garantindo que o usuário possa imediatamente retomar a navegação ou atalhos na lista de arquivos.

