# F003 — Nova aba × duplicar aba

Status: BRIEF APROVADO (Claude, 03/10/2026, a partir de análise do código). Executor: AGY. Branch: `feature/new-vs-duplicate-tab` (só se algum item abaixo exigir código).

## RESULTADO DA ANÁLISE (lido no código em 03/10/2026; nada executado, tudo NOT TESTED até a AGY confirmar no app)

O Files **já separa** as duas ações, ao contrário da queixa original (que é do OneCommander):

| Ação | Código | Atalho | Onde aparece |
|---|---|---|---|
| Nova aba | `Actions/Navigation/NewTabAction.cs` → `NavigationHelpers.AddNewTabAsync()` → `AddNewTabByPathAsync(typeof(ShellPanesPage), "Home", true)` | `Ctrl+T` | botão `+` (`TabBar.xaml` ~l.236, mesmo `Commands.NewTab`) e menu da aba |
| Duplicar aba | `Actions/Navigation/DuplicateSelectedTabAction.cs` → reabre `selectedTab.NavigationParameter` em `SelectedTabIndex + 1` | `Ctrl+Shift+K` | menu de contexto da aba (`TabBar.xaml` ~l.31) |

Ou seja: `Ctrl+T` e `+` abrem a **Home**, nunca a pasta atual. O requisito do §7 ("Ctrl+T deverá criar nova aba sem duplicar automaticamente a localização atual") **já é atendido**.

## TASK

1. **Confirmar no app** (`Open-FilesDev.ps1`, `C:\FilesUXLab`) os casos do §7: `Ctrl+T`, botão `+`, menu, duplicar, uma aba, várias abas, aba fixa, aba com seleção, fechar, restaurar (`ReopenClosedTab`), reiniciar, arrastar/reordenar. Registrar cada um como `OBSERVED`/`CONFIRMED` com captura, no `STATUS.md`. O smoke test do G0 cobre parte disso: não duplique o trabalho.
2. **Investigar e registrar, sem implementar**, estas lacunas candidatas (INFERRED):
   - A "nova aba" não tem política configurável (`§33 New Tab Behavior`: Home / local padrão / duplicar). Hoje é fixo em Home. `OpenSpecificPageOnStartupPath` existe só para a inicialização.
   - `Duplicate Tab` só está no menu de contexto da aba e no atalho; não aparece no menu da barra de ferramentas nem no `+` (descoberta). Isso é insumo da F004 (menu clássico).
   - Aba duplicada preserva o local mas não a seleção nem a posição de rolagem: confirmar.
3. Decisão do Claude já tomada: **NÃO criar a opção `New Tab Behavior` agora** (§33: só se houver razão legítima; o Alexandre reclamou justamente de nova aba que duplica). Registrar como `DISCOVERY` com estado `IMPLEMENT LATER`, e só reabrir se o Alexandre pedir.

## ACCEPTANCE

Tabela do §7 preenchida com evidência; `STATUS.md` marca F003 como "já atendido no Files, confirmado em <data>" ou lista o caso que falhou. Se algum caso falhar, abrir correção mínima em `feature/new-vs-duplicate-tab` com teste.

## DO NOT CHANGE

`NewTabAction`, `NavigationHelpers.AddNewTabByPathAsync` (compartilhados com jump list, "abrir em nova aba", sessão restaurada), a menos que um caso real falhe.

## FORA DE ESCOPO

Menu clássico (F004), configurações novas, comportamento de abas do OneCommander.

## ENTREGA

Handoff em `docs/agents/handoffs/`, commit local, sem push.
