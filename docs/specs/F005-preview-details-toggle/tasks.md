# F005 — Preview e Details com acesso imediato — TASKS

Status: **APROVADAS** (Claude, 04/10/2026). Executor: AGY. Branch: `feature/preview-details-shortcuts` (a partir de `main`; a F001 fica na própria branch). Uma tarefa por commit.

| # | Tarefa | Atende | Pronto quando | Estado |
|---|---|---|---|---|
| T1 | Reconfirmar por busca que `Alt+P` e `Alt+Shift+P` estão livres em `Actions/` e checar o menu e as teclas de acesso; se houver conflito, escolher outro par e registrar em `DECISIONS.md` | FR-004 | resultado da busca anotado no handoff | pendente |
| T2 | Criar a função pura de alternância (arquivo novo em `Helpers/`, genérica no tipo da aba) e o teste dos 6 casos; registrar em `DECISIONS.md` a escolha entre script `pwsh` e projeto `tests/Files.Custom.Tests` | FR-001, AC-1..AC-6 | teste executado com saída de 6 aprovados | pendente |
| T3 | Ajustar `TogglePreviewPaneAction` e `ToggleDetailsPaneAction`: usar a função, `IsExecutable => true`, `IsAccessibleGlobally => true`, `HotKey` | FR-001..FR-004 | `mkfile release` com 0 Warning(s) e 0 Error(s) | pendente |
| T4 | Mostrar o atalho nos tooltips das abas (`InfoPane.xaml`); string nova só se faltar | FR-005, AC-11 | captura do tooltip | pendente |
| T5 | Verificar foco ao fechar por atalho e `AutomationName`; corrigir só se faltar | FR-007, AC-9 | captura ou UI Automation mostrando o foco na lista | pendente |
| T6 | Validar no app (`C:\FilesUXLab`): AC-1 a AC-11 nos 3 layouts, com imagem, texto, pasta e seleção vazia; reiniciar o app; regressão `Ctrl+Alt+I`, botão, abas | AC-1..AC-11 | capturas em `docs/agents/evidence/f005/` | pendente |
| T7 | Handoff com o estado **por AC** (CONFIRMED, OBSERVED, NOT TESTED), `STATUS.md` e **nota de liberação** (`docs/releases/`, regra do PLAYBOOK) | todos | arquivos commitados, sem push | pendente |

## Teste obrigatório
Um por `AC-n`, do tipo definido no `plan.md`. Feature só é "concluída" no gate de revisão do Claude ou do Alexandre.

## Entrega
Compilar release (0/0), abrir o app e usar a feature, um commit por tarefa, handoff por cenário, nota de liberação. Sem push.
