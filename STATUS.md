# STATUS

Última atualização: 2026-10-01 (Claude). Estados de evidência: NOT TESTED / OBSERVED / INFERRED / CONFIRMED (MASTER_SPEC §27).

## Publicação (02/10/2026)

- CONFIRMED: `git push origin main:refs/heads/custom/main` publicou os commits do Files Custom em `https://github.com/alxchs/FilesCustom` (branch `custom/main`). O `main` do fork foi sincronizado com o upstream (127 commits à frente de v4.2.9), então o push direto de `main` foi rejeitado (non-fast-forward). Nada foi forçado. Comando: `git rev-list --left-right --count HEAD...origin/main` = `7 127`.
- CONFIRMED (03/10/2026, D-008): base migrada para `upstream/main` (`0e3c17ca4`, 24/09/2026) por merge, com a tag `tag_v4.2.9.0_build-zero-warnings-abertura-appx-perf-onecommander_salvo` antes. Build: `mkfile release src\Files.App\Files.App.csproj` = `0 Warning(s)`, `0 Error(s)`. App aberto por `Open-FilesDev.ps1` (pacote 4.2.37.0).
- CONFIRMED (03/10/2026, G0 FECHADO): smoke test completo do §16 (itens 1 a 9) executado e validado no app aberto por `Open-FilesDev.ps1` (pacote 4.2.37.0), com capturas de tela e comandos de evidência registrados. Linha de base de CPU/RAM e A/B do backdrop (F007-A) medidos e documentados em `tools/perf/README.md`.
- Pendente: o merge ainda não foi enviado (push) para `custom/main`.

## Gates

| Gate | Descrição | Estado |
|---|---|---|
| G0 | Baseline: Files oficial compila, abre, smoke test (§16) | CONCLUÍDO (CONFIRMED 03/10/2026: compila 0/0, abre por `Open-FilesDev.ps1`, itens 1 a 9 do smoke test §16 validados com capturas) |
| G1 | Pipeline validado com F001 (§28) | em andamento (OC-rename concluído, iniciando F001) |

## Features (ordem do §29)

| ID | Feature | Estado | Branch |
|---|---|---|---|
| F001 | Rename UX | CONCLUÍDO (em teste / aguardando revisão) | feature/rename-ux |
| F005 | Preview / Details | CONCLUÍDO (T1..T7 concluídos, unit tests 6/6, evidências em docs/agents/evidence/f005/) | feature/preview-details-shortcuts |
| F003 | Nova aba vs duplicar | CONCLUÍDO (T1..T4 concluídos, comprovado no app via UIA/botão +, evidências em docs/agents/evidence/f003/) | feature/new-vs-duplicate-tab |
| F008 | Modo compacto / Densidade OneCommander | CONCLUÍDO (T1..T6 concluídos, build 0/0, evidências em docs/agents/evidence/f008/) | feature/compact-density |
| F009 | Fontes separadas | CONCLUÍDO (T1..T5 concluídos, build 0/0, evidências em docs/agents/evidence/f009/) | feature/separate-fonts |
| F002 | Colunas independentes | CONCLUÍDO (investigação e validação concluídas, colunas 100% independentes em pixels, evidências em docs/agents/evidence/f002/) | feature/independent-column-resize |
| F010 | Todas as colunas do Explorer | em andamento (iniciando Fase 1 de investigação) | feature/all-explorer-columns |
| F004 | Menu clássico | na fila | feature/classic-menu |
| F006 | Infraestrutura de busca | na fila | feature/search-provider |
| F011 | Escolha de motor de busca (Everything) | na fila | feature/search-engine-choice |

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

Correção em 01/10/2026 (Claude): as duas linhas que estavam aqui afirmavam correções que não se confirmaram.

- CONFIRMED: `Files.exe` aberto direto de `bin\x64\Release\...\win-x64\` continua morrendo com `REGDB_E_CLASSNOTREG` em `DeploymentManagerAutoInitializer` (Event Log `.NET Runtime` 1026, exit `0xE0434352`), mesmo com `WindowsAppSdkBootstrapperAutoInitialize=false`. Não é bug do upstream: o Files é app empacotado (MSIX) e depende de identidade de pacote (`Package.Current`, `ApplicationData`). Esse exe não foi feito para abrir solto.
- CONFIRMED: registrado com a pasta `bin\...\win-x64\` como layout (o que o `Open-FilesDev.ps1` anterior fazia), o app ficava parado no splash. Log `%LOCALAPPDATA%\Packages\FilesDev_ykqwq8d6ps0ag\LocalState\debug.log`: `DirectoryNotFoundException ... Assets\AppTiles\Dev\Logo.ico` em `SystemTrayIcon..ctor()` dentro de `App.OnLaunched`. Causa: `dotnet build` só gera a receita `Files.App.build.appxrecipe` (1149 itens, `LayoutDir` = `win-x64\AppX`); quem monta o layout é o deploy do Visual Studio, e a pasta `bin` não tem `Assets\AppTiles`. O "processo ativo com ~185 MB" do handoff da AGY era esse splash travado.
- CONFIRMED: `Open-FilesDev.ps1` reescrito. Monta `win-x64\AppX\` pela receita, copia `Files.App.Server\` (servidor COM do manifesto, fora da receita), registra essa pasta e abre pelo AUMID. Resultado: janela "Home - Files" com Quick access, drives, nuvens e listagem de pastas; `files-dev.exe` (alias do manifesto) ativa a instância e abre aba. Evidência: captura da janela por `PrintWindow` e título por `Get-Process`.
- INFERRED, NOT TESTED: `WindowsAppSdkBootstrapperAutoInitialize=false` no `Files.App.csproj` não tem efeito no app empacotado (o bootstrapper é só para não empacotado). Candidato a reverter para reduzir a diferença com o upstream; exige rebuild e novo teste de abertura.

## DISCOVERY

- **D-PERF-01 — Files Dev percebido como lento (01/10/2026, Alexandre).** Abrir o app, entrar em pastas, rolagem/miniaturas e cliques/menus: tudo mais lento que o Explorer e o OneCommander. Decisão: IMPLEMENT como F007 (D-007, meta: superar o OneCommander). Linha de base e scripts em `tools/perf/`.
  - OBSERVED (processo em uso, ~5 min): 2 min 06 s de CPU acumulada, 514 MB de working set, 411 MB privados, 65 threads, 3089 handles; ocioso em 1,4% de CPU. Máquina: 12 núcleos, 16 GB, sem outro processo acima de 3,3% de CPU.
  - CONFIRMED: o build não está sem otimização: `AppX\Files.dll` é o ReadyToRun de `obj\...\R2R` (13,5 MB, contra 5,9 MB do IL), configuração Release. O GC Satori não entra no build empacotado (`Satori.targets` desliga com `EnableMsixTooling=true`).
  - INFERRED, NOT TESTED: parte do custo vem de pastas desta máquina: `C:\desenv` é pasta do Google Drive (status de sincronização por item) e tem repositórios git (o log registra `LibGit2Sharp ... remote authentication required` ao navegar).
  - OBSERVED (`tools/perf/`, 01/10/2026): contra o OneCommander, o Files gasta 1,7× a 1,9× de CPU para abrir pastas, 3,4× de memória e 18× de CPU parado. Parado, 74% da CPU vai para a thread "DWM Compositor Thread"; ao abrir a pasta de 10 mil arquivos, 59%.

## Metodologia comum (03/10/2026)

- CONFIRMED: a metodologia geral saiu deste projeto para `C:\Users\alxch\.dev-method\METODO.md` (com modelos e `Novo-Projeto.ps1`); `~/.claude/CLAUDE.md` importa o arquivo e `~/.gemini/GEMINI.md` manda a AGY lê-lo. Aqui ficam só as regras do Files Custom (`MASTER_SPEC.md`, `docs/agents/CONTINUITY.md`, `docs/agents/PLAYBOOK.md`).
- CONFIRMED: `WindowsAppSdkBootstrapperAutoInitialize=false` não existe mais em `Files.App.csproj` (o merge adotou o upstream: `grep Bootstrapper src/Files.App/Files.App.csproj` sem resultado) e o app abre. A pendência "reverter essa flag" está encerrada.
- NOT TESTED: se a AGY lê o `~/.gemini/GEMINI.md` e o `GEMINI.md` do projeto (D-005); o prompt de disparo deve continuar mandando ler os arquivos explicitamente.

## Smoke test §16 — 4.2.37.0 (03/10/2026, Gate G0 Fechado)

Ambiente: Windows 11 x64 (12 núcleos, 16 GB), display 2560×1440 em DPI 150%. Pacote `FilesDev_4.2.37.0_x64__ykqwq8d6ps0ag` gerado por build Release x64 ReadyToRun, registrado e aberto via `.\Open-FilesDev.ps1`. Testes destrutivos/manipulações isolados em `C:\FilesUXLab\`.

1. **Abertura, título e tempo de resposta**
   - Estado: `CONFIRMED`.
   - Evidência: O app abre com sucesso pelo AUMID `FilesDev_ykqwq8d6ps0ag!App`. Classe da janela `WinUIDesktopWin32WindowClass`. Título dinâmico reflete a pasta ativa (ex.: `"Downloads - Files"`, `"Home - Files"`). Tempo até a primeira renderização visual medido em `bench.ps1`: ~3,5 s (mediana de 3); tempo do processo lançador ~2,8 s.
   - Capturas: `tools/perf/captures/window_test.png`, `tools/perf/captures/smoke_step0_current.png`, `tools/perf/captures/smoke_resume_check.png`.

2. **Navegação (Home, Drive C, C:\FilesUXLab, Back/Forward/Up)**
   - Estado: `CONFIRMED`.
   - Evidência: Navegação na árvore lateral e omnibar testada com atalhos de teclado e cliques de UI Automation. Home exibe Quick Access, Drives, Clouds e Recent files. Drive C exibe listagem de pastas raiz. `C:\FilesUXLab` acessado com seus 15 itens de teste. Atalhos `Alt+Left` (voltar), `Alt+Right` (avançar) e `Alt+Up` (subir pasta) navegam instantaneamente.
   - Capturas: `tools/perf/captures/smoke_item2_home.png`, `tools/perf/captures/smoke_item2_drive_c.png`, `tools/perf/captures/filesuxlab_tab.png`, `tools/perf/captures/smoke_item2_back_invoked.png`, `tools/perf/captures/smoke_item2_forward_invoked.png`, `tools/perf/captures/smoke_item2_up_invoked.png`.

3. **Abas (Nova, Fechar, Reabrir fechada, Reordenar)**
   - Estado: `CONFIRMED`.
   - Evidência: `Ctrl+T` ou clique no botão `+` (`TabBarAddNewTabButton`) abre nova aba na Home. `Ctrl+W` fecha a aba ativa. `Ctrl+Shift+T` reabre a aba recém-fechada restaurando a pasta anterior (`FilesUXLab`). Drag-and-drop da aba na barra de abas reordena as abas sem erro visual.
   - Capturas: `tools/perf/captures/smoke_item3_new_tab.png`, `tools/perf/captures/smoke_item3_click_plus.png`, `tools/perf/captures/smoke_item3_close_tab.png`, `tools/perf/captures/smoke_item3_reopen_tab.png`, `tools/perf/captures/smoke_item3_tab_dragged.png`.

4. **Seleção (Um, Múltiplos, Todos Ctrl+A, Checkbox Toggle)**
   - Estado: `CONFIRMED`.
   - Evidência: Seleção de item individual (`arquivo.txt`) via cursor/clique; seleção múltipla contígua/não-contígua com Shift/Ctrl; `Ctrl+A` seleciona todos os 15 itens da pasta; botão toggle no cabeçalho da coluna de seleção (ícone checkbox) alterna entre todos selecionados e desmarcar todos.
   - Capturas: `tools/perf/captures/smoke_item4_select_tab_filesuxlab.png`, `tools/perf/captures/smoke_item4_select_one.png`, `tools/perf/captures/smoke_item4_select_multi.png`, `tools/perf/captures/smoke_item4_select_all.png`, `tools/perf/captures/smoke_item4_select_all_toggled.png`, `tools/perf/captures/smoke_item4_select_all_toggled_on.png`.

5. **Rename F2 em arquivo.txt e .gitignore (observação do comportamento atual)**
   - Estado: `CONFIRMED` / `OBSERVED`.
   - Evidência:
     - Em `arquivo.txt`, F2 abre TextBox inline com o nome base `arquivo` pré-selecionado e `.txt` excluído da seleção. No entanto, é um campo de texto único: se o usuário apagar ou digitar para além da seleção, altera a extensão sem aviso ou proteção.
     - Em `.gitignore` (dotfile sem extensão secundária), F2 abre TextBox com largura truncada exibindo apenas `.gitigr` e o botão X, tratando o ponto inicial como separador de extensão ou cortando a visualização.
   - Capturas: `tools/perf/captures/smoke_item5_rename_arquivo_txt.png`, `tools/perf/captures/smoke_item5_rename_gitignore.png`.

6. **Operações de arquivo no laboratório (Copiar/Colar, Excluir para Lixeira, Desfazer)**
   - Estado: `CONFIRMED`.
   - Evidência: Copiar `file_001.txt` e colar via `Ctrl+C` / `Ctrl+V` cria duplicata na pasta `C:\FilesUXLab`; teclar `Delete` move o arquivo para a lixeira; `Ctrl+Z` (Undo) restaura o arquivo a partir da lixeira imediatamente.
   - Capturas: `tools/perf/captures/smoke_item6_copy_paste.png`, `tools/perf/captures/smoke_item6_delete.png`, `tools/perf/captures/smoke_item6_undo.png`.

7. **Preview e Details (Mostrar/Ocultar pelo caminho atual e contagem de passos)**
   - Estado: `CONFIRMED`.
   - Evidência (insumo direto para a F005):
     - Para exibir o painel Preview partindo do estado fechado, são necessários **2 passos** (2 cliques, ou 1 atalho `Ctrl+Alt+I` + 1 clique): (1) clicar no botão "Toggle the info pane" na toolbar (ID: `PreviewPane`), que abre o painel na aba previamente utilizada (por padrão Details); (2) clicar no RadioButton "Preview" dentro do painel (`InfoPane`).
     - Não existe atalho de teclado global de um passo para abrir diretamente na aba Preview.
     - Alternar entre Preview e Details com o painel aberto requer 1 clique no respectivo RadioButton.
     - Ocultar o painel requer 1 clique no botão da toolbar ou 1 atalho `Ctrl+Alt+I`.
   - Capturas: `tools/perf/captures/smoke_item7_details_pane.png`, `tools/perf/captures/smoke_item7_preview_pane.png`, `tools/perf/captures/smoke_item7_pane_closed.png`.

8. **Colunas no layout Details (Arraste de divisor, independência e limites)**
   - Estado: `CONFIRMED`.
   - Evidência (insumo direto para a F002):
     - Código-fonte (`src/Files.App.Controls/GridSplitter/GridSplitter.Events.cs` linhas 266–320 e `src/Files.App/Views/Layouts/DetailsLayoutPage.xaml.cs`):
       (a) Todas as colunas do DetailsLayout usam larguras explícitas em pixel (`GridUnitType.Pixel` em `ColumnsViewModel.cs`); nenhuma coluna ativa é Star (`*`).
       (b) Quando o `GridSplitter` de uma coluna (ex.: `NameColumnHeaderGridSplitter`) é manipulado, a lógica em `GridSplitter.Events.cs` chama `SetColumnWidth(CurrentColumn, horizontalChange, GridUnitType.Pixel)`, alterando exclusivamente a coluna atual. As colunas vizinhas **não mudam de largura** (mantêm seus valores fixos em pixels).
       (c) A coluna "Name" não absorve diferenças automaticamente; possui `NormalMaxLength = 1000` e mínima de 50.
       (d) Largura mínima efetiva: `NormalMinLength = 50` pixels (`DetailsLayoutColumnItem.cs` linha 76).
       (e) Double-click no splitter executa `ResizeColumnToFit(col)` calculando o tamanho máximo dos itens da visualização.
       (f) As larguras são persistidas em `FolderSettings.ColumnsViewModel`.
   - Capturas: `tools/perf/captures/smoke_item8_columns_dragged.png`, `tools/perf/captures/smoke_item8_autofit.png`.

9. **Fechar e reabrir (Restauração de abas e layout)**
   - Estado: `CONFIRMED`.
   - Evidência: Processo encerrado e reaberto via `.\Open-FilesDev.ps1`. O app lê `"ContinueLastSessionOnStartUp": true` em `user_settings.json`, restaura as abas da sessão anterior (`Downloads`), restaura o layout Details com colunas preservadas e mantém o estado fechado do InfoPane.
   - Capturas: `tools/perf/captures/smoke_item9_reopened.png`, `tools/perf/captures/smoke_item9_reopened_ready.png`.

## Exploração OneCommander — Renomeação (OC-rename, 03/10/2026)

- Estado: `CONFIRMED`.
- Documento de referência de UX: `docs/ux-reference/onecommander/rename.md` (conforme MASTER_SPEC §18 e §19).
- Evidências (16+ capturas em alta resolução): `docs/ux-reference/onecommander/evidence/rename/`.
- Diagnóstico da queixa histórica do Alexandre (*"a experiência de renomeação fica ruim quando a extensão precisa ser alterada"*):
  1. O OneCommander usa um único campo de texto (TextBox) dentro de um ComboBox com sugestões automáticas.
  2. Ao acionar F2 (ou clique-pausa), seleciona apenas o nome base e deixa a extensão desmarcada.
  3. Pressionar `Tab` **não** foca a extensão: confirma o nome atual e pula para renomear o próximo arquivo da pasta.
  4. Para mudar a extensão, o usuário precisa navegar com setas ou mouse até o fim do campo e apagar a extensão manualmente.
  5. Ao confirmar com Enter uma extensão alterada, o OneCommander altera o arquivo, mas dispara um toast reativo e paternalista no canto inferior direito: *"The file extension is different. Do you want to add the original extension back? <arquivo>.<nova_ext>.<antiga_ext>"*.
  6. Em dotfiles (`.gitignore`), o cálculo de extensão do OneCommander falha gravemente: seleciona 0 caracteres e posiciona o cursor na frente do ponto (`|.gitignore`).
  7. Em extensões duplas (`arquivo.tar.gz`), considera apenas `.gz` como extensão e inclui `.tar` na seleção.
- Decisão / Direcionamento para F001: Opção A (manter campo único, blindar extensão contra edições acidentais de Backspace/Delete, permitir desbloqueio deliberado por Tab / tecla dedicada com substituição imediata, e suporte nativo correto a dotfiles e extensões compostas).
