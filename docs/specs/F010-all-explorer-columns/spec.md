# F010 — Todas as Colunas do Windows Explorer

## 1. Objetivo

Permitir que o usuário inclua no layout Details do Files App qualquer coluna oferecida pelo Windows Explorer (o diálogo "Escolher Detalhes... / More..." do Explorer com centenas de propriedades do Windows Property System: Autor, Álbum, Dimensões, Duração, Taxa de bits, Data de captura, Câmera, Modelo, etc.), além das 16 colunas fixas atuais do Files.

## 2. Origem e Decisão de Arquitetura

- **Origem:** MASTER_SPEC §46 (pedido expresso do Alexandre, D-009). Task brief em `docs/agents/tasks/F010-all-explorer-columns.md`.
- **Arquitetura Aprovada (06/10/2026):** **Opção A — Abordagem Híbrida**:
  - As 16 colunas padrão existentes permanecem estáticas e de alto desempenho no XAML/ViewModel (zero risco de regressão no uso cotidiano).
  - Colunas estendidas do Windows Explorer são injetadas dinamicamente sob demanda.
  - Armazenamento esparso em memória (`ListedItem` com dicionário alocado sob demanda, custo zero de RAM quando inativo).
  - Extração estritamente assíncrona, virtualizada e em segundo plano (`scrollSettledTcs` + `CancellationToken`), garantindo fluidez mesmo em pastas com 10.000 itens.
  - Persistência híbrida por pasta (mantém formato existente no Registro e adiciona string JSON para colunas customizadas).

---

## 3. Escopo da Fase 1 (Concluída)
- Enumeração de 868 propriedades do Windows 11 (`369` colunas elegíveis).
- Prova de conceito e benchmark empírico: 1,3 ms por propriedade via `IShellItem2` e `PSFormatForDisplayAlloc`.
- Documentação arquitetural em `docs/architecture/explorer-columns.md`.

---

## 4. Escopo da Fase 2 (Implementação da Arquitetura Híbrida)

1. **Catálogo de Propriedades do Windows Property System**:
   - Serviço `IExplorerPropertyService` que expõe a lista de 369 propriedades com nome canônico (`System.*`), nome localizado (pt-BR e en-US), categoria e alinhamento padrão.
2. **Modelo de Dados e Armazenamento Esparso**:
   - `DynamicColumnDefinition`: representa uma coluna dinâmica ativa (CanonicalName, DisplayName, Width, Category).
   - `ListedItem`: método `GetDynamicProperty` e `SetDynamicProperty` com dicionário alocado sob demanda.
3. **Extração Virtualizada em Segundo Plano**:
   - Integração com `ShellViewModel.LoadExtendedItemPropertiesAsync`: extrai propriedades dinâmicas ativas apenas para itens no viewport durante repouso.
4. **Interface do Usuário (Layout Details)**:
   - Opção *"Mais..."* no menu de contexto do cabeçalho de colunas.
   - Diálogo `ChooseDetailsDialog` WinUI 3 com busca rápida, lista por categorias, checkboxes e reordenação.
   - Renderização no cabeçalho e linhas do `DetailsLayoutPage` para as colunas dinâmicas ativas.
5. **Persistência**:
   - Gravação das colunas ativas e suas larguras nas preferências da pasta via Registro.
6. **Qualidade e Performance**:
   - Build Release x64 limpo: `0 Warning(s), 0 Error(s)`.
   - Testes e capturas de tela comprovando a exibição de colunas extras (ex.: *Dimensões*, *Câmera*, *Autores*).
