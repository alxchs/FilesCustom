# F007-A — A/B do fundo (backdrop) contra a CPU do compositor

Status: BRIEF APROVADO (Claude, 02/10/2026). Executor: AGY. Branch: `feature/perf-backdrop-ab` (só se houver mudança de código; a medição em si não altera código).

## TASK

Provar ou refutar a hipótese: o fundo `MicaAlt` (padrão, `AppearanceSettingsService.AppThemeBackdropMaterial`, `src/Files.App/Helpers/UI/AppSystemBackdrop.cs`) é a causa da CPU da thread "DWM Compositor Thread" (74% parado, 59% ao abrir `10k`). Medir o Files Dev com cada valor de `BackdropMaterialType` (`Solid`, `Mica`, `MicaAlt`, `Acrylic`) e comparar.

## COMO

1. Pré-requisitos de `tools/perf/README.md` (laboratório `New-PerfLab.ps1`, Files Dev aberto por `Open-FilesDev.ps1`).
2. Trocar o fundo pela tela Settings > Appearance do app (ou editando `%LOCALAPPDATA%\Packages\FilesDev_ykqwq8d6ps0ag\LocalState\settings\user_settings.json` com o app fechado). Registrar qual caminho usou.
3. Para cada valor, com a mesma janela, mesmo tamanho e mesma pasta: `idle.ps1 -WaitS 10` e `thr.ps1 -Folder C:\FilesUXLab\perf\10k`, 3 rodadas, mediana.
4. Registrar em `tools/perf/README.md` (nova seção "A/B do fundo") a tabela valor × CPU parado × CPU ao abrir × % do compositor, com os comandos usados.

## ACCEPTANCE

- Tabela com os 4 valores, 3 rodadas cada, comandos citados. Cada número marcado `OBSERVED`.
- Conclusão em uma frase: o fundo explica (ou não) a CPU do compositor. Se `Solid` reduzir o CPU parado para perto do OneCommander (~2%), a hipótese é `CONFIRMED`. Se não reduzir, dizer isso e **não** mexer em código: abrir novo DISCOVERY com o próximo suspeito (animação contínua, `ProgressRing`, vídeo/GIF, thumbnails).
- Se confirmar: propor (sem implementar) a correção mínima, p.ex. padrão `Solid`/`Mica` ou desligar o `MicaAlt` quando a janela estiver inativa, com o risco para o upstream (§13).

## ARQUIVOS PROVÁVEIS

Só leitura: `AppSystemBackdrop.cs`, `AppearanceSettingsService.cs`, `BackdropMaterialType.cs`. Escrita: `tools/perf/README.md`, handoff.

## DO NOT CHANGE

Código de produto em `src/` e `tests/`. Nada do OneCommander além de observar por fora (§3.1).

## TESTES OBRIGATÓRIOS

Mesma máquina, nenhum outro app pesado aberto, janelas do Files Dev sem mexer durante a medição. Restaurar o fundo original (`MicaAlt`) ao terminar.

## FORA DE ESCOPO

Qualquer otimização de código; comparar com o Files oficial (D-007).
