# AGENT_CONTEXT

Estado atual, curto. Atualize ao mudar de tarefa, ao parar e ao receber bloqueio. Detalhes ficam em `STATUS.md`, `DECISIONS.md` e `docs/agents/`.

```text
PROJECT        Files Custom (derivado do Files Community). Regras: MASTER_SPEC.md; continuidade: docs/agents/CONTINUITY.md
OBJECTIVE      File manager moderno com UX mais previsível (rename, colunas, abas, menu, preview/details, busca). Ver MASTER_SPEC.md §2 e §44
CURRENT PHASE  G0 — Baseline & Zero-Warning Gate
CURRENT TASK   G0: smoke test completo do §16 com o app aberto por Open-FilesDev.ps1
ACCEPTANCE     Build x64 Release com 0 erros/0 warnings (feito); app abre (CONFIRMED 01/10); smoke §16 registrado em STATUS.md
DO NOT CHANGE  Nenhum código de produto em src/ e tests/ além do necessário para compilar e limpar warnings. Não editar OneCommander (só observar pela UI, §3.1)
OWNER          AGY (tarefa G0)
CURRENT BRANCH main (parte de upstream 99951c66 = v4.2.9)
LAST DECISION  D-001..D-006 em DECISIONS.md (28/09/2026)
NEXT ACTION    1) Smoke test §16  2) Decidir reverter WindowsAppSdkBootstrapperAutoInitialize (STATUS.md)  3) Brief da F001
BLOCKER        Nenhum
LAST UPDATE    2026-10-01 — Claude (app não abria: layout AppX ausente; ver handoff 2026-10-01_1915)
```
