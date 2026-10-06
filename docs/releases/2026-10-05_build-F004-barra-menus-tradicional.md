# Nota de Conclusão: F004 — Barra de Menus Tradicional Opcional

Data: 2026-10-05
Branch: `feature/classic-menu`
Responsável: Antigravity

---

## 1. Escopo e Objetivo

Implementar a **F004 — Barra de Menus Tradicional Opcional** (`MASTER_SPEC.md` §8) no Files Custom:
- Barra de menus clássica completa (WinUI 3 `MenuBar`): **File**, **Edit**, **View**, **Go**, **Tools**, **Help**.
- 100% opcional, desativada por padrão (`false`).
- Configuração do usuário em **Settings > Appearance** (`ShowClassicMenuBar`), persistida de forma nativa no `IAppearanceSettingsService`.
- Acesso por teclado com mnemonics completos (`Alt+F`, `Alt+E`, `Alt+V`, `Alt+G`, `Alt+T`, `Alt+H`), navegação por setas e fechamento por `Escape`.
- Integração total com o `ICommandManager` existente — reuso de 100% dos comandos e atalhos da aplicação (`Commands.<Action>`), sem duplicação de lógica.
- Suporte a localização completo (`en-US` e `pt-BR`).
- Compilação 100% limpa com **0 Warning(s), 0 Error(s)**.

---

## 2. Resumo Executivo da Implementação

| Componente | Detalhe da Implementação |
|---|---|
| **Contrato e Configuração** | Adicionado `ShowClassicMenuBar` em `IAppearanceSettingsService` com valor padrão `false`. |
| **Serviço de Configurações** | Implementado em `AppearanceSettingsService` lendo e gravando via container de configurações. |
| **ViewModels** | Exposto em `AppearanceViewModel` (com `OnPropertyChanged`) e propagado em `MainPageViewModel` ouvindo alterações em tempo real. |
| **Interface do Usuário (MenuBar)** | Criado controle XAML dedicado `ClassicMenuBar` em `src/Files.App/UserControls/Menus/ClassicMenuBar.xaml(.cs)` encapsulando a `MenuBar` e todos os 6 menus e submenus. |
| **Posicionamento na Janela Principal** | Inserido em `MainPage.xaml` na linha 1 do Grid principal (entre o `TabControl` e a barra de ferramentas de navegação `NavToolbar`), com visibilidade vinculada via `BoolToVisibilityConverter`. |
| **Tela de Configurações** | Adicionado `SettingsCard` com `ToggleSwitch` dedicado na aba Aparência (`AppearancePage.xaml`). |
| **Localização** | Adicionadas strings traduzidas em `en-US` e `pt-BR` para títulos dos menus e configurações. |

---

## 3. Evidências Visuais e Técnicas

| Arquivo de Evidência | Descrição |
|---|---|
| `docs/agents/evidence/f004/f004_initial_disabled.png` | Estado padrão inicial: MenuBar oculta, espaço zero ocupado, layout moderno inalterado. |
| `docs/agents/evidence/f004/f004_settings_appearance.png` | Tela de Configurações > Aparência com o interruptor "Show classic menu bar" / "Mostrar barra de menus tradicional". |
| `docs/agents/evidence/f004/f004_menu_bar_visible.png` | Files App renderizado com a barra de menus ativa (File, Edit, View, Go, Tools, Help). |
| `docs/agents/evidence/f004/f004_file_menu_opened.png` | Menu **File** aberto exibindo New tab, New window, New file/folder, Properties, Close tab, Exit. |
| `docs/agents/evidence/f004/f004_edit_menu_opened.png` | Menu **Edit** aberto exibindo Undo, Redo, Cut, Copy, Paste, Select All, Invert Selection. |
| `docs/agents/evidence/f004/f004_view_menu_opened.png` | Menu **View** aberto com submenus de Layout, Sort by, Group by, Panes (Details, Preview) e Refresh. |

---

## 4. Status de Compilação e Qualidade

- **Compilação**: `msbuild -restore src/Files.App/Files.App.csproj -p:Configuration=Release -p:Platform=x64 -v:quiet -clp:ErrorsOnly`
- **Resultado**: `Build succeeded. 0 Warning(s), 0 Error(s)`
- **Regressões**: Zero. A desativação por padrão garante fidelidade 100% à experiência original.
