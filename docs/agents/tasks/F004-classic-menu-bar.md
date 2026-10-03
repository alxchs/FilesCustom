# F004 — Barra de menus tradicional (opcional)

Status: BRIEF EM RASCUNHO, **sem pré-aprovação de implementação** (Claude, 03/10/2026). Executor: AGY (análise e protótipo na branch); o Claude aprova antes do merge. Branch: `feature/classic-menu`. Depende de F003/F005 estarem decididas (os comandos de aba e de painel entram nos menus).

## ARQUITETURA ATUAL (lida no código em 03/10/2026; nada executado)

- **Não existe barra de menus** (`rg "MenuBar" src/Files.App` sem resultado fora de `obj`).
- `Views/MainPage.xaml` (~l.112): `Grid` com 3 linhas: `TabBar`, `NavigationToolbar`, conteúdo. Dentro de cada painel há outra `Toolbar` (`UserControls/Toolbar.xaml`, "InnerNavigationToolbar") personalizável (`CustomizeToolbarAction`, `ToolbarItemDescriptor`, `ToolbarSections`).
- Os comandos são `IAction`/`IToggleAction` com `[GeneratedRichCommand]`: cada um tem `Label`, `Description`, `HotKey`, `Glyph`, `Category` (`ActionCategory`), `IsExecutable`; o gerador cria `Commands.<Nome>` usável no XAML (`Command="{x:Bind Commands.NewTab}"`, `Commands.X.HotKeyText`, `.Label`, `.IsExecutable`, `.AutomationName`). Já existe o Command Palette (`OpenCommandPaletteAction`, `Ctrl+Shift+P`) que lista as ações com `IsAccessibleGlobally`.
- Contagem de ações por categoria (`rg -o "ActionCategory\.\w+" Actions`): FileSystem 30, Open 22, Navigation 13, Show 11, DualPane 10, Grouping 8, Sorting 7, Create 7, Git 6, Window 4, Theme 4, Selection 4, Layout 4, Install 3, Start 2, Run 2, Image 2, Archive 2, Media 1.

Isso torna a F004 viável sem inventar comandos: o menu é só **uma nova superfície** sobre `ICommandManager`.

## PROPOSTA DE DESIGN (INFERRED; a AGY confirma ou corrige)

- Controle: `Microsoft.UI.Xaml.Controls.MenuBar` nativo (acessibilidade e teclado de graça: `Alt` abre, setas navegam, `AccessKey`), em uma nova linha `Auto` no topo de `MainPage.xaml`, **desligada por padrão** e ligada por uma opção (§33: razão legítima, é "opcional" no §8) em Settings > Appearance.
- Arquivos próprios (§13): `UserControls/Menus/ClassicMenuBar.xaml(.cs)` e uma classe de mapeamento menu→comandos; no `MainPage.xaml` só uma linha e uma visibilidade ligada à opção.
- Itens: `MenuFlyoutItem` com `Command="{x:Bind Commands.X}"`, `KeyboardAcceleratorTextOverride="{x:Bind Commands.X.HotKeyText}"`; `IsExecutable` já vira Enabled/Disabled. Reutilizar comandos, **nenhuma lógica nova** nem comando duplicado (§8).
- Estrutura inicial sugerida pelo §8: **File, Edit, View, Go, Tools, Help.** Primeiro rascunho do mapeamento por categoria (a AGY ajusta olhando a lista real de comandos): File = Create, Open, Archive, FileSystem (renomear, excluir, propriedades), Window (nova janela/fechar); Edit = Selection, FileSystem (copiar/colar/recortar), Git; View = Layout, Sorting, Grouping, Show (Toggle Preview/Details/Info, barra de status), Display, DualPane, Theme; Go = Navigation (voltar/avançar/subir, abas: Nova aba, **Duplicar aba**, Reabrir aba fechada), Start; Tools = Run, Install, Image, Media, Command Palette; Help = release notes, documentação, sobre.
- Submenus para o que for grande (Sort by, Group by, Layout). Separadores entre grupos. Sem comandos soltos sem categoria (`Unspecified`).

## TASK

1. **Análise (somente leitura, primeiro):** gerar a lista real de comandos (`Actions/**`) com categoria, hotkey e `IsAccessibleGlobally`; propor a hierarquia final dos 6 menus numa tabela em `docs/architecture/classic-menu.md`, apontando conflitos de atalho e comandos que dependem de contexto (`IsExecutable`).
2. **Exploração do OneCommander** (somente UI): `docs/ux-reference/onecommander/menus.md` (modelo §18). Ele **não** tem a barra clássica (é a queixa §4.4): documentar o que existe no lugar (menu hambúrguer? botões?) e o que o Alexandre sente falta. Não copiar o visual.
3. **Protótipo** na branch, sem merge: `ClassicMenuBar` ligado por opção, com 2 a 3 menus completos para validar o desenho (teclado, `Alt`, tema escuro, DPI 150%).
4. Parar e registrar o handoff para aprovação do Claude antes de completar os 6 menus.

## ACCEPTANCE (§8, §32)

Cada menu com hierarquia clara; atalhos visíveis quando existirem; Enabled/Disabled reflete o estado; sem comandos duplicados; funciona só com teclado (`Alt`, setas, `Esc`); foco volta ao arquivo; `AutomationProperties.Name` em tudo; contraste e DPI verificados; opção desligada = app idêntico ao atual.

## DO NOT CHANGE

Nenhum comando existente (`Actions/**`) além de, se necessário, corrigir um `Label`. Barra de ferramentas atual. Command Palette.

## FORA DE ESCOPO

Personalização dos menus pelo usuário, novos comandos, remoção da `Toolbar`.

## ENTREGA

`docs/architecture/classic-menu.md`, `menus.md` do OneCommander, protótipo em branch, handoff, commit local, sem push.
