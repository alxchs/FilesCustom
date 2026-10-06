# AGENT_CONTEXT

Estado atual, curto. Atualize ao mudar de tarefa, ao parar e ao receber bloqueio. Detalhes ficam em `STATUS.md`, `DECISIONS.md` e `docs/agents/`.

```text
PROJECT        Files Custom (derivado do Files Community). Regras: MASTER_SPEC.md; continuidade: docs/agents/CONTINUITY.md
OBJECTIVE      File manager moderno com UX mais previsível (rename, colunas, abas, menu, preview/details, busca). Ver MASTER_SPEC.md §2 e §44
CURRENT PHASE  G1 — Pipeline & Features OneCommander (F001..F009, F011, F007-B concluídas; F010 Fase 2 em andamento)
CURRENT TASK   F010 Fase 2 — Implementação da Arquitetura Híbrida de Colunas Dinâmicas do Explorer
ACCEPTANCE     G0 fechado; F001..F009, F011 concluídas com build 0/0; F010 Fase 2 com build 0/0 e prova real
DO NOT CHANGE  Nenhum código fora de BaseGroupableLayoutPage, layouts e helper novo de nome/extensão (§13).
OWNER          AGY (fila do PLAYBOOK)
CURRENT BRANCH feature/all-explorer-columns
LAST DECISION  D-001..D-012 em DECISIONS.md; Aprovação da Opção A da F010 (06/10/2026)
NEXT ACTION    Implementar T2.1 e T2.2 (modelo DynamicColumnDefinition e catálogo IExplorerPropertyService)
BLOCKER        Nenhum
LAST UPDATE    2026-10-06 17:58 — AGY (Push geral concluído no remoto origin; arquitetura híbrida aprovada; iniciando Fase 2 da F010)
```
