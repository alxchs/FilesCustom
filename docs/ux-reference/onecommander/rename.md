# Renomeação — OneCommander UX Reference

Documento de referência de UX do OneCommander elaborado conforme MASTER_SPEC §18 e §19, com base em testes automatizados e observações diretas em `C:\FilesUXLab`.
Data da observação: 03/10/2026.
Versão observada do OneCommander: 3.x (WPF 64-bit).

---

## Objetivo

Documentar minuciosamente o comportamento externamente observável da experiência de renomeação no OneCommander, avaliando especialmente a queixa histórica do usuário:
> *"A experiência de renomeação fica ruim quando a extensão precisa ser alterada."* (MASTER_SPEC §4, item 1)

---

## Estado inicial

- O usuário está navegando em uma pasta com itens (ex.: `C:\FilesUXLab`).
- Um item está selecionado na lista (ex.: `arquivo.txt`).
- No painel lateral direito (Preview/Details), os metadados do arquivo são exibidos.
- Evidência inicial: `docs/ux-reference/onecommander/evidence/rename/01_oc_opened_lab.png`.

---

## Fluxo principal

1. O usuário seleciona o arquivo e pressiona **F2** (ou clica no nome selecionado após uma pausa — clique-pausa).
2. Um controle flutuante (overlay/popover) sobrepõe a linha do item.
3. O controle é composto por:
   - Botão de alternância de capitalização `[A|a]` à esquerda;
   - Campo de texto (TextBox) contendo o nome completo do arquivo (`arquivo.txt`);
   - Botão dropdown `v` com sugestões automáticas de nomenclatura;
   - Botão de confirmação `[✓]`;
   - Botão de cancelamento `[X]`.
4. **Seleção inicial:** O OneCommander seleciona automaticamente o nome base (`arquivo`), deixando o ponto e a extensão (`.txt`) sem seleção.
5. Se o usuário digitar um novo nome (ex.: `novo`), o texto selecionado é substituído, preservando `.txt`.
6. Ao pressionar **Enter** (ou clicar em `[✓]`), o novo nome é gravado no disco e o popover se fecha.

---

## Fluxos alternativos

### 1. Clique-pausa (Mouse)
- Clicar em um item já selecionado após ~1 segundo ativa o mesmo popover de renomeação do F2.
- Evidência: `docs/ux-reference/onecommander/evidence/rename/03_rename_click_pause.png`.

### 2. Navegação com Tab (Renomear em cadeia)
- **FACT:** Pressionar `Tab` durante a renomeação **NÃO** move o foco para a extensão.
- **FACT:** O `Tab` confirma a renomeação do arquivo atual com o nome existente (exibindo na barra inferior *"Same name. Nothing changed"*) e abre imediatamente a renomeação no **próximo arquivo da lista**.
- Evidência: `docs/ux-reference/onecommander/evidence/rename/04_rename_after_tab.png`.

### 3. Sugestões automáticas no Dropdown
- **FACT:** Ao abrir a renomeação, um dropdown abre abaixo do campo sugerindo formatos:
  - Capitalização PascalCase/TitleCase (ex.: `Arquivo.txt`);
  - Inclusão da data atual no final (ex.: `arquivo 2026-10-03.txt`);
  - Inclusão da data atual no início (ex.: `2026-10-03 arquivo.txt`).
- **FACT:** O primeiro pressionamento de `Esc` apenas fecha o dropdown de sugestões; um segundo `Esc` cancela a renomeação.

### 4. Alteração deliberada da extensão
- **FACT:** Para alterar a extensão, o usuário é obrigado a navegar manualmente com setas de teclado (`Right Arrow` ou `End`) ou posicionar o cursor com o mouse dentro da extensão, apagar os caracteres com Backspace/Delete e digitar a nova extensão (ex.: mudar `.txt` para `.log`).
- **FACT:** Ao pressionar `Enter` com uma extensão alterada, o OneCommander altera o arquivo no disco, mas **dispara imediatamente um toast de notificação intrusivo no canto inferior direito**:
  > *"The file extension is different. Do you want to add the original extension back? activate_test.log.txt"*
- Evidência: `docs/ux-reference/onecommander/evidence/rename/06_rename_after_enter_extension.png`.

---

## Atalhos

| Atalho | Ação observada no OneCommander |
|---|---|
| `F2` | Inicia renomeação do item focado. |
| `Enter` | Confirma e aplica a renomeação no sistema de arquivos. |
| `Esc` (1x) | Fecha a lista suspensa de sugestões automáticas (se aberta). |
| `Esc` (2x) | Cancela a renomeação e restaura o nome original. |
| `Tab` | Confirma o item atual e abre a renomeação do **próximo arquivo**. |
| `Shift + Tab` | Confirma o item atual e abre a renomeação do **arquivo anterior**. |
| `Right Arrow` | Desfaz a seleção do nome e move o cursor para a direita (em direção ao ponto/extensão). |
| `End` | Move o cursor para o final absoluto da extensão. |
| `Home` | Move o cursor para o início do nome. |

---

## Mouse

- **Clique simples em item não selecionado:** Seleciona o item (não ativa renomeação).
- **Clique em item já selecionado (pausa > 500ms):** Inicia renomeação inline.
- **Clique no botão `[A|a]`:** Alterna caixa do texto (lowercase, UPPERCASE, Title Case).
- **Clique no botão `[✓]`:** Confirma a renomeação.
- **Clique no botão `[X]`:** Cancela a renomeação.
- **Clique fora do popup:** Confirma a renomeação com o texto atualmente no campo (comportamento de perda de foco / blur commit).

---

## Estados visuais

1. **Estado em edição:** Popover escuro com borda destacada sobre a linha do arquivo. Caixa de texto com seleção em azul do nome base e texto da extensão em fundo escuro sem seleção.
2. **Estado com sugestões:** Flyout suspenso logo abaixo exibindo 3 opções geradas dinamicamente com ícone de sugestão.
3. **Estado de conflito de nome:** Ao tentar renomear para um nome que já existe na pasta, a barra de status inferior fica vermelha com aviso:
   `[⚠ File with this name already exists]`. O popup de renomeação não fecha e o arquivo não é sobrescrito.
   - Evidência: `docs/ux-reference/onecommander/evidence/rename/08_rename_name_conflict.png`.
4. **Estado de caracteres inválidos:** Digitar caracteres como `*`, `?`, `|`, `:`, `/`, `\`, `<`, `>` é bloqueado silenciosamente. Os caracteres simplesmente não entram no campo de texto.
   - Evidência: `docs/ux-reference/onecommander/evidence/rename/07_rename_invalid_characters.png`.

---

## Cancelamento

- Pressionar `Esc` (até o fechamento do popup) ou clicar no botão `[X]` reverte qualquer alteração feita no campo de texto e mantém o nome original inalterado no disco.

---

## Persistência

- Confirmar com `Enter`, `[✓]` ou clique fora grava imediatamente a alteração no sistema de arquivos local (`System.IO`).
- A ordenação da lista é recalculada após a confirmação caso a nova inicial altere a posição alfabética.

---

## Edge cases (Matriz de testes §5)

Os casos obrigatórios de `MASTER_SPEC §5` foram testados no OneCommander em `C:\FilesUXLab`. Resultados obtidos:

| Caso | Texto total | Seleção inicial | Parte não selecionada | Avaliação / Comportamento |
|---|---|---|---|---|
| `arquivo.txt` | `arquivo.txt` | `arquivo` | `.txt` | **Correto**: seleciona o nome base, preserva extensão. |
| `arquivo.md` | `arquivo.md` | `arquivo` | `.md` | **Correto**: seleciona o nome base, preserva extensão. |
| `arquivo` (sem ext) | `arquivo` | `arquivo` | *(nenhuma)* | **Correto**: seleciona o nome inteiro. |
| `arquivo.tar.gz` | `arquivo.tar.gz` | `arquivo.tar` | `.gz` | **Falha de conceito**: considera apenas `.gz` como extensão; `.tar` fica exposto na seleção. |
| `arquivo.final.txt` | `arquivo.final.txt` | `arquivo.final` | `.txt` | **Correto**: considera tudo até o último ponto como nome. |
| `arquivo final 01.txt` | `arquivo final 01.txt` | `arquivo final 01` | `.txt` | **Correto**: preserva espaços no nome base. |
| `arquivo.` | `arquivo.` | `arquivo.` | *(nenhuma)* | **Tolerante**: ponto final sem extensão é incluído na seleção. |
| `.gitignore` | `.gitignore` | *(vazio / 0 caracteres)* | `.gitignore` | **BUG / Falha grave**: cursor cai na posição 0 (`|.gitignore`) e nada é selecionado. |
| `Folder A` (pasta) | `Folder A` | `Folder A` | *(nenhuma)* | **Correto**: seleciona o nome inteiro da pasta. |

---

## Comportamentos observados

### 1. Separação visual vs física
- O OneCommander utiliza um **único TextBox**, controlando a seleção via `SelectionStart` e `SelectionLength`. A extensão **não** está em um controle separado nem é fisicamente protegida.
- O usuário pode a qualquer momento apagar o ponto ou alterar a extensão simplesmente usando o teclado dentro da mesma caixa de texto.

### 2. Reação à mudança de extensão
- Ao invés de facilitar a edição deliberada da extensão ou isolá-la, o OneCommander deixa o campo livre, mas aplica uma intervenção reativa paternalista após o commit: um balão de notificação no canto inferior direito perguntando se o usuário quer colocar a extensão antiga de volta.

### 3. Seleção Múltipla
- Ao selecionar múltiplos itens (`file_001.txt` e `file_002.txt`) e pressionar `F2`, o OneCommander cancela a seleção múltipla e entra em renomeação exclusivamente no item que tinha o foco ativo. Não abre diálogo de renomeação em lote.
- Evidência: `docs/ux-reference/onecommander/evidence/rename/13_rename_multiselection.png`.

### 4. Layouts
- O comportamento do popup de renomeação é idêntico nos modos Details e Columns (Miller columns).
- Evidência: `docs/ux-reference/onecommander/evidence/rename/15_rename_columns_layout.png`.

---

## Por que a experiência do OneCommander é ruim (Análise da Queixa do Alexandre)

O diagnóstico da queixa histórica do Alexandre ficou 100% evidente nas medições:

1. **A extensão não tem foco próprio:** O usuário que quer alterar a extensão tenta instintivamente usar `Tab` (como em qualquer formulário com múltiplos campos), mas no OneCommander o `Tab` confirma e salta para renomear o próximo arquivo da pasta.
2. **Navegação manual incômoda:** Para mudar uma extensão de `.txt` para `.csv`, o usuário tem que:
   - Pressionar F2;
   - Pressionar `Right Arrow` ou `End` (cuidado para não apagar o nome);
   - Pressionar Backspace 3 vezes apagando `t`, `x`, `t`;
   - Digitar `csv`;
   - Pressionar Enter.
3. **Paternalismo incômodo (Toast de notificação):** Ao pressionar Enter, a aplicação exibe uma notificação no rodapé sugerindo que o usuário cometeu um erro e perguntando se deseja voltar para `.csv.txt`.
4. **Colapso em dotfiles:** Em arquivos iniciados por ponto como `.gitignore` ou `.env`, o cálculo de extensão do OneCommander falha miseravelmente, selecionando 0 caracteres e posicionando o cursor na frente do ponto.

---

## Possíveis melhorias no Files (PROPOSED REQUIREMENT para F001)

Com base no teste do OneCommander e no brief de `F001`, as melhorias a adotar no Files Custom são:

1. **Opção A (Manter campo único no layout, com desbloqueio explícito da extensão):**
   - Ao teclar `F2`, apenas o nome base é selecionado.
   - A extensão fica **visualmente e operacionalmente travada** contra edições acidentais durante a digitação rápida do nome (teclar Backspace/Delete no limite do nome não come o ponto nem a extensão).
   - **Gesto deliberado para editar a extensão:**
     - Uma tecla específica (ex.: `Tab`, `Ctrl+E` ou seta direita além do limite) ou um clique direto sobre a extensão destrava a extensão para edição.
     - Quando destravada, a extensão inteira fica selecionada, permitindo substituí-la instantaneamente (ex.: teclar `Tab` -> `md` -> `Enter`).
2. **Tratamento inteligente de Dotfiles e Extensões Duplas:**
   - `.gitignore`, `.env`, `.bashrc`: selecionar o nome completo `.gitignore` (ou o corpo `gitignore`), nunca deixar seleção vazia com cursor no limbo.
   - `.tar.gz`, `.tar.bz2`: reconhecer extensões compostas comuns para não selecionar `.tar` por engano.
3. **Sem alertas paternalistas intrusivos:**
   - Se o usuário destravou deliberadamente a extensão e a alterou, respeitar a intenção sem disparar popups reativos no rodapé.

---

## Comportamentos que NÃO devem ser reproduzidos no Files

1. **NUNCA reproduzir a falha do `.gitignore`:** Selecionar 0 caracteres deixando o cursor no limbo é inaceitável.
2. **NUNCA reproduzir o toast *"The file extension is different. Do you want to add the original extension back?"*:** É irritante e desrespeita a intenção consciente do usuário técnico.
3. **NUNCA fazer o `Tab` pular de arquivo sem permitir editar a extensão primeiro:** Se o foco estiver no nome, um atalho intuitivo deve permitir ir para a extensão antes de fechar o arquivo.

---

## Evidências

Todas as capturas de tela foram registradas na pasta:
`docs/ux-reference/onecommander/evidence/rename/`

| Arquivo | Descrição |
|---|---|
| `01_initial_window.png` | Estado da janela do OneCommander aberta na pasta de teste. |
| `01_oc_opened_lab.png` | Vista completa da pasta `C:\FilesUXLab` com a lista de 15 arquivos. |
| `02_rename_f2_arquivo_txt.png` | F2 acionado em `arquivo.txt` exibindo popup flutuante, seleção e sugestões. |
| `03_rename_click_pause.png` | Clique-pausa acionado no arquivo, provando comportamento idêntico ao F2. |
| `04_rename_after_tab.png` | Pressionamento de Tab durante rename, provando que salta para o próximo arquivo. |
| `05_rename_ext_changed_to_log.png` | Edição manual da extensão de `.txt` para `.log`. |
| `06_rename_after_enter_extension.png` | Confirmação da nova extensão e surgimento do toast paternalista de advertência. |
| `07_rename_invalid_characters.png` | Bloqueio silencioso de caracteres ilegais (`?`, `*`, `\|`, `:`). |
| `08_rename_name_conflict.png` | Banner vermelho de conflito de nome na barra de status inferior. |
| `09_rename_multiselection.png` | Tentativa de F2 em seleção múltipla (reduz para o item ativo). |
| `10_rename_aa_click1.png` | Botão `[A|a]` de conversão de caixa. |
| `14_layout_columns.png` | Alternância para o layout Columns (Miller columns). |
| `15_rename_columns_layout.png` | F2 e popup de renomeação funcionando no layout Columns. |
| `edge_tar_gz.png` | Caso `.tar.gz`: seleciona `arquivo.tar` e deixa apenas `.gz` de fora. |
| `edge_dot_middle.png` | Caso `arquivo.final.txt`: seleciona `arquivo.final`. |
| `edge_gitignore.png` | Caso `.gitignore`: falha do OneCommander com seleção vazia e cursor na frente do ponto. |
| `edge_spaces.png` | Caso `arquivo final 01.txt`: seleciona com espaços mantendo `.txt`. |
| `edge_dot_end.png` | Caso `arquivo.`: seleciona com o ponto final. |
| `edge_noext.png` | Caso `arquivo` sem extensão: seleciona o nome completo. |
| `edge_folder.png` | Caso `Folder A`: seleciona o nome do diretório completo. |

---

## Dúvidas

1. **Atalho preferido para o Files Custom:** O `Tab` deve alternar entre Nome <-> Extensão antes de passar para o próximo arquivo, ou `Tab` deve pular de arquivo e uma tecla dedicada (ex.: `Ctrl+E` / `Right Arrow` no final) destravar a extensão?
   - Recomendação para F001: Se houver extensão, `Tab` alterna Nome -> Extensão -> Próximo Arquivo. Isso resolve 100% a queixa do Alexandre sem quebrar o fluxo com uma das mãos no teclado.
