# BoraLá Constitution

O BoraLá é uma plataforma que conecta usuários a eventos em bares e restaurantes,
com agenda diária e status de movimentação em tempo real. Esta constituição define
os princípios não-negociáveis do projeto. Todo plano, tarefa e revisão de código é
avaliado contra ela.

## Core Principles

### I. Separação estrita de camadas

Interface, aplicação, domínio e infraestrutura MUST permanecer em camadas distintas,
sem dependências invertidas.

- No Flutter, a camada `presentation` MUST NOT conter regra de negócio; ela chama
  casos de uso ou repositórios de `domain`.
- No Elixir, controllers MUST NOT acessar `Repo` diretamente; toda leitura e escrita
  passa pela API pública do contexto de domínio correspondente.
- Cada feature Flutter MUST seguir o layout `data/`, `domain/`, `presentation/`.
- Cada contexto Elixir MUST expor uma API de contexto explícita; módulos de outros
  contextos MUST NOT chamar schemas ou funções internas alheias.

**Rationale**: sem esta fronteira, regra de negócio vaza para a UI e para controllers,
e o custo de mudar qualquer coisa cresce de forma não-linear.

### II. Contextos delimitados por domínio

Cada domínio de negócio MUST viver em um contexto próprio e nomeado: `accounts`,
`events`, `venues`, `traffic`, `notifications`, `favorites`, `search`,
`recommendations`, `admin`.

- Comunicação entre contextos MUST ser explícita e por contrato, nunca por acesso
  direto a estruturas internas.
- Um contexto novo MUST ser justificado no plano; não se cria contexto por
  conveniência organizacional.

**Rationale**: contextos delimitados são o que permite ao produto crescer sem que
uma mudança em eventos quebre notificações.

### III. Testes automatizados como requisito estrutural (NÃO-NEGOCIÁVEL)

Nenhuma funcionalidade é considerada entregue sem teste automatizado.

- Toda regra de negócio MUST ter teste unitário.
- Todo endpoint público MUST ter teste de contrato validando request, response,
  status codes e formatos de erro.
- Todo fluxo crítico de usuário (descoberta, busca, favoritar, status de movimentação,
  autenticação) MUST ter teste de integração.
- Casos de borda e cenários de falha MUST ser cobertos explicitamente, não apenas o
  caminho feliz.
- A suíte completa MUST rodar em cada mudança, de forma automatizada no pipeline.

**Rationale**: o produto entrega informação para decisão em tempo real; informação
errada é pior que informação ausente.

### IV. Contratos de API rígidos e versionados

A API é o contrato entre o app Flutter e o backend Elixir e MUST ser tratada como tal.

- Cada endpoint MUST ter definição explícita de método, path, payload de entrada,
  payload de saída, status codes e erros esperados.
- Toda entrada externa MUST ser validada e sanitizada antes de alcançar o domínio.
- Campos de data, localização e status MUST usar formatos inequívocos e documentados
  (ISO 8601 para datas/horas, enums nomeados para status).
- Mudanças incompatíveis MUST ser versionadas, com caminho de migração previsto.
- A documentação MUST ser atualizada na mesma mudança que altera o código.

**Rationale**: o cliente mobile tem ciclo de release lento; quebrar contrato em
produção deixa usuários com app inutilizável.

### V. Resiliência e degradação segura

O sistema MUST tolerar falhas parciais sem falha total, especialmente sob pico de
demanda em finais de semana.

- Processos de negócio de longa duração e integrações externas MUST rodar sob
  supervision tree, isolados do caminho de request.
- Falha na fonte de movimentação MUST degradar para o último dado confiável conhecido,
  com indicação de defasagem — nunca erro crítico ao usuário.
- A aplicação MUST ser stateless o suficiente para rodar em múltiplas instâncias
  atrás de balanceador.
- O app MUST tratar explicitamente os estados de loading, vazio e erro em toda tela.

**Rationale**: o valor do produto está concentrado exatamente nos horários de maior
carga; indisponibilidade em sábado à noite é indisponibilidade total na prática.

### VI. Segurança por design

Segurança MUST ser considerada no desenho, não adicionada no fim.

- Autenticação e autorização MUST ser verificadas em toda operação sensível, no
  backend, independentemente do que o cliente envia.
- Papéis MUST ser distintos e explícitos: usuário final, parceiro (estabelecimento),
  administrador.
- Erros retornados ao cliente MUST NOT vazar detalhes internos (stack traces,
  queries, nomes de tabela).
- Logs MUST NOT conter segredos, tokens ou dados pessoais sensíveis.
- Segredos MUST vir de variáveis de ambiente ou cofre, nunca do repositório.
- O pipeline MUST incluir varredura de dependências e análise estática de segurança.

**Rationale**: a plataforma guarda localização e hábitos sociais de pessoas — dado
sensível por natureza.

### VII. Observabilidade como parte da arquitetura

Instrumentação MUST ser entregue junto da funcionalidade, não depois.

- Logs MUST ser estruturados.
- Métricas de latência, taxa de erro e throughput MUST existir para todo endpoint.
- Falha na API de eventos, erro na atualização de movimentação, pico de latência em
  consulta por região e indisponibilidade de notificações MUST ter alerta.

**Rationale**: sem sinal, uma degradação em horário de pico só é descoberta pelo
usuário que desistiu de usar o app.

## Technology Constraints

O stack é fixo e mudanças exigem emenda a esta constituição:

- **Frontend**: Flutter/Dart, com abordagem de gerenciamento de estado escolhida de
  forma explícita e aplicada de forma consistente em todo o app.
- **Backend**: Elixir sobre a BEAM, com Phoenix para a camada web e Ecto para
  persistência.
- **Persistência**: PostgreSQL como banco transacional, com índices para consulta por
  data, local, categoria e geolocalização.
- **Execução**: containers Docker, com ambiente local reproduzível via Docker Compose
  e desenho preparado para escala horizontal.

## Development Workflow

- Cada submissão MUST passar por: lint, análise estática, testes unitários, testes de
  integração, checagem de build e validações de segurança.
- O pipeline MUST bloquear entregas que não atendam aos critérios mínimos.
- Mudanças que afetem contratos de API, modelo de domínio ou infraestrutura MUST
  receber revisão dedicada.
- Entregas MUST ser incrementais e verificáveis; cada user story deve ser demonstrável
  de forma independente.
- Deploy MUST ser automatizado, rastreável e com rollback rápido.

## Governance

Esta constituição prevalece sobre qualquer outra prática do projeto.

- Todo plano gerado por `/speckit-plan` MUST passar pelo Constitution Check antes da
  fase de pesquisa e novamente após o desenho.
- Violações MUST ser registradas na tabela Complexity Tracking do plano, com
  justificativa e a alternativa mais simples que foi rejeitada — e por quê.
- Complexidade não justificada MUST ser removida, não documentada.
- Emendas exigem: descrição da mudança, justificativa, impacto nos artefatos
  existentes e incremento de versão.
- Versionamento semântico: MAJOR para remoção ou redefinição incompatível de
  princípio, MINOR para novo princípio ou expansão material, PATCH para
  esclarecimento sem mudança normativa.

**Version**: 1.0.0 | **Ratified**: 2026-08-07 | **Last Amended**: 2026-08-07
