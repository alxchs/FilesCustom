# F004 — Plano de Implementação da Barra de Menus Tradicional

## 1. Arquitetura e Componentes

### 1.1 Controle Visual Isolado
- Local: `src/Files.App/UserControls/Menus/ClassicMenuBar.xaml` e `ClassicMenuBar.xaml.cs`.
- Base: `UserControl` envelopando um `MenuBar` nativo do WinUI 3.
- Recursos: `ICommandManager` injetado via `Ioc.Default.GetRequiredService<ICommandManager>()`.
- Menus:
  - `MenuBarItem Title="{helpers:ResourceString Name=Menu_File}" AccessKey="F"`
  - `MenuBarItem Title="{helpers:ResourceString Name=Menu_Edit}" AccessKey="E"`
  - `MenuBarItem Title="{helpers:ResourceString Name=Menu_View}" AccessKey="V"`
  - `MenuBarItem Title="{helpers:ResourceString Name=Menu_Go}" AccessKey="G"`
  - `MenuBarItem Title="{helpers:ResourceString Name=Menu_Tools}" AccessKey="T"`
  - `MenuBarItem Title="{helpers:ResourceString Name=Menu_Help}" AccessKey="H"`

### 1.2 Serviço de Configurações
- `IAppearanceSettingsService`: Adicionar propriedade booleana `ShowClassicMenuBar { get; set; }`.
- `AppearanceSettingsService`: Implementar persistência JSON automática com `Get(false)` e `Set(value)`.
- `AppearanceViewModel`: Expor propriedade TwoWay para ligação na página de configurações.
- `MainPageViewModel`: Expor `bool ShowClassicMenuBar => AppearanceSettingsService.ShowClassicMenuBar` com notificação de `PropertyChanged`.

### 1.3 Integração no Layout Principal (`MainPage.xaml`)
- Inserir linha `Auto` no `Grid` de nível superior logo abaixo do `TabControl` (Row 1):
  ```xml
  <localMenus:ClassicMenuBar
      Grid.Row="1"
      HorizontalAlignment="Stretch"
      Visibility="{x:Bind ViewModel.ShowClassicMenuBar, Mode=OneWay, Converter={StaticResource BoolToVisibilityConverter}}" />
  ```
- Atualizar linhas subsequentes: `NavToolbar` para `Grid.Row="2"` e `SidebarControl` para `Grid.Row="3"`.
- Atualizar imagem de fundo para `Grid.RowSpan="4"`.

### 1.4 Interface de Configuração (`AppearancePage.xaml`)
- Inserir `SettingsCard` na seção de interface com `ToggleSwitch` associado a `ViewModel.ShowClassicMenuBar`.

---

## 2. Etapas de Execução

1. **Documentação de Referência e Arquitetura**:
   - `docs/ux-reference/onecommander/menus.md`: Análise da ausência de menus tradicionais no OneCommander e justificativa técnica.
   - `docs/architecture/classic-menu.md`: Mapeamento completo dos 6 menus e seus respectivos comandos do `ICommandManager`.
2. **Camada de Configuração**:
   - `IAppearanceSettingsService.cs`, `AppearanceSettingsService.cs`, `AppearanceViewModel.cs`, `MainPageViewModel.cs`.
   - Adicionar strings localizadas em `en-US` e `pt-BR`.
3. **Criação do Controle `ClassicMenuBar`**:
   - Desenvolver XAML limpo utilizando `MenuFlyoutItem`, `MenuFlyoutSubItem` e `MenuFlyoutSeparator`.
   - Conectar aos comandos do `ICommandManager`.
4. **Integração na `MainPage.xaml` e `AppearancePage.xaml`**:
   - Posicionamento da linha e visibilidade dinâmica.
5. **Compilação e Verificação**:
   - Compilar sem avisos nem erros.
   - Teste de interface: inicialização padrão (barra oculta), ativação via configurações (barra visível), navegação por teclado (`Alt+F`, setas, `Esc`), verificação de contraste em tema escuro e claro.
6. **Entrega e Checkpoint**:
   - Commit local, nota de liberação em `docs/releases/`, handoff em `docs/agents/handoffs/`, atualização de `STATUS.md`.

