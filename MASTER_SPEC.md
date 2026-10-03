# Files Custom — Especificação de Desenvolvimento
## Aplicativo derivado do Files Community com melhorias de UX inspiradas em uso observável do OneCommander

**Status:** Documento-base de desenvolvimento  
**Objetivo:** servir como `MASTER_SPEC.md` para Claude, Codex e agentes de implementação/teste no desenvolvimento de uma versão customizada do Files Community.

---

# 1. Visão do projeto

Criar uma versão personalizada do **Files Community** para Windows, preservando sua base de file manager moderna, rápida e integrada ao Windows, mas corrigindo pontos de experiência de usuário que hoje incomodam o usuário no OneCommander.

O produto não deve ser um clone do OneCommander.

A estratégia é:

```text
Files Community
    +
customizações de UX e produtividade
    +
melhorias próprias de busca
    +
integração com ferramentas especializadas quando fizer sentido
    =
Files Custom
```

O Files Community é um projeto open source e seu repositório público contém, entre outros itens, `AGENTS.md`, `CLAUDE.md`, projetos em `src`, testes em `tests` e arquivos de licença MIT e MPL-2.0. A estrutura atual também suporta builds para x86, x64 e ARM64. [Referências oficiais: GitHub Files Community e projeto Files.App]

> **Regra:** antes de assumir detalhes atuais do projeto, os agentes devem consultar o código e a documentação existentes no checkout local.

---

# 2. Objetivo de produto

O Files Custom deve buscar a seguinte combinação:

- aparência moderna;
- fluidez;
- baixo atrito nas operações frequentes;
- excelente navegação;
- abas;
- múltiplos painéis quando apropriado;
- preview rápido;
- detalhes facilmente acessíveis;
- menus e comandos facilmente descobríveis;
- renomeação previsível;
- colunas realmente controláveis;
- busca rápida e competente;
- integração natural com o Windows;
- manutenção simples;
- capacidade de acompanhar o upstream do Files.

O princípio central é:

> **Não adicionar recursos apenas porque existem em outro aplicativo. Melhorar aquilo que realmente aumenta produtividade, previsibilidade e prazer de uso.**

---

# 3. Referência de UX: OneCommander

O OneCommander será usado como **referência comportamental e de UX**, não como fonte de código.

A análise deve ser feita como um usuário faria:

- abrir a aplicação;
- clicar;
- usar teclado;
- navegar;
- alterar configurações pela interface;
- observar resultados;
- registrar screenshots;
- registrar vídeos quando necessários;
- comparar estados antes/depois.

## 3.1. O que não deve ser feito

Não utilizar:

- descompilação;
- engenharia reversa;
- análise de assembly;
- inspeção de memória para descobrir implementação;
- extração de IL/código;
- desmontagem;
- cópia de código;
- análise de DLLs com o objetivo de reconstruir a implementação;
- reprodução de componentes proprietários.

A referência deve ser:

> **o comportamento externamente observável.**

Os termos atuais do OneCommander o classificam como software proprietário e proíbem engenharia reversa, descompilação, desmontagem e criação de obras derivadas baseadas no software.

---

# 4. Reclamações que originaram o projeto

As melhorias prioritárias surgem destes problemas observados durante o uso do OneCommander:

1. A experiência de renomeação fica ruim quando a extensão precisa ser alterada.
2. O redimensionamento das colunas fica amarrado/ancorado de forma incômoda.
3. Ao adicionar uma aba, o comportamento frequentemente parece simplesmente duplicar a aba atual.
4. Falta uma barra de menus tradicional no topo, com comandos como File/Edit/View/Help.
5. Mostrar/ocultar detalhes e o painel de preview exige uma sequência de navegação considerada longa demais.
6. A busca do OneCommander é fraca quando comparada a ferramentas especializadas como Everything e Agent Ransack.
7. Apesar dessas limitações, a combinação de aparência, leveza, organização, abas e produtividade do OneCommander continua sendo uma referência importante.

O objetivo do Files Custom é resolver esses pontos mantendo suas qualidades e evitando introduzir complexidade desnecessária.

---

# 5. Requisitos funcionais prioritários

## F001 — Renomeação com tratamento correto da extensão

### Problema

Renomear um arquivo deve permitir alterar o nome sem transformar acidentalmente a extensão em parte da seleção/edição.

### Comportamento desejado

O modo de renomeação deve distinguir claramente:

```text
NOME
+
EXTENSÃO
```

Preferencialmente:

- F2 entra em modo de renomeação;
- o nome principal é selecionado;
- a extensão permanece protegida ou claramente separada;
- alterar o nome não altera a extensão;
- alterar a extensão deve ser uma ação deliberada;
- Enter confirma;
- Esc cancela.

### Casos obrigatórios

Testar:

```text
arquivo.txt
arquivo.md
arquivo
arquivo.tar.gz
arquivo.final.txt
arquivo final 01.txt
arquivo.
.gitignore
```

Testar também:

- arquivo sem extensão;
- múltiplas extensões;
- nomes começando com ponto;
- nomes terminando com ponto;
- extensão vazia;
- alteração somente do nome;
- alteração somente da extensão;
- alteração de nome + extensão;
- conflito de nome;
- nome inválido;
- cancelamento;
- seleção parcial;
- seleção total.

### Critério de aceitação

A experiência deve tornar impossível ou, no mínimo, altamente improvável alterar a extensão por acidente durante uma simples renomeação.

A solução deve utilizar as abstrações existentes do Files sempre que possível e não reescrever o sistema de rename inteiro sem necessidade.

---

# 6. F002 — Colunas com redimensionamento independente

### Problema

O comportamento atual de colunas pode fazer o usuário sentir que as colunas estão amarradas ou que alterar uma afeta outra de forma pouco previsível.

### Objetivo

Dar ao usuário controle intuitivo da largura das colunas.

### Requisitos

Investigar e, quando tecnicamente apropriado, permitir:

- redimensionamento independente;
- largura mínima;
- largura máxima;
- auto-fit;
- double-click para ajustar ao conteúdo, se fizer sentido;
- persistência;
- comportamento previsível ao redimensionar a janela;
- comportamento consistente entre pastas;
- comportamento consistente entre sessões.

### Testes

Usar:

- nomes curtos;
- nomes muito longos;
- milhares de arquivos;
- poucas colunas;
- muitas colunas;
- janela pequena;
- janela maximizada;
- diferentes escalas de DPI.

### Critério de aceitação

O usuário deve conseguir ajustar uma coluna sem receber efeitos colaterais inesperados nas outras.

---

# 7. F003 — Nova aba versus duplicar aba

### Problema

A criação de uma aba deve ser semanticamente distinta da duplicação da aba atual.

### Modelo desejado

```text
New Tab
    ≠
Duplicate Current Tab
```

### New Tab

Deve criar uma nova aba seguindo uma política definida, por exemplo:

- Home;
- localização padrão configurada;
- ou outra localização explicitamente definida pelo usuário.

### Duplicate Tab

Deve:

- copiar a localização da aba atual;
- preservar o contexto desejado;
- permanecer como ação separada.

### Testar

- Ctrl+T;
- botão +;
- menu;
- comando de duplicação;
- uma aba;
- várias abas;
- aba fixa;
- aba com seleção;
- fechar;
- restaurar;
- reiniciar;
- arrastar/reordenar.

### Critério de aceitação

O usuário deve saber, sem ambiguidade, quando está:

```text
criando uma nova aba
```

e quando está:

```text
duplicando a aba atual.
```

---

# 8. F004 — Barra de menus tradicional opcional

### Problema

Falta de uma barra de menus superior com comandos facilmente descobertos.

### Objetivo

Criar uma opção de menu tradicional, compatível com a linguagem visual do Files, sem abandonar a interface moderna.

### Estrutura inicial sugerida

```text
File
Edit
View
Go
Tools
Help
```

A lista final deve ser determinada após análise do conjunto real de comandos do Files.

### Requisitos

Cada menu deve:

- possuir hierarquia clara;
- mostrar atalhos quando aplicável;
- refletir estados Enabled/Disabled;
- evitar comandos duplicados;
- reutilizar os comandos existentes;
- não conter funções sem necessidade;
- respeitar acessibilidade;
- funcionar com teclado.

### Regra

Não copiar visualmente o OneCommander.

Usar o conceito de descoberta e organização de comandos, adaptando-o ao design do Files.

---

# 9. F005 — Preview e Details com acesso imediato

### Problema

Mostrar/ocultar Preview e Details deve exigir poucas interações.

### Objetivo

Disponibilizar comandos claros e rápidos.

### Requisitos

Cada função deve poder ser acionada por pelo menos um destes meios:

- botão;
- menu;
- shortcut;
- Command Palette;
- configuração.

Idealmente:

```text
Toggle Preview Pane
Toggle Details Pane
Toggle Info Pane
```

Os nomes finais devem respeitar o vocabulário utilizado pelo Files.

### Critério de aceitação

Uma operação frequente de mostrar/ocultar painel não deve exigir uma "volta gigante" pela interface.

---

# 10. F006 — Busca de alto desempenho

### Problema

Busca é um dos pontos em que o OneCommander é percebido como inferior a ferramentas especializadas.

### Estratégia

Não assumir que o melhor caminho seja simplesmente reescrever a busca nativa do Files.

Primeiro investigar:

```text
Files Search
    vs
Everything
    vs
Agent Ransack
```

### Objetivos

Avaliar:

- latência;
- indexação;
- nome;
- extensão;
- caminho;
- wildcard;
- regex;
- conteúdo;
- filtros;
- tamanho;
- datas;
- atributos;
- subpastas;
- atualização;
- grandes volumes.

### Possível arquitetura

```text
Search Provider
    ├── Native Files Provider
    └── Everything Provider (opcional)
```

### Regra

Everything não deve ser dependência obrigatória sem análise.

Se não estiver instalado:

- a busca nativa deve continuar funcionando;
- a interface não deve quebrar;
- o usuário deve poder saber qual mecanismo está sendo usado, se isso for relevante.

### Critério de aceitação

A busca deve ser uma ferramenta de produtividade real, e não apenas uma pesquisa visual integrada ao explorador.

---

# 11. Descobertas adicionais

Durante a exploração do OneCommander, agentes podem encontrar outros recursos interessantes.

Exemplos:

- navegação;
- breadcrumbs;
- favoritos;
- histórico;
- drag-and-drop;
- seleção;
- agrupamento;
- ordenação;
- filtros;
- copy/move;
- undo;
- tratamento de conflitos;
- operações em lote;
- comportamento de erros.

Esses itens devem ser registrados, mas **não implementados automaticamente**.

Devem entrar no backlog como:

```text
DISCOVERY
```

e posteriormente receber decisão:

```text
IMPLEMENT
DO NOT IMPLEMENT
IMPLEMENT LATER
NEEDS MORE INVESTIGATION
```

---

# 12. Regras de arquitetura

Antes de modificar código:

1. entender a arquitetura atual;
2. identificar View;
3. identificar ViewModel;
4. identificar Commands;
5. identificar Services;
6. identificar abstrações;
7. localizar testes existentes;
8. localizar APIs Windows utilizadas;
9. encontrar o menor ponto seguro de alteração.

Preferir:

- reutilização;
- MVVM;
- abstrações existentes;
- baixo acoplamento;
- mudanças pequenas;
- testes.

Evitar:

- hacks;
- timers arbitrários;
- sleeps;
- polling desnecessário;
- lógica pesada na UI thread;
- code-behind sem necessidade;
- duplicação;
- dependências externas sem justificativa.

---

# 13. Regra de preservação do upstream

O projeto deve ser tratado como um fork sustentável.

Objetivo:

```text
upstream Files
      ↓
fork
      ↓
Files Custom
```

Evitar alterações que dificultem futuras atualizações do Files.

Quando possível:

- manter features customizadas isoladas;
- utilizar arquivos próprios;
- criar abstrações próprias;
- manter commits pequenos;
- evitar editar o mesmo trecho central sem necessidade;
- documentar alterações customizadas.

---

# 14. Git e branches

Criar uma branch por feature.

Exemplos:

```text
feature/rename-ux
feature/independent-column-resize
feature/new-vs-duplicate-tab
feature/classic-menu
feature/preview-details-shortcuts
feature/search-provider
```

Evitar trabalhar várias features não relacionadas no mesmo commit.

### Commits

Preferir:

```text
feat(rename): improve filename and extension editing
feat(tabs): separate new tab from duplicate tab
feat(columns): allow independent column resizing
feat(ui): add optional classic menu
feat(search): add search provider abstraction
```

---

# 15. Testes obrigatórios

Toda alteração precisa de três níveis de validação.

## 15.1. Teste automatizado

Criar ou atualizar testes quando a arquitetura permitir.

## 15.2. Teste funcional

Executar a aplicação e reproduzir o fluxo real.

## 15.3. Regressão

Verificar se o comportamento anterior importante continua funcionando.

---

# 16. Baseline

Antes da primeira alteração:

```text
git status
git branch
git diff
```

Depois:

1. compilar versão original;
2. executar aplicação;
3. executar smoke test;
4. registrar problemas preexistentes.

Não atribuir ao trabalho customizado problemas que já existiam.

---

# 17. Test Lab

Criar uma pasta de laboratório contendo:

```text
C:\FilesUXLab\
```

com arquivos controlados:

```text
arquivo.txt
arquivo.md
arquivo
arquivo.tar.gz
arquivo.final.txt
arquivo final 01.txt
arquivo.
.gitignore
file_001.txt
file_002.txt
```

e pastas:

```text
Folder A
Folder B
Folder C
```

Os testes destrutivos devem utilizar exclusivamente arquivos descartáveis.

---

# 18. Documentação de UX do OneCommander

Cada feature explorada deve gerar:

```text
docs/
└── ux-reference/
    └── onecommander/
        ├── rename.md
        ├── columns.md
        ├── tabs.md
        ├── menus.md
        ├── preview-details.md
        ├── search.md
        └── discoveries.md
```

Cada documento:

```markdown
# Feature

## Objetivo

## Estado inicial

## Fluxo principal

## Fluxos alternativos

## Atalhos

## Mouse

## Estados visuais

## Cancelamento

## Persistência

## Edge cases

## Comportamentos observados

## Possíveis melhorias no Files

## Comportamentos que não devem ser reproduzidos

## Evidências

## Dúvidas
```

---

# 19. Separação entre fato, interpretação e requisito

Sempre diferenciar:

## FACT

Foi observado.

## INFERRED

Foi interpretado, mas não confirmado.

## PROPOSED REQUIREMENT

É o comportamento que desejamos no Files.

Exemplo:

```text
FACT:
Ctrl+T abriu uma aba em X.

INFERRED:
A aplicação considera essa operação como nova aba
independente da atual.

PROPOSED REQUIREMENT:
Ctrl+T deverá criar nova aba sem duplicar automaticamente
a localização atual.
```

---

# 20. Workflow de agentes

A equipe de IA deve trabalhar com papéis distintos.

## Claude — Chief / Architect

Responsável por:

- objetivo;
- escopo;
- arquitetura;
- prioridades;
- critérios de aceite;
- decisões difíceis;
- revisão dos resultados;
- aprovação de marcos.

Claude **não precisa acompanhar cada erro de compilação**.

---

## Antigravity / agentes de execução

Responsáveis por:

- explorar;
- implementar;
- testar;
- corrigir;
- compilar;
- repetir;
- documentar;
- gerar release.

Os agentes devem tentar resolver autonomamente problemas técnicos antes de escalar.

---

# 21. Política de escalonamento

O agente deve tentar resolver sozinho:

- erro de compilação;
- erro de teste;
- warning comum;
- bug localizado;
- ajuste de UI;
- problema de binding;
- erro simples de build.

Escalar para Claude somente quando houver:

- dúvida arquitetural;
- mudança de escopo;
- conflito entre requisitos;
- dependência incompatível;
- risco grande de regressão;
- problema persistente após tentativas razoáveis;
- decisão que afete várias funcionalidades.

Isso reduz consumo desnecessário da cota do Claude.

---

# 22. Pipeline recomendado

```text
Claude
  ↓
Define TASK
  ↓
Define ACCEPTANCE
  ↓
Agente explora/análise
  ↓
Agente implementa
  ↓
Agente testa
  ↓
Agente corrige
  ↓
Agente compila
  ↓
Agente gera relatório
  ↓
Claude revisa
  ↓
APPROVE ou CHANGES REQUIRED
```

Claude deve entrar principalmente nos **gates de decisão**, e não em cada microetapa.

---

# 23. Divisão dos três agentes de execução

Os três agentes podem funcionar como um pool, em vez de ficarem permanentemente presos a um único projeto.

### Agent 1 — Builder

- implementação;
- debugging;
- testes unitários;
- build.

### Agent 2 — Reviewer

- revisão de código;
- edge cases;
- regressões;
- UX;
- arquitetura.

### Agent 3 — QA / Release

- build final;
- testes de integração;
- smoke test;
- documentação;
- release.

Os papéis podem ser alternados conforme a fase.

---

# 24. Projeto com outros trabalhos simultâneos

O usuário normalmente trabalha com dois projetos ao mesmo tempo.

Portanto, o modelo recomendado é:

```text
máximo de 2 projetos ACTIVE
outros projetos = WAITING
```

Os agentes devem trabalhar em tarefas fechadas e transferíveis.

Para este projeto, isso significa que o Files Custom não deve depender da presença contínua do Claude em cada minuto de execução.

---

# 25. Contexto persistente para agentes

Criar no repositório:

```text
MASTER_SPEC.md
AGENT_CONTEXT.md
STATUS.md
DECISIONS.md
CHANGELOG.md
```

### AGENT_CONTEXT.md

Deve ser curto e conter somente o estado atual:

```text
PROJECT
OBJECTIVE
CURRENT PHASE
CURRENT TASK
ACCEPTANCE
DO NOT CHANGE
CURRENT BRANCH
LAST DECISION
NEXT ACTION
BLOCKER
```

Isso evita desperdiçar contexto reexplicando o projeto a cada sessão.

---

# 26. Handoff entre agentes

Todo agente deve deixar:

```markdown
# Agent Handoff

## Completed

## Files created

## Files modified

## Findings

## Problems

## Tests performed

## Tests not performed

## Next recommended action

## Warnings
```

---

# 27. Regra contra invenção

Agentes nunca devem declarar um comportamento como testado quando não foi testado.

Estados obrigatórios:

```text
NOT TESTED
OBSERVED
INFERRED
CONFIRMED
```

Exemplo:

```text
OBSERVED — comportamento visual confirmado.
INFERRED — causa ainda não confirmada.
NOT TESTED — cenário de múltipla seleção.
```

---

# 28. Primeiro marco do projeto

Não começar implementando todas as melhorias.

A primeira feature deverá ser:

## F001 — Rename UX

Motivo:

- escopo relativamente pequeno;
- fácil de reproduzir;
- fácil de testar;
- permite validar todo o processo de exploração → especificação → implementação → QA.

Somente depois de validar esse pipeline devem ser iniciadas as demais features.

---

# 29. Ordem inicial de execução

```text
1. Baseline
2. Exploração OneCommander — Rename
3. Análise Files — Rename
4. Implementação Rename
5. Testes Rename
6. Review Rename

7. Tabs
8. Preview / Details
9. Columns
10. Menus
11. Search
12. Descobertas adicionais
```

Search fica mais tarde por possuir maior potencial de impacto arquitetural.

---

# 30. Critérios gerais de aceitação

Uma feature só pode ser marcada como concluída quando:

- build passa;
- aplicação inicia;
- fluxo principal passa;
- casos relevantes passam;
- cancelamento funciona;
- edge cases foram avaliados;
- regressões relevantes foram avaliadas;
- acessibilidade foi considerada;
- performance foi considerada;
- documentação foi atualizada;
- Git está limpo ou mudanças estão claramente identificadas;
- não há workaround desnecessário.

---

# 31. Performance

Qualquer alteração deve considerar:

- diretórios grandes;
- milhares de arquivos;
- UI thread;
- troca de abas;
- resize de colunas;
- preview;
- seleção múltipla;
- busca;
- operações de rename em lote;
- uso de memória.

Evitar:

- polling;
- sleeps;
- reconstruções desnecessárias;
- operações pesadas síncronas;
- consultas repetidas à Shell sem necessidade.

---

# 32. Acessibilidade

Para qualquer mudança de UI verificar:

- navegação por teclado;
- foco;
- ordem de tabulação;
- nomes acessíveis;
- estados Enabled/Disabled;
- contraste;
- DPI scaling;
- leitores de tela quando aplicável.

---

# 33. Decisões de configuração

Criar configuração somente quando existir uma razão legítima para suportar preferências diferentes.

Exemplo:

```text
New Tab Behavior
    ○ Home
    ○ Default Location
    ○ Duplicate Current Location
```

Não criar uma opção para toda pequena diferença de comportamento.

---

# 34. Release

A versão customizada deve ser identificável como derivada/customizada.

Exemplo conceitual:

```text
Files Custom
version:
  upstream-version + custom revision
```

A estratégia exata de versionamento deve ser definida depois de analisar como o Files atualmente versiona, empacota e publica builds.

Antes de distribuir internamente:

- revisar licenças;
- revisar dependências;
- revisar avisos de terceiros;
- verificar requisitos do ambiente corporativo;
- documentar a origem do código.

---

# 35. Licenciamento

O repositório do Files possui arquivos de licença MIT e MPL-2.0.

Isso significa que o fork deve respeitar as licenças aplicáveis ao código e às dependências utilizadas.

Antes de uma distribuição corporativa ou pública, realizar uma revisão de:

- licença do Files;
- licença de cada componente utilizado;
- dependências NuGet;
- componentes do Windows App SDK;
- bibliotecas adicionais;
- avisos de terceiros.

A distribuição não deve ser tratada como "simplesmente MIT" sem verificar quais arquivos/componentes estão efetivamente envolvidos.

---

# 36. Estrutura de diretórios sugerida

```text
FilesCustom/
│
├── MASTER_SPEC.md
├── AGENT_CONTEXT.md
├── STATUS.md
├── DECISIONS.md
├── CHANGELOG.md
│
├── docs/
│   ├── ux-reference/
│   │   └── onecommander/
│   ├── architecture/
│   ├── test-plans/
│   └── decisions/
│
├── src/
├── tests/
└── releases/
```

A estrutura real do projeto deve respeitar o upstream e não ser alterada apenas para coincidir com este exemplo.

---

# 37. Registro de decisões

Criar:

```text
docs/decisions/
```

Cada decisão importante deve responder:

```text
Context
Problem
Options
Decision
Reason
Trade-offs
Consequences
```

Exemplo:

```text
Decision:
Adicionar abstração SearchProvider antes de integrar Everything.

Reason:
Permitir que a busca nativa permaneça funcional e evitar acoplamento
direto ao mecanismo externo.
```

---

# 38. Relatório final de cada feature

```markdown
# Feature: <nome>

## OneCommander observed behavior

## Files original behavior

## Desired Files Custom behavior

## Architectural analysis

## Implementation

## Files changed

## Tests

## Results

## Performance impact

## Accessibility impact

## Risks

## Known limitations

## Final decision

## Git branch

## Commit
```

---

# 39. Prompt operacional para agentes

Use este bloco como instrução inicial para qualquer agente que trabalhar no projeto:

> Você está trabalhando no Files Custom, uma versão derivada do Files Community.
>
> Leia `MASTER_SPEC.md`, `AGENT_CONTEXT.md` e os documentos relevantes antes de agir.
>
> Não modifique código até entender a tarefa, o estado atual do repositório e os critérios de aceitação.
>
> Quando a tarefa envolver uma referência do OneCommander, observe somente seu comportamento externo pela interface. Não descompile, não faça engenharia reversa e não procure implementar algo copiando sua implementação interna.
>
> Antes de codificar:
> 1. localize a implementação atual;
> 2. localize abstrações existentes;
> 3. localize testes;
> 4. identifique riscos;
> 5. escreva ou atualize a especificação necessária.
>
> Implemente somente o escopo solicitado.
>
> Depois:
> 1. compile;
> 2. execute testes;
> 3. corrija falhas;
> 4. repita;
> 5. execute os testes manuais necessários;
> 6. atualize documentação;
> 7. gere handoff.
>
> Nunca invente resultados.
>
> Se algo não foi testado, declare `NOT TESTED`.
>
> Se surgir uma melhoria fora do escopo, documente-a como `DISCOVERY` e continue sem implementá-la.
>
> Não peça ajuda para problemas técnicos que possam ser resolvidos autonomamente. Escale somente questões arquiteturais, ambiguidades relevantes ou bloqueios persistentes.

---

# 40. Prompt de exploração do OneCommander

Quando a tarefa for descobrir comportamento:

> Atue como um especialista em UX de aplicações desktop.
>
> Abra o OneCommander e comporte-se como um usuário humano.
>
> O objetivo é documentar comportamento observável, não descobrir implementação interna.
>
> Para a feature em análise:
> - registre estado inicial;
> - execute fluxo principal;
> - teste atalhos;
> - teste mouse;
> - teste menus;
> - teste cancelamento;
> - teste persistência;
> - teste casos extremos;
> - registre screenshots relevantes;
> - diferencie FACT, INFERRED e PROPOSED REQUIREMENT.
>
> Não implemente nada.
>
> Produza a documentação antes de qualquer alteração no Files.

---

# 41. Prompt de análise arquitetural

> Analise somente o Files Custom.
>
> Para a feature especificada:
> - encontre View;
> - ViewModel;
> - Commands;
> - Services;
> - Models/abstrações;
> - testes existentes;
> - dependências;
> - APIs Windows envolvidas.
>
> Determine o menor ponto de alteração possível.
>
> Não altere código.
>
> Entregue:
> - arquitetura atual;
> - arquivos relevantes;
> - proposta;
> - riscos;
> - testes necessários;
> - possíveis regressões.

---

# 42. Prompt de implementação

> Implemente somente a feature especificada em `MASTER_SPEC.md`.
>
> Não amplie escopo.
>
> Preserve a arquitetura existente.
>
> Reutilize abstrações existentes.
>
> Crie ou atualize testes.
>
> Compile.
>
> Execute os testes.
>
> Corrija problemas encontrados.
>
> Não marque a tarefa como concluída sem evidência.
>
> Ao finalizar, atualize `STATUS.md` e produza `Agent Handoff`.

---

# 43. Prompt de revisão

> Revise a alteração implementada sem assumir que o agente anterior está correto.
>
> Examine:
> - diff;
> - arquitetura;
> - testes;
> - edge cases;
> - regressões;
> - performance;
> - acessibilidade;
> - manutenção futura.
>
> Compare a implementação com o requisito.
>
> Não faça revisão superficial.
>
> Classifique cada problema como:
> - BLOCKER
> - MAJOR
> - MINOR
> - NOTE
>
> Se estiver tudo correto, apresente evidências de validação.

---

# 44. Princípio final do projeto

O produto não deve buscar ser "mais cheio de recursos".

Deve ser:

> **um file manager moderno e agradável que faz as operações do dia a dia de maneira mais previsível, rápida e direta.**

O OneCommander serve como referência de boas ideias de UX.

O Files fornece a base aberta, a integração e a arquitetura sobre a qual essas melhorias podem ser construídas.

O resultado final deve ser um aplicativo próprio, sustentável e tecnicamente bem estruturado.

---

# 45. Referências

- Files Community — repositório oficial:  
  https://github.com/files-community/Files

- Files Community — documentação oficial:  
  https://files.community/docs/

- OneCommander — termos e licença:  
  https://www.onecommander.com/terms

---

# 46. Requisitos adicionais: configurações e busca (Alexandre, 03/10/2026)

Acrescentado por pedido do Alexandre, registrado em `DECISIONS.md` (D-009). O §33 diz "criar configuração só com razão legítima": estas quatro **têm** razão legítima porque foram pedidas expressamente. Cada uma vira feature com brief em `docs/agents/tasks/`. Itens de configuração entram na tela de Settings existente, com strings localizáveis, e **o padrão não muda o comportamento atual do Files** (quem não mexe vê o mesmo app).

## F008 — Modo compacto (menor entrelinhamento)

Objetivo: reduzir a altura das linhas e o espaçamento vertical para caber mais itens na tela.

- Opção de configuração de densidade que valha para a **lista de arquivos** (Details, List, Columns, Grid onde fizer sentido) e para as **áreas fixas** (barra lateral, abas, barra de ferramentas, barra de status).
- O Files já tem tamanhos por layout (`DetailsViewSizeKind.Compact` = 28 px de linha no Details, o menor hoje). O requisito é ir **além** do Compact atual (linha mais baixa, espaçamento interno menor) e aplicar a densidade também às áreas fixas, que hoje não têm opção. O upstream tem uma branch de trabalho de densidade da barra lateral (`ya/CompactSpacing`); ler antes de implementar e preferir alinhar com ela para reduzir conflito futuro (§13).
- Critério: legibilidade preservada (fonte e ícone proporcionais), alvo de clique mínimo documentado, DPI 100/150%, acessibilidade (§32), sem corte de texto. Medir quantas linhas cabem antes/depois na mesma janela.

## F009 — Fonte das áreas fixas separada da fonte dos resultados

Objetivo: poder escolher uma fonte (família e tamanho) para as **áreas fixas** (menus, barra lateral, abas, barra de ferramentas, barra de status, diálogos) diferente da fonte da **lista de resultados** (nomes de arquivo e colunas).

- Hoje existe uma única fonte global (`AppearanceSettingsService.AppThemeFontFamily`, aplicada por `AppThemeResourcesHelper`). O requisito é separar em duas configurações independentes, com padrão = fonte atual para as duas.
- Tamanho opcional por grupo. Aplicar sem reiniciar o app. Fonte inexistente cai no padrão sem quebrar.
- Critério: trocar uma não muda a outra; persiste entre sessões; funciona nos três layouts e na barra de menus da F004.

## F010 — Todas as colunas do Windows Explorer

Objetivo: o usuário poder incluir no layout Details **qualquer coluna que o Windows Explorer oferece** (a lista "More..." do Explorer: Autor, Álbum, Dimensões, Duração, Taxa de bits, Data de captura, Câmera, Marca, e as centenas de propriedades do Windows Property System), além das colunas atuais do Files.

- Fonte dos dados: o Property System do Windows (propriedades `System.*` e as de formato). Enumerar as propriedades visualizáveis (`PSEnumeratePropertyDescriptions`) e ler o valor de cada item (`IPropertyStore`/`IShellItem2`) pelo CsWin32, sem P/Invoke ad hoc (AGENTS.md). **Validar na investigação** que isso reproduz a lista do Explorer; se não, documentar a diferença.
- Interface: seletor de colunas (como o "More..." do Explorer) com busca e agrupamento; as escolhas persistem por pasta/tipo de pasta como já ocorre com as colunas atuais.
- Desempenho: ler propriedades **só das linhas visíveis** e de forma assíncrona e com cancelamento; cache; nunca na UI thread; testar a pasta de 10 mil arquivos (§31). Ordenação e agrupamento por coluna nova são desejáveis, mas podem vir em fase posterior.
- Dependência: F002 (larguras) e o modelo de colunas (`ColumnsViewModel`, hoje com um conjunto fixo de propriedades `DetailsLayoutColumnItem`). A mudança central é passar a um modelo **dinâmico** de colunas: decisão de arquitetura do Claude antes de codar.

## F011 — Motor de busca escolhido pelo usuário no F3 (e Ctrl+F)

Objetivo: o atalho de busca (hoje `F3` e `Ctrl+F` ligados ao `SearchAction`) usar o motor que o usuário escolher nas configurações: **Busca nativa do Files**, **Agent Ransack** ou **Everything**.

- **Sem abrir a tela do outro programa.** Os resultados voltam para a lista do próprio Files. Usar o motor deles em segundo plano:
  - Everything: pelo IPC/SDK oficial (o Everything 1.4.1.1032 já está instalado e em execução nesta máquina, OBSERVED). Verificar se precisa do `Everything64.dll` do SDK (licença MIT, redistribuível) ou implementar o protocolo de mensagens via CsWin32; avaliar o que é compatível com NativeAOT.
  - Agent Ransack: está instalado (versão 9.2.3425.1, `C:\Program Files\Mythicsoft\Agent Ransack`) com `flpsearch.exe` e `flpidx.exe` (INFERRED: motor de linha de comando do mesmo fabricante). **NOT TESTED**: descobrir os parâmetros do `flpsearch.exe` e se ele devolve resultados em texto estruturado sem abrir janela; se não houver modo silencioso, registrar e propor alternativa (por exemplo, só busca de conteúdo).
  - Nativa: o `FolderSearch` atual, inalterado.
- A configuração tem um valor por motor e mostra a disponibilidade (instalado/não instalado/não respondendo). Motor indisponível cai na busca nativa com aviso discreto, nunca erro (§10). Rótulo/ícone indica qual motor está ativo na caixa de busca.
- Sobrepõe a F006: a **F006 passa a ser a infraestrutura** (abstração `ISearchProvider`, benchmark) e a F011 é a **escolha pelo usuário e os dois provedores externos**. Ver `docs/agents/tasks/F006-search-provider.md` e `F011-search-engine-choice.md`.

## Nova ordem de execução (substitui o §29 a partir de 03/10/2026)

1. F001 Rename UX (em andamento) → F005 Preview/Details → F003 abas (confirmar, já atendido).
2. F008 Modo compacto → F009 Fontes separadas (pequenas, valor diário imediato, tocam em recursos/estilos).
3. F002 Colunas (investigação por teste) → **F010 Todas as colunas** (depende do modelo dinâmico de colunas).
4. F004 Menu clássico (os itens F008/F009 precisam funcionar nele).
5. F006 infraestrutura de busca → F011 escolha de motor (Everything e Agent Ransack).
6. F007 desempenho em paralelo (medição, sem código) e DISCOVERY.

Racional: itens pequenos e de baixo risco primeiro; os dois de arquitetura mais pesada (colunas dinâmicas e busca) depois de F002/F006 darem o desenho.
