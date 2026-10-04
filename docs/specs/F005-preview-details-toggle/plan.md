# F005 — Preview e Details com acesso imediato — PLAN

Status: **APROVADO** (Claude, 04/10/2026). Só vale com a `spec.md` APROVADA. Estado de cada afirmação: lido em 04/10/2026 nos arquivos citados.

## Arquitetura atual
- **CONFIRMED** (arquivo lido): `Actions/Show/TogglePreviewPaneAction.cs` e `ToggleDetailsPaneAction.cs` são `IAction` (não `IToggleAction`), sem `HotKey`, com `IsAccessibleGlobally => false` e `IsExecutable => infoPaneViewModel.IsEnabled`. `ExecuteAsync` só faz `infoPaneSettingsService.SelectedTab = InfoPaneTabs.Preview` (ou `Details`). (O `ToggleDetailsPaneAction.cs` não foi reaberto hoje; o brief de 03/10 o descreve igual.)
- **CONFIRMED**: `ToggleInfoPaneAction` (`IToggleAction`, `Ctrl+Alt+I`) alterna `InfoPaneViewModel.IsEnabled`.
- **CONFIRMED** (busca em `Actions/`): nenhuma ação usa `Alt+P` nem `Alt+Shift+P`. Usadas com Alt: `Alt+D`, `Alt+←/→/↑`, `Alt+Enter`, `Alt+Shift+H/V/Enter`; `Ctrl+Shift+P` é a paleta.
- **CONFIRMED** (busca em `InfoPane.xaml`): os botões das abas ficam em `UserControls/Pane/InfoPane.xaml`, ligados a `Commands.ToggleDetailsPane` e `Commands.TogglePreviewPane` (~l.169-175).
- **INFERRED**: o foco volta à lista ao fechar pelo botão da barra; não verificado para o atalho (T5 verifica).
- **NOT TESTED**: conflito com teclas de acesso do menu e comportamento no layout Column.

## Abordagem
1. A **decisão** fica numa função pura em arquivo próprio, genérica no tipo da aba: `(painelAberto, abaAtual, abaPedida) → (painelAberto', aba')` com as 6 linhas da tabela AC-1..AC-6. Isso permite testar sem WinUI e mantém o diff pequeno (`MASTER_SPEC` §13).
2. As duas ações chamam a função e aplicam o resultado em `InfoPaneViewModel.IsEnabled` e `SelectedTab` (só por suas propriedades públicas já existentes).
3. `IsExecutable => true`, `IsAccessibleGlobally => true`, `HotKey` `Alt+P` / `Alt+Shift+P` (mesmo padrão do `ToggleInfoPaneAction`).
4. Tooltips das abas (`InfoPane.xaml`) mostram o atalho; strings existentes (`TogglePreviewPane`, `ToggleDetailsPane`), nova só se faltar.
- **Descartada:** transformar em `IToggleAction`: o estado "ligado" é por aba, não booleano; o `IsOn` ficaria ambíguo.
- **Descartada:** mexer em `InfoPaneViewModel`: fora do escopo e arriscado para o upstream.

## Mapa spec → código
| Requisito | Onde |
|---|---|
| FR-001 | função pura nova (`Helpers/`) usada pelas duas ações |
| FR-002, FR-003 | `IsExecutable`, `IsAccessibleGlobally` das duas ações |
| FR-004, FR-005 | `HotKey` das ações; tooltips em `InfoPane.xaml` |
| FR-006 | já existente (`SelectedTab` e `IsEnabled` persistem); T6 reconfirma |
| FR-007 | T5: verificar foco e `AutomationName`; corrigir só se faltar |
| FR-008 | nenhum arquivo tocado além dos listados |

## Arquivos
- Mexer: `Actions/Show/TogglePreviewPaneAction.cs`, `Actions/Show/ToggleDetailsPaneAction.cs`, `UserControls/Pane/InfoPane.xaml` (tooltips), arquivo de strings en-US só se faltar texto; **novo** arquivo da função pura em `Helpers/`.
- **Não mexer:** `InfoPaneViewModel`, `IInfoPaneSettingsService`, `ToggleInfoPaneAction`, o conteúdo dos painéis, `BulkRenameDialog` e tudo da F001.

## Riscos e regressões a vigiar
- Conflito do `Alt+P` com tecla de acesso de menu: provar no app (T6).
- `Alt+Shift+P` com o atalho de troca de idioma do teclado do Windows (`Alt+Shift`): **INFERRED** que só a combinação sem letra troca o idioma; provar no app.
- Comando sempre executável: não pode abrir o painel sobre estado inválido (sem aba escolhida): usar a aba padrão já existente.

## Estratégia de teste
Não existe projeto de testes unitários no repositório (`tests/` tem só `Files.App.UITests`, `Files.InteractionTests` e o script `test-rename-helper.ps1`; **os briefs antigos citam `tests/Files.App.UnitTests`, que não existe**). A função pura é testada por **script `pwsh` no padrão da F001** ou por projeto novo `tests/Files.Custom.Tests` que compila só o arquivo puro; escolher o mais simples e registrar em `DECISIONS.md`.

| Cenário | Tipo | Prova |
|---|---|---|
| AC-1 a AC-6 | unitário da função pura (6 casos) | script/projeto de teste verde |
| AC-1 a AC-6 | funcional no app | atalho nos 3 layouts, com imagem, texto, pasta, seleção vazia; captura |
| AC-7, AC-11 | funcional | captura da paleta com o atalho e do tooltip |
| AC-8 | funcional | fechar e reabrir o app nos dois estados |
| AC-9 | funcional | fechar por atalho e apertar uma seta: a seleção na lista muda |
| AC-10 | regressão | `Ctrl+Alt+I`, botão da barra, clique nas abas |
