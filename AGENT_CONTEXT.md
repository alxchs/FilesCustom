# AGENT_CONTEXT

Estado atual, curto. Atualize ao mudar de tarefa, ao parar e ao receber bloqueio. Detalhes ficam em `STATUS.md`, `DECISIONS.md` e `docs/agents/`.

```text
PROJECT        Files Custom (derivado do Files Community). Regras: MASTER_SPEC.md; continuidade: docs/agents/CONTINUITY.md
OBJECTIVE      File manager moderno com UX mais previsível (rename, colunas, abas, menu, preview/details, busca). Ver MASTER_SPEC.md §2 e §44
CURRENT PHASE  G1 — Pipeline & Primeira Feature (F001 Rename UX)
CURRENT TASK   F001 Rename UX (docs/agents/tasks/F001-rename-ux.md)
ACCEPTANCE     G0 fechado; OC-rename concluído com docs/ux-reference/onecommander/rename.md e 16+ evidências
DO NOT CHANGE  Nenhum código fora de BaseGroupableLayoutPage, layouts e helper novo de nome/extensão (§13).
OWNER          AGY (fila do PLAYBOOK); Claude em pausa a pedido do Alexandre (03/10/2026)
CURRENT BRANCH feature/rename-ux (a criar a partir de main)
LAST DECISION  D-001..D-008 em DECISIONS.md (D-008: base migrada para upstream/main; OC-rename aprovou Opção A de F001)
NEXT ACTION    Criar branch feature/rename-ux, implementar blindagem de extensão no TextBox (Opção A), compilar release 0/0, validar em C:\FilesUXLab
BLOCKER        nenhum
LAST UPDATE    2026-10-03 12:55 — AGY (OC-rename concluído, brief F001 aprovado, pronto para codar F001)

```
