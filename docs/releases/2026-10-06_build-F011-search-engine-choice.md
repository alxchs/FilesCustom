# Nota de Conclusão: F011 — Escolha de Motor de Busca pelo Usuário (F3 / Ctrl+F e Settings)

Data: 2026-10-06
Branch: `feature/search-engine-choice`
Responsável: Antigravity

---

## 1. Escopo e Objetivo

Implementar a **F011 — Escolha de Motor de Busca pelo Usuário** (`MASTER_SPEC.md` §10 e §46) sobre a infraestrutura plugável criada na F006:
- Permitir que o usuário escolha seu motor de busca em **Configurações > Pastas** (`SearchEngine`):
  1. **Files Nativo (Windows Search / Win32)** (padrão)
  2. **Agent Ransack (Conteúdo e regex)**
  3. **Everything (Índice instantâneo)**
- Provedores externos operam **sem abrir interfaces gráficas de terceiros**, retornando resultados limpos diretamente na visualização ativa do Files como `ListedItem`.
- Roteamento transparente em `ShellViewModel.SearchAsync` conectando com `ISearchProviderFactory`.
- Fallback automático e gracioso para a busca nativa se o motor escolhido não estiver instalado ou falhar.
- Localização completa das opções em inglês (`en-US`) e português (`pt-BR`).
- Compilação Release x64 100% limpa com **0 Warning(s), 0 Error(s)**.

---

## 2. Detalhes Técnicos da Implementação

| Componente | Detalhe |
|---|---|
| **Domínio e Enums** | `SearchEngineKind` (`Native = 0`, `AgentRansack = 1`, `Everything = 2`) em `src/Files.App/Data/Enums/SearchEngineKind.cs`. |
| **Configuração** | Adicionada propriedade `SearchEnginePreference` persistida nativamente em `IFoldersSettingsService` e `FoldersSettingsService`. |
| **ViewModel de Configurações** | `FoldersViewModel` expõe o dicionário de opções traduzidas `SearchEngineOptions` e a propriedade bidirecional `SelectedSearchEngineOption`. |
| **Interface do Usuário (XAML)** | Adicionado `SettingsCard` com `ComboBoxEx` na página de configurações `FoldersPage.xaml`. |
| **Provedor Agent Ransack** | `AgentRansackSearchProvider` invoca `AgentRansack.exe` em modo silencioso (`-d ... -f ... -o ... -ofc`), processa o CSV delimitado assincronamente com suporte a cancelamento `CancellationToken` e mapeia para `ListedItem`. |
| **Provedor Everything** | `EverythingSearchProvider` detecta a presença do serviço/processo Everything e realiza busca via CLI/IPC com fallback seguro para Native. |
| **Fábrica Dinâmica** | `SearchProviderFactory` injeta `IUserSettingsService` e resolve o provedor correto no runtime com fallback automático. |
| **Execução de Busca** | `ShellViewModel.SearchAsync` utiliza `ISearchProviderFactory.GetCurrentProvider()` para despachar consultas externas quando ativas. |

---

## 3. Status de Compilação e Qualidade

- **Compilação**: `msbuild -restore src/Files.App/Files.App.csproj -p:Configuration=Release -p:Platform=x64 -v:quiet -clp:ErrorsOnly`
- **Resultado**: `Build succeeded. 0 Warning(s), 0 Error(s)`
- **Deploy**: Pacote montado pela receita e registrado com sucesso via `Open-FilesDev.ps1`.
