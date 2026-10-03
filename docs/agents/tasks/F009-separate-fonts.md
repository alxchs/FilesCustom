# F009 — Fonte das áreas fixas separada da fonte dos resultados

Status: BRIEF APROVADO para análise e implementação (Claude, 03/10/2026), depois de F008 (fila do §46). Executor: AGY. Branch: `feature/separate-fonts`. Spec: `MASTER_SPEC.md` §46.

## ARQUITETURA ATUAL (lida no código em 03/10/2026; nada executado)

- Uma única fonte global: `IAppearanceSettingsService.AppThemeFontFamily` (padrão `Constants.Appearance.StandardFont`, Segoe UI Variable no Windows 11), lida em `Helpers/UI/AppThemeResourcesHelper.cs` (~l.22 e ~l.106: `service.SetAppThemeFontFamily(...)` só se diferente do padrão) e escolhida em `ViewModels/Settings/AppearanceViewModel.cs` (lista `AppThemeFontFamilyOptions`, `LoadAppThemeFontFamilyOptions`).
- Hipótese (INFERRED): `SetAppThemeFontFamily` sobrescreve um recurso de tema global (ex.: `ContentControlThemeFontFamily`), que afeta **tudo**, inclusive nomes de arquivo e colunas. Confirmar no código de `AppThemeResourcesHelper`.

## TASK

1. **Análise:** confirmar como a fonte global é aplicada e onde estão os modelos dos itens da lista (Details: `ItemName`, colunas; List; Grid; Columns) para ver como dar a eles uma fonte própria sem mexer em cada XAML.
2. **Desenho** (`docs/architecture/separate-fonts.md`): duas configurações, **Fonte da interface** (áreas fixas: menus, barra lateral, abas, toolbar, status, diálogos) e **Fonte da lista de arquivos** (nomes e colunas), mais tamanho opcional de cada uma. Padrão das duas = fonte atual. Mecanismo sugerido: manter o recurso global para a interface e introduzir um recurso próprio (ex.: `FileListFontFamily`/`FileListFontSize`) referenciado pelos modelos de item dos layouts.
3. **Implementar** em `feature/separate-fonts`, com a tela de Settings > Appearance mostrando as duas.

## ACCEPTANCE

- Mudar a fonte da interface não muda a lista, e vice-versa; aplica sem reiniciar; persiste; fonte ausente cai no padrão sem erro.
- Funciona em Details, List, Columns, Grid e na barra de menus da F004.
- Altura de linha da lista respeita o tamanho da fonte (integração com F008: fonte maior não pode cortar na densidade compacta).
- Acessibilidade: respeita escala de texto do Windows; contraste intacto.

## DO NOT CHANGE

O mecanismo de tema atual além do necessário; `Constants.Appearance.StandardFont`.

## TESTES OBRIGATÓRIOS

Fonte monoespaçada na lista e Segoe na interface (e o inverso), tamanho 9 e 16, DPI 100/150%, nomes longos, caracteres CJK/emoji; reiniciar e conferir persistência.

## ENTREGA

`docs/architecture/separate-fonts.md`, relatório do §38, handoff, commits locais, sem push.
