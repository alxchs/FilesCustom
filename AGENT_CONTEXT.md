# AGENT_CONTEXT

Estado atual, curto. Atualize ao mudar de tarefa, ao parar e ao receber bloqueio. Detalhes ficam em `STATUS.md`, `DECISIONS.md` e `docs/agents/`.

```text
PROJECT        Files Custom (derivado do Files Community). Regras: MASTER_SPEC.md; continuidade: docs/agents/CONTINUITY.md
OBJECTIVE      File manager moderno com UX mais previsível (rename, colunas, abas, menu, preview/details, busca). Ver MASTER_SPEC.md §2 e §44
CURRENT PHASE  G1 — Pipeline & Primeira Feature (F001 Rename UX)
CURRENT TASK   F001 Rename UX (feature/rename-ux, em wip pela AGY); depois a fila do PLAYBOOK (ordem do MASTER_SPEC §46)
ACCEPTANCE     G0 fechado; OC-rename concluído com docs/ux-reference/onecommander/rename.md e 16+ evidências
DO NOT CHANGE  Nenhum código fora de BaseGroupableLayoutPage, layouts e helper novo de nome/extensão (§13).
OWNER          AGY (fila do PLAYBOOK); Claude em pausa a pedido do Alexandre (03/10/2026)
CURRENT BRANCH feature/rename-ux (main publicado em 3c86f0109 nao; ver git)
LAST DECISION  D-001..D-008 em DECISIONS.md (D-008: base migrada para upstream/main; OC-rename aprovou Opção A de F001)
NEXT ACTION    Criar branch feature/rename-ux, implementar blindagem de extensão no TextBox (Opção A), compilar release 0/0, validar em C:\FilesUXLab
BLOCKER        AGY sem cota desde 13:29 de 03/10 (429, renova ~16:21; conta do CLI desconhecida). F001 em wip na feature/rename-ux (commit 774f5eb64, nao revisado). Teste de troca de credencial bloqueado pelo classificador do Claude: precisa de regra de permissao do Alexandre
LAST UPDATE    2026-10-03 13:35 — Claude (AGY em 429; F001 em wip; specs F008-F011 no MASTER_SPEC §46; ordem nova no PLAYBOOK)

```
