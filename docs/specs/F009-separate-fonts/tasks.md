# Tarefas: F009 — Fonte das Áreas Fixas Separada da Fonte dos Resultados

- [x] **T1: Modelagem e Serviços de Configuração**
  - Adicionar propriedade `AppThemeFileAreaFontFamily` em `IAppearanceSettingsService.cs` e `AppearanceSettingsService.cs`.
  - Adicionar método `SetAppThemeFileAreaFontFamily` em `IResourcesService.cs` e `AppResourcesService.cs`.
  - Adicionar inicialização em `AppThemeResourcesHelper.cs`.

- [x] **T2: Recursos XAML e Vínculo aos Layouts de Arquivos**
  - Declarar `App.Theme.FileArea.FontFamily` em `src/Files.App/App.xaml`.
  - Vincular `{ThemeResource App.Theme.FileArea.FontFamily}` em:
    - `src/Files.App/Views/Layouts/DetailsLayoutPage.xaml`
    - `src/Files.App/Views/Layouts/GridLayoutPage.xaml`
    - `src/Files.App/Views/Layouts/ColumnLayoutPage.xaml`
    - `src/Files.App/UserControls/DataGridHeader.xaml`

- [x] **T3: ViewModel e UI de Configurações**
  - Adicionar strings localizadas em `src/Files.App/Strings/en-US/Resources.resw` e `pt-BR/Resources.resw`.
  - Expor `SelectedAppThemeFileAreaFontFamilyOption` em `AppearanceViewModel.cs`.
  - Adicionar `SettingsCard` de "Fonte da lista de arquivos" em `AppearancePage.xaml`.

- [x] **T4: Compilação e Validação do Build**
  - Compilar em Release x64 garantindo **0 Warning(s) e 0 Error(s)**.
  - Registrar pacote via `Open-FilesDev.ps1 -Configuration Release -NoLaunch`.

- [x] **T5: Validação Funcional, Evidências e Fechamento**
  - Testar alternância independente entre as duas fontes no app em execução.
  - Capturar evidências em `docs/agents/evidence/f009/`.
  - Gerar nota de liberação em `docs/releases/`.
  - Gerar handoff em `docs/agents/handoffs/`.
  - Atualizar `AGENT_CONTEXT.md` e `STATUS.md`.
