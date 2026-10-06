# F010 — Plano de Implementação (Fase 2)

## Etapas de Execução

### T2.1 — Modelo de Dados e Suporte a Propriedades em `ListedItem`
- Adicionar `DynamicColumnDefinition` em `src/Files.App/Data/Models/`.
- Adicionar armazenamento esparso sob demanda em `src/Files.App/Data/Items/ListedItem.cs`:
  - `Dictionary<string, string>? _dynamicProperties`
  - `GetDynamicProperty(string canonicalName)`
  - `SetDynamicProperty(string canonicalName, string value)`

### T2.2 — Catálogo de Propriedades do Explorer (`IExplorerPropertyService`)
- Criar contrato `IExplorerPropertyService` em `src/Files.App/Data/Contracts/`.
- Criar implementação `ExplorerPropertyService` em `src/Files.App/Services/`:
  - Catálogo nativo das principais propriedades de colunas do Windows Explorer (`PDEF_COLUMN`), divididas por categoria (Mídia, Imagem, Áudio, Vídeo, Documento, etc.).
  - Tradução e nomes amigáveis em pt-BR e en-US via recursos ou Windows Property System.
  - Registro no container IoC (`AppLifecycleHelper.cs`).

### T2.3 — Extrator Virtualizado em Background
- Integrar a extração de propriedades dinâmicas ativas em `ShellViewModel.LoadExtendedItemPropertiesAsync`:
  - Utilizar `ShellItemPropertyStore` existente com `PSFormatForDisplayAlloc`.
  - Execução assíncrona com cancelamento e pausa durante scroll rápido.

### T2.4 — Renderização Dinâmica no DetailsLayoutPage
- Estender `ColumnsViewModel` para expor a lista de `DynamicColumnDefinition` ativas.
- Atualizar `DetailsLayoutPage.xaml.cs` para adicionar dinamicamente cabeçalhos e colunas na Grid do layout quando colunas extras estiverem habilitadas.
- Suporte a redimensionamento com o `GridSplitter` da F002.

### T2.5 — Diálogo Seletor de Colunas ("Mais..." / "Choose Details")
- Adicionar opção *"Mais..."* no menu de contexto do cabeçalho de colunas (`DetailsLayoutPage.xaml`).
- Criar `ChooseDetailsDialog.xaml` com busca, árvore/lista agrupada por categoria, seleção com checkboxes e reordenação.

### T2.6 — Persistência por Pasta
- Atualizar `LayoutPreferencesManager` para persistir as colunas dinâmicas ativas e suas larguras no Registro da pasta.

### T2.7 — Validação e Evidências
- Compilação Release x64: `0 Warning(s), 0 Error(s)`.
- Abrir pasta com imagens/mídia (`C:\FilesUXLab\perf\img400`), adicionar colunas (ex: Dimensões, Câmera), validar exibição de dados reais e capturar telas.
- Nota de liberação e handoff.
