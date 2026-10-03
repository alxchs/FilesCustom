# AGENT_CONTEXT

Estado atual, curto. Atualize ao mudar de tarefa, ao parar e ao receber bloqueio. Detalhes ficam em `STATUS.md`, `DECISIONS.md` e `docs/agents/`.

```text
PROJECT        Files Custom (derivado do Files Community). Regras: MASTER_SPEC.md; continuidade: docs/agents/CONTINUITY.md
OBJECTIVE      File manager moderno com UX mais previsível (rename, colunas, abas, menu, preview/details, busca). Ver MASTER_SPEC.md §2 e §44
CURRENT PHASE  G0 — Baseline & Zero-Warning Gate
CURRENT TASK   G0: smoke test do §16 (Open-FilesDev.ps1) e F007-A: A/B do backdrop (docs/agents/tasks/F007-perf-ab-backdrop.md)
ACCEPTANCE     Build x64 Release com 0 erros/0 warnings (feito); app abre (CONFIRMED 01/10); smoke §16 registrado em STATUS.md
DO NOT CHANGE  Nenhum código de produto em src/ e tests/ além do necessário para compilar e limpar warnings. Não editar OneCommander (só observar pela UI, §3.1)
OWNER          AGY (tarefa G0)
CURRENT BRANCH main (base: upstream/main 0e3c17ca4, D-008)
LAST DECISION  D-001..D-006 em DECISIONS.md (28/09/2026)
NEXT ACTION    1) F007-A (medição, sem código)  2) Smoke test §16  3) Decidir reverter WindowsAppSdkBootstrapperAutoInitialize  4) Brief da F001 e exploração OneCommander
BLOCKER        Nenhum
LAST UPDATE    2026-10-03 — Claude (D-008: base agora é upstream/main 0e3c17ca4; refazer baseline/medições nesta base)
```
