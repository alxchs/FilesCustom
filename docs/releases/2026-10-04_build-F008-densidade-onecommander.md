# Nota de Liberação: F008 - Densidade Ultra-Compacta (OneCommander Style)

Data: 2026-10-04  
Versão do Pacote: `FilesDev_4.2.37.0_x64__ykqwq8d6ps0ag`  
Branch: `feature/compact-density`  
Autor: Antigravity (AGY)

---

## 1. Resumo da Entrega

Implementação do recurso **F008: Modo Compacto / Densidade OneCommander**, permitindo ajustar a densidade visual de toda a aplicação entre 3 modos:
1. **Normal**: espaçamento padrão do Files (36px altura de linha em Details, 40px na barra lateral).
2. **Compacto**: espaçamento reduzido e otimizado para mouse (28px altura de linha em Details, 32px na barra lateral).
3. **Ultra-Compacto (OneCommander)**: máxima densidade de itens visíveis por tela (24px altura de linha em Details, 22px em Lista/Colunas, 30px na barra lateral), ideal para gerenciamento intensivo de arquivos e navegação rápida por teclado/mouse.

---

## 2. Componentes e Alterações

- **Modelo de Dados e Enums**:
  - `src/Files.App/Data/Enums/AppDensityKind.cs`: Enum com `Normal=0`, `Compact=1`, `UltraCompact=2`.
  - `IAppearanceSettingsService.cs` / `AppearanceSettingsService.cs`: Propriedade persistida `AppDensity`.
- **Serviço de Recursos Dinâmicos**:
  - `IResourcesService.cs` / `AppResourcesService.cs`: Método `SetAppThemeDensity(AppDensityKind density)` que ajusta em tempo de execução a chave `{ThemeResource App.Theme.Sidebar.ItemHeight}` (Normal=40, Compact=32, UltraCompact=30) e ouve eventos de alteração de preferências.
- **Layouts e Altura de Linha**:
  - `src/Files.App/Helpers/Layout/LayoutSizeKindHelper.cs`: Cálculo de alturas de linha para Details, List e Columns considerando a preferência `AppDensity`.
  - `src/Files.App/Views/Layouts/DetailsLayoutPage.xaml.cs`: Listener de `AppearanceSettingsService.PropertyChanged` para invalidar `RowHeight` e re-estilizar contêineres sem resetar o scroll.
- **UI e Configurações**:
  - `src/Files.App/ViewModels/Settings/AppearanceViewModel.cs`: Exposição de `AppDensityOptions` e `SelectedAppDensityIndex`.
  - `src/Files.App/Views/Settings/AppearancePage.xaml`: Inclusão do `SettingsCard` de Densidade da interface sob a seção Aparência.
  - `Resources.resw` (`en-US` e `pt-BR`): Chaves de localização adicionadas.

---

## 3. Verificação de Qualidade e Compilação

- **Compilação**:
  - Comando: `dotnet build src/Files.App/Files.App.csproj -c Release -p:Platform=x64 -v:quiet -clp:ErrorsOnly`
  - Resultado: **0 Warning(s), 0 Error(s)**.
- **Registro do Pacote**:
  - Registrado com sucesso pelo script `Open-FilesDev.ps1 -Configuration Release -NoLaunch`.
- **Evidências Visuais Capturadas**:
  - `docs/agents/evidence/f008/density_normal.png`: Exibição padrão.
  - `docs/agents/evidence/f008/density_compact.png`: Modo compacto.
  - `docs/agents/evidence/f008/density_ultracompact.png`: Modo ultra-compacto estilo OneCommander.
  - `docs/agents/evidence/f008/density_settings_appearance.png`: Seletor de densidade em Configurações > Aparência.
