# F005 — Preview e Details com acesso imediato — SPEC

Status: **APROVADA** (Claude, 04/10/2026). Primeira feature em SDD (`METODO.md` §6); nasce do brief `docs/agents/tasks/F005-preview-details-toggle.md` (agora só histórico) e do `MASTER_SPEC.md` §9. Fonte da verdade do **comportamento**; sem arquivo nem classe aqui.

## 1. Por quê
Mostrar o Preview de um arquivo exige hoje dois passos: abrir o painel de informações e depois clicar na aba Preview. Os comandos chamados "Toggle Preview Pane" e "Toggle Details Pane" não alternam: só trocam de aba, e só funcionam com o painel já aberto. O Alexandre quer o mesmo atalho de um passo que o Explorer do Windows oferece.

## 2. Histórias de usuário
- **US1 (P1)** Como usuário, quero um atalho que mostre o Preview do item selecionado e, ao repetir, o esconda, para olhar um arquivo sem abrir menus.
- **US2 (P1)** Como usuário, quero o mesmo para o painel Details.
- **US3 (P2)** Como usuário, quero achar os dois comandos na paleta de comandos, com o atalho visível.

## 3. Cenários de aceite

| ID | Dado | Quando | Então |
|---|---|---|---|
| AC-1 | painel fechado | aciono Preview | o painel abre já na aba Preview |
| AC-2 | painel fechado | aciono Details | o painel abre já na aba Details |
| AC-3 | painel aberto na aba Details | aciono Preview | a aba muda para Preview e o painel continua aberto |
| AC-4 | painel aberto na aba Preview | aciono Preview | o painel fecha |
| AC-5 | painel aberto na aba Preview | aciono Details | a aba muda para Details e o painel continua aberto |
| AC-6 | painel aberto na aba Details | aciono Details | o painel fecha |
| AC-7 | painel fechado | abro a paleta de comandos e busco "Preview" ou "Details" | os dois comandos aparecem e podem ser executados |
| AC-8 | painel aberto numa aba | fecho e reabro o app | o painel volta aberto na mesma aba; fechado volta fechado |
| AC-9 | painel aberto | fecho com o atalho | o foco volta para a lista de arquivos |
| AC-10 | qualquer estado | uso `Ctrl+Alt+I`, o botão da barra de ferramentas ou clico nas abas do painel | tudo se comporta como antes da feature |
| AC-11 | os atalhos definidos | olho a paleta de comandos e a dica do botão (tooltip) das abas | o atalho aparece escrito |

## 4. Requisitos
- **FR-001** "Preview" e "Details" DEVEM alternar conforme a tabela AC-1 a AC-6.
- **FR-002** Os dois comandos DEVEM estar sempre disponíveis, inclusive com o painel fechado (hoje só com o painel aberto).
- **FR-003** Os dois comandos DEVEM aparecer na paleta de comandos.
- **FR-004** Atalhos padrão: `Alt+P` para Preview e `Alt+Shift+P` para Details (os do Explorer do Windows).
- **FR-005** O atalho DEVE aparecer nos lugares onde o comando é mostrado (paleta e tooltip das abas).
- **FR-006** O estado aberto/fechado e a aba escolhida DEVEM continuar persistindo entre sessões.
- **FR-007** Ao fechar por atalho, o foco DEVE voltar à lista de arquivos; os controles DEVEM ter nome acessível.
- **FR-008** O comando de abrir/fechar o painel inteiro (`Ctrl+Alt+I`), o botão da barra e as abas NÃO DEVEM mudar de comportamento.
- **NFR-001** Funciona igual nos layouts Details, Grid e Column, com imagem, texto, pasta e seleção vazia.
- **NFR-002** Sem aumento perceptível no tempo de abertura do painel (não medido: comparar a olho com o app atual).

## 5. Casos de borda
- Seleção vazia ou pasta: o painel abre mesmo assim, mostrando o que o painel já mostra hoje nesses casos.
- Atalho acionado enquanto o painel está sendo aberto ou fechado pelo botão: segue o estado atual, sem estado intermediário.
- Usuário que já personalizou os atalhos do app: a personalização dele vale (não sobrescrever).
- Tecla `Alt` sozinha continua ativando a navegação por teclas de acesso do app.

## 6. Fora de escopo
Menu clássico (F004), redesenho do painel, novos tipos de preview, mudar o conteúdo dos painéis, a opção "New Tab Behavior".

## 7. Critérios de sucesso
Com o painel fechado, um único atalho mostra o Preview e o mesmo atalho o esconde; o Alexandre confirma no app aberto, nos três layouts.

## 8. Pontos em aberto
- Nenhum bloqueante. Os atalhos `Alt+P`/`Alt+Shift+P` são a sugestão do Claude (iguais ao Explorer); se o Alexandre preferir outros, muda-se o FR-004 e o histórico abaixo, e só.

## 9. Histórico
- 04/10/2026: criada a partir do brief aprovado em 03/10/2026; cenários numerados.
