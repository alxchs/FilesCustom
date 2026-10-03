# F001 — Rename UX (extensão protegida)

Status: **APROVADO (Claude, 03/10/2026)**, opção A. Pré-requisitos cumpridos: G0 fechado (revisão `docs/agents/reviews/2026-10-03_Claude_revisao-G0-smoke.md`) e `docs/ux-reference/onecommander/rename.md` existe. Executor: AGY. Branch: `feature/rename-ux`.

## DECISÃO (Claude, 03/10/2026, depois de ler o `rename.md` e o código)

Opção **A** (caixa de texto única, blindada), pelos fatos:

- FACT (OneCommander, `rename.md`): também usa uma caixa única, seleciona só o nome base, `Tab` pula para o **próximo arquivo** (não para a extensão), e trocar a extensão exige setas + Backspace manual. Após o Enter mostra um toast pedindo para recolocar a extensão antiga. Falha em `.gitignore` (seleção vazia) e em `.tar.gz` (seleciona `arquivo.tar`).
- FACT (Files, código lido): também caixa única; a extensão fica livre para editar; `.gitignore` tem o mesmo defeito de seleção vazia (e a caixa aparece truncada, ver revisão do G0). Ao trocar a extensão o Files mostra um **diálogo modal Sim/Não** (`FilesystemHelpers.RenameAsync`, ~l.587-601: `showExtensionDialog && GetExtension(origem) != GetExtension(novo) && FoldersSettings.ShowFileExtensionWarning`), desligável pela opção `ShowFileExtensionWarning`.
- Conclusão: o problema de fundo é o mesmo nos dois (sem gesto deliberado para a extensão, sem proteção contra apagá-la sem querer). Um segundo campo (opção B) mexe nos três layouts sem ganho extra.

### Requisitos fechados para a implementação

1. **Seleção inicial correta** em todos os casos do §5: `arquivo.txt` → `arquivo`; `arquivo` → tudo; `arquivo.final.txt` → `arquivo.final`; `arquivo.tar.gz` → `arquivo` (extensão composta `.tar.gz`/`.tar.bz2`/`.tar.xz`/`.tar.zst` reconhecida por uma lista pequena e fixa); `arquivo.` → o nome inteiro; **dotfile (`.gitignore`, `.env`)** → nome inteiro `.gitignore` selecionado, sem extensão (nunca seleção vazia); pasta e atalho `.lnk` como hoje.
2. **Proteção da extensão enquanto edita o nome:** mudanças de texto que atinjam a região da extensão são rejeitadas (`TextBox.BeforeTextChanging`/seleção), por exemplo Backspace no limite nome|extensão não apaga o ponto. Ctrl+A seleciona só o nome.
3. **Gesto deliberado para a extensão:** `Tab` move a seleção para a extensão (já destravada e toda selecionada, pronta para substituir); `Shift+Tab` volta ao nome. Clicar com o mouse dentro da extensão também a destrava. Enter confirma, Esc cancela, em qualquer ponto.
4. **Diálogo de confirmação:** se a extensão foi destravada pelo gesto do item 3, **não** mostrar o diálogo Sim/Não (a intenção é explícita); a proteção do item 2 torna o diálogo redundante nesse caso. A opção `ShowFileExtensionWarning` continua valendo para os outros caminhos (ex.: BulkRename). Nenhuma opção nova (§33).
5. **Largura da caixa** no layout Details: corrigir o corte (`.gitigr`) ou, se a causa for a largura herdada da coluna Nome, usar largura mínima segura. Testar `.gitignore` separadamente de `.gitignore` com seleção (são dois defeitos distintos, ver revisão).
6. Lógica de separar nome/extensão em **helper próprio e puro** (arquivo novo, testável), usado pelos três layouts (Details, Grid, Column) para não duplicar.

### DISCOVERY registrado (não implementar agora)
- **Renomear em cadeia com `Tab` → próximo arquivo** (comportamento do OneCommander). Estado: `IMPLEMENT LATER`. Conflita com o uso de `Tab` do item 3; se um dia entrar, usar `Ctrl+Tab`/seta para baixo.
- **Seleção múltipla + F2:** o OneCommander reduz ao item ativo; o Files abre o `BulkRenameDialog`. O do Files é melhor; manter.

## TASK
Renomear (F2) deve separar NOME e EXTENSÃO: mudar o nome não altera a extensão; mudar a extensão é ato deliberado. Casos: MASTER_SPEC §5 (`arquivo.txt`, `arquivo`, `arquivo.tar.gz`, `arquivo.final.txt`, `arquivo final 01.txt`, `arquivo.`, `.gitignore`).

## ARQUITETURA ATUAL (lida no código em 03/10/2026; nada foi executado, tudo NOT TESTED)
- Início: `RenameAction` (F2, `Actions/FileSystem/RenameAction.cs`) → `ItemManipulationModel.StartRenameItem` → `BaseGroupableLayoutPage.StartRenameItem(string)` (`Views/Layouts/BaseGroupableLayoutPage.cs`, ~l.286). Seleção múltipla abre `BulkRenameDialog`.
- A edição é um `TextBox` único com o nome completo (`ItemNameRaw`). A extensão vem de `ListedItem.FileExtension = Path.GetExtension(name)` (`Data/Items/ListedItem.cs`, ~l.573). Seleciona `Length - extensionLength` caracteres, ou seja, só o nome. A extensão **não está protegida**: dá para apagá-la com Ctrl+A, End+Backspace, ou o clique.
- Confirmar: `CommitRenameAsync` → `newItemName = textBox.Text.Trim().TrimEnd('.')` → `UIFilesystemHelpers.RenameFileItemAsync(..., nameIsComplete: ShouldShowExtensionInRename)` (`Helpers/UI/UIFilesystemHelpers.cs`, l.51). `showExtensionDialog = true`: existe um diálogo de confirmação ao trocar extensão (verificar o gatilho em `FilesystemHelpers.RenameAsync`).
- Layouts com TextBox próprio: Details, Grid, Column (`DetailsLayoutPage`, `GridLayoutPage`, `ColumnLayoutPage`). Três lugares para manter coerentes.

## SUSPEITAS A CONFIRMAR POR TESTE (INFERRED, NOT TESTED)
1. `.gitignore`: `Path.GetExtension(".gitignore")` = `".gitignore"`, logo seleção de 0 caracteres (nada selecionado).
2. `arquivo.`: o `TrimEnd('.')` no commit remove o ponto final em silêncio.
3. `arquivo.tar.gz`: `GetExtension` = `.gz`, seleciona `arquivo.tar` (comportamento aceitável, decidir se `.tar.gz` deve ser protegido inteiro).

## OPÇÕES (decisão do Claude após o rename.md do OneCommander)
- A) Manter o TextBox único e **blindar**: regra de extensão única/dupla, dotfile, seleção correta, e travar a edição da extensão até um gesto deliberado. Menor diff, bom para o upstream (§13).
- B) Dois campos (nome + extensão). Mais fiel ao spec, mais código em 3 layouts.
- Recomendação provisória: A, salvo se a observação do OneCommander mostrar que B é o que resolve a reclamação.

## ACCEPTANCE
§5 do spec: impossível ou altamente improvável alterar a extensão por acidente; Enter confirma, Esc cancela; todos os casos da lista passam; conflito de nome e nome inválido tratados; cancelamento não altera nada; teste de seleção múltipla (Bulk) sem regressão.

## ARQUIVOS PROVÁVEIS
`BaseGroupableLayoutPage.cs`, `DetailsLayoutPage.xaml.cs`, `GridLayoutPage.xaml.cs`, `ColumnLayoutPage.xaml.cs`, helper novo isolado para separar nome/extensão (arquivo próprio, §13), testes em `tests/Files.App.UnitTests`.

## DO NOT CHANGE
`BulkRenameDialog` (fora de escopo), motor de rename de `FilesystemHelpers`, outros recursos.

## TESTES OBRIGATÓRIOS
Unitário do helper nome/extensão com todos os casos do §5; funcional no `C:\FilesUXLab` nos três layouts; regressão: rename de pasta, atalho `.lnk`, alternate stream, desfazer.
