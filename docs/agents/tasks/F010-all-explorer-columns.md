# F010 — Todas as colunas do Windows Explorer

Status: BRIEF EM RASCUNHO, **sem pré-aprovação de implementação** (Claude, 03/10/2026). A AGY faz a fase 1 (investigação); o Claude decide o desenho de colunas dinâmicas antes de qualquer código de produto. Branch: `feature/explorer-columns`. Spec: `MASTER_SPEC.md` §46. Depende de F002.

## ARQUITETURA ATUAL (lida no código em 03/10/2026; nada executado)

- O layout Details tem colunas **fixas e nomeadas**: `ColumnsViewModel` (`Data/Models/ColumnsViewModel.cs`) com um `DetailsLayoutColumnItem` por coluna (Icon, Name, Tag, Path, OriginalPath, DateDeleted, DateModified, DateCreated, ItemType, Size, Status e 5 de Git). O XAML (`DetailsLayoutPage.xaml`) declara um `ColumnDefinition` por coluna ligado a `ColumnsViewModel.<Coluna>.Length`, e `DetailsLayoutPage.xaml.cs` (`UpdateColumnLayout`) copia larguras uma a uma. `AutoFitColumns` já escala pelas propriedades do tipo `DetailsLayoutColumnItem`.
- Acrescentar uma coluna hoje exige editar o view model, o XAML e o code-behind (3 lugares). Para "todas as colunas do Explorer" isso não escala: é preciso um modelo **dinâmico** (lista de colunas com identidade = chave de propriedade).
- O Files já lê propriedades estendidas de arquivos (ex.: `ListedItem` com propriedades carregadas por demanda para o painel de detalhes e para a coluna de tags/Git). Localizar esse mecanismo (`FileProperty`/`GetExtendedProperties`/`ShellViewModel`) e reaproveitar.

## FASE 1 — Investigação (autorizada à AGY, sem código de produto)

1. **Descobrir a lista do Explorer**: via PowerShell/CsWin32 de teste (fora de `src/`), enumerar `PSEnumeratePropertyDescriptions` e comparar com as colunas do diálogo "More..." do Explorer (captura). Produzir `docs/architecture/explorer-columns.md` com: quantas propriedades, as categorias (Geral, Mídia, Imagem, Documento…), nome canônico e nome localizado, tipo (texto, número, data, tamanho, booleano, enumeração), se são ordenáveis/agrupáveis (`PDTF`/`PDSD`).
2. **Ler o valor**: provar que `IShellItem2.GetProperty`/`IPropertyStore` devolve o valor para um arquivo de teste de cada tipo (foto com EXIF, mp3, mp4, docx, pdf). Medir o tempo por item e em 10 mil itens (§31).
3. **Mapear no Files**: quais dessas já existem como coluna, quais podem reaproveitar o leitor atual de propriedades, e o impacto no `ColumnsViewModel`.
4. **Propor o desenho** (colunas dinâmicas: modelo, persistência por pasta/tipo de pasta compatível com a existente, seletor de colunas com busca, leitura só das linhas visíveis, assíncrona e cancelável) em `docs/architecture/explorer-columns.md`. **Parar** e registrar `PENDING DECISION` para o Claude aprovar.

## ACCEPTANCE (fase 1)

Documento com números medidos (OBSERVED, com o comando) e a comparação com o Explorer; nenhuma mudança em `src/`.

## ACCEPTANCE (fases seguintes, §46)

Seletor de colunas reproduz a lista do Explorer (ou documenta as diferenças); valores corretos nos tipos de teste; pasta de 10 mil itens sem engasgo e sem leitura em UI thread; persiste; padrão idêntico ao atual; ordenação por coluna nova em fase posterior se barata.

## DO NOT CHANGE

Formato de persistência atual de colunas sem migração; colunas atuais.

## FORA DE ESCOPO

Editar propriedades (somente exibir); colunas calculadas próprias.

## ENTREGA

`docs/architecture/explorer-columns.md`, handoff, commit local, sem push.
