# Plano de Implementação: F008 Densidade Ultra-Compacta

## Fases do Plano
1. **Fase 1: Modelo de Dados e Serviços**
   - Criar enum `AppDensityKind` (`Normal=0`, `Compact=1`, `UltraCompact=2`).
   - Adicionar propriedade `AppDensity` em `IAppearanceSettingsService` e `AppearanceSettingsService`.

2. **Fase 2: Recursos de Tema da Barra Lateral**
   - Adicionar método `SetAppThemeDensity(AppDensityKind density)` em `IResourcesService` e `AppResourcesService`.
   - Declarar recurso `App.Theme.Sidebar.ItemHeight` em `App.xaml` e aplicá-lo em `SidebarStyles.xaml`.

3. **Fase 3: Altura de Linhas dos Layouts**
   - Atualizar `LayoutSizeKindHelper` para considerar `AppDensity`.
   - Conectar escuta de `PropertyChanged` em `DetailsLayoutPage` para invalidar e reaplicar estilos quando `AppDensity` mudar.

4. **Fase 4: Interface do Usuário (Settings)**
   - Adicionar strings localizadas em `en-US` e `pt-BR`.
   - Adicionar propriedade `SelectedAppDensityIndex` e coleção `AppDensityOptions` em `AppearanceViewModel`.
   - Adicionar `SettingsCard` com ComboBox em `AppearancePage.xaml`.

5. **Fase 5: Verificação e Validação**
   - Compilação Release x64 com 0 Warnings / 0 Errors.
   - Atualização do pacote local via `Open-FilesDev.ps1 -NoLaunch`.
   - Teste de interface e registro de evidências.
