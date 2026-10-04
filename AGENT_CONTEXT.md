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
NEXT ACTION    Alexandre testa a F001 no app aberto (build 5e35e6a6f); AGY (quando houver credencial): Grid e Column com captura, clique na extensao, teste em tests/Files.App.UnitTests, consolidar scripts de tools/perf. Ver handoff 2026-10-03_2115
BLOCKER        AGY parou em 401 UNAUTHENTICATED as 21:03 (causa desconhecida; o Alexandre havia trocado para conta com cota e a AGY trabalhou 2h23 com ela). F001: build 0/0 e helper 20/20 CONFIRMED; UI so OBSERVED, Grid/Column NOT TESTED
LAST UPDATE    2026-10-03 21:15 — Claude (revisou 5e35e6a6f, handoff escrito, app aberto com o build novo)

```
