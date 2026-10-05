# Arquitetura: F010 — Todas as Colunas do Windows Explorer

Status: **FASE 1 CONCLUÍDA — PENDING DECISION (Claude / Alexandre)**
Data: 2026-10-05
Autor: Antigravity
Branch: `feature/all-explorer-columns`
Referência: MASTER_SPEC §46, `docs/agents/tasks/F010-all-explorer-columns.md`

---

## 1. Descoberta e Enumeração da Lista do Explorer

Utilizando a API nativa `PSEnumeratePropertyDescriptions` (`propsys.dll`) com `IPropertyDescriptionList` (`{1f9fc1d0-c39b-4b26-817f-011967d3440e}`) e `IPropertyDescription` (`{6f79d558-3e96-4549-a1d1-7d75d2288814}`), enumeramos o conjunto completo de propriedades do Windows 11 nesta máquina:

- **Total de Propriedades no Sistema (`PDEF_ALL`):** **868 propriedades**
- **Propriedades Elegíveis para Colunas (`PDEF_COLUMN`):** **369 propriedades**
- **Propriedades Visualizáveis (`PDEF_VIEWABLE`):** **356 propriedades**

A listagem integral de 868 propriedades foi exportada para `docs/architecture/windows_properties.csv`.

### Categorias Principais (por agrupamento canônico `System.<Grupo>.*`):

| Grupo | Quantidade de Colunas | Exemplos de Propriedades |
|---|---|---|
| **Contact** | 73 | `System.Contact.EmailAddress`, `System.Contact.HomePhone` |
| **Document** | 34 | `System.Document.DateCreated`, `System.Document.CharacterCount`, `System.Document.PageCount` |
| **Media** | 34 | `System.Media.Duration`, `System.Media.Year`, `System.Media.Producer` |
| **Photo** | 22 | `System.Photo.DateTaken`, `System.Photo.CameraModel`, `System.Photo.CameraManufacturer`, `System.Photo.FNumber`, `System.Photo.ISOSpeed` |
| **Music** | 20 | `System.Music.Artist`, `System.Music.AlbumTitle`, `System.Music.TrackNumber`, `System.Music.Genre` |
| **Message** | 17 | `System.Message.DateReceived`, `System.Message.FromAddress`, `System.Message.Subject` |
| **RecordedTV** | 15 | `System.RecordedTV.EpisodeName`, `System.RecordedTV.StationCallSign` |
| **Calendar** | 14 | `System.Calendar.Duration`, `System.Calendar.Location` |
| **Video** | 12 | `System.Video.FrameWidth`, `System.Video.FrameHeight`, `System.Video.FrameRate`, `System.Video.TotalBitrate` |
| **Image** | 7 | `System.Image.Dimensions`, `System.Image.HorizontalSize`, `System.Image.VerticalSize` |
| **Audio** | 5 | `System.Audio.EncodingBitrate`, `System.Audio.SampleRate`, `System.Audio.ChannelCount` |
| **VersionControl** | 6 | `System.VersionControl.LastCheckinDate`, `System.VersionControl.Author` |
| **Link / Shell** | 9 | `System.Link.TargetParsingPath`, `System.FileOperation.TargetName` |

Comparação com o diálogo *"Choose Details"* do Windows Explorer:
O diálogo do Windows Explorer lista exatamente o subconjunto de `PDEF_COLUMN` (as ~369 propriedades registradas) com seus respectivos `DisplayName` localizados e larguras padrões recomendadas (`GetDefaultColumnWidth`).

---

## 2. Leitura Empírica de Valores e Medição de Desempenho

### 2.1. Prova de Conceito com `IShellItem2` e `PSFormatForDisplayAlloc`

Testado em arquivo real de imagem (`C:\FilesUXLab\sample.jpg`):
```text
  System.ItemNameDisplay      = "sample.jpg"
  System.Image.Dimensions     = "800 x 600"
  System.Image.HorizontalSize = "800 pixels"
  System.Image.VerticalSize   = "600 pixels"
  System.Size                 = "10,1 KB"
  System.DateModified         = "01/10/2026 19:31"
  System.ItemTypeText         = "JPG File"
```
**Resultado:** Os valores foram extraídos e formatados pelo subsistema do Windows com 100% de precisão sem necessidade de parsers manuais ou bibliotecas externas.

### 2.2. Medição de Desempenho e Projeção (10.000 Itens)

Executadas 100 iterações de extração de propriedades completas via `tools/perf/PropertyExplorer/`:

- **Tempo por propriedade individual:** **~1.300 µs (1,3 ms)**
- **Tempo por item (7 propriedades):** **~9,1 ms**
- **Projeção para pasta de 10.000 itens (síncrono puro):**
  $$\text{Tempo Total} = 10.000 \times 9,1\text{ ms} = 91,1\text{ segundos}$$

> [!WARNING] Risco Crítico de Performance
> A leitura síncrona na UI thread de propriedades estendidas para 10.000 itens congelaria o aplicativo por mais de 1 minuto e meio (~91 segundos).
>
> **Requisito Mandatório:** A leitura de colunas dinâmicas deve ocorrer de forma **estritamente assíncrona, virtualizada e pausada durante scroll rápido**, aproveitando o padrão `scrollSettledTcs` já existente em `ShellViewModel.cs:LoadExtendedItemPropertiesAsync`.

---

## 3. Mapeamento no Files App Atual

### 3.1. Estado Atual das Colunas (100% Estático)
Hoje o Files App possui exatamente **16 colunas fixas**:
1. `Icon`
2. `Name`
3. `Tag`
4. `DateModified`
5. `DateCreated`
6. `ItemType`
7. `Size`
8. `Path`
9. `OriginalPath`
10. `DateDeleted`
11. `Status` (SyncStatus de nuvem)
12. `GitStatus`
13. `GitLastCommitDate`
14. `GitLastCommitMessage`
15. `GitCommitAuthor`
16. `GitLastCommitSha`

Essas colunas estão codificadas fixamente em:
- `ColumnsViewModel.cs`: propriedades fortes de cada coluna.
- `DetailsLayoutPage.xaml`: 33 `ColumnDefinition`s (16 colunas + 16 divisores + 1 trailing), cabeçalhos `DataGridHeader` e células no `ItemTemplate`.
- `DetailsLayoutPage.xaml.cs`: switches de cópia de largura e auto-fit.
- `LayoutPreferencesManager.cs` / `LayoutPreferencesDatabase.cs`: serialização no Registro.

### 3.2. Infraestrutura Existente Pronta para Reuso
- `ShellItemPropertyStore` (`src/Files.App/Utils/Shell/ShellItem.cs`): Já possui o método `GetPropertyString(string propertyName)` que chama `PSGetPropertyKeyFromName` e `PSFormatForDisplayAlloc`.
- `ShellViewModel.LoadExtendedItemPropertiesAsync`: Já possui o loop virtualizado em background com cancelamento.

---

## 4. Proposta de Desenho Arquitetural (Colunas Dinâmicas)

Para permitir qualquer coluna do Explorer sem quebrar as 16 colunas existentes nem degradar a performance, propomos o seguinte desenho:

### 4.1. Modelo Dinâmico de Coluna (`DynamicColumnDefinition`)
```csharp
public sealed class DynamicColumnDefinition : ObservableObject
{
    public string CanonicalName { get; init; } // Ex: "System.Image.Dimensions"
    public PROPERTYKEY PropertyKey { get; init; }
    public string DisplayName { get; init; }   // Ex: "Dimensões"
    public string Category { get; init; }      // Ex: "Imagem"
    public GridLength Width { get; set; }      // Padrão do Property System ou 120px
    public TextAlignment Alignment { get; init; }
    public bool IsVisible { get; set; }
}
```

### 4.2. Armazenamento Esparso em `ListedItem`
Adicionar em `ListedItem`:
```csharp
private Dictionary<string, string>? _dynamicProperties;

public string? GetDynamicProperty(string canonicalName)
{
    if (_dynamicProperties != null && _dynamicProperties.TryGetValue(canonicalName, out var val))
        return val;
    return null;
}

public void SetDynamicProperty(string canonicalName, string value)
{
    _dynamicProperties ??= new(StringComparer.OrdinalIgnoreCase);
    _dynamicProperties[canonicalName] = value;
}
```
*Vantagem:* Dicionário alocado apenas quando o usuário habilitar colunas dinâmicas para a pasta. Impacto zero de memória para uso padrão.

### 4.3. Renderização Dinâmica no Layout Details
- Manter as 16 colunas fixas nativas inalteradas para máxima performance e compatibilidade de template.
- Adicionar uma seção dinâmica de colunas à direita (ou coleção de `ColumnDefinition`s adicionadas em tempo de execução ao `HeaderGrid` e `RowStackPanel`).
- Células dinâmicas utilizam `TextBlock` estilizado idêntico ao `ColumnContentTextBlock`.

### 4.4. Interface do Seletor de Colunas ("Escolher Detalhes...")
- Adicionar item no menu de contexto do cabeçalho de colunas: `"Mais..."` ou `"Escolher Detalhes..."` (como no Windows Explorer).
- Abrir diálogo WinUI `ContentDialog` com:
  1. Campo de busca rápida no topo.
  2. Lista com checkboxes agrupada por categoria (Áudio, Vídeo, Imagem, Documento, etc.).
  3. Botões "Mover para Cima", "Mover para Baixo" e largura em pixels.

### 4.5. Persistência Híbrida
- As 16 colunas existentes continuam usando a chave de Registro atual (`HKCU\Software\Files Community\<PackageId>\v1\LayoutPreferences\<pasta>`).
- Novas colunas ativas são serializadas como lista de nomes canônicos e larguras em valor string JSON (`DynamicColumns = "[{\"Key\":\"System.Image.Dimensions\",\"Width\":140}]"`). Se não houver colunas adicionais, a chave não é criada.

---

## 5. Próximos Passos e Decisão Pendente

A Fase 1 de investigação técnica e benchmark empírico está **100% concluída**.
Aguardando aprovação do Claude e do Alexandre sobre o desenho proposto antes de iniciar a Fase 2 (implementação em `src/`).
