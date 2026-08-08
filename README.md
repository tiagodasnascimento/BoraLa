## 1. Introdução
BoraLá - uma plataforma que conecta usuários a eventos em bares e restaurantes, disponibilizando agendas de eventos diários e status de movimentação.

## 2. Projeto de Sistema de Software Escolhido
O sistema atua na indústria de entretenimento e hospitalidade. Ele soluciona a dificuldade de conectar os usuários de forma centralizada aos eventos e programações da vida noturna de uma cidade.

## 3. Ferramenta de SDD, IA e Demais Tecnologias Utilizadas

* **Ferramenta de SDD (Spec-Driven Development):** O projeto emprega o **GitHub Spec Kit**. O desenvolvimento é orientado a documentos textuais versionados que progridem em fases lógicas, utilizando os comandos de *Quality Gates* e execução (`/speckit.constitution`, `/speckit.specify`, `/speckit.analyze`, `/speckit.plan`, `/speckit.tasks` e `/speckit.implement`).

* **Modelos/Agentes de IA Empregados:** Utilização do **GitHub Copilot** e **Cloud** no Visual Studio Code como agentes de IA autônomos. Eles não atuam gerando código livremente, mas sim lendo, interpretando e executando as implementações estritamente baseadas nos artefatos arquiteturais (`plan.md` e `tasks.md`) gerados pela metodologia SDD. **Gemini** como suporte para montar os prompts, ajudando a condução o desenvolvimento do trabalho e preparação do material para apresentação.

* **Frontend:** Desenvolvimento mobile multiplataforma utilizando as tecnologias **Dart e Flutter**.

* **Backend:** Desenvolvimento utilizando a linguagem **Elixir**, extraindo valor da máquina virtual **BEAM** (Erlang) e do modelo de atores (OTP e GenServers) para garantir o controle perfeito da alta concorrência durante picos de acessos e disputas por reservas. Utilização do Ecto para persistência de dados.

* **Infraestrutura e Suporte do Ecossistema:** O projeto nasce orientado à nuvem (*Cloud Native*), empregando **Docker** para conteinerização. O fluxo de desenvolvimento exige validações automatizadas de testes e build integrados em esteiras de **CI**, no **GitHub Actions**. 

# Comandos do Speckit

## Instruções inicias para construção do projeto

Instruções do fluxo Speckit que foram usados para orientar a criação e evolução do projeto BoraLá.

## 1) Fluxo de geração de artefatos

### Constituição
```bash
/speckit.constitution Estabeleça as diretrizes fundamentais de arquitetura, qualidade de código e segurança para o projeto "BoraLá", uma plataforma que conecta usuários a eventos em bares e restaurantes, disponibilizando agendas de eventos diários e status de movimentação.

Stack Tecnológica e Arquitetura:

Frontend: Mobile nativo utilizando Flutter (Dart). Exija o uso de padrões de projeto claros para o gerenciamento de estado, separação estrita entre UI e regras de negócio, e componentes altamente reutilizáveis.
Backend: Desenvolvido em Elixir. O código deve explorar ao máximo o modelo de atores, a concorrência e a resiliência nativa da máquina virtual BEAM, utilizando padrões de design funcionais e mantendo os domínios de negócio isolados (contextos delimitados).

Engenharia e Qualidade:

Todo código gerado deve ser modular, escalável e coberto por testes automatizados (unitários e de integração).
A documentação de APIs deve ser clara e orientada a contratos rígidos.

DevSecOps e Infraestrutura:

A aplicação deve ser pensada desde o dia zero para rodar em ambientes conteinerizados (Docker), garantindo alta disponibilidade durante picos de acesso aos finais de semana.
O design deve facilitar a integração contínua (CI), com validações automatizadas de segurança, linting e testes a cada submissão de código.`

Salve o conteúdo do comando /speckit.constitution em um arquivo constituition.md
```

Objetivo:
- definir princípios de arquitetura,
- padrões de qualidade,
- segurança,
- e diretrizes de engenharia para o projeto.

### Especificação
```bash
/speckit.specify Especifique as funcionalidades core do aplicativo "BoraLá" e salve no arquivo spec.md
```

Objetivo:
- listar requisitos funcionais principais,
- definir objetivos do produto,
- documentar o MVP e as principais experiências do usuário.

### Plano de arquitetura
```bash
/speckit.plan Leia o arquivo spec.md e elabore o plano de arquitetura e engenharia detalhado para o projeto "BoraLá". Salve o conteúdo em plan.md.
```

Objetivo:
- descrever arquitetura do frontend/backend,
- definir stacks e fluxos,
- planejar módulos, integrações e evolução do sistema.

### Backlog de tarefas
```bash
/speckit.tasks salve num arquivo tasks.md
```

Objetivo:
- transformar o plano em backlog executável,
- separar entregas por fases e milestones,
- organizar o trabalho em ordem de prioridade.

### Implementação
```bash
/speckit.implement
```

Objetivo:
- executar a implementação prática do projeto com base nos artefatos gerados.

## Instruções para modificação do projeto

### Especificação

```bash
/speckit.specify
```

```
Quero que o frontend seja desenvolvido seguindo fielmente a proposta visual do mockup desenhado à mão que estou fornecendo como referência. O objetivo é criar uma experiência moderna, elegante e visualmente marcante — não quero uma interface genérica baseada apenas em componentes padrão de bibliotecas.

A aplicação terá como principal elemento um *mapa interativo*, onde serão exibidos os locais que possuem eventos acontecendo. Cada local/evento deve ser facilmente identificável no mapa e permitir que o usuário veja mais informações ao interagir com ele.

- Funcionalidades principais

* Mapa interativo como elemento central da aplicação.
* Exibição de locais com eventos através de marcadores visualmente personalizados.
* Busca por eventos e locais.
* Filtros para facilitar a descoberta dos eventos.
* Filtro por *estilo/gênero musical*.
* Possibilidade de combinar diferentes filtros.
* Cada evento deve apresentar informações relevantes, como:

  * Nome do local;
  * Nome do evento;
  * Estilo/gênero musical;
  * Data e horário;
  * Nível de movimento/lotação do local, por exemplo: tranquilo, movimentado ou muito movimentado;
  * Outras informações relevantes que ajudem o usuário a decidir onde ir.

- Experiência e UI

A prioridade é entregar uma UI *muito bem trabalhada e com personalidade própria*.

Use o mockup desenhado à mão como referência principal para a composição, hierarquia visual, posicionamento dos elementos e experiência geral. Não transforme o desenho simplesmente em uma tela utilizando cards e componentes genéricos.

*Não utilize os componentes padrão de bibliotecas de UI de forma visualmente crua.* Se uma biblioteca for utilizada, seus componentes devem ser altamente customizados para fazer parte de um sistema visual próprio.

Quero uma interface:

* Moderna;
* Premium;
* Intuitiva;
* Fluida;
* Visualmente rica;
* Com excelente hierarquia de informações;
* Com microinterações e estados de interação bem pensados;
* Responsiva;
* Com boa utilização de espaço;
* Que transmita uma experiência de descoberta de eventos musicais.

Capriche especialmente nos detalhes de UI/UX: marcadores do mapa, filtros, busca, cards de eventos, estados ativos/inativos, hover, seleção de um evento, transições, indicadores de movimentação e hierarquia tipográfica.

- Mapa

O mapa deve ser tratado como uma parte importante da experiência, e não apenas como um componente de fundo.

Os marcadores precisam ter uma identidade visual própria e deixar claro quando um local está selecionado ou possui maior relevância. Ao selecionar um local/evento, deve existir uma forma elegante de visualizar suas informações sem prejudicar a navegação pelo mapa.

Também considere a possibilidade de diferentes níveis de zoom e diferentes densidades de eventos.

- Eventos

Os eventos devem ser apresentados de maneira que o usuário consiga entender rapidamente:

*onde é → o que está tocando → quando acontece → quão movimentado está.*

O nível de movimento pode ser representado visualmente de maneira intuitiva, evitando depender apenas de texto.

- Responsividade

A experiência deve funcionar muito bem tanto em desktop quanto em dispositivos móveis.

No mobile, repense a disposição dos elementos para que o mapa continue sendo útil e os filtros/busca não ocupem espaço excessivo. Pode utilizar elementos como bottom sheets, painéis deslizantes ou outras soluções que façam sentido para a experiência.

- Diretriz importante

Não quero que o resultado pareça um dashboard administrativo ou um template pronto.

Quero que pareça um *produto real, moderno e cuidadosamente projetado para descoberta de eventos musicais*, seguindo a identidade visual do mockup fornecido.

Antes de implementar, analise o mockup e extraia dele os principais padrões visuais, estrutura, hierarquia e intenção de UX. A implementação deve preservar essa essência, mas pode melhorar e refinar o que for necessário para transformar o conceito desenhado à mão em uma interface profissional.
```

```bash
/speckit.analyze
```

```bash
/speckit.plan
```

```bash
/speckit.tasks
```

```bash
/speckit.implement
```

## Instruções para correção do CI

- Vibecode. 

## Desvantagens e Limitações Identificadas:

- Sem um escopo pré-definido, a IA "alucina" funcionalidades e cria documentações gigantescas, forçando o engenheiro a perder horas apenas apagando especificações inúteis.

- Burocracia para tarefas simples: O ciclo obrigatório do SDD (especificar, clarificar, planejar, gerar tarefas) gera um atraso desnecessário para implementações rápidas, como criar um CRUD básico ou ajustar uma funcionalidade.

- A IA frequentemente propõe arquiteturas genéricas ou complexas demais para o problema, dando mais trabalho para corrigir o plano do que se o engenheiro o tivesse escrito do zero.

## Vantagens e Pontos Positivos Identificados:

- Se o engenheiro entrega as regras do projeto bem definidas desde o início, a IA não tenta adivinhar; ela vira uma assistente focada que só faz o que foi pedido, sem mexer na arquitetura.

- Subir uma nova feature não foi um problema, pois a IA não fez nada que quebrou o sistema. O resultado foi uma alteração direcionada, preservando o restante do código.

- Implementação dos testes em primeiro plano. Com o SDD, a IA implementou os testes em paralelo com o código, já ia executado os testes e validando, garantindo a qualidade da implementação.

- Como no SDD a documentação é o primeiro conteúdo a ser desenvolvido, a gente elimina aquele problema clássico dela ficar sempre para o final (ou de simplesmente não ser feita). O projeto já nasceu com tudo registrado.

## Conclusão

A adoção do SDD com Inteligência Artificial traz benefícios práticos ao desenvolvimento, mas exige um controle rigoroso. A IA não atua de forma independente; sem restrições claras, a ferramenta burocratiza tarefas simples, introduz complexidade desnecessária e consome o tempo do engenheiro na correção de requisitos gerados incorretamente. Nesse modelo, o papel do desenvolvedor muda da escrita direta de código para a curadoria técnica e de escopo.

Por outro lado, quando os parâmetros iniciais são bem definidos, a metodologia resolve problemas comuns da engenharia de software: assegura a criação da documentação antes do início do desenvolvimento, garante a implementação simultânea de testes e permite a inserção de novas features de forma isolada, sem comprometer a estabilidade do sistema existente. Em resumo, é uma abordagem eficaz para a construção de sistemas robustos, desde que a equipe tenha clareza dos requisitos antes de iniciar os comandos na ferramenta.