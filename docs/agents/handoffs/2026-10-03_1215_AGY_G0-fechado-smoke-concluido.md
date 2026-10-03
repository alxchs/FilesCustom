# Agent Handoff — 2026-10-03 12:15 AGY — Gate G0 Fechado e Smoke Test §16 Concluído

## Completed
- Smoke test do §16 (`docs/agents/tasks/G0-smoke-test-base-upstream.md`) concluído integralmente (itens 1 a 9) com o app aberto por `Open-FilesDev.ps1` (pacote 4.2.37.0).
- Itens 7 (Preview/Details), 8 (Colunas) e 9 (Fechar/Reabrir) executados, medidos e fotografados com resolução nativa HiDPI (capturas adicionadas em `tools/perf/captures/`).
- Registro detalhado de todos os 9 itens com estados de evidência, comandos e capturas gravado em `STATUS.md`.
- Gate G0 marcado como `CONCLUÍDO` em `STATUS.md`.
- Revisão do A/B do backdrop (F007-A) em `tools/perf/README.md`: números e metodologia conferidos. Hipótese parcialmente confirmada (MicaAlt explica 62% da CPU ociosa, mas o compositor continua gastando ~18% mesmo em Solid). O draft brief `docs/agents/tasks/F007-B-compositor-idle.md` já aguarda para a próxima investigação.
- `AGENT_CONTEXT.md` atualizado para a fase G1.
- `Capture-FilesWindow` em `tools/perf/SmokeTest-Helper.ps1` aprimorado com `SetProcessDpiAwarenessContext(PerMonitorAwareV2)` e auto-restauração de janelas minimizadas.

## Files created
- `tools/perf/captures/smoke_item7_details_pane.png`
- `tools/perf/captures/smoke_item7_preview_pane.png`
- `tools/perf/captures/smoke_item7_pane_closed.png`
- `tools/perf/captures/smoke_item8_columns_dragged.png`
- `tools/perf/captures/smoke_item8_autofit.png`
- `tools/perf/captures/smoke_item9_reopened.png`
- `tools/perf/captures/smoke_item9_reopened_ready.png`
- `tools/perf/captures/smoke_resume_check.png`
- `docs/agents/handoffs/2026-10-03_1215_AGY_G0-fechado-smoke-concluido.md`

## Files modified
- `STATUS.md` (Gate G0 concluído, seção Smoke test §16 com itens 1 a 9 registrada)
- `AGENT_CONTEXT.md` (fase G1, próxima ação PLAYBOOK itens 3 e 4)
- `tools/perf/SmokeTest-Helper.ps1` (compatibilidade PowerShell 5.1/7 com `uint16`, `SetProcessDpiAwarenessContext` e restauração de janela iconic)

## Findings
- CONFIRMED: App abre, navega e responde com fluidez em Release x64 ReadyToRun (pacote 4.2.37.0).
- CONFIRMED: Insumo F005 (Item 7): Preview fechado exige 2 cliques/passos para abrir (botão da toolbar + aba Preview). Não existe atalho global de 1 passo.
- CONFIRMED: Insumo F002 (Item 8): As colunas do DetailsLayout são dimensionadas exclusivamente em pixel (`GridUnitType.Pixel` em `ColumnsViewModel.cs`). Ao redimensionar uma coluna, as outras não mudam de largura. A coluna Name não absorve como estrela. A largura mínima efetiva é 50 pixels (`DetailsLayoutColumnItem.NormalMinLength`). Double-click no splitter executa `ResizeColumnToFit`.
- CONFIRMED: Insumo F001 (Item 5): F2 em `arquivo.txt` seleciona apenas o nome base, mas mantém a extensão no mesmo campo editável. Em `.gitignore`, o campo abre truncado (`.gitigr`) cortando visualização.
- CONFIRMED: Item 9: Ao fechar e reabrir via `Open-FilesDev.ps1`, a sessão (`Downloads`), o layout Details e o estado do painel são perfeitamente restaurados.

## Problems
- Nenhum bloqueio. Cota ativa e operacional.

## Tests performed
- Validação completa dos itens 1 a 9 do smoke test do MASTER_SPEC §16.
- Abertura, fechamento e restauração do Files Dev.
- Capturas de tela HiDPI sem distorção ou corte.

## Tests not performed
- Código das features F001 e seguintes (ainda na fase de exploração/design pré-aprovado do PLAYBOOK).

## Next recommended action
- Seguir a fila do `docs/agents/PLAYBOOK.md`:
  - Item 3: `OC-rename` — Observar OneCommander e escrever `docs/ux-reference/onecommander/rename.md` conforme `docs/agents/tasks/OC-rename-exploration.md`.
  - Item 4: `F001 Rename UX` — Opção A pré-aprovada em branch `feature/rename-ux`.

## Warnings
- Não realizar `git push` sem autorização explícita do Alexandre naquele momento.
