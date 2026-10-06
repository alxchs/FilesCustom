# F010 — Tarefas da Fase 2 (Implementação da Arquitetura Híbrida)

## Status: EM ANDAMENTO (Arquitetura Híbrida Aprovada pelo Alexandre em 06/10/2026)

Data: 2026-10-06
Branch: `feature/all-explorer-columns`

---

### Fase 1: Concluída
- [x] T1 — Enumeração de 868 Propriedades do Windows (`369` colunas elegíveis `PDEF_COLUMN`).
- [x] T2 — Medição de latência por propriedade (~1,3 ms) e comprovação de extração via `IShellItem2`.
- [x] T3 — Desenho arquitetural híbrido documentado em `docs/architecture/explorer-columns.md`.
- [x] T4 — Aprovação do desenho pelo Alexandre e push prévio concluído.

---

### Fase 2: Implementação
- [ ] T2.1 — Criar `DynamicColumnDefinition` e adicionar suporte a propriedades esparsas em `ListedItem`.
- [ ] T2.2 — Criar `IExplorerPropertyService` / `ExplorerPropertyService` com catálogo das propriedades `PDEF_COLUMN`.
- [ ] T2.3 — Integrar extração virtualizada em segundo plano no `ShellViewModel.LoadExtendedItemPropertiesAsync`.
- [ ] T2.4 — Renderização dinâmica de cabeçalhos e células no `DetailsLayoutPage` preservando as 16 colunas padrão.
- [ ] T2.5 — Criar diálogo seletor de colunas ("Mais..." / `ChooseDetailsDialog`) com busca e agrupamento.
- [ ] T2.6 — Persistência híbrida por pasta via Registro.
- [ ] T2.7 — Validação empírica no app com imagens (`Dimensões`), compilação Release `0/0` e capturas de tela.
