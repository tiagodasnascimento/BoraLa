---
description: "Task list for 001-core-discovery-events"
---

# Tasks: Descoberta de Eventos, Agenda Diária e Status de Movimentação

**Input**: Design documents from `/specs/001-core-discovery-events/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md)

**Tests**: incluídos e obrigatórios. O Princípio III da constituição torna teste
automatizado requisito estrutural, não opcional.

**Organization**: tarefas agrupadas por user story, para que cada história seja
implementável, testável e demonstrável de forma independente.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: pode rodar em paralelo (arquivos diferentes, sem dependência)
- **[Story]**: a qual user story a tarefa pertence (US1..US8)
- Caminhos de arquivo exatos nas descrições

## Path Conventions

- **Backend**: `backend/lib/bora_la/`, testes em `backend/test/`
- **Frontend**: `frontend/lib/`, testes em `frontend/test/`

---

## Estado atual verificado (2026-08-07)

Auditoria do código no momento da migração para o spec-kit:

- ✅ Estrutura de monorepo, Docker Compose e pipeline de CI existem.
- ✅ App Flutter estruturado por feature com camadas `data`/`domain`/`presentation`.
- ✅ Rotas da API definidas em `backend/lib/bora_la/web/router.ex` para eventos,
  locais, movimentação, favoritos, notificações, recomendações, busca e login.
- ✅ Lógica real de classificação de movimentação em
  `backend/lib/bora_la/traffic/status.ex`.
- ✅ Suítes de teste existem nos dois lados e passam.
- ⚠️ **Nenhuma persistência**: `BoraLa.Repo` está declarado mas nunca é usado, não
  existe `backend/priv/repo/migrations/`, e **todos os controllers retornam dados
  fixos codificados no próprio arquivo**. A API responde, mas não há banco por trás.
- ⚠️ Controllers implementam a resposta diretamente, sem passar por contexto de
  domínio — violação do Princípio I.
- ❌ Não existem os contextos `events`, `venues` e `admin` como contextos de domínio.
- ❌ Sem autorização por perfil, sem supervision tree de negócio, sem observabilidade.

Consequência: o que existe é um **esqueleto navegável com dados de demonstração**, não
o MVP. As tarefas abaixo partem desse estado.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: fechar as lacunas de fundação do projeto

- [X] T001 Estrutura de monorepo com `frontend/` e `backend/`
- [X] T002 Docker Compose com PostgreSQL para ambiente local em `docker-compose.yml`
- [X] T003 Pipeline de CI inicial em `.github/workflows/ci.yml`
- [ ] T004 [P] Configurar lint e análise estática do Dart em
      `frontend/analysis_options.yaml` com regras estritas
- [ ] T005 [P] Adicionar `credo` e `dialyzer` às deps em `backend/mix.exs` e configurar
- [ ] T006 [P] Definir variáveis de ambiente e gestão de segredos em
      `backend/config/runtime.exs`, sem segredo versionado
- [ ] T007 Adicionar lint, análise estática e checagem de segurança ao
      `.github/workflows/ci.yml`, bloqueando merge em falha
- [ ] T008 [P] Documentar onboarding da equipe em `README.md`

**Checkpoint**: qualquer submissão passa por lint, análise estática e testes.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: infraestrutura sem a qual nenhuma user story pode ser implementada de
verdade

**⚠️ CRITICAL**: enquanto esta fase não fechar, os endpoints continuam devolvendo
dados fixos e nenhuma user story está realmente entregue.

**Decisões prévias**: resolver R-004 (autenticação), R-008 (índice geoespacial) e
R-009 (fuso e meia-noite) em [research.md](./research.md) antes de T012 e T014.

- [ ] T009 Configurar `BoraLa.Repo` de fato e conectar ao PostgreSQL em
      `backend/config/config.exs` e `backend/config/runtime.exs`
- [ ] T010 Criar diretório de migrations e a migration inicial em
      `backend/priv/repo/migrations/`
- [ ] T011 [P] Criar contexto `venues` com schema de estabelecimento e categoria em
      `backend/lib/bora_la/venues/`
- [ ] T012 [P] Criar contexto `events` com schema de evento e status de publicação em
      `backend/lib/bora_la/events/`
- [ ] T013 [P] Criar módulos compartilhados de validação e erro em
      `backend/lib/bora_la/shared/`
- [ ] T014 Definir índices para consulta por data, categoria e geolocalização nas
      migrations (depende de T010, T011, T012 e da decisão R-008)
- [ ] T015 Implementar autenticação com papéis usuário/parceiro/administrador no
      contexto `backend/lib/bora_la/accounts/` (depende da decisão R-004)
- [ ] T016 Implementar plug de autorização por perfil em
      `backend/lib/bora_la/web/` e aplicá-lo no pipeline do router
- [ ] T017 Implementar tratamento centralizado de erro que não vaza detalhe interno
      (FR-049), em `backend/lib/bora_la/web/`
- [ ] T018 Montar supervision tree de negócio em
      `backend/lib/bora_la/application.ex` para trabalho de fundo e integrações
- [ ] T019 [P] Configurar logs estruturados em `backend/config/config.exs`
- [ ] T020 [P] Definir a abordagem de gerenciamento de estado do Flutter (decisão
      R-007) e aplicá-la em `frontend/lib/core/di/service_locator.dart`
- [ ] T021 [P] Criar tema e design system em `frontend/lib/core/theme/`
- [ ] T022 [P] Criar widgets reutilizáveis de card, filtro, botão e os estados de
      loading/vazio/erro em `frontend/lib/core/widgets/` (FR-047)

**Checkpoint**: existe banco real, autenticação com papéis e componentes base. As user
stories podem começar.

---

## Phase 3: User Story 1 - Descobrir o que está acontecendo hoje por perto (Priority: P1) 🎯 MVP

**Goal**: agenda diária de eventos ordenada por proximidade, navegável por dia.

**Independent Test**: com eventos e locais no banco e uma localização conhecida, a
agenda do dia retorna os eventos corretos, ordenados por proximidade, com distância.

**Decisão prévia**: R-006 (raio de proximidade) e R-009 (eventos cruzando meia-noite).

### Tests for User Story 1

- [ ] T023 [P] [US1] Teste de contrato de `GET /api/events` cobrindo filtro por dia,
      ordenação e formato em `backend/test/bora_la_web/events_contract_test.exs`
- [ ] T024 [P] [US1] Teste de contexto para listagem por data e proximidade em
      `backend/test/bora_la/events_test.exs`
- [ ] T025 [P] [US1] Teste de widget da agenda, incluindo estado vazio e distinção
      entre evento em andamento e futuro, em `frontend/test/events_agenda_test.dart`

### Implementation for User Story 1

- [ ] T026 [US1] Implementar consulta de eventos por data e proximidade no contexto
      `backend/lib/bora_la/events/` (FR-001, FR-006, FR-008)
- [ ] T027 [US1] Reescrever `backend/lib/bora_la/web/controllers/events_controller.ex`
      para delegar ao contexto e remover os dados fixos
- [ ] T028 [US1] Implementar navegação entre dias na agenda (FR-002) em
      `frontend/lib/features/events/presentation/events_screen.dart`
- [ ] T029 [US1] Exibir nome, local, horário, descrição curta, imagem, categoria e
      distância no card (FR-004, FR-008)
- [ ] T030 [US1] Distinguir eventos em andamento, próximos e futuros (FR-003)
- [ ] T031 [US1] Destacar eventos de alta demanda (FR-005)
- [ ] T032 [US1] Implementar fluxo de permissão de localização com fallback para
      seleção de cidade ou bairro (FR-007) em `frontend/lib/features/events/`
- [ ] T033 [US1] Implementar visualização em mapa além da lista (FR-009)
- [ ] T034 [US1] Aplicar estados de loading, vazio e erro na agenda (FR-047)

**Checkpoint**: US1 funciona de ponta a ponta com dados reais e é demonstrável sozinha.

---

## Phase 4: User Story 2 - Decidir para onde ir com base na movimentação (Priority: P1) 🎯 MVP

**Goal**: indicador de movimentação confiável, com idade do dado explícita.

**Independent Test**: um local com status registrado exibe o nível correto, o
indicador visual e o horário da última atualização.

**Decisão prévia**: R-001 (fonte do dado), R-002 (intervalo) e R-003 (retenção).

### Tests for User Story 2

- [ ] T035 [P] [US2] Teste de contrato de leitura e atualização de movimentação em
      `backend/test/bora_la_web/traffic_contract_test.exs`
- [ ] T036 [P] [US2] Teste de validação de faixas e rejeição de valor inválido em
      `backend/test/bora_la/traffic_test.exs` (FR-016)
- [ ] T037 [P] [US2] Teste de degradação para último valor conhecido quando a fonte
      falha (FR-019)
- [ ] T038 [P] [US2] Teste de widget do indicador nos quatro níveis, no estado "sem
      informação" e no estado "desatualizado", em `frontend/test/traffic_test.dart`

### Implementation for User Story 2

- [ ] T039 [US2] Criar schema e migration de status de movimentação com nível, momento
      da medição e origem, em `backend/lib/bora_la/traffic/`
- [ ] T040 [US2] Persistir o status classificado por
      `backend/lib/bora_la/traffic/status.ex`, hoje apenas em memória
- [ ] T041 [US2] Implementar endpoint autenticado de atualização de status por
      parceiro, com validação de faixas (FR-016, FR-041)
- [ ] T042 [US2] Implementar consulta de movimentação por local delegando ao contexto
      em `backend/lib/bora_la/web/controllers/traffic_controller.ex`
- [ ] T043 [US2] Implementar histórico por janela temporal e política de retenção
      (FR-020, depende de R-003)
- [ ] T044 [US2] Implementar mecanismo de atualização escolhido em R-002, sob a
      supervision tree criada em T018
- [ ] T045 [US2] Implementar degradação para último valor conhecido com marcação de
      defasagem (FR-019)
- [ ] T046 [US2] Exibir nível, indicador visual e momento da última atualização
      (FR-015, FR-017) em `frontend/lib/features/traffic/presentation/`
- [ ] T047 [US2] Exibir "sem informação" explicitamente quando não houver dado (FR-018)

**Checkpoint**: US1 + US2 completas — este é o MVP.

---

## Phase 5: User Story 3 - Buscar e filtrar até encontrar o evento certo (Priority: P2)

**Goal**: busca textual e filtros combináveis, com ordenação preservando filtros.

**Independent Test**: cada filtro isolado e a busca textual retornam exatamente o
conjunto esperado.

### Tests for User Story 3

- [ ] T048 [P] [US3] Teste de contrato de `GET /api/search` com todos os filtros em
      `backend/test/bora_la_web/search_contract_test.exs`
- [ ] T049 [P] [US3] Teste de cada filtro isoladamente e combinados em
      `backend/test/bora_la/search_test.exs`
- [ ] T050 [P] [US3] Teste de busca com acento, erro de digitação e termo curto
- [ ] T051 [P] [US3] Teste de widget de filtros e estado vazio em
      `frontend/test/search_test.dart`

### Implementation for User Story 3

- [ ] T052 [US3] Implementar busca textual sobre nome de evento, estabelecimento e
      tipo de experiência no contexto `backend/lib/bora_la/search/` (FR-011)
- [ ] T053 [US3] Implementar filtros de categoria, data, localidade, faixa de preço e
      tipo de ambiente (FR-012)
- [ ] T054 [US3] Implementar ordenação por relevância, proximidade, popularidade e
      horário (FR-013)
- [ ] T055 [US3] Ligar `search_controller.ex` ao contexto, removendo dados fixos
- [ ] T056 [US3] Implementar UI de filtros preservando estado ao reordenar (FR-014)
- [ ] T057 [US3] Implementar estado vazio com sugestão de relaxar filtros

**Checkpoint**: US1, US2 e US3 funcionam de forma independente.

---

## Phase 6: User Story 4 - Ver os detalhes antes de decidir (Priority: P2)

**Goal**: tela de detalhe completa de evento e estabelecimento, com rota.

**Independent Test**: o detalhe de um evento completo exibe todos os campos e a rota
abre para o endereço correto.

### Tests for User Story 4

- [ ] T058 [P] [US4] Teste de contrato de `GET /api/events/:id` e `GET /api/venues/:id`
      em `backend/test/bora_la_web/detail_contract_test.exs`
- [ ] T059 [P] [US4] Teste de omissão limpa de campos opcionais não preenchidos
- [ ] T060 [P] [US4] Teste de widget da tela de detalhe em
      `frontend/test/event_detail_test.dart`

### Implementation for User Story 4

- [ ] T061 [US4] Implementar detalhe de evento no contexto `events` com descrição,
      atrações, horários, público, faixa etária e regras (FR-023)
- [ ] T062 [US4] Implementar detalhe de estabelecimento no contexto `venues` com nome,
      endereço, categoria, fotos e contato (FR-024)
- [ ] T063 [US4] Expor informação de reserva, fila, entrada gratuita e restrições
      (FR-025)
- [ ] T064 [US4] Ligar `events_controller.ex` e `venues_controller.ex` aos contextos
- [ ] T065 [US4] Criar a feature `venues` no app em `frontend/lib/features/venues/`
- [ ] T066 [US4] Implementar tela de detalhe com rota para o endereço (FR-026)
- [ ] T067 [US4] Exibir avaliações, destaques e movimentação do local (FR-027)

**Checkpoint**: a jornada completa de descoberta até decisão está fechada.

---

## Phase 7: User Story 5 - Parceiro publica e mantém sua agenda (Priority: P2)

**Goal**: parceiro autenticado cadastra, edita e publica eventos do seu local.

**Independent Test**: publicar um evento como parceiro, verificar que aparece na agenda
após aprovação, editar e verificar a propagação.

### Tests for User Story 5

- [ ] T068 [P] [US5] Teste de contrato de criação e edição de evento em
      `backend/test/bora_la_web/partner_events_contract_test.exs`
- [ ] T069 [P] [US5] Teste de rejeição de evento com dados inválidos, com mensagem por
      campo (FR-039)
- [ ] T070 [P] [US5] Teste de negação quando o parceiro tenta editar evento de outro
      estabelecimento (FR-042)

### Implementation for User Story 5

- [ ] T071 [US5] Implementar cadastro e edição de evento por parceiro no contexto
      `events` (FR-038)
- [ ] T072 [US5] Implementar validação completa antes da publicação (FR-039)
- [ ] T073 [US5] Implementar fluxo de aprovação com estados de publicação (FR-040)
- [ ] T074 [US5] Aplicar autorização de propriedade do estabelecimento (FR-042)
- [ ] T075 [US5] Adicionar as rotas autenticadas de parceiro em
      `backend/lib/bora_la/web/router.ex`

**Checkpoint**: a plataforma se abastece de conteúdo sem carga manual.

---

## Phase 8: User Story 6 - Guardar preferências e receber recomendações (Priority: P3)

**Goal**: favoritos persistidos, histórico e recomendações contextuais.

**Independent Test**: favoritar itens, verificar persistência entre sessões, e conferir
que as recomendações refletem o histórico.

### Tests for User Story 6

- [ ] T076 [P] [US6] Teste de contrato de favoritos e recomendações em
      `backend/test/bora_la_web/favorites_contract_test.exs`
- [ ] T077 [P] [US6] Teste de recomendação para usuário sem histórico (fallback por
      popularidade e proximidade)

### Implementation for User Story 6

- [ ] T078 [US6] Criar schema e migration de favorito, com persistência real no
      contexto `backend/lib/bora_la/favorites/` (FR-030)
- [ ] T079 [US6] Ligar `favorites_controller.ex` ao contexto, removendo dados fixos e o
      `user_id` codificado
- [ ] T080 [US6] Implementar remoção de favorito e a rota correspondente
- [ ] T081 [US6] Implementar histórico de eventos visitados ou marcados (FR-031)
- [ ] T082 [US6] Implementar recomendações por histórico e localização, com fallback
      por popularidade (FR-032)
- [ ] T083 [US6] Implementar UI de favoritos e recomendações com persistência entre
      sessões

**Checkpoint**: o produto passa a ter memória do usuário.

---

## Phase 9: User Story 7 - Ser lembrado do que importa (Priority: P3)

**Goal**: lembretes de eventos marcados e avisos de mudança, respeitando preferências.

**Independent Test**: marcar um evento, simular a aproximação do horário e verificar
que o lembrete respeita as preferências configuradas.

**Decisão prévia**: R-005 (canal de entrega).

### Tests for User Story 7

- [ ] T084 [P] [US7] Teste de geração de lembrete na antecedência configurada
- [ ] T085 [P] [US7] Teste de supressão quando o tipo de notificação está desativado
- [ ] T086 [P] [US7] Teste de notificação em mudança ou cancelamento de evento marcado

### Implementation for User Story 7

- [ ] T087 [US7] Criar schema de notificação e de preferência de notificação em
      `backend/lib/bora_la/notifications/`
- [ ] T088 [US7] Implementar worker de lembretes sob a supervision tree (FR-034)
- [ ] T089 [US7] Implementar notificação de mudança relevante em evento marcado
      (FR-035)
- [ ] T090 [US7] Implementar endpoint de preferências de notificação (FR-036)
- [ ] T091 [US7] Integrar o canal de entrega decidido em R-005 (FR-037)
- [ ] T092 [US7] Ligar `notifications_controller.ex` ao contexto
- [ ] T093 [US7] Implementar tela de preferências no app

**Checkpoint**: o produto alcança o usuário fora do app.

---

## Phase 10: User Story 8 - Administrar conteúdo e operação (Priority: P4)

**Goal**: moderação de eventos e visão operacional para a equipe da plataforma.

**Independent Test**: como administrador, aprovar e rejeitar eventos pendentes e
verificar que apenas os aprovados aparecem na agenda pública.

### Tests for User Story 8

- [ ] T094 [P] [US8] Teste de aprovação e rejeição com justificativa (FR-043)
- [ ] T095 [P] [US8] Teste de negação de acesso ao painel para perfil não
      administrativo

### Implementation for User Story 8

- [ ] T096 [US8] Criar contexto `admin` em `backend/lib/bora_la/admin/`
- [ ] T097 [US8] Implementar fila de moderação com aprovação e rejeição justificada
      (FR-043)
- [ ] T098 [US8] Implementar gestão de parceiros, locais e categorias (FR-044)
- [ ] T099 [US8] Implementar métricas de eventos ativos, uso e popularidade (FR-045)
- [ ] T100 [US8] Expor sinais de integridade operacional (FR-046)
- [ ] T101 [US8] Implementar a interface do painel administrativo

**Checkpoint**: a plataforma é operável em escala.

---

## Phase 11: Polish & Cross-Cutting Concerns

**Purpose**: fechar os gates constitucionais pendentes e preparar produção

- [ ] T102 [P] Documentar todos os contratos de API em
      `specs/001-core-discovery-events/contracts/` (Princípio IV)
- [ ] T103 [P] Escrever `specs/001-core-discovery-events/quickstart.md` com o passo a
      passo de execução e validação local
- [ ] T104 [P] Escrever `specs/001-core-discovery-events/data-model.md` com o modelo de
      dados consolidado
- [ ] T105 Implementar métricas de latência, erro e throughput por endpoint
      (Princípio VII)
- [ ] T106 Configurar alertas para os sinais críticos definidos na constituição
- [ ] T107 [P] Implementar tracing distribuído
- [ ] T108 Implementar cache com TTL curto para listagens frequentes e movimentação
- [ ] T109 Implementar proteção contra abuso de endpoints e rate limiting
- [ ] T110 Revisar logs para garantir ausência de segredos e dados sensíveis
- [ ] T111 Ajustar imagens Docker de frontend e backend para produção
- [ ] T112 Configurar deploy automatizado por ambiente com rollback
- [ ] T113 Executar testes de carga validando SC-005 e SC-006
- [ ] T114 Revisar performance de listagens e otimizar payloads de API
- [ ] T115 Tratar os casos de borda listados no spec que ainda não tiverem cobertura
- [ ] T116 Remover os arquivos `spec.md`, `plan.md`, `tasks.md` e `constitution.md` da
      raiz do repositório, agora substituídos pelos artefatos do spec-kit

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Fase 1)**: sem dependências.
- **Foundational (Fase 2)**: depende do Setup e **bloqueia todas as user stories**.
  Sem banco real, nenhuma história está de fato entregue.
- **User Stories (Fases 3–10)**: dependem da Fase 2.
  - US1 e US2 (P1) formam o MVP e podem ser feitas em paralelo por pessoas diferentes.
  - US3 e US4 (P2) dependem apenas da Fase 2, mas ganham sentido após US1.
  - US5 (P2) depende de US4 para o modelo de evento estar completo.
  - US6 (P3) e US7 (P3) — US7 depende de US6 para saber o que o usuário marcou.
  - US8 (P4) depende de US5, pois modera o que os parceiros publicam.
- **Polish (Fase 11)**: depende das histórias desejadas estarem completas.

### Decisões que bloqueiam tarefas

| Decisão | Bloqueia |
|---------|----------|
| R-001, R-002, R-003 | US2 (T039–T045) |
| R-004 | T015, e por consequência US5, US6, US7, US8 |
| R-005 | US7 (T091) |
| R-006 | US1 (T026) |
| R-007 | T020 e toda a camada de apresentação |
| R-008 | T014, e a meta de desempenho SC-002 |
| R-009 | US1 (T026) |

### Within Each User Story

- Testes escritos primeiro e falhando antes da implementação.
- Schemas antes de contextos; contextos antes de controllers; controllers antes da UI.
- História completa antes de passar para a próxima prioridade.

### Parallel Opportunities

- Todas as tarefas marcadas [P] na Fase 1 podem rodar em paralelo.
- Na Fase 2, T011, T012, T013, T019, T020, T021 e T022 são paralelizáveis.
- Todos os testes marcados [P] dentro de uma história podem ser escritos em paralelo.
- Backend e frontend de uma mesma história podem avançar em paralelo assim que o
  contrato de API estiver acordado.

---

## Implementation Strategy

### MVP primeiro (US1 + US2)

1. Fase 1: Setup
2. Fase 2: Foundational — **crítica**, é o que transforma o esqueleto atual em sistema
3. Fase 3: US1 — agenda diária por proximidade
4. Fase 4: US2 — status de movimentação
5. **PARE E VALIDE**: as duas histórias funcionando com dados reais são o produto
   mínimo defensável

### Entrega incremental

1. Setup + Foundational → fundação pronta
2. US1 + US2 → MVP demonstrável
3. US3 + US4 → descoberta completa
4. US5 → conteúdo se abastece sozinho
5. US6 + US7 → retenção
6. US8 → operação em escala

---

## Notes

- Tarefas [P] tocam arquivos diferentes e não têm dependência entre si.
- O rótulo [Story] mantém a rastreabilidade entre tarefa, user story e requisito.
- Cada tarefa referencia o `FR-###` que satisfaz; se uma tarefa não mapeia para nenhum
  requisito, ela provavelmente não deveria existir.
- Commite a cada tarefa ou grupo lógico.
- A remoção dos dados fixos dos controllers é condição para qualquer história ser
  considerada entregue.
