# Continuidade entre agentes (Claude ↔ AGY)

Complementa `MASTER_SPEC.md` (§20–27). Objetivo: se um agente parar (cota, erro, sessão encerrada), o outro continua **sem inventar contexto e sem perder trabalho**.

> **Metodologia geral** (papéis, arquivos de continuidade, briefs, handoffs, estados de evidência, tags, forks, medição) está em `C:\Users\alxch\.dev-method\METODO.md`, comum a todos os projetos. Este arquivo mantém só o que é do Files Custom. O passo a passo para a AGY seguir sozinha está em `docs/agents/PLAYBOOK.md`. Onde este texto repete o METODO, vale o METODO.

## Princípio

A memória de uma conversa não conta. Só existe o que está em arquivo no repositório: código, commits, `AGENT_CONTEXT.md`, `STATUS.md`, `DECISIONS.md`, `docs/agents/`. Quem não escreveu lá, não deixou para o outro.

## Ao começar qualquer sessão (Claude ou AGY)

1. Ler `AGENTS.md`, `AGENT_CONTEXT.md`, `STATUS.md` e o handoff mais recente em `docs/agents/handoffs/`.
2. Ler `MASTER_SPEC.md` só nas seções da tarefa atual (é longo; as regras gerais estão em §12–15, §19, §27, §30).
3. Rodar `git status`, `git branch`, `git log -10 --oneline`, `git diff --stat`. Se não houver repositório git, isso é um BLOCKER registrado em `STATUS.md`: avise e não comece feature.
4. Reverificar no código/estado atual o que o handoff afirma. Afirmação não reverificada vale **INFERRED**, nunca CONFIRMED.

## Enquanto trabalha

- **Checkpoint a cada passo verde**: build que passou, teste que passou, doc concluída. Commit local na branch da feature (`wip(<feature>): ...` é aceito; a limpeza fica para o fim). Cota pode acabar sem aviso: trabalho não commitado é trabalho que pode se perder.
- Atualizar `AGENT_CONTEXT.md` (campos CURRENT TASK, NEXT ACTION, BLOCKER, OWNER, LAST UPDATE) quando a situação mudar, não só no fim.
- **Dono da tarefa**: o campo OWNER de `AGENT_CONTEXT.md` diz quem está mexendo. O outro agente não edita os arquivos dessa tarefa. Isso evita dois agentes sobrescrevendo um ao outro.
- Nunca desfazer trabalho que não é seu: sem `git reset --hard`, `git checkout -- <arquivo>`, `git clean` ou sobrescrita em arquivo com mudança de outro agente. Se houver conflito, registre no handoff e resolva sem descartar.
- `git push` só com confirmação explícita do Alexandre naquele momento.

## Quando um agente para

Ao parar por cota/erro/fim de sessão, o agente escreve o handoff (modelo §26) em
`docs/agents/handoffs/AAAA-MM-DD_HHMM_<agente>_<feature>.md` e atualiza `AGENT_CONTEXT.md`. Se a parada for abrupta e não houver handoff, vale o último commit + `AGENT_CONTEXT.md`; tudo o que só estava no chat é INFERRED ou NOT TESTED.

### A AGY parou (cota 429 ou outro motivo)

- O Claude **não implementa nem conclui o código da AGY por falta de cota** (regra global do Alexandre). Só assume código se a AGY falhou por outro motivo após 5+ tentativas, e diz isso ao Alexandre.
- O Claude usa o tempo para produzir **insumos**: task briefs em `docs/agents/tasks/`, análise arquitetural somente-leitura (§41), critérios de aceite, revisão do que já foi commitado (§43), atualização de docs. A AGY retoma do brief + handoff quando voltar.
- Troca de conta/modelo da AGY segue as regras globais de cota; não é assunto deste documento.

### O Claude parou

- A AGY segue **dentro** da TASK e da ACCEPTANCE já aprovadas em `docs/agents/tasks/`. Não muda escopo, arquitetura nem critério de aceite.
- Dúvida que exigiria decisão do Claude: registrar em `DECISIONS.md` como `PENDING DECISION` (contexto + opções + a que a AGY escolheria e por quê), e seguir com uma tarefa independente ou com documentação. Não decidir por conta própria e não "chutar" o comportamento.
- Melhoria fora do escopo vira `DISCOVERY` (§11), sem implementar.

## Task brief (Claude → AGY)

Um arquivo por tarefa em `docs/agents/tasks/Fxxx-<nome>.md`, com: `TASK`, `ACCEPTANCE`, `ARQUIVOS PROVÁVEIS`, `DO NOT CHANGE`, `TESTES OBRIGATÓRIOS` (§15, casos do §5–§10), `FORA DE ESCOPO`, `BRANCH`. Sem brief aprovado, a AGY não começa a feature.

## Evidência e honestidade

- Estados: `NOT TESTED`, `OBSERVED`, `INFERRED`, `CONFIRMED` (§27). Relatório cita o comando e a saída que sustentam cada `CONFIRMED`.
- Feature com UI só é concluída depois de aberta e usada de verdade (captura de tela ou UI Automation), não só por build/teste.
- "X não existe/não está instalado" exige busca exaustiva com o comando citado. "Não achei em Y" é a frase válida até lá.
- Mesmo sintoma pela 2ª vez: investigar causa raiz comum antes de mais um contorno.
- Não copiar afirmação técnica de doc anterior sem reverificar no código atual.
- OneCommander: só comportamento observável pela interface (§3.1).

## Gate G0 — baseline

Nenhuma feature (F001 em diante) começa antes do G0. G0 = versão do repositório oficial, **sem customização de produto**, compilada, executada e com smoke test registrado (§16), problemas preexistentes anotados. Só ajustes de ambiente/build necessários para compilar são permitidos antes do G0, e cada um deve estar listado em `STATUS.md`. Quem verifica o G0 registra o comando de build, a saída resumida e o que foi aberto na tela.
