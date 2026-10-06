# Análise de UX: Menus no OneCommander vs Files Custom

## 1. Objetivo

Analisar a organização de menus e comandos do OneCommander em relação ao paradigma clássico de gerenciadores de arquivos do Windows (Windows Explorer clássico, Total Commander, FreeCommander, etc.), documentando as limitações observadas e fundamentando a inclusão de uma barra de menus tradicional opcional no Files Custom.

## 2. Comportamento Observado no OneCommander

- **Ausência de Barra Superior de Menus**: O OneCommander não possui uma barra tradicional suspensa contendo os menus clássicos (`File`, `Edit`, `View`, `Go`, `Tools`, `Help`).
- **Mecanismos Substitutivos Utilizados no OneCommander**:
  1. *Menu Hambúrguer / Botão de Configurações*: Pequeno ícone de engrenagem / menu no canto superior ou barra de título, que reúne opções de personalização, temas e preferências gerais.
  2. *Toolbar de Ícones e Botões de Cabeçalho*: Botões compactos para operações frequentes (Nova Pasta, Recortar, Copiar, Colar, Visualização).
  3. *Menu de Contexto Estendido (Right-Click)*: Grande parte das operações avançadas é empurrada para menus de clique direito, exigindo que o usuário selecione itens antes de saber quais ações são possíveis.
  4. *Quick Access / Hotkeys*: Usuários avançados utilizam atalhos diretos, porém sem uma referência visual unificada.

## 3. Limitações Identificadas (Queixa MASTER_SPEC §4.4)

1. **Baixa Descoberta de Funcionalidades**: Usuários novatos ou acostumados com aplicações de produtividade do Windows não conseguem ter uma visão panorâmica imediata de todas as capacidades do aplicativo.
2. **Perda de Navegação por Mnemonics (`Alt+F`, `Alt+E`, etc.)**: No Windows, operadores ágeis de teclado usam combinações de tecla de acesso sem olhar para o mouse (ex.: `Alt+F` seguido de `N` para criar, ou `Alt+V` para ajustar exibição). A ausência de barra quebra esse fluxo motor consagrado por décadas.
3. **Dependência Excessiva de Menus de Contexto**: Para descobrir o que pode ser feito com um arquivo ou aba, o usuário é obrigado a clicar com o botão direito, poluindo a interação.

## 4. Requisitos de Design para o Files Custom

1. **Não Copiar o Visual do OneCommander**: O Files Custom adota o design system nativo Fluent / WinUI 3 com `Microsoft.UI.Xaml.Controls.MenuBar`.
2. **Natureza Opcional**: O usuário que prefere o design contemporâneo minimalista (estilo Windows 11 Explorer) mantém a barra desativada (padrão `false`).
3. **Zero Poluição Visual**: Quando ativada, a barra ocupa apenas a altura necessária (`Auto`), perfeitamente integrada à paleta de cores, tipografia e tema atual (claro, escuro ou cores personalizadas).
4. **Comportamento 100% Nativo de Teclado**:
   - Pressionar a tecla `Alt` foca a barra e exibe os marcadores de tecla de acesso (`F`, `E`, `V`, `G`, `T`, `H`).
   - Teclas de setas (esquerda/direita) transitam suavemente entre os cabeçalhos.
   - Pressionar `Escape` restaura o foco no arquivo ou pasta ativa sem efeitos colaterais.

