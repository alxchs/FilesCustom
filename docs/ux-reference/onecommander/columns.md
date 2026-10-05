# Comparação de UX: Colunas — OneCommander vs. Files App

## 1. Origem da Investigação

MASTER_SPEC §6 e §4.2: Queixa de que o comportamento de colunas pode fazer o usuário sentir que as colunas estão "amarradas" ou que alterar uma afeta outra de forma pouco previsível.

## 2. Comportamento no OneCommander (Observação Externa)

No OneCommander (versão 3.x/WPF):
- O layout de detalhes utiliza uma grade com colunas configuráveis.
- A coluna de nome de arquivo frequentemente opera em modo auto-expansível (equivalente a Star `*` do WPF) quando o espaço da janela não está preenchido, de modo a ocupar a largura disponível do painel.
- Consequência: quando o usuário arrasta o divisor de uma coluna secundária (ex.: Tamanho, Data de Modificação) para a esquerda ou direita, a coluna Nome aumenta ou encolhe em tempo real para compensar o espaço, gerando a sensação física de que as colunas estão "amarradas" (efeito gangorra).
- Ao atingir o limite da janela ou em janelas estreitas, o comportamento de rolagem horizontal entra em conflito com o redimensionamento elástico.

## 3. Comportamento no Files App

No Files App (WinUI 3):
- **Todas as colunas** usam largura explícita em pixels (`GridUnitType.Pixel` em `ColumnsViewModel.cs`).
- Nenhuma coluna ativa no `DetailsLayoutPage.xaml` utiliza dimensionamento Star (`*`).
- O manipulador de arraste em `src/Files.App.Controls/GridSplitter/GridSplitter.Events.cs` (linhas 266–274):
  ```csharp
  if (!IsStarColumn(CurrentColumn))
  {
      if (!SetColumnWidth(CurrentColumn, horizontalChange, GridUnitType.Pixel))
      {
          return true;
      }
  }
  ```
  Ao detectar que a coluna à esquerda do divisor tem largura fixa, o `GridSplitter` chama `SetColumnWidth` exclusivamente para a coluna atual e retorna imediatamente, sem alterar a coluna seguinte (`SiblingColumn`).
- Ao arrastar qualquer divisor:
  1. Apenas a coluna à esquerda do divisor é redimensionada.
  2. Todas as demais colunas permanecem estritamente com suas larguras em pixels inalteradas.
  3. A coluna "Nome" não absorve diferenças nem encolhe quando outra coluna cresce.
  4. Se a largura total exceder a viewport, a barra de rolagem horizontal (`ScrollViewer`) surge de forma fluida.
  5. Se a janela for alargada, sobra espaço em branco neutro à direita sem distorcer as colunas configuradas.

## 4. Conclusão

A queixa original de "colunas amarradas" decorre de comportamentos observados em ferramentas com colunas elásticas (`*`). No Files App, a arquitetura já é totalmente independente e em pixels fixos, cumprindo o critério do §6.

A única oportunidade de melhoria identificada é a amarração de `MinWidth` no XAML (`ColumnDefinition.MinWidth`), pois hoje o limite mínimo de 50px só é garantido pelo auto-fit programático, permitindo que o mouse arraste até ~13px. Essa melhoria foi proposta no relatório de F002.
