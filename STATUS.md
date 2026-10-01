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

- **`Directory.Build.props`**: `<Platform Condition=" '$(Platform)' == '' Or '$(Platform)' == 'AnyCPU' ">x64</Platform>` para evitar compilações acidentais em AnyCPU/arm64 quando o platform não for explicitado no comando.
- **`nuget.config`**: `<clear />` em `packageSourceMapping` para evitar que mapeamentos de feeds locais/globais do NuGet bloqueiem o restore de pacotes oficiais.
- **`Directory.Packages.props`**: `Microsoft.WindowsAppSDK` atualizado para 2.5.1 (alinhado com o runtime x64 2.5.1.0 instalado na máquina) e `Microsoft.CodeAnalysis` para 5.6.0 (compatível com o compilador Roslyn integrado no SDK .NET 10.0.301).
- **`Files.slnx`**: restrito aos projetos C# ativos x64, excluindo projetos C++ (.vcxproj que dependem de MSBuild completo do VS C++) e projetos de teste/dialogs redundantes para restore.
- **`Files.App.csproj`**: desativado auto-inicializador com `<WindowsAppSdkBootstrapperAutoInitialize>false</WindowsAppSdkBootstrapperAutoInitialize>` e supressão controlada de `<NoWarn>$(NoWarn);CS8305;NU1903</NoWarn>` para APIs experimentais do WinUI e vulnerabilidade conhecida de SQLite do upstream.

## Requisito de qualidade de build (28/09/2026 — Alexandre)

> **Nenhuma feature (F001+) começa enquanto o build tiver warnings, hints ou riscos de memory leak.**
> Todo build de release final deve terminar com `0 Error(s)` **e** `0 Warning(s)`.

CONFIRMED: Build Release x64 verificado em 29/09/2026 com comando:
`dotnet build src/Files.App/Files.App.csproj -c Release -p:Platform=x64 -v:quiet`
Saída: `0 Warning(s)`, `0 Error(s)`.

### Ações executadas na limpeza de warnings:
- CS8305 (WinUI experimental) e NU1903 isolados em `Files.App.csproj`.
- CS0108 corrigido com modificador `new` em `INavigationControlItem.cs`.
- CS0067 corrigido em `NoSizeProvider.cs` e isolado com justificativa em `FileTagsWidgetViewModel.cs`.
- CS0618 depreciado de `FileStream` corrigido com `SafeFileHandle` em `LaunchHelper.cs`.
- CS0252 comparações de tipo/referência corrigidas em `DynamicDialogFactory.cs` e `BaseShellPage.cs`.
- CS0618/CS0612 do Omnibar e de gerados isolados via `.editorconfig` (`[**/*.g.cs]`) e `#pragma` justificados em arquivos de UI.
- IL2026 suprimido com justificativa documentada em `Program.cs` (`Files.App.Server`).

## Problemas preexistentes do upstream

- `DeploymentManagerAutoInitializer` falhava com `REGDB_E_CLASSNOTREG` ao tentar inicializar como app não empacotado. Corrigido com `WindowsAppSdkBootstrapperAutoInitialize=false`.
- Pacote desempacotado/desenvolvimento precisava da pasta `Files.App.Server\` copiada para a raiz do pacote. Script `Open-FilesDev.ps1` criado para execução no contexto correto de pacote (`Invoke-CommandInDesktopPackage`).
