# F002 — Tarefas de Investigação e Validação

## Status: CONCLUÍDO (Investigação e Validação Empírica / Arquitetural)

Data: 2026-10-05
Branch: `feature/independent-column-resize`

---

### T1 — Medição e arquitetura de larguras
- [x] Inspecionar modelo de colunas (`ColumnsViewModel.cs`, `DetailsLayoutColumnItem.cs`).
- [x] Inspecionar definição de colunas no XAML (`DetailsLayoutPage.xaml`).
- [x] Inspecionar manipulador do `GridSplitter` (`GridSplitter.Events.cs`, `GridSplitter.Helper.cs`).
- [x] Evidência: `GridSplitter.Events.cs` linhas 266–274 confirma que para colunas de pixel fixo (`!IsStarColumn(CurrentColumn)`), apenas a coluna atual é redimensionada via `SetColumnWidth`. Nenhuma coluna vizinha é alterada.

### T2 — Teste de independência entre colunas
- [x] Verificar se o arraste do divisor de uma coluna altera a coluna vizinha.
- [x] Resultado: **CONFIRMED — Não altera**. Todas as colunas usam `GridUnitType.Pixel`. O `GridSplitter` opera exclusivamente sobre `CurrentColumn`. As colunas irmãs (`SiblingColumn`) permanecem intactas.
- [x] Verificar se a coluna Nome absorve diferenças automaticamente: **CONFIRMED — Não absorve**. A coluna Nome tem largura fixa em pixels com `NormalMaxLength = 1000d`.

### T3 — Teste de limites (mínimo e máximo)
- [x] Largura máxima: `NormalMaxLength` definida por coluna (Nome: 1000px, Status: 80px, Path: 500px, demais: 800px). Respeitada no drag e no auto-fit.
- [x] Largura mínima: `NormalMinLength = 50px` definida no modelo.
- [x] **Discrepância detectada**: `ColumnDefinition.MinWidth` não está vinculada no XAML (`DetailsLayoutPage.xaml`). Durante o arraste manual com mouse, o splitter permite reduzir até ~13px (largura física do splitter + 1). No duplo clique (`ResizeColumnToFit`), o mínimo de 50px é garantido.
- [x] Proposta de correção mínima (registrada para implementação futura, sem alteração de produto agora): vincular `MinWidth="{x:Bind ColumnsViewModel.<Col>.MinLength, Mode=OneWay}"` nas `ColumnDefinition` do `DetailsLayoutPage.xaml`.

### T4 — Comportamento com redimensionamento de janela
- [x] Janela expandida além da largura total das colunas: espaço em branco após a última coluna, sem distorção das colunas existentes.
- [x] Janela estreitada: scrollbar horizontal (`ScrollViewer.HorizontalScrollBarVisibility="Auto"`) é exibida automaticamente, preservando as larguras das colunas sem corte de conteúdo.
- [x] Redimensionar a janela não dispara auto-fit indesejado.

### T5 — Persistência
- [x] Persistência por pasta: gravada no Registro do Windows em `HKCU\Software\Files Community\<PackageId>\v1\LayoutPreferences\<pasta>` ao soltar o splitter (`GridSplitter_ManipulationCompleted`).
- [x] Persistência padrão global: item de menu "Definir como padrão" (`SetCurrentColumnsAsDefaultMenuFlyoutItem`) salva as larguras atuais no JSON de configurações de layout do usuário.

### T6 — Auto-fit por duplo clique e menu
- [x] Duplo clique no divisor: `GridSplitter_DoubleTapped` dispara `ResizeColumnToFit(coluna)`.
- [x] Menu de contexto: item "Ajustar todas as colunas ao conteúdo" (`SizeAllColumnsToFit_Click`) chama `Commands.AutoFitColumns`.
- [x] Opção `LayoutSettingsService.AutoSizeColumnsInDetailsLayout`: auto-fit opcional ao carregar a pasta com debounce de 250ms.

### T7 — Comparação OneCommander e queixa histórica
- [x] Comparação documentada em `docs/ux-reference/onecommander/columns.md`.
- [x] Diagnóstico: O sintoma de "colunas amarradas" decorre de layouts onde a coluna principal usa dimensionamento proporcional (`Star` / `*`), fazendo com que o ajuste de uma coluna reduza a coluna principal. No Files App, todas as colunas já utilizam largura fixa em pixels (`Pixel`), portanto a queixa não procede no código atual.
