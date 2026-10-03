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
NEXT ACTION    AGY: corrigir os MAJOR de comportamento de docs/agents/reviews/2026-10-03_Claude_revisao-F001-wip.md (End, dialogo), testes do helper, validar no app em C:FilesUXLab, handoff; depois a ordem do MASTER_SPEC §46
BLOCKER        AGY sem cota em 03/10 18:41: 429 no grupo gemini (renova ~20:17) e no grupo claude com claude-sonnet-4-6 (renova ~22:56), mesma credencial do CLI. Regra de permissao do agy.exe --print ja existe em .claude/settings.local.json. Defeitos de comportamento da F001 (End, dialogo) seguem abertos
LAST UPDATE    2026-10-03 18:45 — Claude (AGY redisparada 2x, 429 nos dois grupos; F001 parada em ad1ef50be)

```
