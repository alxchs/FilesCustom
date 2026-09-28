# AGENT_CONTEXT

Estado atual, curto. Atualize ao mudar de tarefa, ao parar e ao receber bloqueio. Detalhes ficam em `STATUS.md`, `DECISIONS.md` e `docs/agents/`.

```text
PROJECT        Files Custom (derivado do Files Community). Regras: MASTER_SPEC.md; continuidade: docs/agents/CONTINUITY.md
OBJECTIVE      File manager moderno com UX mais previsível (rename, colunas, abas, menu, preview/details, busca). Ver MASTER_SPEC.md §2 e §44
CURRENT PHASE  G0 — Baseline (app oficial ainda sem customização)
CURRENT TASK   AGY: compilar e executar o Files do repositório oficial pela primeira vez; smoke test; registrar preexistentes (MASTER_SPEC §16)
ACCEPTANCE     Build x64 Debug passa; app abre; smoke test anotado em STATUS.md com comando e saída; ajustes de build listados
DO NOT CHANGE  Nenhum código de produto em src/ e tests/ além do necessário para compilar (listar cada ajuste em STATUS.md). Não editar OneCommander (só observar pela UI, §3.1)
OWNER          AGY (tarefa G0). Claude: docs, briefs, revisão; não edita src/ enquanto o G0 estiver aberto
CURRENT BRANCH main (parte de upstream 99951c66 = v4.2.9). Ajustes de build da AGY estão no working tree, sem commit
LAST DECISION  D-001..D-006 em DECISIONS.md (28/09/2026)
NEXT ACTION    1) AGY: justificar/reverter os ajustes de build listados em STATUS.md e concluir o G0  2) AGY: commit separado dos ajustes  3) Claude escreve o brief de F001 (docs/agents/tasks/F001-rename-ux.md)
BLOCKER        Nenhum de infraestrutura. Risco: ajustes da AGY em Files.slnx/pacotes podem descaracterizar o baseline (ver STATUS.md)
LAST UPDATE    2026-09-28 — Claude
```
