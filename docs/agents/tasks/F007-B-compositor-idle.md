# F007-B — O que mantém o compositor acordado com o app parado

Status: BRIEF APROVADO (Claude, 03/10/2026). Executor: AGY. Só medição, sem código de produto. Continua o F007-A.

## REVISÃO DO CLAUDE SOBRE O F007-A (lida em `tools/perf/README.md`, commit `eb688ef22`)

CONFIRMED (recalculei): medianas e razões batem. Parado (10 s, mediana de 3): MicaAlt 4.906 ms, Solid 1.844, Mica 1.875, Acrylic 1.516. Queda de 62% (Solid) a 69% (Acrylic). OneCommander: 141 ms.

Ressalvas que valem para quem usar esses números:
1. **O fundo explica uma parte, não a causa.** Mesmo com `Solid`, 184 ms de CPU por segundo (18% de um núcleo), 95% no `DWM Compositor Thread`, contra 14 ms/s do OneCommander (13×). A AGY escreveu isso; concordo.
2. **Mica comum e Acrylic já valem quase o mesmo que Solid.** Então o problema do `MicaAlt` é específico dele (o upstream mexeu no backdrop em `0f44e927d Fixed mica backdrop` e `17961ceef Fixed backdrop when reactivating window`; ler esses commits).
3. **A parte "abrir pasta de 10 mil" está ruidosa** e não sustenta conclusão: MicaAlt 5.047/3.219/2.750, Solid 14.609*/2.469/3.219, Mica 1.484/1.172/1.203. Mica fica abaixo de Solid, o que não faz sentido físico. Provavelmente ordem de execução e estado do app (cache, aquecimento). Não use essa coluna para decidir nada.
4. **Não foram intercalados** (cada material numa sequência própria) e o estado do app não foi controlado (4 abas do Alexandre, qual página estava aberta, janela com ou sem foco). Isso pode explicar parte das diferenças pequenas (Solid 1.844 × Mica 1.875 × Acrylic 1.516).
5. A afirmação "aponta para um loop ou animação contínua (ProgressRing, caret, timer...)" é **INFERRED, NOT TESTED**. A "proposta 2" (suspender o backdrop sem foco) também é hipótese.
6. Sobre a mudança de padrão para `Solid`/`Mica`: é uma decisão de produto do Alexandre (aparência), não só técnica. Não implementar sem ele.

## TASK

Descobrir, por bissecção medida, o que mantém o compositor acordado com o app ocioso, com **fundo Solid** (para tirar o backdrop da equação) e depois com MicaAlt. Cada passo muda **uma** variável, ordem intercalada, mesma janela e tamanho, 3 rodadas, `idle.ps1 -WaitS 10`. Registrar tabela em `tools/perf/README.md` (seção "F007-B"), cada número `OBSERVED` com o comando.

Matriz (marcar o que foi feito; parar quando uma variável derrubar o consumo para perto de 14 ms/s):

1. App em **primeiro plano** × **sem foco** (outra janela na frente) × **minimizado**. Se sem foco/minimizado cair, o consumo é da renderização visível.
2. **Página aberta**: Home (widgets/miniaturas de unidades) × pasta pequena × pasta vazia × Settings. Home é suspeita (atualização periódica de widgets).
3. **Número de abas**: 1 × 4 (as abas inativas continuam compondo?).
4. **Painel de info** aberto × fechado; **barra de status**; **Omnibar** em foco (caret piscando) × fora de foco; **dual pane**.
5. **Sidebar** (seções de nuvem/rede/WSL, que atualizam por eventos) recolhida × aberta.
6. Mouse parado sobre a janela × fora dela (hover states).
7. Com **Windows animations** desligadas (Configurações > Acessibilidade > Efeitos visuais) para ver se é animação de cursor/transição.

Ferramenta complementar (opcional, sem instalar nada novo): `Get-Counter` / contador "GPU Engine" ou o Gerenciador de Tarefas para ver se a GPU também fica ocupada; e o log `LocalState\debug.log` para ver se há eventos periódicos.

## ACCEPTANCE

Tabela com ao menos as variáveis 1 a 4, conclusão em uma frase por variável (derruba / não derruba / inconclusivo), e uma recomendação de correção **proposta** (arquivo e mecanismo), sem implementar. Se nenhuma variável explicar, dizer isso e abrir F007-C com captura ETW (WPR) do `Files.exe` — pedir ao Alexandre antes de instalar qualquer ferramenta.

## DO NOT CHANGE

`src/`, `tests/`. Restaurar `user_settings.json` ao original (MicaAlt) ao final.

## ENTREGA

Handoff, commit local, sem push.
