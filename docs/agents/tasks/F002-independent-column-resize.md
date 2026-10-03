# F002 — Colunas com redimensionamento independente

Status: BRIEF EM RASCUNHO, **sem pré-aprovação de implementação** (Claude, 03/10/2026). Executor: AGY faz a investigação por teste; o Claude aprova antes de codar. Branch: `feature/independent-column-resize`.

## ARQUITETURA ATUAL (lida no código em 03/10/2026; nada executado, tudo NOT TESTED)

`src/Files.App/Views/Layouts/DetailsLayoutPage.xaml(.cs)`, layout Details:

- Cada coluna é um `ColumnDefinition` de um `Grid` com um `Files.App.Controls.GridSplitter` entre elas. `ColumnsViewModel` (`Data/Models/ColumnsViewModel.cs`) guarda um `DetailsLayoutColumnItem` por coluna (`UserLength`, `NormalMaxLength`, `UserCollapsed`, `IsResizable`).
- Arrastar: `GridSplitter_ManipulationDelta` → `UpdateColumnLayout()` copia `Column2.Width`…`Column12.Width` para o view model; ao soltar, `GridSplitter_ManipulationCompleted` grava em `FolderSettings.ColumnsViewModel` (persistência por pasta/layout). Teclado: `GridSplitter_PreviewKeyUp` (setas).
- Duplo clique no divisor: `GridSplitter_DoubleTapped` → `ResizeColumnToFit(colunaÍndice)` (já existe auto-fit por coluna). Menu "Size all columns to fit" → `Commands.AutoFitColumns` (`Actions/Display/AutoFitColumnsAction.cs`).
- Existe a opção `LayoutSettingsService.AutoSizeColumnsInDetailsLayout` (auto-fit ao carregar, com debounce de 250 ms em `AutoFitColumnsIfEnabled`).
- Há larguras máximas (`NormalMaxLength`, p.ex. 1000, 500, 80). Mínima: ver `ColumnsViewModel`/estilo do `GridSplitter` (**não lida ainda**).

Ou seja, grande parte do §6 (auto-fit, double-click, persistência, máximo) **já existe**. O que não se sabe é se arrastar um divisor muda **outra** coluna (efeito colateral), que é a queixa do §6/§4.2.

## TASK (investigação por teste, sem código de produto)

No app (`Open-FilesDev.ps1`, `C:\FilesUXLab`, pasta com nomes curtos, nomes muito longos e a de 10 mil arquivos):

1. Arrastar o divisor de cada coluna e medir a largura de **todas** as colunas antes/depois (UI Automation ou captura + régua; registrar números). Responder: (a) a coluna vizinha muda? (b) a coluna Nome (provavelmente `*`) absorve a diferença? (c) existe largura mínima efetiva e qual? (d) o que acontece ao reduzir a janela e ao maximizar? (e) os valores persistem após fechar/reabrir e entre pastas?
2. Repetir em DPI 100% e 150% se possível (§6).
3. Comparar com o OneCommander só por observação externa: `docs/ux-reference/onecommander/columns.md` (modelo §18) e dizer se a queixa original ("colunas amarradas") ocorre no Files.
4. Resultado em `STATUS.md` (CONFIRMED/OBSERVED por caso, com captura) e proposta de correção mínima (qual arquivo, qual comportamento), **sem implementar**.

## ACCEPTANCE (do §6, para a fase de implementação futura)

Ajustar uma coluna não causa efeito colateral inesperado nas outras; largura mínima e máxima definidas; auto-fit por duplo clique; persistência entre pastas e sessões; comportamento previsível ao redimensionar a janela.

## ARQUIVOS PROVÁVEIS (fase de implementação, se for necessária)

`DetailsLayoutPage.xaml(.cs)`, `ColumnsViewModel.cs`, `Controls/GridSplitter` (em `Files.App.Controls`). Layout Column (`ColumnLayoutPage`) e Grid ficam fora.

## DO NOT CHANGE

Formato de persistência de `FolderSettings.ColumnsViewModel` sem migração (quebra as configurações existentes). `AutoFitColumnsAction`.

## FORA DE ESCOPO

Reordenar colunas, novas colunas, outros layouts.

## ENTREGA

Handoff, evidências em `docs/ux-reference/onecommander/evidence/columns/` (OneCommander) e `STATUS.md` (Files), commit local, sem push.
