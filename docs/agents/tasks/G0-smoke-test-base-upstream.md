# G0 — Smoke test do §16 na base upstream/main (D-008)

Status: BRIEF APROVADO (Claude, 03/10/2026). Executor: AGY. Sem mudança de código.

## TASK
Fechar o G0 na base atual (`upstream/main` 0e3c17ca4 + ajustes de build; pacote 4.2.37.0): smoke test do MASTER_SPEC §16 com o app aberto por `Open-FilesDev.ps1`.

## ACCEPTANCE
Cada item abaixo registrado em `STATUS.md` (seção nova "Smoke test §16 — 4.2.37.0") com estado `CONFIRMED`/`OBSERVED`/`NOT TESTED`, o comando ou a captura que sustenta, e problemas preexistentes anotados à parte (não atribuir à customização):
1. App abre; título da janela; tempo até a janela responder.
2. Navegar: Home, uma unidade, `C:\FilesUXLab` (criar o laboratório do §17 se não existir, só com arquivos descartáveis), voltar/avançar/subir.
3. Abas: nova (Ctrl+T), fechar, reabrir fechada, reordenar.
4. Seleção: um, vários (Ctrl/Shift), todos (Ctrl+A).
5. Rename F2 em `arquivo.txt` e `.gitignore` (só observar o comportamento atual; **não** corrigir, é a F001).
6. Copiar/colar, recortar/colar, excluir para lixeira e desfazer, em arquivos do laboratório.
7. Preview e Details: mostrar/ocultar pelo caminho atual e contar quantos cliques/teclas exige (insumo da F005).
8. Colunas: arrastar a borda de uma coluna e anotar se as outras se mexem (insumo da F002).
9. Fechar e reabrir: abas e layout restauram?

## DO NOT CHANGE
`src/`, `tests/`. Não excluir nada fora de `C:\FilesUXLab`. OneCommander só observar (§3.1).

## ENTREGA
Handoff em `docs/agents/handoffs/` (modelo do §26), commit local, **sem push**. Atualizar `AGENT_CONTEXT.md`.
