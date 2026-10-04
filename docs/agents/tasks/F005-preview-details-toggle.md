# F005 — Preview e Details com acesso imediato

Status: **SUBSTITUÍDO pelo conjunto SDD `docs/specs/F005-preview-details-toggle/` (spec, plan, tasks; Claude, 04/10/2026).** Este brief fica como histórico; a AGY executa `tasks.md`. Branch: `feature/preview-details-shortcuts`.

## ARQUITETURA ATUAL (lida no código em 03/10/2026; nada executado, tudo NOT TESTED)

Ações em `src/Files.App/Actions/Show/`:

| Ação | Atalho | Global (Command Palette)? | Executável quando | O que faz |
|---|---|---|---|---|
| `ToggleInfoPaneAction` (`IToggleAction`) | `Ctrl+Alt+I` | sim | sempre | `InfoPaneViewModel.IsEnabled = !IsOn`; botão na `Toolbar.xaml` ~l.851 |
| `ToggleDetailsPaneAction` | **nenhum** | **não** (`IsAccessibleGlobally = false`) | **só se o painel já está aberto** (`IsExecutable => infoPaneViewModel.IsEnabled`) | só troca a aba para `Details` (`infoPaneSettingsService.SelectedTab = InfoPaneTabs.Details`), não alterna |
| `TogglePreviewPaneAction` | **nenhum** | **não** | **só se o painel já está aberto** | só troca a aba para `Preview` |

Os botões Details/Preview só existem dentro do próprio painel (`UserControls/Pane/InfoPane.xaml` ~l.169-175). Resultado (INFERRED): mostrar o Preview com o painel fechado exige abrir o painel (botão ou `Ctrl+Alt+I`) e depois clicar na aba Preview: 2 passos, e nomes "Toggle" que não alternam. É a "volta gigante" do §9.

## TASK

Fazer `Toggle Preview Pane` e `Toggle Details Pane` serem comandos de um passo, com a semântica de alternar:

1. Painel fechado → abre **já na aba pedida** (Preview ou Details).
2. Painel aberto em outra aba → troca para a aba pedida.
3. Painel aberto na aba pedida → fecha o painel.
4. Sempre executáveis (remover a dependência de `IsEnabled`) e `IsAccessibleGlobally = true`, para aparecerem no Command Palette.
5. Atalhos sugeridos, **familiares do Explorer do Windows**: `Alt+P` = Preview, `Alt+Shift+P` = Details. Verificado por busca em `Actions/`: nenhuma ação usa essas combinações (`EditPath` usa `Alt+D`, `SplitPaneVertically` usa `Alt+Shift+V`, `CommandPalette` usa `Ctrl+Shift+P`). **Reconfirme** com `rg "KeyModifiers.Alt"` antes de fixar e verifique também o menu e o modo de navegação por teclas de acesso. Se houver conflito, escolha outra e registre.
6. Exibir o atalho na UI onde o comando aparece (`HotKeyText`) e no tooltip dos botões do painel.
7. Manter `ToggleInfoPane` como está.

Nomes de strings: usar as existentes (`Strings.TogglePreviewPane`, `Strings.ToggleDetailsPane`); só crie string nova (e entrada no `Strings.resx` en-US) se faltar.

## ACCEPTANCE (§9, §32)

- Com o painel fechado, um único atalho mostra o Preview (ou Details). O mesmo atalho de novo fecha.
- Aparecem no Command Palette.
- Estado persistido (aba escolhida e aberto/fechado) continua restaurando ao reiniciar.
- Teclado: foco volta para a lista de arquivos ao fechar; nomes acessíveis (AutomationName) preenchidos.
- Sem regressão no botão da toolbar e nas abas internas do painel.

## ARQUIVOS PROVÁVEIS

`Actions/Show/TogglePreviewPaneAction.cs`, `Actions/Show/ToggleDetailsPaneAction.cs` (edição pequena, são só estes dois), `InfoPane.xaml` (tooltips), `Strings.resx` se necessário. Testes em `tests/Files.App.UnitTests` se a lógica puder ser isolada (decisão aberto/aba como função pura).

## DO NOT CHANGE

`InfoPaneViewModel`, `IInfoPaneSettingsService`, `ToggleInfoPaneAction`, o conteúdo dos painéis.

## TESTES OBRIGATÓRIOS

Unitário da regra de alternância (fechado→abre na aba; aberto em outra aba→troca; aberto na mesma→fecha). Funcional: os 3 casos acima nos layouts Details, Grid e Column, com arquivo de imagem, texto, pasta e seleção vazia; reiniciar o app e conferir persistência. Regressão: `Ctrl+Alt+I`, botão da toolbar, troca de aba clicando.

## FORA DE ESCOPO

Menu clássico (F004), redesenho do painel, novos tipos de preview.

## ENTREGA

Handoff, relatório do §38, commit local na branch da feature, sem push.
