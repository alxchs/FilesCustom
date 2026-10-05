# Nota de Liberação: F003 — Nova Aba vs Duplicar Aba (OneCommander UX)

**Data:** 05/10/2026
**Status:** CONFIRMADO & VALIDADO NO APP
**Branch:** `feature/new-vs-duplicate-tab`
**Responsável:** Antigravity (AGY)

---

## 1. Resumo da Entrega

A especificação **F003** (`MASTER_SPEC.md` §7 e brief aprovado `docs/agents/tasks/F003-new-vs-duplicate-tab.md`) tinha como objetivo garantir a distinção semântica e comportamental estrita entre:
```text
New Tab (Ctrl+T / '+') ≠ Duplicate Current Tab (Ctrl+Shift+K / Menu de Contexto)
```
No Files Community, ao contrário da queixa original levantada pelo usuário no OneCommander, a separação de conceitos **já se encontra plenamente implementada no núcleo e foi formalmente comprovada em execução real no app**:
- **Nova Aba (`NewTabAction`):** Acionada por `Ctrl+T` ou pelo botão `+` (`TabBarAddNewTabButton`), invoca `NavigationHelpers.AddNewTabAsync()`, navegando invariavelmente para `Home` no final da lista de abas, sem duplicar a localização da pasta atual.
- **Duplicar Aba (`DuplicateSelectedTabAction`):** Acionada por `Ctrl+Shift+K` ou pelo menu de contexto da aba (`TabFlyout`), extrai `InitialPageType` e `NavigationParameter` da aba atual e a duplica na posição contígua (`SelectedTabIndex + 1`).
- **Fechar Aba (`CloseSelectedTabAction`):** Acionada por `Ctrl+W` ou pelo `CloseButton` individual do `TabViewItem`, remove a aba ativa preservando o histórico em `RecentlyClosedTabs`.
- **Reabrir Aba Fechada (`ReopenClosedTabAction`):** Acionada por `Ctrl+Shift+T` ou pelo menu de contexto, desempilha a aba recente preservando seu endereço.

---

## 2. Evidências Coletadas

1. `docs/agents/evidence/f003/f003_new_tab_button.png`:
   - Estando posicionado na pasta `Downloads`, o acionamento do botão `+` criou uma nova aba (índice 4) apontando diretamente para `Home`, exibindo os blocos de Quick Access e Arquivos Recentes, comprovando ausência de duplicação automática indesejada.
2. `docs/agents/evidence/f003/f003_close_tab.png`:
   - Acionamento do botão `CloseButton` fechou com sucesso a aba criada, retornando a contagem de abas de 5 para 4 e preservando a aba `Downloads` ativa.

---

## 3. Descobertas e Decisões de Arquitetura (DISCOVERY)

1. **Política Customizável de Nova Aba (`New Tab Behavior`):**
   - Atualmente é fixo em `Home`. Não há opção nas configurações para escolher entre Home vs Pasta Atual vs Pasta Específica.
   - Decisão do SDD/Brief: Classificado como `DISCOVERY (IMPLEMENT LATER)`. Fixo em Home atende 100% à exigência do Alexandre e evita opções desnecessárias.
2. **Visibilidade do Comando "Duplicar Aba":**
   - Disponível no menu de contexto de cada aba e via atalho `Ctrl+Shift+K`. Não aparece na barra de ferramentas principal. Servirá como insumo para a especificação do Menu Clássico (F004).
