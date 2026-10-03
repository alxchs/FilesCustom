# Agent Handoff — 2026-10-03 02:20 Claude — AGY parada por cota (429), estado para retomar

Escrito pelo Claude porque a AGY não conseguiu escrever o dela (cota). Tudo que a AGY fez está só nas capturas e no README; ela não registrou nada em `STATUS.md`.

## Completed (pela AGY, na execução de 00:55 a 02:13, conversa `5e01924e-a1c9-4ec0-af37-1c2717beaae9`)
- F007-A: A/B do backdrop e linha de base na base 4.2.37.0, escritos em `tools/perf/README.md` (commit `eb688ef22`, "wip"). **Não revisados pelo Claude.**
- Smoke test §16 (`docs/agents/tasks/G0-smoke-test-base-upstream.md`) exercitado até o item 6: Up, fechar aba (Ctrl+W), reabrir (Ctrl+Shift+T), aba FilesUXLab, Ctrl+A, toggle do checkbox de seleção, rename F2 em `arquivo.txt` e `.gitignore`, cancelar com Esc, copiar/colar, excluir para lixeira, Ctrl+Z, cut. Capturas em `tools/perf/captures/` (35 arquivos, commit `0da7a0416`).

## Files created / modified
- `tools/perf/` (README, scripts, `SmokeTest-Helper.ps1`, capturas). Nenhum código de produto em `src/`.

## Findings
- NOT TESTED: o conteúdo das capturas. Nenhum item do smoke está registrado em `STATUS.md`; portanto o G0 **continua aberto**.
- OBSERVED (Claude): a AGY terminou com 429 `RESOURCE_EXHAUSTED`, "Resets in 2h16m57s" (grupo Gemini, conta `heloize`). O grupo Claude da mesma conta renova em 68h47m.
- OBSERVED (Claude): depois de `trocarConta alexandre`, o `agy --print` voltou com "Resets in 2h13m50s" e o mesmo prefixo de `error_id` (`b55f26a6-a255-47c4-a70b-d8296c4b23f4-84x/85x`). A diferença de 3m07s bate com o tempo decorrido entre as duas tentativas (~3m14s). Conclusão provisória (INFERRED): o `agy --print` **não usa** o perfil trocado por `trocarConta`; continua na mesma cota. Não foi testado `ale-chs-sousa`.

## Problems
- Cota. Regra global: o Claude não faz o trabalho da AGY por cota.

## Tests not performed
- Itens 6 (cut/paste concluído?), 7 (cliques para mostrar Preview/Details), 8 (arrastar borda de coluna e ver se as outras mudam), 9 (fechar e reabrir o app: abas e layout restauram).

## Next recommended action
1. Quando houver cota: a AGY lê as capturas, registra os itens 1 a 9 no `STATUS.md` (estado e evidência), faz os itens 7 a 9, revisa a conclusão do A/B, fecha o G0, commit local.
2. Depois segue a fila do `docs/agents/PLAYBOOK.md`.
3. Renovação esperada do grupo Gemini da `heloize`: ~04:31 de 03/10/2026 (`~/.gemini/accounts/esgotada.txt`).

## Warnings
- `trocarConta` encerrou todos os `agy.exe`/Antigravity da máquina às 02:16 (comportamento do script).
- Não confie em "CONFIRMED" no README sem rever o comando citado.
