# F008 — Modo compacto (menor entrelinhamento)

Status: BRIEF APROVADO para análise e implementação (Claude, 03/10/2026), mas só **depois** de F001 e F005 (fila do §46). Executor: AGY. Branch: `feature/compact-density`. Spec: `MASTER_SPEC.md` §46.

## ARQUITETURA ATUAL (lida no código em 03/10/2026; nada executado)

- Altura de linha por layout, em `src/Files.App/Helpers/Layout/LayoutSizeKindHelper.cs`: `GetDetailsViewRowHeight` devolve **28 (Compact), 36, 40, 44, 48 px**; o tamanho do ícone vem do mesmo helper (Compact = `ShellIconSizes.Small`). Enums `DetailsViewSizeKind`, `ListViewSizeKind`, `ColumnsViewSizeKind` (Compact=1 … ExtraLarge=5), escolhidos em `ILayoutSettingsService`.
- Sem opção de densidade para as áreas fixas (barra lateral, abas, barra de ferramentas, barra de status). O upstream tem trabalho nisso na branch `ya/CompactSpacing` (commit "Added density setting for the sidebar"): ler o diff antes (`git log origin/ya/CompactSpacing`) e reaproveitar o desenho para não divergir.

## TASK

1. **Análise (somente leitura):** onde cada altura/margem vem (lista: helper e `DetailsLayoutPage.xaml`; barra lateral: `Files.App.Controls/Sidebar`; abas: `TabBar.xaml`; toolbar: `Toolbar.xaml`/`NavigationToolbar.xaml`; status: `StatusBar.xaml`). Medir quantas linhas cabem hoje na mesma janela (captura) com Compact.
2. **Desenho:** uma opção "Densidade da interface" (ex.: Padrão / Compacta / Ultra compacta) separada do tamanho de ícone por layout, aplicada à lista **e** às áreas fixas por **recursos de estilo** (valores num `ResourceDictionary` próprio, não valores soltos em cada XAML). Ultra compacta = abaixo dos 28 px atuais (ex.: 22-24 px), com ícone e fonte proporcionais. Decidir no `docs/architecture/compact-density.md`.
3. **Implementar** em `feature/compact-density`, com padrão = comportamento atual.

## ACCEPTANCE

- Padrão idêntico ao app atual (comparar capturas antes/depois).
- Compacta e Ultra compacta aumentam as linhas visíveis (medir: número de linhas na mesma janela e resolução, antes/depois, em Details, List e Columns).
- Texto sem corte, ícones nítidos, DPI 100% e 150%, tema claro e escuro, seleção e hover legíveis, navegação por teclado intacta, alvo de clique documentado.
- Aplica sem reiniciar; persiste.

## DO NOT CHANGE

`DetailsViewSizeKind` e valores atuais (outras partes dependem deles). Layouts que a densidade não deve afetar (Grid usa miniaturas).

## TESTES OBRIGATÓRIOS

Funcional nos três layouts com a pasta de 10 mil itens (rolagem sem engasgo, §31); regressão de seleção por arraste e de renomear (F001: caixa de edição deve caber na linha compacta).

## ENTREGA

`docs/architecture/compact-density.md`, relatório do §38, handoff, commits locais, sem push.
