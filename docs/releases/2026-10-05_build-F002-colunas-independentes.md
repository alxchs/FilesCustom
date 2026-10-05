# Nota de Conclusão: F002 — Colunas com Redimensionamento Independente

Data: 2026-10-05
Branch: `feature/independent-column-resize`
Responsável: Antigravity

---

## 1. Escopo e Objetivo

Investigar e auditar a independência de redimensionamento de colunas no layout Details do Files App (MASTER_SPEC §6), respondendo empiricamente se arrastar o divisor de uma coluna causa efeito colateral nas outras ("colunas amarradas"), e mapeando os limites de mínimo/máximo, auto-fit, persistência e redimensionamento de janela.

## 2. Resumo Executivo dos Resultados

| Requisito (§6) | Estado | Evidência / Diagnóstico |
|---|---|---|
| Redimensionamento independente | **CONFIRMED** | `GridSplitter.Events.cs` linhas 266–274. Todas as colunas são `GridUnitType.Pixel`. Arrastar afeta apenas a coluna da esquerda; vizinhas não mudam. |
| Coluna Nome não absorve diferenças | **CONFIRMED** | Nome tem largura fixa em pixels com `NormalMaxLength = 1000px`. Não é Star (`*`). |
| Auto-fit por duplo clique | **CONFIRMED** | `GridSplitter_DoubleTapped` dispara `ResizeColumnToFit(coluna)` calculando a largura necessária pelo texto dos itens. |
| Auto-fit global | **CONFIRMED** | Item de menu "Size all columns to fit" aciona `Commands.AutoFitColumns`. |
| Limite máximo | **CONFIRMED** | `NormalMaxLength` respeitado no drag e no fit (Nome: 1000px, Status: 80px, Path: 500px, demais: 800px). |
| Limite mínimo | **OBSERVED** | Modelo prevê `NormalMinLength = 50px` (garantido no duplo clique), mas `ColumnDefinition.MinWidth` não está amarrado no XAML, permitindo arraste manual até ~13px. Proposta de ajuste documentada. |
| Persistência por pasta | **CONFIRMED** | Gravado no Registro (`HKCU\Software\Files Community\<PackageId>\v1\LayoutPreferences\<pasta>`) ao soltar o mouse. |
| Persistência padrão global | **CONFIRMED** | Menu "Set current columns as default" salva no JSON de configurações do usuário. |
| Redimensionamento de janela | **CONFIRMED** | As colunas mantêm largura fixa; janela menor ativa scrollbar horizontal sem perda de dados; janela maior exibe espaço neutro à direita. |

## 3. Evidências Visuais e Técnicas

- `docs/agents/evidence/f002/f002_columns_current.png`: Exibição de colunas no Downloads com scrollbar horizontal ativa.
- `docs/agents/evidence/f002/f002_filesuxlab_rendered.png`: Exibição de colunas no laboratório `C:\FilesUXLab`.
- `docs/ux-reference/onecommander/columns.md`: Comparação técnica com o modelo do OneCommander.
- `docs/specs/F002-independent-column-resize/`: Documentos de especificação, plano e tarefas concluídos.

## 4. Proposta de Ajuste Mínimo (Sem código de produto nesta fase)

No arquivo `src/Files.App/Views/Layouts/DetailsLayoutPage.xaml`, adicionar a propriedade `MinWidth` em cada uma das `ColumnDefinition` ativas:
```xml
MinWidth="{x:Bind ColumnsViewModel.<Coluna>.MinLength, Mode=OneWay}"
```
Isso assegurará que o divisor físico impeça o arraste manual do mouse abaixo do limite mínimo de 50 pixels definido no modelo de domínio.
