# PLAYBOOK — como a AGY segue sozinha se o Claude estiver ausente

Escrito pelo Claude em 03/10/2026. Metodologia geral: `C:\Users\alxch\.dev-method\METODO.md` (leia primeiro). Este arquivo só traz o específico do Files Custom. Estado vivo: `AGENT_CONTEXT.md`. Regras do produto: `MASTER_SPEC.md`.

## Situação (03/10/2026)

- Base: `upstream/main` `0e3c17ca4` (pacote 4.2.37.0) + ajustes de build e limpeza de warnings. Build Release x64: 0 erros, 0 warnings (`mkfile release src\Files.App\Files.App.csproj`, PowerShell). App abre com `Open-FilesDev.ps1`.
- Tag de checkpoint publicada: `tag_v4.2.9.0_build-zero-warnings-abertura-appx-perf-onecommander_salvo` (estado antes do merge). Voltar atrás: `git reset --hard <tag>` (só com o Alexandre saber).
- Baseline e medições anteriores valem para o v4.2.9. **Nesta base: smoke test e medição NOT TESTED.**
- O Claude não conseguiu disparar a AGY por `--dangerously-skip-permissions` (bloqueado). Quem estiver lendo isto já foi iniciada pelo Alexandre.

## Fila (em ordem; marque cada item no `STATUS.md` ao concluir)

**Ordem vigente desde 03/10/2026 (MASTER_SPEC §46, substitui a ordem anterior; ordem completa em §46 "Nova ordem de execução").**

Feito: F007-A, G0 (smoke), OC-rename (exploração). Em andamento: **F001**.

1. **F001 Rename UX** — `docs/agents/tasks/F001-rename-ux.md` (aprovado, opção A). Termine com testes, handoff e commit na `feature/rename-ux`.
2. **F005** — `F005-preview-details-toggle.md` (implementar). Em seguida **F003** — `F003-new-vs-duplicate-tab.md` (só confirmar e registrar).
3. **F008 Modo compacto** — `F008-compact-density.md` (análise, depois implementação). Depois **F009 Fontes separadas** — `F009-separate-fonts.md`.
4. **F002 Colunas** — `F002-independent-column-resize.md` (investigação por teste, sem código). Depois **F010 Todas as colunas do Explorer** — `F010-all-explorer-columns.md` (fase 1: investigação; **para no gate do Claude**).
5. **F004 Menu clássico** — `F004-classic-menu-bar.md` (análise + protótipo; para no gate).
6. **F006 infraestrutura de busca** — `F006-search-provider.md` fase 1 (benchmark) e **F011 escolha de motor** — `F011-search-engine-choice.md` fase 1 (provar Everything e Agent Ransack **sem abrir a tela deles**; para no gate).
7. **F007-B** — `F007-B-compositor-idle.md` (medição, pode intercalar com os itens acima quando a tela estiver livre).
8. Novas explorações do OneCommander (lista de tópicos do Alexandre ainda não entregue) viram briefs de exploração.

Se a fila acabar: `DISCOVERY` em `STATUS.md`, handoff, `AGENT_CONTEXT.md` atualizado e pare.

## Pré-aprovado (decida sem perguntar)

- **F001:** opção A do brief (manter o TextBox único e blindar a extensão: nome selecionável, extensão travada até gesto deliberado, regras para dotfile e extensão dupla). Só passe para a opção B (dois campos) se o `rename.md` mostrar que A não resolve a queixa original. Marque o brief como `APROVADO (pré-aprovação do PLAYBOOK)` antes de codar. Branch `feature/rename-ux`.
- **F003:** brief aprovado `docs/agents/tasks/F003-new-vs-duplicate-tab.md`. A análise do Claude mostrou que o Files já separa Ctrl+T (Home) de Duplicar (Ctrl+Shift+K): a tarefa é confirmar no app e registrar; **não** criar a opção New Tab Behavior (DISCOVERY, IMPLEMENT LATER).
- **F005:** brief aprovado `docs/agents/tasks/F005-preview-details-toggle.md` (Toggle Preview/Details de um passo, Alt+P / Alt+Shift+P, no Command Palette; edição só em `Actions/Show/`). Branch `feature/preview-details-shortcuts`.
- **F007:** se o A/B mostrar que o fundo (Mica Alt) explica a CPU do compositor, **proponha** a correção mínima no brief; implementar só com aprovação do Claude. Se não explicar, abra novo `DISCOVERY` com o próximo suspeito e meça-o.
- Nomes de arquivos novos: em arquivos próprios, comentários mínimos, strings via `Strings.resx` (localização), CRLF, `.editorconfig` do repo.
- Warning novo em build de release: corrigir antes de seguir, supressão só escopada com motivo.

## Precisa do Alexandre ou do Claude (registre `PENDING DECISION` e siga com outra coisa)

- Qualquer mudança de escopo, de arquitetura, de critério de aceite (§21).
- F002, F004, F006 (implementação), e qualquer interface/abstração nova de busca (Everything).
- Trazer upstream de novo, rebase, reescrita de histórico, `git push` (**sempre** pedir ao Alexandre naquele momento; o push de `main` do fork é rejeitado por divergência, publique em `custom/main`).
- Lista de tópicos do OneCommander do Alexandre (ainda não entregue): ao receber, vira um brief de exploração por tópico.

## Como compilar, abrir e medir

```powershell
cd C:\desenv\utils\FilesApp
mkfile release src\Files.App\Files.App.csproj      # PowerShell (mkfile não está no PATH do Bash)
.\Open-FilesDev.ps1                                # monta o layout AppX pela receita, registra, abre. Feche o Files Dev antes
pwsh tools\perf\New-PerfLab.ps1                    # laboratório de 10k arquivos e 400 JPGs
pwsh tools\perf\idle.ps1 -WaitS 10                 # CPU por thread parado
pwsh tools\perf\thr.ps1 -Folder C:\FilesUXLab\perf\10k
pwsh tools\perf\bench.ps1 -Runs 3                  # Files × OneCommander
```

- Configurações do app (inclusive o fundo): `%LOCALAPPDATA%\Packages\FilesDev_ykqwq8d6ps0ag\LocalState\settings\user_settings.json`; log: `...\LocalState\debug.log`.
- Captura de tela: `PrintWindow` por janela do processo `Files` (scripts em `tools/perf/`); leia o PNG para verificar a UI.
- Laboratório de testes: `C:\FilesUXLab` (§17). Teste destrutivo só ali.

## Armadilhas já pagas

- Depois de merge ou troca de pacote, rode `dotnet restore` em **cada** projeto (assets velhos geram `MSB3277` falso no Server).
- Roslyn (`Microsoft.CodeAnalysis.CSharp/Analyzers`) está fixado em **5.6.0**: o compilador do SDK 10.0.301 é 5.6.0 e o 5.9.0 do upstream dá `CS9057`. Se o SDK for atualizado, reavalie e registre.
- `Files.exe` solto morre com `REGDB_E_CLASSNOTREG`: o app é MSIX; só abre por `Open-FilesDev.ps1`.
- O `python` do Bash é o atalho da Store e não roda; o Python 3.11 real está em `C:\Users\alxch\AppData\Local\Programs\Python\Python311` e funciona no PowerShell. Heredoc grande no Bash pode quebrar; use PowerShell ou a ferramenta de edição.
- Não mate `agy.exe --hub` de outra janela. Cota/troca de conta: regras globais (`~/.gemini/GEMINI.md`).
- OneCommander: só comportamento externo (§3.1). Nada de descompilar, inspecionar memória ou copiar código.
- O Files Dev tem abas e sessão do Alexandre: ao reabrir para testar, não feche trabalho dele sem motivo.
- Medição de desempenho: não mexa nas janelas durante a medição; o `PrintWindow` custa 100-160 ms por quadro.

## Definição de pronto de uma feature (resumo do §30, METODO §8)

Build 0/0, app aberto e feature usada de verdade (captura), casos do spec passando (§5–§10), cancelamento, edge cases, regressão, teclado/foco/DPI, performance, docs (`STATUS.md`, relatório do §38), testes unitários onde a arquitetura permitir, handoff, commit local. Depois **pare no gate de revisão**: o Claude (ou o Alexandre) aprova; sem isso, a feature fica "implementada, aguardando revisão", não "concluída".

## Tags

Ao concluir um marco: `tag_<versão do Package.appxmanifest>_<assunto predominante do que mudou desde a última tag>_salvo` (METODO §9). Publicar a tag só com o Alexandre autorizando push.

## Nota de liberação (sempre que gerar um exe)

Pedido do Alexandre em 03/10/2026: **todo executável gerado e entregue para teste** ganha uma nota de liberação, porque o projeto tem muitos itens e ele precisa saber o que está em cada exe.

- Escreva `docs/releases/AAAA-MM-DD_HHMM_build-<assunto>.md` (modelo: `docs/releases/2026-10-03_2109_build-F001.md`) e, quando a ferramenta de publicação existir na sessão, publique também uma página HTML (Artifact) com o mesmo conteúdo e informe o link.
- Conteúdo mínimo: caminho do exe, commit e versão do pacote, resultado do build (`0 Warning(s)` / `0 Error(s)`), **o que foi liberado** (item por item, com estado CONFIRMED / OBSERVED / NOT TESTED), **como testar**, **o que ainda não está no exe** (lista das F00x) e pendências.
- A nota descreve o exe que existe: só marque o que foi conferido, com o mesmo rigor do handoff. Sem exe novo, sem nota nova.
- Quem não puder publicar (AGY): escreva só o `.md`; o Claude publica a página.
