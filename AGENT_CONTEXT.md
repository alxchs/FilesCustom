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
NEXT ACTION    AGY (apos a cota): corrigir os 3 MAJOR de docs/agents/reviews/2026-10-03_Claude_revisao-F001-wip.md (ActiveRenameParts null, tecla End, regressao do dialogo), compilar release 0/0, testes do helper, validar no app em C:FilesUXLab, handoff; depois a ordem do MASTER_SPEC §46
BLOCKER        AGY sem cota desde 13:29 de 03/10 (429, renova ~16:21; conta do CLI desconhecida). F001 em wip na feature/rename-ux (commit 774f5eb64, nao revisado). Teste de troca de credencial bloqueado pelo classificador do Claude: precisa de regra de permissao do Alexandre
LAST UPDATE    2026-10-03 15:20 — Claude (revisao do wip da F001 gravada em docs/agents/reviews; AGY segue sem cota ate ~16:21)

```
