# Tarefas: F003 Nova Aba vs Duplicar Aba (OneCommander UX)

- [x] **T1: Análise e Confirmação de Código**
  - [x] Inspecionar `NewTabAction.cs` e `DuplicateSelectedTabAction.cs`.
  - [x] Inspecionar `TabBar.xaml` e `NavigationHelpers.cs`.
  - [x] Confirmar semântica: `NewTab` -> Home, `DuplicateTab` -> caminho atual na aba adjacente (`SelectedTabIndex + 1`).

- [x] **T2: Execução de Testes Automatizados no App**
  - [x] Criar script de teste em `tools/perf/` executando no app sem roubar foco do usuário.
  - [x] Validar criação de Nova Aba (`+` / `NewTab`) a partir de pasta ativa (comprovado: cria aba apontando para `Home`, sem clonar pasta ativa).
  - [x] Inspecionar e validar fechamento de aba via `CloseButton` (comprovado: fecha aba e restaura contagem anterior).
  - [x] Validar ciclo de vida e histórico em `RecentlyClosedTabs` (`ReopenClosedTabAction`).

- [x] **T3: Evidências e Capturas de Tela**
  - [x] Capturar telas comprovando os estados de Nova Aba (`docs/agents/evidence/f003/f003_new_tab_button.png`).
  - [x] Capturar telas comprovando fechamento de aba (`docs/agents/evidence/f003/f003_close_tab.png`).

- [x] **T4: Documentação e Fechamento**
  - [x] Atualizar `docs/specs/F003-new-vs-duplicate-tab/tasks.md`.
  - [x] Criar nota de liberação em `docs/releases/2026-10-05_build-F003-abas-confirmado.md`.
  - [x] Criar handoff em `docs/agents/handoffs/2026-10-05_AGY_F003-concluido.md`.
  - [x] Atualizar `STATUS.md` e `AGENT_CONTEXT.md`.
  - [x] Realizar commit local na branch `feature/new-vs-duplicate-tab`.
