# F010 — Tarefas da Fase 1

## Status: FASE 1 CONCLUÍDA — PENDING DECISION

Data: 2026-10-05
Branch: `feature/all-explorer-columns`

---

### T1 — Enumeração de Propriedades do Windows
- [x] Implementar script de enumeração `PSEnumeratePropertyDescriptions` em `tools/perf/PropertyExplorer/`.
- [x] Executar e extrair contagem total de propriedades registradas: **868 propriedades no Windows 11**.
- [x] Mapear categorias, nomes canônicos e rótulos de exibição: **369 propriedades de coluna (`PDEF_COLUMN`)** e **356 visualizáveis (`PDEF_VIEWABLE`)**.
- [x] Exportar CSV com todas as propriedades para `docs/architecture/windows_properties.csv`.
- [x] Comparar com a lista do diálogo do Explorer: idêntica ao conjunto `PDEF_COLUMN`.

### T2 — Medição de Leitura de Propriedades
- [x] Implementar leitor via `IShellItem2` e `PSFormatForDisplayAlloc` em `tools/perf/PropertyExplorer/`.
- [x] Testar em arquivo real de imagem (`sample.jpg`): extraiu Dimensões (800 x 600), Tamanho (10,1 KB), Data e Tipo perfeitamente formatados pelo Windows.
- [x] Medir tempo de extração: ~1,3 ms por propriedade, ~9,1 ms por item.
- [x] Projeção para 10 mil itens: **~91 segundos** se feito de forma síncrona.
- [x] Conclusão mandatória: carregamento deve ser estritamente assíncrono e virtualizado (apenas itens em tela).

### T3 — Mapeamento e Desenho de Colunas Dinâmicas
- [x] Mapear as 16 colunas fixas atuais do Files App contra o Property System.
- [x] Definir estrutura de modelo para colunas dinâmicas (`DynamicColumnDefinition`).
- [x] Desenhar o armazenamento esparso em `ListedItem` com custo de memória zero quando inativo.
- [x] Desenhar o seletor de colunas (diálogo modal com busca, categorias e ordenação).
- [x] Definir estratégia de persistência híbrida (Registro existente + JSON).

### T4 — Documentação Final da Fase 1
- [x] Gerar `docs/architecture/explorer-columns.md`.
- [x] Atualizar `STATUS.md` e `AGENT_CONTEXT.md`.
- [x] Formalizar handoff e relatório com decisão pendente para o Claude.
