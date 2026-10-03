# Revisão do Claude — smoke test §16 / G0 (AGY, 03/10/2026)

Revisado: handoff `2026-10-03_1215_AGY_G0-fechado-smoke-concluido.md` e a seção "Smoke test §16 — 4.2.37.0" do `STATUS.md` (ainda não commitados pela AGY quando li). Método: li o texto, abri a captura `smoke_item5_rename_gitignore.png` e conferi no código as afirmações do item 8. Classificação do §43: BLOCKER / MAJOR / MINOR / NOTE.

## Veredito

**G0: ACEITO como fechado**, com as correções MAJOR/MINOR abaixo registradas. O build 0/0 foi verificado por mim (`mkfile release`, 03/10) e o app foi aberto e capturado por mim. O smoke cobre os 9 itens do brief com capturas. Nenhum BLOCKER.

## Achados

- **MAJOR — item 8 (colunas) está como CONFIRMED por leitura de código, não por uso do app.** O brief F002 exigia medir a largura de todas as colunas antes e depois de arrastar. O texto cita só código-fonte. O código **bate** com a conclusão: `DetailsLayoutPage.xaml` liga `Width` de cada coluna a `ColumnsViewModel.<Coluna>.Length` (em pixel, sem `*`), `DetailsLayoutColumnItem.NormalMinLength = 50`, e `GridSplitter.Events.cs` só mexe na coluna vizinha se a atual for estrela (`IsStarColumn`). Logo: "outras colunas não mudam ao arrastar" é **fortemente INFERRED pelo código; a medição no app é NOT TESTED**. Estado correto: `OBSERVED (código) / NOT TESTED (medição)`. A queixa original do Alexandre ("colunas amarradas") **não se reproduz por design no Files**; a F002 provavelmente se reduz a largura mínima/máxima e ao Nome truncado (ver NOTE).
- **MINOR — item 1: tempo de abertura.** "~3,5 s medido em `bench.ps1`" é o tempo de abrir uma pasta de teste, não o da abertura do app (o README do `tools/perf` já avisa que inclui o processo lançador). Não é o tempo até a janela responder. Estado correto: `NOT TESTED` para tempo de inicialização.
- **MINOR — item 5, `.gitignore`.** A captura confirma o que se vê: a caixa de edição mostra `.gitigr` com o X ao lado, ou seja, **truncada**. A explicação ("trata o ponto inicial como separador de extensão") é **INFERRED**. Pelo código (`StartRenameItem`), `Path.GetExtension(".gitignore")` devolve `.gitignore`, logo a seleção é de 0 caracteres; o corte parece da largura da caixa, que é herdada da coluna Nome. Dois defeitos possíveis diferentes (seleção vazia × largura). A F001 deve testá-los separadamente.
- **NOTE — a coluna Nome está estreita por padrão** na captura (`activate_te...`, `arquivo fin...`). Isso afeta a legibilidade dos nomes e a caixa de renomear; insumo para F001 e F002.
- **NOTE — item 3** cita arraste de aba "sem erro visual" com uma captura estática. Para F003 e a regra de Drag and Drop do Alexandre, falta decidir se haverá GIF (pergunta feita ao Alexandre, sem resposta).
- **NOTE — handoff "Problemas: nenhum; cota ativa".** O próprio handoff do Claude registra que a conta usada pelo `agy --print` é desconhecida; "cota ativa" vale por ora, sem garantia.
- **OK — item 7.** Bate com a análise do código do Claude (`ToggleDetailsPane`/`TogglePreviewPane` só trocam de aba; `Ctrl+Alt+I` abre o painel). A contagem de 2 passos está correta.
- **OK — item 9.** Plausível e coerente com `ContinueLastSessionOnStartUp`. Aceito.
- **OK — A/B do backdrop.** Revisão separada em `F007-B-compositor-idle.md`.

## Ações

1. AGY: ao commitar, ajustar os estados do item 8 (para `OBSERVED/NOT TESTED`) e do item 1, e anotar os dois defeitos distintos do `.gitignore` no item 5. Não precisa refazer o smoke.
2. AGY: na F002, a medição antes/depois de larguras no app continua sendo a primeira tarefa.
3. Claude: reabrir a decisão da F001 quando existir o `rename.md` do OneCommander.
