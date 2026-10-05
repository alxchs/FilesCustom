# AGENT_CONTEXT

Estado atual, curto. Atualize ao mudar de tarefa, ao parar e ao receber bloqueio. Detalhes ficam em `STATUS.md`, `DECISIONS.md` e `docs/agents/`.

```text
PROJECT        Files Custom (derivado do Files Community). Regras: MASTER_SPEC.md; continuidade: docs/agents/CONTINUITY.md
OBJECTIVE      File manager moderno com UX mais previsível (rename, colunas, abas, menu, preview/details, busca). Ver MASTER_SPEC.md §2 e §44
CURRENT PHASE  G1 — Pipeline & Features OneCommander (F001, F005, F008, F009, F003 e F002 concluídas)
CURRENT TASK   F010 Todas as Colunas do Windows Explorer
ACCEPTANCE     G0 fechado; F001, F005, F008, F009, F003 e F002 concluídas com evidências visuais e build 0/0
DO NOT CHANGE  Nenhum código fora de BaseGroupableLayoutPage, layouts e helper novo de nome/extensão (§13).
OWNER          AGY (fila do PLAYBOOK)
CURRENT BRANCH feature/all-explorer-columns
LAST DECISION  D-001..D-012 em DECISIONS.md
NEXT ACTION    Fase 1 de F010: Investigação e mapeamento do Windows Property System (PSEnumeratePropertyDescriptions e IPropertyStore)
BLOCKER        Nenhum
LAST UPDATE    2026-10-05 14:05 — AGY (F002 concluído: confirmação empírica e arquitetural de independência 100% de colunas em pixels, sem amarração)
```
