# F004 — Barra de Menus Tradicional Opcional

## Visão Geral

Implementação de uma barra de menus tradicional suspensa (`MenuBar`) no topo da janela principal do Files App (contendo os menus clássicos **File**, **Edit**, **View**, **Go**, **Tools** e **Help**). A barra é **opcional**, iniciando desativada por padrão (preservando 100% da interface moderna e do layout padrão), e pode ser ativada pelo usuário em **Configurações > Aparência**.

## Origem e Motivação

- **MASTER_SPEC §8**: Barra de menus tradicional opcional para fácil descoberta de comandos e navegação ágil por teclado.
- **MASTER_SPEC §4.4**: Reclamação de uso do OneCommander — ausência de barra tradicional com `File`, `Edit`, `View`, `Go`, `Tools`, `Help`, dificultando o acesso mnemonico (`Alt+F`, `Alt+E`, etc.) e visão geral das capacidades.
- **Task Brief**: `docs/agents/tasks/F004-classic-menu-bar.md`.

## Requisitos Funcionais

1. **Estrutura dos 6 Menus**:
   - **File (`Alt+F`)**: Ações de arquivo, abas, janelas, criação, renomeação, exclusão, propriedades e encerramento.
   - **Edit (`Alt+E`)**: Desfazer, refazer, recortar, copiar, colar, cópia de caminho, seleção total/inversão/limpeza.
   - **View (`Alt+V`)**: Alternância de layouts, ordenação, agrupamento, exibição de painéis (Preview, Details, Info, DualPane), itens ocultos, extensões, auto-fit de colunas, tela cheia e atualizar.
   - **Go (`Alt+G`)**: Navegação de histórico (Voltar, Avançar, Subir, Home), abas (Nova aba, Duplicar aba, Reabrir aba fechada, Próxima/Anterior), foco no painel secundário, barra de endereço e busca.
   - **Tools (`Alt+T`)**: Command Palette, operações Git, integração com IDEs, Terminal, Bloco de Notas, personalização da barra de ferramentas e configurações.
   - **Help (`Alt+H`)**: Documentação, notas de versão, visualização de logs, arquivos de configuração e Sobre.

2. **Reutilização Total de Comandos (`ICommandManager`)**:
   - Nenhum comando novo ou lógica duplicada; todos os itens de menu conectam-se diretamente a instâncias de `IRichCommand` expostas por `ICommandManager`.
   - O estado de habilitação (`IsEnabled`) acompanha automaticamente `Action.IsExecutable` via eventos `CanExecuteChanged`.
   - Os atalhos de teclado configurados no Files aparecem ao lado de cada item via `KeyboardAcceleratorTextOverride`.

3. **Acessibilidade e Navegação por Teclado**:
   - Controle nativo `Microsoft.UI.Xaml.Controls.MenuBar` do WinUI 3.
   - Tecla `Alt` ativa os mnemonics (`F`, `E`, `V`, `G`, `T`, `H`).
   - Setas de direção navegam horizontalmente entre menus e verticalmente entre itens e submenus.
   - `Escape` fecha os menus e devolve o foco imediatamente para o painel de arquivos.

4. **Configuração e Persistência**:
   - Nova configuração booleana `ShowClassicMenuBar` em `IAppearanceSettingsService`.
   - Valor padrão: `false` (desligada por padrão).
   - Interruptor `ToggleSwitch` dedicado na página de configurações **Aparência** (`AppearancePage.xaml`).
   - Quando desligada, o container na `MainPage.xaml` fica `Collapsed` com custo zero de espaço e layout inalterado.

5. **Critérios de Aceitação**:
   - Desligada por padrão; quando desligada, o visual e comportamento são idênticos ao baseline.
   - Quando ligada, exibe a barra no topo (entre abas e toolbar) de forma limpa e consistente com o tema (claro/escuro/Mica).
   - Todos os menus abrem por clique e por teclado (`Alt+F`, etc.).
   - Estados habilitado/desabilitado refletem a seleção ativa.
   - Zero quebra de compilação e zero avisos novos.

