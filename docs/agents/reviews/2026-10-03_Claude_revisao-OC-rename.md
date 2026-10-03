# Revisão do Claude — `docs/ux-reference/onecommander/rename.md` (AGY, 03/10/2026)

Método: li o documento inteiro, conferi que as capturas citadas existem (`05_`, `10_`, `14_`, `15_` e as `edge_*` estão na pasta `evidence/rename/`, 31 PNG) e comparei com o código do Files. Não reabri o OneCommander: as observações dele são da AGY, ainda não reproduzidas por mim.

## Veredito

**ACEITO como insumo da F001.** Cobre todos os casos do §5, atalhos, mouse, cancelamento, conflito, caracteres inválidos, seleção múltipla e dois layouts, e responde à queixa original. Decisão tomada a partir dele: F001 aprovado com a opção A (ver `docs/agents/tasks/F001-rename-ux.md`).

## Achados

- **MINOR — afirmações de implementação escritas como FACT.** "O OneCommander utiliza um único TextBox, controlando a seleção via `SelectionStart`/`SelectionLength`", "grava via `System.IO`" e "WPF 64-bit" são **INFERRED**: o §3.1 permite só o comportamento externamente observável. O que é FACT é "a extensão está na mesma caixa e pode ser apagada pelo teclado". Reclassificar ou remover os nomes de API.
- **MINOR — rótulos FACT/INFERRED/PROPOSED (§19) quase só nas "Fluxos alternativos".** O resto das seções mistura observação e interpretação. A frase "diagnóstico 100% evidente nas medições" é exagero: não houve medição, houve observação por captura e script.
- **MINOR — "toast ... `activate_test.log.txt`".** O texto do toast mostra a extensão antiga concatenada. Está na captura `06_`; conferir se o texto citado bate letra a letra (o Claude não reabriu a captura).
- **NOTE — a tabela de edge cases é a parte mais valiosa.** O `.gitignore` e o `.tar.gz` falham **igual no Files** (confirmado no smoke do G0 e no código). Isso reposiciona a F001: não é "o Files é melhor que o OneCommander", é "os dois têm o mesmo defeito de fundo".
- **NOTE — diferença a favor do Files:** F2 em seleção múltipla abre o `BulkRenameDialog`, enquanto o OneCommander reduz ao item ativo.
- **NOTE — recurso do OneCommander que o Files não tem:** renomear em cadeia com `Tab` (próximo arquivo) e o menu de sugestões (maiúsculas, data). Registrados como DISCOVERY no brief da F001, sem implementar.
- **NOTE — o "Tab = Nome → Extensão → próximo arquivo" que a AGY recomendou** conflita com o `Tab` em cadeia do OneCommander e pode surpreender quem vem dele; a decisão final do brief usa `Tab` = extensão e `Shift+Tab` = nome, sem pular de arquivo.

## Ações (AGY)

1. Reclassificar as afirmações de implementação como INFERRED (ou removê-las).
2. Seguir para a F001 conforme o brief aprovado (`feature/rename-ux`): primeiro o helper puro com testes unitários, depois a integração nos três layouts.
