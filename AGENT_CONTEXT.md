# AGENT_CONTEXT

Estado atual, curto. Atualize ao mudar de tarefa, ao parar e ao receber bloqueio. Detalhes ficam em `STATUS.md`, `DECISIONS.md` e `docs/agents/`.

```text
PROJECT        Files Custom (derivado do Files Community). Regras: MASTER_SPEC.md; continuidade: docs/agents/CONTINUITY.md
OBJECTIVE      File manager moderno com UX mais previsível (rename, colunas, abas, menu, preview/details, busca). Ver MASTER_SPEC.md §2 e §44
CURRENT PHASE  G1 — Pipeline & Features OneCommander (F001, F005, F008, F009, F003, F002, F004 concluídas; F010 Fase 1 concluída)
CURRENT TASK   F006 Infraestrutura de busca plugável
ACCEPTANCE     G0 fechado; F001..F005, F008, F009 concluídas com evidências visuais e build 0/0; F010 Fase 1 documentada
DO NOT CHANGE  Nenhum código fora de BaseGroupableLayoutPage, layouts e helper novo de nome/extensão (§13).
OWNER          AGY (fila do PLAYBOOK)
CURRENT BRANCH feature/classic-menu
LAST DECISION  D-001..D-012 em DECISIONS.md
NEXT ACTION    Commit local de F004, branch feature/search-provider e SDD de F006
BLOCKER        Nenhum
LAST UPDATE    2026-10-05 23:00 — AGY (F004 concluída: MenuBar clássica com 6 menus, Alt mnemonics, toggle em Settings > Appearance, build Release 0/0)
```
