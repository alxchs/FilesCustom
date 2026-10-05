# AGENT_CONTEXT

Estado atual, curto. Atualize ao mudar de tarefa, ao parar e ao receber bloqueio. Detalhes ficam em `STATUS.md`, `DECISIONS.md` e `docs/agents/`.

```text
PROJECT        Files Custom (derivado do Files Community). Regras: MASTER_SPEC.md; continuidade: docs/agents/CONTINUITY.md
OBJECTIVE      File manager moderno com UX mais previsível (rename, colunas, abas, menu, preview/details, busca). Ver MASTER_SPEC.md §2 e §44
CURRENT PHASE  G1 — Pipeline & Features OneCommander (F001, F005, F008, F009, F003, F002 concluídas; F010 Fase 1 concluída)
CURRENT TASK   F004 Barra de menus tradicional opcional
ACCEPTANCE     G0 fechado; F001..F003, F005, F008, F009, F002 concluídas com evidências visuais e build 0/0; F010 Fase 1 em docs/architecture/explorer-columns.md
DO NOT CHANGE  Nenhum código fora de BaseGroupableLayoutPage, layouts e helper novo de nome/extensão (§13).
OWNER          AGY (fila do PLAYBOOK)
CURRENT BRANCH feature/all-explorer-columns
LAST DECISION  D-001..D-012 em DECISIONS.md
NEXT ACTION    Criar branch feature/classic-menu e iniciar SDD de F004 (Menu clássico opcional)
BLOCKER        Nenhum
LAST UPDATE    2026-10-05 14:20 — AGY (F010 Fase 1 concluída: 868 propriedades enumeradas, benchmark 1,3ms/prop medido, arquitetura de colunas dinâmicas em docs/architecture/explorer-columns.md)
```
