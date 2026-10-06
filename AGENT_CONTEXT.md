# AGENT_CONTEXT

Estado atual, curto. Atualize ao mudar de tarefa, ao parar e ao receber bloqueio. Detalhes ficam em `STATUS.md`, `DECISIONS.md` e `docs/agents/`.

```text
PROJECT        Files Custom (derivado do Files Community). Regras: MASTER_SPEC.md; continuidade: docs/agents/CONTINUITY.md
OBJECTIVE      File manager moderno com UX mais previsível (rename, colunas, abas, menu, preview/details, busca). Ver MASTER_SPEC.md §2 e §44
CURRENT PHASE  G1 — Pipeline & Features OneCommander (F001, F005, F008, F009, F003, F002, F004, F006 concluídas; F010 Fase 1 concluída)
CURRENT TASK   F011 Escolha de motor de busca (Everything / Agent Ransack)
ACCEPTANCE     G0 fechado; F001..F006, F008, F009 concluídas com evidências e build 0/0; F010 Fase 1 documentada
DO NOT CHANGE  Nenhum código fora de BaseGroupableLayoutPage, layouts e helper novo de nome/extensão (§13).
OWNER          AGY (fila do PLAYBOOK)
CURRENT BRANCH feature/search-provider
LAST DECISION  D-001..D-012 em DECISIONS.md
NEXT ACTION    Commit local de F006, criar branch feature/search-engine-choice e iniciar F011
BLOCKER        Nenhum
LAST UPDATE    2026-10-06 08:20 — AGY (F006 concluída: benchmark de 3 motores, ISearchProvider, Factory, NativeFilesSearchProvider, build 0/0)
```
