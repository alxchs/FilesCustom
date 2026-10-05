# F010 — Todas as Colunas do Windows Explorer

## Objetivo

Permitir que o usuário inclua no layout Details do Files App qualquer coluna oferecida pelo Windows Explorer (o diálogo "More..." do Explorer com centenas de propriedades do Windows Property System: Autor, Álbum, Dimensões, Duração, Taxa de bits, Data de captura, Câmera, Modelo, etc.), além das 16 colunas fixas atuais do Files.

## Origem

MASTER_SPEC §46 (pedido expresso do Alexandre, D-009). Task brief em `docs/agents/tasks/F010-all-explorer-columns.md`.

## Escopo da Fase 1 (Investigação e Arquitetura — sem código de produto)

1. **Enumeração das Propriedades do Explorer**:
   - Enumerar via `PSEnumeratePropertyDescriptions` do Windows Property System todas as propriedades visualizáveis.
   - Comparar com a lista do diálogo "Choose Details / More..." do Windows Explorer.
   - Categorizar por grupo (Geral, Mídia, Imagem, Documento, Áudio, Vídeo, etc.).
   - Mapear nome canônico (`System.*`), nome localizado (em pt-BR e en-US), tipo de dado (string, data, número, tamanho, enum), capacidade de ordenação/agrupamento (`PDTF` / `PDSD`).

2. **Prova de Leitura de Valores**:
   - Provar que `IShellItem2.GetProperty` / `IPropertyStore` lê os valores com precisão para diferentes tipos de arquivo reais:
     - Foto com EXIF (`.jpg` / `.png`): Dimensões, Data de captura, Câmera, Fabricante.
     - Áudio (`.mp3`): Artista, Álbum, Título, Duração, Taxa de bits, Ano.
     - Vídeo (`.mp4`): Duração, Largura/Altura do quadro, Taxa de quadros.
     - Documentos (`.docx`, `.pdf`): Autor, Páginas, Contagem de palavras.
   - Medir o tempo de extração por item e projetar o custo em 10.000 itens (§31).

3. **Mapeamento de Impacto no Files**:
   - Mapear as 16 colunas fixas atuais no `ColumnsViewModel` e no XAML.
   - Reaproveitamento da infraestrutura existente (`ShellItemPropertyStore`, `PSFormatForDisplayAlloc`, `RetrievePropertiesAsync`).
   - Identificar alterações necessárias para suportar um modelo **dinâmico** de colunas.

4. **Proposta de Desenho Arquitetural (`docs/architecture/explorer-columns.md`)**:
   - Modelo de dados dinâmico de colunas.
   - Estratégia de carregamento sob demanda (apenas linhas visíveis, thread em background, cancelável, sem engasgo de rolagem).
   - Mecanismo de persistência por pasta / tipo de pasta (compatível com a persistência de registro existente).
   - Seletor de colunas com busca, agrupamento por categoria e ordenação.

## Critérios de Aceitação (Fase 1)

Documento `docs/architecture/explorer-columns.md` contendo todos os números e comparações medidas de forma empírica (`OBSERVED` / `CONFIRMED`, com scripts de reprodução em `tools/perf/`); nenhuma alteração invasiva em `src/` nesta fase.
