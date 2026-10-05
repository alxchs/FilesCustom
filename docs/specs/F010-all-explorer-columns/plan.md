# F010 — Plano de Investigação e Desenho (Fase 1)

## Etapas de Execução

### T1 — Enumerar Propriedades do Windows Property System
- Criar script C# / PowerShell em `tools/perf/enumerate_properties.ps1` usando `PSEnumeratePropertyDescriptions` (`propsys.dll`).
- Extrair:
  - Quantidade total de propriedades registradas no Windows 11.
  - Nome canônico (`System.Author`, `System.Image.Dimensions`, etc.).
  - Nome localizado em português do Brasil e inglês.
  - Tipo de dado e representação (`PROPVARIANT` type).
  - Flags de exibição (`PROPDESC_VIEW_FLAGS`).
- Comparar com a janela "More Details" do Explorer.

### T2 — Teste Empírico de Leitura de Valores (`IPropertyStore` / `IShellItem2`)
- Criar script em `tools/perf/test_property_read.ps1` para ler propriedades reais de arquivos de mídia, documentos e imagens.
- Testar nos arquivos existentes de `C:\FilesUXLab` e mídia do sistema:
  - Imagem JPG/PNG (Dimensões, Câmera).
  - Áudio MP3 (Título, Artista, Duração).
  - Vídeo MP4.
  - Documentos PDF/TXT/DOCX.
- Medir a latência por propriedade e por item (Stopwatch em microssegundos / milissegundos).
- Calcular o impacto em 10.000 itens se carregado síncrono vs assíncrono virtualizado.

### T3 — Análise de Integração no Files App
- Analisar a classe `ShellItemPropertyStore` existente em `src/Files.App/Utils/Shell/ShellItem.cs` que já utiliza `PInvoke.PSFormatForDisplayAlloc`.
- Analisar como estender `ListedItem` para armazenar propriedades dinâmicas sem overhead de memória desnecessário (ex.: dicionário esparso ou array indexado por ID de coluna visível).
- Desenhar a interface do Seletor de Colunas (diálogo modal com busca incremental, árvore/lista agrupada por categoria, checkboxes e reordenação).

### T4 — Elaboração do Relatório de Arquitetura e Decisão
- Produzir `docs/architecture/explorer-columns.md`.
- Concluir Fase 1 com status `PENDING DECISION` para validação do Claude e do usuário antes de codar a Fase 2.
