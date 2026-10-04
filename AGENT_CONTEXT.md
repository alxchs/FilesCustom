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
CURRENT BRANCH feature/preview-details-shortcuts (a partir de feature/rename-ux; nada publicado apos ad1ef50be)
LAST DECISION  D-001..D-009 em DECISIONS.md (D-009: F008-F011 e nova ordem)
NEXT ACTION    AGY (cota renova ~04:47): F005 T6 e T7 (validar AC-1..AC-11 no app com capturas, handoff por cenario); corrigir achados do review (BOM, Open-FilesDev.ps1, scripts soltos). Alexandre testa o exe de 02:00 (nota em docs/releases)
BLOCKER        AGY 429 (grupo gemini) as ~01:55 de 04/10, renova ~04:47. F005: T1..T5 commitados (cc7d1beb8), build 0/0 e regra 6/6 CONFIRMED; UI NOT TESTED
LAST UPDATE    2026-10-04 02:10 — Claude (revisou T1..T5 da F005, build 0/0, nota de liberacao publicada)

```
