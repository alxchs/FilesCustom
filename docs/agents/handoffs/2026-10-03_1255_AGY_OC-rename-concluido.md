# Handoff — Conclusão de OC-rename (Exploração do OneCommander)

Data: 03/10/2026 12:55
Autor: AGY
Fase: G1 — Item 3 do PLAYBOOK (OC-rename) concluído
Próximo passo: Item 4 do PLAYBOOK — F001 Rename UX (branch `feature/rename-ux`)

---

## 1. O que foi feito

1. **Exploração Completa do OneCommander (Comportamento Externo §3.1 e §40):**
   - Automatizada e fotografada em `C:\FilesUXLab` com scripts em `tools/perf/`.
   - 16+ capturas em alta resolução registradas em `docs/ux-reference/onecommander/evidence/rename/`.
   - Cobertos: F2, clique-pausa, navegação de cursor, Tab, edição de extensão, Enter, Esc (1x fecha sugestões, 2x cancela), conflito de nomes, caracteres inválidos, seleção múltipla e layouts Details vs Columns.
   - Todos os casos da matriz do §5 testados e medidos: `arquivo.txt`, `arquivo.md`, `arquivo` (sem ext), `arquivo.tar.gz`, `arquivo.final.txt`, `arquivo final 01.txt`, `arquivo.`, `.gitignore` e `Folder A`.

2. **Diagnóstico Preciso da Queixa Histórica do Alexandre:**
   - O OneCommander utiliza uma caixa de texto única dentro de um ComboBox com sugestões.
   - A extensão **não** é protegida: fica exposta a edições acidentais no mesmo campo.
   - Teclar `Tab` durante a renomeação confirma o nome atual e salta para renomear o próximo arquivo da pasta, em vez de focar a extensão.
   - Para alterar a extensão, o usuário precisa navegar manualmente com setas/mouse até o final e apagar caractere por caractere.
   - Ao alterar a extensão e pressionar Enter, a aplicação exibe um toast de notificação reativo e paternalista no canto inferior direito perguntando se o usuário quer recolocar a extensão anterior de volta (*"The file extension is different. Do you want to add the original extension back?"*).
   - Em dotfiles (`.gitignore`), o OneCommander falha: seleciona 0 caracteres e posiciona o cursor na posição 0 (`|.gitignore`).
   - Em extensões duplas (`arquivo.tar.gz`), reconhece apenas `.gz` e expõe `.tar` na seleção.

3. **Documento de Referência Entregue:**
   - `docs/ux-reference/onecommander/rename.md` criado rigorosamente na estrutura do MASTER_SPEC §18 e com distinção entre FACT / INFERRED / PROPOSED REQUIREMENT (§19).

4. **Direcionamento Aprovado para F001 (Opção A):**
   - Caixa única com blindagem nativa da extensão contra apagamento acidental (Backspace/Delete na fronteira não apagam a extensão; Ctrl+A seleciona só o nome).
   - Gesto deliberado para destravar a extensão (`Tab` / clique direto) que já a seleciona inteira para substituição imediata.
   - Tratamento correto para dotfiles (`.gitignore`) e extensões compostas (`.tar.gz`).
   - Sem notificações paternalistas após commit explícito.

---

## 2. Estado do Repositório

- Commit local do G0 já realizado na `main`.
- Este commit encerra o item 3 do PLAYBOOK (`OC-rename`) e prepara o branch `feature/rename-ux` para a implementação da F001.
- `STATUS.md` e `AGENT_CONTEXT.md` atualizados.
- Nenhum push realizado (`git push` aguarda autorização explícita).
