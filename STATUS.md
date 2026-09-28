# STATUS

Última atualização: 2026-09-28 (Claude). Estados de evidência: NOT TESTED / OBSERVED / INFERRED / CONFIRMED (MASTER_SPEC §27).

## Gates

| Gate | Descrição | Estado |
|---|---|---|
| G0 | Baseline: Files oficial compila, abre, smoke test (§16) | NOT TESTED (em andamento pela AGY) |
| G1 | Pipeline validado com F001 (§28) | não iniciado |

## Features (ordem do §29)

| ID | Feature | Estado | Branch |
|---|---|---|---|
| F001 | Rename UX | não iniciado (aguarda G0) | feature/rename-ux |
| F003 | Nova aba vs duplicar | não iniciado | feature/new-vs-duplicate-tab |
| F005 | Preview / Details | não iniciado | feature/preview-details-shortcuts |
| F002 | Colunas | não iniciado | feature/independent-column-resize |
| F004 | Menu clássico | não iniciado | feature/classic-menu |
| F006 | Busca | não iniciado | feature/search-provider |

## Observações do ambiente (28/09/2026)

- CONFIRMED: repositório git criado em 28/09/2026 (D-006). `main` parte do commit upstream `99951c66` ("Build: v4.2.9", 19/08/2026), que bate com os horários dos arquivos da pasta. Comando: `git reset --mixed 99951c66` + `git status`. Remotos: `origin` = `alxchs/FilesCustom` (fork), `upstream` = `files-community/Files`. Nada foi enviado (push).
- OBSERVED: `Get-ChildItem src\Files.App\bin -Recurse -Filter Files.App.exe` não encontrou nada. Isso diz que não há build nesse caminho, não que o app não compila.
- CONFIRMED: em relação ao upstream v4.2.9, só quatro arquivos de código/build diferem (`git diff --ignore-cr-at-eol`). São ajustes da AGY, ainda **sem commit**; INFERRED que foram feitos para compilar, NOT TESTED o motivo de cada um:
  - `Files.slnx`: removidas as plataformas arm64/x86 e os projetos Files.App.Launcher, OpenDialog (+Win32), SaveDialog (+Win32), Files.App.Server, Files.App.UITests e Files.InteractionTests; Files.App perdeu as BuildDependency deles.
  - `Directory.Packages.props`: `Microsoft.WindowsAppSDK` 2.4.0→2.5.1; `Microsoft.CodeAnalysis.CSharp/Analyzers/Workspaces.Common` 5.9.0→5.6.0.
  - `Directory.Build.props`: `Platform` vazio/AnyCPU passa a x64; BOM removido.
  - `nuget.config`: `<clear />` em `packageSourceMapping`; BOM removido.
  - **Risco para o G0:** o G0 pede o app *oficial*. Um app compilado sem Launcher/Dialogs/Server e com pacotes trocados pode não ser o baseline. A AGY deve justificar cada item abaixo, com o erro de build que o motivou, ou reverter.
- `CLAUDE.md` do upstream é um link simbólico (modo 120000) para `AGENTS.md`; no Windows sem symlink vira o texto `AGENTS.md`, que não é um import. Por isso `.claude/CLAUDE.md` importa `@AGENTS.md` de fato (D-005) e o repositório usa `core.symlinks=false`.

## Ajustes de build feitos antes do G0

(A AGY lista aqui cada item da seção acima só para compilar, com o erro que o motivou e o comando que provou o efeito. Depois, commit separado: `chore(build): ...`.)

## Problemas preexistentes do upstream

(Registrar no G0, com o comando que os reproduz. Não atribuir ao trabalho customizado, §16.)
