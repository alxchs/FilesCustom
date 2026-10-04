# AGENT_CONTEXT

Estado atual, curto. Atualize ao mudar de tarefa, ao parar e ao receber bloqueio. Detalhes ficam em `STATUS.md`, `DECISIONS.md` e `docs/agents/`.

```text
PROJECT        Files Custom (derivado do Files Community). Regras: MASTER_SPEC.md; continuidade: docs/agents/CONTINUITY.md
OBJECTIVE      File manager moderno com UX mais previsível (rename, colunas, abas, menu, preview/details, busca). Ver MASTER_SPEC.md §2 e §44
CURRENT PHASE  G1 — Pipeline & Primeira Feature (F001 Rename UX)
CURRENT TASK   F001 Rename UX (feature/rename-ux, em wip pela AGY); depois a fila do PLAYBOOK (ordem do MASTER_SPEC §46)
ACCEPTANCE     G0 fechado; OC-rename concluído com docs/ux-reference/onecommander/rename.md e 16+ evidências
DO NOT CHANGE  Nenhum código fora de BaseGroupableLayoutPage, layouts e helper novo de nome/extensão (§13).
OWNER          AGY (fila do PLAYBOOK)
CURRENT BRANCH feature/rename-ux (local main = origin/main + commits ate 3c86f0109 ainda sem push)
LAST DECISION  D-001..D-009 em DECISIONS.md (D-009: F008-F011 e nova ordem)
NEXT ACTION    AGY (com credencial valida): F005 pelo SDD (docs/specs/F005-preview-details-toggle/tasks.md); depois fechar pendencias da F001 (Grid/Column, clique na extensao). Alexandre testa a F001 no app aberto
BLOCKER        AGY parou em 401 UNAUTHENTICATED as 21:03 (causa desconhecida; o Alexandre havia trocado para conta com cota e a AGY trabalhou 2h23 com ela). F001: build 0/0 e helper 20/20 CONFIRMED; UI so OBSERVED, Grid/Column NOT TESTED
LAST UPDATE    2026-10-04 01:30 — Claude (D-012: SDD adotado; spec/plan/tasks da F005 criados)

```
