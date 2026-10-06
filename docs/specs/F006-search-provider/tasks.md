# Tarefas: F006 — Infraestrutura de Busca Plugável (Search Provider)

Data: 2026-10-06
Branch: `feature/search-provider`

---

## Lista de Tarefas

- [x] **T1: Investigação e Benchmark de Motores de Busca**
  - [x] Executar benchmark comparativo entre Files Native Search, Agent Ransack CLI e Everything.
  - [x] Investigar flags CLI de Agent Ransack e modo silencioso (`AgentRansack.exe -d ... -f ... -o ... -ofc`).
  - [x] Investigar protocolo IPC e presença de ferramentas Everything na máquina.
  - [x] Documentar resultados em `docs/test-plans/search-benchmark.md`.
- [x] **T2: Documentação de Arquitetura e SDD**
  - [x] Desenhar a arquitetura em `docs/architecture/search-provider.md`.
  - [x] Criar especificação SDD em `docs/specs/F006-search-provider/` (`spec.md`, `plan.md`, `tasks.md`).
- [x] **T3: Contratos e Modelos de Domínio**
  - [x] Criar `src/Files.App/Data/Contracts/ISearchProvider.cs` com `SearchRequest`, `SearchCapabilities` e `ISearchProvider`.
  - [x] Criar `src/Files.App/Data/Contracts/ISearchProviderFactory.cs`.
- [x] **T4: Implementação do Provedor Nativo**
  - [x] Implementar `src/Files.App/Services/Search/NativeFilesSearchProvider.cs` integrando com `FolderSearch`.
  - [x] Implementar `src/Files.App/Services/Search/SearchProviderFactory.cs`.
- [x] **T5: Registro no IoC e Validação de Build**
  - [x] Registrar serviços no container em `src/Files.App/Helpers/Application/AppLifecycleHelper.cs`.
  - [x] Compilar projeto em Release (`mkfile r`) garantindo `0 Warning(s), 0 Error(s)`.
- [x] **T6: Formalização e Handoff**
  - [x] Atualizar `STATUS.md` e `AGENT_CONTEXT.md`.
  - [x] Criar handoff e nota de liberação.
  - [x] Commit local na branch `feature/search-provider`.
