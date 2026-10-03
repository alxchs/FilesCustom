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
- **Decision (Alexandre):** trazer o upstream agora e ajustar. Tag de segurança `safety/pre-upstream-merge-v4.2.9` criada antes (local, não enviada).
- **Reason:** quanto mais tarde, mais conflito. Antes de F001+ a base precisa ser a atual.
- **Trade-offs:** o baseline do G0 e as medições de `tools/perf/` foram feitos no v4.2.9 e precisam ser refeitos nesta base. 7 conflitos, todos resolvidos com a versão do upstream (as supressões de warning da AGY nesses pontos foram descartadas e reavaliadas). Roslyn continua fixado em 5.6.0 porque o compilador do SDK 10.0.301 é 5.6.0 (o 5.9.0 do upstream dá CS9057).
- **Consequences:** voltar atrás = `git reset --hard safety/pre-upstream-merge-v4.2.9`.

## PENDING DECISION

(Dúvidas que a AGY encontrar enquanto o Claude estiver parado: contexto, opções, a escolha que ela faria e por quê.)
