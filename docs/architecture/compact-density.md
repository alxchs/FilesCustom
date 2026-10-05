# Arquitetura: Densidade de Interface OneCommander (UltraCompact / Compact)

## Contexto & Motivação
O OneCommander é reconhecido pela alta densidade de informação por polegada quadrada de tela. Usuários avançados e gestores de arquivos que lidam com centenas de itens por pasta necessitam visualizar o máximo de linhas possíveis sem rolagem excessiva.

No Files App Community padrão:
- O modo Detalhes (Details) com tamanho "Small" utilizava 36px de altura por item. Em telas 1080p padrão, isso limitava a visão a aproximadamente 22–24 itens simultâneos.
- A barra lateral de navegação (Sidebar) utilizava altura fixa de 40px por item.

Com a especificação F008, o Files ganha a opção de Densidade de Interface em 3 níveis:
1. **Normal (Padrão do Files)**: Linhas de 36px em detalhes, 40px na barra lateral.
2. **Compacto (Compact)**: Linhas de 28px em detalhes, 24px em lista/colunas, 32px na barra lateral.
3. **Ultra-compacto (UltraCompact / OneCommander Style)**: Linhas de 24px em detalhes, 22px em lista/colunas, 30px na barra lateral. Em telas 1080p, permite visualizar 38 a 42 itens simultâneos (aumento de mais de 75% na densidade útil de tela).

---

## Componentes Modificados

1. **`AppDensityKind` (Enum)**:
   - `Normal` (0)
   - `Compact` (1)
   - `UltraCompact` (2)

2. **Configurações de Aparência (`IAppearanceSettingsService` / `AppearanceSettingsService`)**:
   - Propriedade persistente `AppDensity` serializada nas configurações do usuário.

3. **Recursos de Tema XAML Dinâmicos (`IResourcesService` / `AppResourcesService` / `AppThemeResourcesHelper`)**:
   - `App.Theme.Sidebar.ItemHeight`: chave `x:Double` manipulada em tempo de execução para redimensionar itens do NavigationView/Sidebar (Normal=40, Compact=32, UltraCompact=30).
   - Estilo de `SidebarStyles.xaml` vinculado via `{ThemeResource App.Theme.Sidebar.ItemHeight}`.

4. **Cálculo de Altura de Linha (`LayoutSizeKindHelper`)**:
   - `GetDetailsRowHeight`:
     - Normal: Small = 36px
     - Compact: Small/Compact = 28px
     - UltraCompact: 24px
   - `GetListRowHeight` / `GetColumnsRowHeight`:
     - Normal: Small = 28px
     - Compact: 24px
     - UltraCompact: 22px

5. **Interface de Configurações (`AppearanceViewModel` / `AppearancePage.xaml`)**:
   - `SettingsCard` intuitivo com seletor ComboBox com opções localizadas (pt-BR e en-US) e suporte a troca dinâmica instantânea sem necessidade de reiniciar a aplicação.
