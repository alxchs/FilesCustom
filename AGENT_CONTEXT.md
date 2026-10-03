# AGENT_CONTEXT

Estado atual, curto. Atualize ao mudar de tarefa, ao parar e ao receber bloqueio. Detalhes ficam em `STATUS.md`, `DECISIONS.md` e `docs/agents/`.

```text
PROJECT        Files Custom (derivado do Files Community). Regras: MASTER_SPEC.md; continuidade: docs/agents/CONTINUITY.md
OBJECTIVE      File manager moderno com UX mais previsível (rename, colunas, abas, menu, preview/details, busca). Ver MASTER_SPEC.md §2 e §44
CURRENT PHASE  G0 — Baseline & Zero-Warning Gate
CURRENT TASK   G0: smoke test do §16 (Open-FilesDev.ps1) e F007-A: A/B do backdrop (docs/agents/tasks/F007-perf-ab-backdrop.md)
ACCEPTANCE     Build x64 Release com 0 erros/0 warnings (feito); app abre (CONFIRMED 01/10); smoke §16 registrado em STATUS.md
DO NOT CHANGE  Nenhum código de produto em src/ e tests/ além do necessário para compilar e limpar warnings. Não editar OneCommander (só observar pela UI, §3.1)
OWNER          AGY (fila do PLAYBOOK); Claude em pausa a pedido do Alexandre (03/10/2026)
CURRENT BRANCH main (base: upstream/main 0e3c17ca4, D-008)
LAST DECISION  D-001..D-008 em DECISIONS.md (D-008, 03/10/2026: base migrada para upstream/main)
NEXT ACTION    Seguir a fila de docs/agents/PLAYBOOK.md: 1) F007-A  2) G0 smoke  3) OC-rename  4) F001 (pré-aprovado)  5) explorações F003/F005/F002/F004/F006
BLOCKER        AGY sem cota (429, grupo Gemini renova ~04:31 de 03/10; grupo Claude ~68h). Ver handoff 2026-10-03_0220. Troca de conta via trocarConta NAO alterou a cota do agy --print (evidencia no handoff)
LAST UPDATE    2026-10-03 02:20 — Claude (AGY parada por cota; handoff escrito; G0 segue aberto)
```
