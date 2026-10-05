# Nota de Liberação: F009 — Fonte das Áreas Fixas Separada da Fonte dos Resultados

Data: 2026-10-04  
Versão do Pacote: `FilesDev_4.2.37.0_x64__ykqwq8d6ps0ag`  
Branch: `feature/separate-fonts`  
Autor: Antigravity (AGY)

---

## 1. Resumo da Entrega

Implementação do recurso **F009: Fonte das Áreas Fixas Separada da Fonte dos Resultados (OneCommander Style)**.
No Files original, havia apenas uma única fonte global (`ContentControlThemeFontFamily`) aplicada indistintamente a todos os controles e textos da aplicação.

Com o F009, o usuário agora tem controle granular independente:
1. **Fonte da Interface (Áreas Fixas)**:
   - Configura a tipografia de menus, abas, barra de ferramentas, barra lateral e diálogos.
2. **Fonte da Lista de Arquivos e Colunas (Resultados)**:
   - Configura a tipografia exclusiva da listagem de arquivos, cabeçalhos de coluna e detalhes em todos os modos de exibição (`Details`, `Grid`, `Columns`).
   - Permite usar uma tipografia otimizada (como fontes compactas, monoespaçadas ou mais densas) para o conteúdo de arquivos sem afetar a harmonia visual da moldura e menus do aplicativo.

---

## 2. Componentes e Alterações

- **Contratos e Serviços de Configuração**:
  - `src/Files.App/Data/Contracts/IAppearanceSettingsService.cs` & `AppearanceSettingsService.cs`:
    - Adicionada propriedade persistida `AppThemeFileAreaFontFamily`.
  - `src/Files.App/Data/Contracts/IResourcesService.cs` & `AppResourcesService.cs`:
    - Adicionado método `SetAppThemeFileAreaFontFamily(string fontFamily)` com atualização dinâmica de `Application.Current.Resources["App.Theme.FileArea.FontFamily"]`.
  - `src/Files.App/Helpers/UI/AppThemeResourcesHelper.cs`:
    - Carregamento e aplicação das duas fontes na inicialização do app.
- **Recursos XAML e Estilos de Layout**:
  - `src/Files.App/App.xaml`:
    - Declarado recurso XAML `{ThemeResource App.Theme.FileArea.FontFamily}`.
  - `src/Files.App/UserControls/DataGridHeader.xaml`:
    - Cabeçalhos de coluna (Nome, Data, Tipo, Tamanho) agora usam `{ThemeResource App.Theme.FileArea.FontFamily}`.
  - `src/Files.App/Views/Layouts/DetailsLayoutPage.xaml`, `GridLayoutPage.xaml`, `ColumnLayoutPage.xaml`:
    - Contêiner de lista `FileList` e estilos de cabeçalho vinculados a `{ThemeResource App.Theme.FileArea.FontFamily}`.
- **UI de Configuração e Localização**:
  - `src/Files.App/ViewModels/Settings/AppearanceViewModel.cs`:
    - Expostos `AppThemeFileAreaFontFamily` e `SelectedAppThemeFileAreaFontFamilyOption`.
  - `src/Files.App/Views/Settings/AppearancePage.xaml`:
    - Adicionado `SettingsCard` independente para "Fonte dos arquivos e colunas".
  - `src/Files.App/Strings/en-US/Resources.resw` e `pt-BR/Resources.resw`:
    - Chaves `AppThemeFileAreaFontFamily` adicionadas e traduzidas.

---

## 3. Validação e Compilação

- **Compilação**:
  - Comando: `dotnet build src/Files.App/Files.App.csproj -c Release -p:Platform=x64 -v:quiet -clp:ErrorsOnly`
  - Resultado: **0 Warning(s), 0 Error(s)** em 00:03:50.
- **Registro do Pacote**:
  - Registrado com sucesso pelo script `Open-FilesDev.ps1 -Configuration Release -NoLaunch`.
- **Evidências Visuais Capturadas**:
  - `docs/agents/evidence/f009/f009_settings_fonts.png`: Mostra a página Configurações > Aparência com os dois seletores ativos: "Font" configurado com Trebuchet MS e "Files and columns font" com Default.
  - `docs/agents/evidence/f009/f009_files_separate_font.png`: Mostra o aplicativo em operação real, com a barra lateral/abas exibindo a fonte de interface (Trebuchet MS) e a lista de itens/arquivos recentes exibindo a fonte padrão dedicada.
