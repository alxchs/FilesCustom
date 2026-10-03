# Revisão do Claude — F001 Rename UX, commit wip `774f5eb64` (AGY, 03/10/2026)

Método: li o diff inteiro do commit e o brief `docs/agents/tasks/F001-rename-ux.md`. **Nada foi compilado nem executado** (a AGY parou por cota antes de compilar). Tudo abaixo é leitura de código: estado `INFERRED`, nenhum `CONFIRMED`. O Claude não alterou código (cota da AGY não vira trabalho do Claude); a AGY corrige ao retomar.

## Veredito

**Direção correta, não está pronto.** O helper e a arquitetura (caixa única blindada, estado em `BaseGroupableLayoutPage`, `ResetRenameState` nos três layouts) seguem o brief. Há 1 defeito provável de crash, 2 furos na proteção da extensão que o brief exige fechar, e 1 regressão do diálogo.

## Achados

- **MAJOR — `ActiveRenameParts` pode ser `null` (NRE + warning).** `FileNameParts` é `class`; a propriedade `protected FileNameParts ActiveRenameParts { get; set; }` não é inicializada e `ResetRenameState` faz `= default` (null). Dá CS8618/CS8625 (viola "0 Warning(s)") e, pior, `ValidateItemNameInputTextAsync` e `RenameTextBox_KeyDown` leem `ActiveRenameParts.HasExtension` sem checar null; `BeforeTextChanging` do TextBox pode disparar fora de um rename (binding do template). Correção: inicializar com `new FileNameParts(string.Empty, string.Empty, string.Empty)` e resetar para esse valor (ou tornar `readonly struct`).
- **MAJOR — tecla `End` desprotege a extensão (requisito 2 do brief).** Não há `case VirtualKey.End`; o caret vai ao fim, `RenameTextBox_SelectionChanged` vê `SelectionStart > nameLen` e **destrava** (`IsExtensionUnlocked` e `IsExtensionDeliberatelyModified = true`). Resultado: `End` + `Backspace` apaga a extensão e ainda suprime o diálogo. É exatamente o furo descrito no brief ("End+Backspace"). O mesmo vale para clicar à direita do texto (fora da extensão). Correção: no `SelectionChanged`, só destravar por clique de mouse dentro da extensão (PointerPressed) ou por `Tab`; para `End`/setas, **limitar** o caret a `nameLen` em vez de destravar.
- **MAJOR — regressão do diálogo de extensão.** `CommitRenameAsync` usa `IsExtensionDeliberatelyModified || IsExtensionUnlocked`, e `IsExtensionUnlocked = !HasExtension` no início. Logo, em arquivo **sem** extensão, dotfile, pasta, ou com extensões ocultas, `showExtensionDialog` vira `false` sempre; renomear `arquivo` → `arquivo.exe` perde o aviso que o Files original mostra. O brief (item 4) só suprime o diálogo quando a extensão foi destravada **pelo gesto deliberado**. Usar só `IsExtensionDeliberatelyModified`.
- **MINOR — `Tab` em arquivo sem extensão.** A condição `HasExtension || IsExtensionUnlocked` entra no bloco para arquivos sem extensão, marca `IsExtensionDeliberatelyModified = true` (suprime diálogo) e não faz nada útil. Sem extensão, `Tab` deve ser no-op (`e.Handled = true` apenas).
- **MINOR — `IsExtensionDeliberatelyModified` nunca volta a `false`.** Após `Tab` → `Shift+Tab`, o diálogo continua suprimido mesmo que a extensão tenha sido editada. Aceitável (intenção foi explícita); registrar a decisão em `DECISIONS.md` ou comparar a extensão final com a original.
- **MINOR — lista de extensões compostas passou do "pequena e fixa".** O brief fala em `.tar.gz/.bz2/.xz/.zst`. O helper acrescenta `.tar.lz/.lzma/.lzo/.z/.7z` e `.user.js` (esta última não é compressão e muda o resultado para qualquer userscript). Remover `.user.js`; os demais `tar.*` são inofensivos, mas confirmar que o Alexandre quer.
- **MINOR — `Tab` seleciona a extensão sem o ponto** (`extStart + 1`). O brief diz "toda selecionada, pronta para substituir"; escolha defensável (digitar `md` mantém o ponto), mas é decisão nova: registrar em `DECISIONS.md` ou seguir o brief literal.
- **MINOR — `Math.Max(260, parentGrid.ActualWidth)` na Details** é chute: o brief pede primeiro **achar a causa** do corte (`.gitigr`) e testar `.gitignore` nos dois defeitos. Validar no app antes de aceitar; se não resolver, não deixar o número mágico.
- **MINOR — testes fora do lugar pedido.** O brief pede teste unitário em `tests/Files.App.UnitTests`; a AGY fez `tests/test-rename-helper.ps1` (compila o `.cs` com `Add-Type`). Útil como smoke rápido, mas não substitui o teste do projeto. O "All 12 test cases" é texto fixo. Faltam casos: `arquivo.txt.`, `ARQUIVO.TAR.GZ`, `.tar.gz` sozinho, `a.b.c`, string vazia, e o caso `.env.local` está certo no código mas contradiz a regra "dotfile → nome inteiro" do brief se o Alexandre esperar `.env.local` inteiro: decidir e registrar.
- **NOTE — `Tab` → próximo arquivo foi removido** (o código antigo com `NextRenameIndex`). Coerente com o brief (DISCOVERY, `IMPLEMENT LATER`), mas `NextRenameIndex`/`TryStartRenameNextItem` ficam como código morto nos layouts; deixar para a feature futura, sem apagar (diff pequeno, §13).
- **NOTE — a guarda `BeforeTextChanging`** (`NewText.EndsWith(extensão)`) roda de forma síncrona antes do primeiro `await`, então `args.Cancel` vale também nos chamadores `_ =` (Grid/Details). OK.

## Ações (AGY, ao retomar)

1. Corrigir os 3 MAJOR primeiro; compilar release 0/0.
2. Mover/duplicar o teste do helper para `tests/Files.App.UnitTests` e acrescentar os casos faltantes.
3. Validar no app (`C:\FilesUXLab`, três layouts), incluindo `.gitignore`, `End`+`Backspace`, `Ctrl+A`, `Tab`/`Shift+Tab`, clique na extensão, `arquivo` → `arquivo.exe` (diálogo deve aparecer), pasta, `.lnk`, desfazer; capturas como evidência.
4. Handoff e `STATUS.md` só com o que foi `CONFIRMED` (comando + saída).
