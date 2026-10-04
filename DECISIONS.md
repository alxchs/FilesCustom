# DECISIONS

Formato (MASTER_SPEC §37): Context, Problem, Options, Decision, Reason, Trade-offs, Consequences. Decisões maiores podem ir em `docs/decisions/`.

## D-001 — MASTER_SPEC.md é regra de desenvolvimento para Claude e AGY (28/09/2026)

- **Context:** o Alexandre entregou `Files_Custom_MASTER_SPEC.md` e pediu que valha para as próximas etapas, com Claude e AGY alinhados a partir do momento em que a AGY conseguir rodar o app oficial.
- **Decision:** o texto foi salvo sem alterações como `MASTER_SPEC.md` na raiz. `AGENTS.md` aponta para ele. Mudança no spec só com decisão registrada aqui.
- **Consequences:** o spec vale integralmente a partir do gate G0; antes disso valem só as restrições do G0 em `docs/agents/CONTINUITY.md`.

## D-002 — Papéis: spec × regras globais do Alexandre

- **Problem:** o spec (§20, §23) trata Claude como Chief/Architect e a AGY como executora; as regras globais do Alexandre proíbem o Claude de fazer o trabalho da AGY por falta de cota.
- **Decision:** prevalece o mais restritivo. Claude: arquitetura, briefs, critérios, revisão, docs. AGY: exploração, implementação, teste, build. Claude só escreve o código da AGY se ela falhar por motivo que não seja cota, após 5+ tentativas, avisando o Alexandre.
- **Consequences:** ver "Quando um agente para" em `docs/agents/CONTINUITY.md`.

## D-003 — Continuidade por arquivos e commits, não por conversa

- **Decision:** estado em `AGENT_CONTEXT.md`, `STATUS.md`, handoffs e task briefs em `docs/agents/`; checkpoints em commits locais. Protocolo completo em `docs/agents/CONTINUITY.md`.
- **Reason:** cota acaba sem aviso; o que só estava no chat se perde e o agente seguinte tenderia a preencher a lacuna com suposição.

## D-004 — Gate G0 antes de qualquer feature

- **Decision:** nada de F001+ antes do baseline (§16). Tarefa da AGY agora: compilar/rodar o Files oficial.

## D-005 — Como cada agente carrega estas regras

- **Decision:** `AGENTS.md` recebe uma seção curta no fim do arquivo (um único trecho, para facilitar merge com o upstream, §13). `.claude/CLAUDE.md` importa `@AGENTS.md` e `@AGENT_CONTEXT.md`. `GEMINI.md` na raiz repete o apontamento para a AGY.
- **Trade-off:** NOT TESTED se a AGY (`agy.exe`) lê `AGENTS.md`/`GEMINI.md` do projeto; até confirmar, o prompt de disparo da AGY deve mandar ler `AGENTS.md` e `AGENT_CONTEXT.md` explicitamente.

## D-006 — Repositório: fork `alxchs/FilesCustom` ancorado no upstream v4.2.9 (28/09/2026)

- **Context:** a pasta não era um repositório git; o spec (§13) pede fork sustentável.
- **Decision:** fork de `files-community/Files` criado em `https://github.com/alxchs/FilesCustom` (nome do §36). Local: `origin` = fork, `upstream` = Files oficial; `main` parte do commit `99951c66` (Build: v4.2.9), o único que bate com a árvore existente.
- **Reason:** dá diff real contra o upstream e permite `git merge upstream/main` depois; separa ajustes da AGY do código oficial.
- **Trade-offs:** GitHub não permite fork privado de repositório público; o fork é **público**. Nada foi enviado. Um `git push` publicaria `MASTER_SPEC.md`, `STATUS.md` etc.; só com confirmação do Alexandre (regra global). Alternativa: repositório privado sem vínculo de fork.
- **Consequences:** o histórico do upstream vem junto (baixado localmente). `core.symlinks=false` porque o `CLAUDE.md` do upstream é symlink.

## D-007 — Desempenho: a referência é o OneCommander (01/10/2026)

- **Context:** o Files Dev abriu (G0 parcial) e o Alexandre o achou lento em quase tudo: abrir o app, entrar em pastas, rolagem/miniaturas, cliques e menus. Ele quer substituir o OneCommander.
- **Decision (Alexandre):** a meta de desempenho é ficar melhor que o OneCommander nas mesmas ações. Comparar com o Files oficial não interessa.
- **Consequences:** desempenho vira trilha própria (F007), medida pelos scripts de `tools/perf/`, com linha de base em `tools/perf/README.md`. Cada otimização precisa mostrar o antes/depois com os mesmos scripts. Continua valendo D-002 (Claude define brief e critério; AGY implementa) e o gate G0.

## D-008 — Base migrada do upstream v4.2.9 para upstream/main (03/10/2026)

- **Context:** o `main` do fork no GitHub foi sincronizado com o upstream (127 commits à frente de v4.2.9, nenhum do Alexandre ou da AGY). O local estava em v4.2.9.
- **Decision (Alexandre):** trazer o upstream agora e ajustar. Tag de segurança `tag_v4.2.9.0_build-zero-warnings-abertura-appx-perf-onecommander_salvo` criada antes (publicada em origin).
- **Reason:** quanto mais tarde, mais conflito. Antes de F001+ a base precisa ser a atual.
- **Trade-offs:** o baseline do G0 e as medições de `tools/perf/` foram feitos no v4.2.9 e precisam ser refeitos nesta base. 7 conflitos, todos resolvidos com a versão do upstream (as supressões de warning da AGY nesses pontos foram descartadas e reavaliadas). Roslyn continua fixado em 5.6.0 porque o compilador do SDK 10.0.301 é 5.6.0 (o 5.9.0 do upstream dá CS9057).
- **Consequences:** voltar atrás = `git reset --hard tag_v4.2.9.0_build-zero-warnings-abertura-appx-perf-onecommander_salvo`.

## PENDING DECISION

(Dúvidas que a AGY encontrar enquanto o Claude estiver parado: contexto, opções, a escolha que ela faria e por quê.)

## D-009 — Requisitos adicionais: densidade, fontes, colunas do Explorer e motor de busca (03/10/2026)

- **Context:** o Alexandre pediu quatro itens de configuração: modo compacto (menor entrelinhamento), fonte das áreas fixas separada da fonte dos resultados, todas as colunas que o Windows Explorer oferece, e escolher se o F3 usa a busca do Files, o Agent Ransack ou o Everything, sem abrir a tela deles. Autorizou reordenar tudo.
- **Decision:** acrescentados ao `MASTER_SPEC.md` como §46 (F008 a F011), com briefs em `docs/agents/tasks/`. Nova ordem de execução no §46 e no `PLAYBOOK.md`. F006 passa a ser a infraestrutura de busca e a F011 é a escolha de motor.
- **Reason:** são pedidos expressos, logo têm "razão legítima" para configuração (§33). F008/F009 são pequenos e de baixo risco; F010 exige modelo dinâmico de colunas e a F011 depende de `ISearchProvider`.
- **Trade-offs:** o spec original (D-001) era "verbatim"; esta seção é a primeira alteração, registrada aqui. Colunas dinâmicas (F010) e busca externa (F011) aumentam o diff contra o upstream; mitigação: arquivos próprios e fases com gate do Claude.
- **Consequences:** a lista no §29 está superada pelo §46. Nenhuma configuração muda o comportamento padrão.
- **Fatos verificados em 03/10/2026:** F3 e Ctrl+F já estão em `SearchAction`; linha mínima do Details é 28 px; fonte global única `AppThemeFontFamily`; Everything 1.4.1.1032 e Agent Ransack 9.2.3425.1 (com `flpsearch.exe`) instalados. O que é INFERRED/NOT TESTED está marcado nos briefs.


## D-010 — Claude corrigiu 3 erros de compilacao do wip da F001 (03/10/2026)

- **Context:** o wip da AGY (`774f5eb64`) nunca tinha sido compilado e `mkfile release` falhou com 3 erros em `BaseGroupableLayoutPage.cs`. O disparo da AGY foi bloqueado pelo classificador do Claude Code mesmo com a permissao do Alexandre no chat, e ele nao soube criar a regra de permissao. O Alexandre queria um exe testavel.
- **Options:** (1) esperar a AGY; (2) Claude corrige so os erros de compilacao; (3) reabrir o exe antigo.
- **Decision:** opcao 2, autorizada explicitamente pelo Alexandre em 03/10/2026 ("Tem minha autorizacao"). Escopo: `using Windows.Storage;`, inicializar `ActiveRenameParts` com `FileNameParts` vazio (no campo e em `ResetRenameState`) e `[DynamicWindowsRuntimeCast(typeof(TextBox))]` em `RenameTextBox_SelectionChanged` (warning CsWinRT1034). Nada mais.
- **Reason:** a falha da AGY nao foi cota nem 5 tentativas; foi bloqueio de disparo. Excecao pontual e autorizada a regra "a AGY faz, o Claude nunca termina por ela".
- **Trade-offs:** os achados MAJOR de comportamento (tecla End destrava a extensao; `showExtensionDialog` suprimido em arquivo sem extensao) **continuam abertos** na AGY, em `docs/agents/reviews/2026-10-03_Claude_revisao-F001-wip.md`.
- **Consequences:** `mkfile release src\Files.App\Files.App.csproj` = 0 Warning(s), 0 Error(s) (03/10/2026 18:29). App aberto por `Open-FilesDev.ps1`.

## D-011 — F001: Correcao de comportamento (End, dialogo, Tab, clique e edge cases) (03/10/2026)

- **Context:** Revisao `docs/agents/reviews/2026-10-03_Claude_revisao-F001-wip.md` apontou 2 achados MAJOR restantes (End e clique fora da extensao destravavam a extensao; `showExtensionDialog` suprimido para arquivos sem extensao) e MINORs (Tab em arquivo sem extensao, `.user.js` na lista de compostas, cobertura de testes do helper).
- **Decision:**
  1. No `RenameTextBox_KeyDown`, a tecla `End` e `Down` limitam a selecao a `nameLen` quando a extensao estiver travada; em `SelectionChanged`, qualquer posicao do cursor alem de `nameLen` e truncada de volta para `nameLen` a menos que tenha havido clique de mouse explicitamente dentro dos limites da extensao (`PointerPressed` com medicao do texto da extensao).
  2. Em `CommitRenameAsync`, o dialogo de extensao so e suprimido se `IsExtensionDeliberatelyModified == true`. Arquivo sem extensao (`arquivo` -> `arquivo.exe`) preserva `IsExtensionDeliberatelyModified = false` e exibe o dialogo modal Sim/Nao.
  3. `Tab` em item sem extensao (`!ActiveRenameParts.HasExtension`) e no-op (`e.Handled = true`).
  4. `.user.js` removido de `CompoundExtensions` (mantendo apenas compressoes `.tar.*`).
  5. Casos de borda no helper: dotfiles com multiplos pontos (`.env.local`, `.tar.gz` sem prefixo) tratam o ultimo segmento como extensao (`.local`, `.gz`), permitindo editar o nome base e protegendo a extensao final. Nomes terminando com ponto (`arquivo.txt.`) tem extensao vazia. Testes do helper ampliados para 20 casos cobrindo todos os cenarios.
  6. `Tab` seleciona a extensao sem o ponto inicial para agilizar a substituicao direta.
- **Consequences:** `mkfile release src\Files.App\Files.App.csproj` resulta em 0 Warning(s) e 0 Error(s). Todos os 20 casos de teste passam com sucesso.



## D-012 — Spec-Driven Development (SDD) passa a ser a metodologia de features (04/10/2026)

- **Context:** o Alexandre pediu "specs para metodologia SDD" a partir de agora (interpretado como Spec-Driven Development; o pedido veio escrito "ssd"). Até aqui cada feature tinha um brief único (TASK/ACCEPTANCE/ARQUIVOS) e o `MASTER_SPEC.md` como spec-mãe.
- **Decision:** `METODO.md` §6 reescrito: por feature, `docs/specs/<ID>-<nome>/` com `spec.md` (o quê e por quê, cenários `AC-n`, requisitos `FR-n`), `plan.md` (como) e `tasks.md` (o que a AGY executa); portões spec, plan, tasks, código; rastreabilidade por `AC-n` no handoff e na nota de liberação. Modelos em `~/.dev-method/templates/`, `Novo-Projeto.ps1` cria `docs/specs`. Primeira feature: F005.
- **Reason:** o brief misturava comportamento e implementação, e a verificação ficava sem critério numerado; a F001 mostrou o custo (defeitos de comportamento só achados na revisão).
- **Trade-offs:** mais três arquivos por feature e um portão a mais. Mitigação: specs curtas, briefs de exploração e medição continuam como estão, e features já aprovadas (F001) terminam pelo brief.
- **Consequences:** a AGY não implementa sem `tasks.md` aprovado. Descoberta no caminho: o projeto `tests/Files.App.UnitTests` citado nos briefs **não existe** (CONFIRMED por `git ls-files`), então teste unitário exige script `pwsh` ou projeto novo; decisão fica na T2 da F005.

## D-013 — Teste da função pura da F005 via script PowerShell (04/10/2026)

- **Context:** a tarefa T2 da F005 exige teste automatizado dos 6 cenários de alternância (AC-1 a AC-6) e registro em DECISIONS.md da escolha entre script `pwsh` e projeto novo `tests/Files.Custom.Tests`.
- **Problem:** o projeto de testes unitários não existe no repositório; criar projeto novo em `Files.slnx` introduz churn no build e risco de divergência com o upstream.
- **Options:** (1) Criar um projeto `tests/Files.Custom.Tests.csproj` adicionando-o à solution; (2) Criar script `tests/test-pane-toggle-helper.ps1` que compila dinamicamente a função com `Add-Type` e valida os casos em milissegundos, replicando o padrão já aprovado de `tests/test-rename-helper.ps1`.
- **Decision:** opção 2 (`tests/test-pane-toggle-helper.ps1`).
- **Reason:** atende 100% ao critério de aceite com diff mínimo, sem tocar em arquivos de projeto (.csproj / .slnx), mantendo compatibilidade total com upstream e execução instantânea.
- **Consequences:** os 6 casos AC-1..AC-6 são validados executando `pwsh -File tests/test-pane-toggle-helper.ps1` com 6/6 aprovados.

