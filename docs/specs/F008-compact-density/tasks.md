# Tarefas: F008 Densidade Ultra-Compacta

- [x] **T1: Modelagem e Configurações**
  - Criar enum `AppDensityKind` em `src/Files.App/Data/Enums/AppDensityKind.cs`.
  - Adicionar propriedade `AppDensity` em `IAppearanceSettingsService.cs` e `AppearanceSettingsService.cs`.

- [x] **T2: Ajustes Dinâmicos da Barra Lateral (Sidebar)**
  - Adicionar `SetAppThemeDensity` em `IResourcesService` e `AppResourcesService`.
  - Definir `App.Theme.Sidebar.ItemHeight` em `App.xaml` e conectar em `SidebarStyles.xaml`.
  - Chamar `SetAppThemeDensity` na inicialização em `AppThemeResourcesHelper.cs`.

- [x] **T3: Ajustes de Altura de Itens nos Layouts**
  - Atualizar `LayoutSizeKindHelper.cs` com alturas para `Compact` e `UltraCompact`.
  - Adicionar listener de atualização em `DetailsLayoutPage.xaml.cs`.

- [x] **T4: UI de Configuração e Localização**
  - Adicionar strings `AppDensity`, `AppDensityNormal`, `AppDensityCompact`, `AppDensityUltraCompact` em `en-US` e `pt-BR`.
  - Expor `AppDensityOptions` e `SelectedAppDensityIndex` em `AppearanceViewModel.cs`.
  - Incluir `SettingsCard` de Densidade da Interface em `AppearancePage.xaml`.

- [x] **T5: Validação e Build Oficial**
  - Compilar em Release x64 com 0 Warnings e 0 Errors.
  - Registrar pacote via `Open-FilesDev.ps1 -Configuration Release -NoLaunch`.

- [x] **T6: Evidências e Fechamento**
  - Documentar evidências visuais e comportamentais.
  - Elaborar nota de liberação em `docs/releases/`.
  - Elaborar handoff em `docs/agents/handoffs/`.
  - Atualizar `AGENT_CONTEXT.md` e `STATUS.md`.
