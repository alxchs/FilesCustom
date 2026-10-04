# Handoff — F001 Rename UX, revisão do trabalho da AGY (Claude, 03/10/2026 21:15)

A AGY trabalhou ~2h23 (19:00–21:03, perfil `alexandre`), fez o commit `5e35e6a6f` e parou com **401 UNAUTHENTICATED** no meio da validação visual dos três layouts. Ela não escreveu handoff; este documento o substitui. Tudo abaixo foi conferido pelo Claude em 03/10/2026, salvo onde dito.

## CONFIRMED (comando e saída)

- `mkfile release src\Files.App\Files.App.csproj` (commit `5e35e6a6f`): `0 Warning(s)`, `0 Error(s)`, 5m02s.
- `pwsh -NoProfile -File tests\test-rename-helper.ps1`: `All 20 test cases passed successfully.` exit 0. Nota: no Windows PowerShell 5.1 o script **não compila** (compilador C# antigo); precisa de `pwsh`.
- Diff do `5e35e6a6f` lido: `End`/`Down` limitam o caret a `nameLen` com extensão travada; clique só destrava via `PointerPressed` medido dentro da extensão; `showExtensionDialog` só é suprimido por `IsExtensionDeliberatelyModified`; `Tab` sem extensão é no-op; `.user.js` removido.

## OBSERVED (captura vista pelo Claude, build presumido `5e35e6a6f`, não reproduzido por ele)

Em `docs/agents/evidence/f001/` (Details, `C:\FilesUXLab`):
- `01`: `.gitignore` abre com o nome inteiro selecionado e a caixa sem corte.
- `04`: `End` + `Backspace` em `arquivo.txt` apagou só uma letra do nome (`arquiv.txt`); a extensão ficou.
- `10`: `arquivo` → `arquivo.exe` mostra o diálogo Sim/Não (o texto digitado não aparece na captura).

## NOT TESTED / INFERRED

- Layouts **Grid e Column**: nenhuma captura útil (os scripts `test_grid_*`/`run_all_layouts_unified` rodaram, sem evidência conferida).
- Clique do mouse **dentro da extensão** (captura `09` mostra só o cursor ao lado do ponto; não prova o destravamento).
- `Tab`/`Shift+Tab`, `Ctrl+A`, pasta (`11`), `.lnk` (`12`), commit (`13`) e desfazer (`14`): capturas existem, o Claude **não as abriu**.
- Falta o teste unitário em `tests/Files.App.UnitTests` (só existe o `.ps1`).
- Decisões novas da AGY (D-011) ainda sem o OK do Claude: `Tab` seleciona a extensão sem o ponto; `.env.local` → nome `.env`, extensão `.local`.

## Pendências

1. Alexandre testa no app aberto (build `5e35e6a6f`, pacote `FilesDev` 4.2.37.0): F2 em `arquivo.txt`, `.gitignore`, `arquivo.tar.gz`; `End`+`Backspace`; `Tab`; clique na extensão; os três layouts.
2. AGY (quando houver cota/credencial): validar Grid e Column com captura, clique na extensão, teste em `tests/Files.App.UnitTests`; **consolidar** os ~30 scripts soltos em `tools/perf/` (hoje sem commit, de teste exploratório) em poucos scripts versionados.
3. Credencial da AGY no CLI: o último disparo caiu em 401, não em 429; pode ser troca de perfil no meio da execução. Verificar `trocarConta list` e o login antes de redisparar.
