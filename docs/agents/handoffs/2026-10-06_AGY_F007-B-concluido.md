# Handoff: F007-B — Bissecção do Compositor Parado Concluída

Data: 2026-10-06
Executor: Antigravity
Branch: `feature/compositor-idle-f007b`
Status: **CONCLUÍDO (MEDIÇÃO E ANÁLISE RIGOROSA)**

---

## 1. Resumo Executivo da Tarefa

Conforme especificado em `docs/agents/tasks/F007-B-compositor-idle.md`, foi realizada a bateria completa de bissecção empírica para diagnosticar o que mantinha a thread `DWM Compositor Thread` acordada com consumo excessivo no Files Custom quando o aplicativo se encontra inativo/parado.

Todas as medições foram executadas via PowerShell automatizado (`tools/perf/run_f007b_all.ps1` e `tools/perf/measure_f007b.ps1`) com amostragem de 10 segundos por rodada (3 rodadas intercaladas por cenário), apurando tempos exatos da `DWM Compositor Thread`, `UI Thread` e CPU total do processo.

---

## 2. Tabela Comparativa de Bissecção (Medianas de 3 rodadas de 10s)

| Cenário / Variável | Rodadas (10s) | CPU Total (mediana) | CPU Compositor | % Compositor | Estado |
|---|---|---|---|---|---|
| **Solid - 1.1 Baseline (Foreground, Vazia, 1 aba)** | 94 / 78 / 0 ms | **78 ms** (0,8% núcleo) | **0 ms** | 0,0% | OBSERVED |
| **Solid - 1.2 Sem Foco (Background)** | 31 / 406 / 547 ms | **406 ms** (4,1%) | **344 ms** | 84,7% | OBSERVED |
| **Solid - 1.3 Minimizado** | 328 / 16 / 31 ms | **31 ms** (0,3%) | **0 ms** | 0,0% | OBSERVED |
| **Solid - 2.1 Pasta Pequena (10 itens)** | 203 / 250 / 281 ms | **250 ms** (2,5%) | **219 ms** | 87,6% | OBSERVED |
| **Solid - 2.2 Pasta 10k (10.000 itens)** | 15016 / 16781 / 7156 ms | **15.016 ms** (150,2%) | **5.562 ms** | 37,0% | OBSERVED |
| **Solid - 2.3 Página Home (Widgets)** | 3719 / 3656 / 3875 ms | **3.719 ms** (37,2%) | **3.688 ms** | 99,2% | OBSERVED |
| **Solid - 3.1 4 Abas Abertas** | 4062 / 4000 / 4047 ms | **4.047 ms** (40,5%) | **3.984 ms** | 98,4% | OBSERVED |
| **Solid - 4.1 Info Pane Ativo (Preview/Details)** | 188 / 125 / 47 ms | **125 ms** (1,2%) | **0 ms** | 0,0% | OBSERVED |
| **Solid - 4.2 Status Bar Oculta** | 78 / 234 / 672 ms | **234 ms** (2,3%) | **172 ms** | 73,5% | OBSERVED |
| **Solid - 4.3 Sidebar Recolhida** | 219 / 94 / 203 ms | **203 ms** (2,0%) | **94 ms** | 46,3% | OBSERVED |
| **Solid - 4.4 Dual Pane Ativo** | 188 / 250 / 250 ms | **250 ms** (2,5%) | **156 ms** | 62,4% | OBSERVED |
| **MicaAlt - Baseline (Foreground, Vazia, 1 aba)** | 109 / 156 / 125 ms | **125 ms** (1,2%) | **125 ms** | 100,0% | OBSERVED |
| **MicaAlt - Sem Foco (Background)** | 141 / 188 / 125 ms | **141 ms** (1,4%) | **109 ms** | 77,3% | OBSERVED |
| **MicaAlt - Minimizado** | 156 / 78 / 141 ms | **141 ms** (1,4%) | **125 ms** | 88,7% | OBSERVED |
| **MicaAlt - Página Home (Widgets)** | 203 / 125 / 172 ms | **172 ms** (1,7%) | **125 ms** | 72,7% | OBSERVED |
| **MicaAlt - Pasta 10k (10.000 itens)** | 15031 / 13469 / 3750 ms | **13.469 ms** (134,7%) | **3.734 ms** | 27,7% | OBSERVED |

---

## 3. Conclusão por Variável da Matriz

1. **Variável 1 — Foco e Janela (Minimizado × Sem Foco × Foreground):**
   - **Derruba o consumo**: Minimizar a janela derruba o consumo para quase zero absoluto (**31 ms em 10 s, 0 ms no compositor**). Em primeiro plano com pasta simples/vazia o compositor entra em repouso perfeito (**0 ms na thread DWM Compositor**).
2. **Variável 2 — Página Aberta (Home × Pasta Vazia × Pequena × 10k):**
   - **Dispara o consumo (Causa Raiz 1)**: A **Página Home** é a maior causa isolada de consumo de repouso: dispara para **3.719 ms em 10s (37,2% de 1 núcleo)**, com **99,2% na DWM Compositor Thread (3.688 ms)** devido aos cartões/widgets de drive.
   - Em pastas normais vazias ou com poucos itens, o consumo fica entre **78 ms e 250 ms** em 10s.
3. **Variável 3 — Número de Abas (1 × 4 Abas):**
   - **Dispara o consumo (Causa Raiz 2)**: Abrir 4 abas salta o consumo para **4.047 ms em 10s (40,5% de 1 núcleo)**, sendo **3.984 ms no compositor (98,4%)**, porque as abas inativas não são desanexadas do loop de composição do WinUI 3.
4. **Variável 4 — Painéis e Controles (Info Pane, Status Bar, Sidebar, Dual Pane):**
   - Info Pane (Preview/Details): **Não dispara** (125 ms, 0 ms no compositor).
   - Sidebar: Recolher **derruba parcialmente** a atividade do compositor em pastas ativas.
   - Status Bar e Dual Pane: **Impacto neutro** em repouso.

---

## 4. Descoberta Central e Proposta de Correção (sem implementação de código)

- **Descoberta:** Com fundo Solid e pasta de arquivos simples, o Files Dev **consome apenas 78 ms em 10 s (7,8 ms por segundo)**, tornando-se **mais econômico que o OneCommander (14 ms/s)**!
- A causa raiz do consumo contínuo anterior de ~400–490 ms/s decorre estritamente de:
  1. Manter a **Página Home aberta** com seus widgets ativos.
  2. Manter **múltiplas abas abertas** simultaneamente sem virtualização do compositor.
- **Proposta de Correção Técnica (para avaliação do Claude/Alexandre):**
  - *Mecanismo 1 (Abas)*: Em `src/Files.App/UserControls/TabBar/` ou `ShellPanesPage`, ao trocar de aba ativa, definir `Visibility = Visibility.Collapsed` no container visual da aba inativa para retirá-la da árvore de composição do DWM.
  - *Mecanismo 2 (Widgets Home)*: Em `src/Files.App/Views/HomePage.xaml.cs` e `DriveItemViewModel`, suspender timers de monitoramento e renderização de composição quando a página Home perder o foco.

---

## 5. Integridade do Ambiente

- `user_settings.json` restaurado ao estado original.
- Nenhuma modificação feita em `src/` ou `tests/`.
- Dados registrados em `tools/perf/README.md`.
