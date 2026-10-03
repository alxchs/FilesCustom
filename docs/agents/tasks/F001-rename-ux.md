# F001 — Rename UX (extensão protegida)

Status: BRIEF EM RASCUNHO (Claude, 03/10/2026). Só vira APROVADO depois de G0 fechado e de `docs/ux-reference/onecommander/rename.md` existir (pipeline do §22/§28). Executor: AGY. Branch: `feature/rename-ux`.

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
