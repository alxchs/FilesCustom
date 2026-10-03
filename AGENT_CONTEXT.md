# AGENT_CONTEXT

Estado atual, curto. Atualize ao mudar de tarefa, ao parar e ao receber bloqueio. Detalhes ficam em `STATUS.md`, `DECISIONS.md` e `docs/agents/`.

```text
PROJECT        Files Custom (derivado do Files Community). Regras: MASTER_SPEC.md; continuidade: docs/agents/CONTINUITY.md
OBJECTIVE      File manager moderno com UX mais previsível (rename, colunas, abas, menu, preview/details, busca). Ver MASTER_SPEC.md §2 e §44
CURRENT PHASE  G1 — Pipeline & Primeira Feature (F001 Rename UX)
CURRENT TASK   OC-rename (docs/agents/tasks/OC-rename-exploration.md) e F001 Rename UX (docs/agents/tasks/F001-rename-ux.md)
ACCEPTANCE     G0 fechado (CONFIRMED 03/10: build 0/0, app abre, smoke test §16 itens 1 a 9 validados e registrados em STATUS.md); F007-A concluído
DO NOT CHANGE  Nenhum código de produto em src/ e tests/ fora do escopo aprovado. Não editar OneCommander (só observar pela UI, §3.1)
OWNER          AGY (fila do PLAYBOOK); Claude em pausa a pedido do Alexandre (03/10/2026)
CURRENT BRANCH main (base: upstream/main 0e3c17ca4, D-008)
LAST DECISION  D-001..D-008 em DECISIONS.md (D-008, 03/10/2026: base migrada para upstream/main)
NEXT ACTION    Seguir a fila de docs/agents/PLAYBOOK.md: 3) OC-rename  4) F001 (pré-aprovado)  5) explorações F003/F005/F002/F004/F006
BLOCKER        nenhum
LAST UPDATE    2026-10-03 12:15 — AGY (G0 fechado, smoke test §16 validado com capturas, A/B revisado)
```
