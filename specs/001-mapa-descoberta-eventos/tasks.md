---

description: "Task list for feature implementation"
---

# Tasks: Mapa Interativo de Descoberta de Eventos

**Input**: Design documents from `/specs/001-mapa-descoberta-eventos/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/discovery-repository.md](./contracts/discovery-repository.md), [quickstart.md](./quickstart.md)

**Tests**: incluídas de forma leve (um teste de widget por user story), pois `contracts/discovery-repository.md` exige explicitamente que o contrato de comportamento marcador→painel seja coberto por teste, e o repositório já segue esse padrão (`frontend/test/*_test.dart` por feature). Não é uma abordagem TDD estrita — a spec não pediu isso.

**Organization**: Tarefas agrupadas por user story (P1/P2/P3 de `spec.md`) para permitir implementação e teste independentes de cada uma.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: pode rodar em paralelo (arquivos diferentes, sem dependências pendentes)
- **[Story]**: a qual user story a tarefa pertence (US1, US2, US3)
- Caminhos de arquivo exatos incluídos em cada descrição, relativos à raiz do repositório

## Path Conventions

Projeto Flutter único em `frontend/`, já estruturado por feature (`frontend/lib/features/<feature>/{data,domain,presentation}`, testes em `frontend/test/`) — ver "Structure Decision" em `plan.md`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: preparar dependências e estrutura de pastas antes de qualquer código de feature

- [X] T001 Adicionar `flutter_map`, `flutter_map_marker_cluster`, `latlong2` e `geolocator` em `frontend/pubspec.yaml` e rodar `flutter pub get` (versões conforme decisão em `research.md` §1-3)
- [X] T002 [P] Criar a estrutura de pastas da feature `discovery` em `frontend/lib/features/discovery/{data,domain,presentation/{cubit,widgets}}` (vazias, apenas estrutura)
- [X] T003 [P] Configurar permissão de localização nas plataformas: `ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION` em `frontend/android/app/src/main/AndroidManifest.xml` e `NSLocationWhenInUseUsageDescription` em `frontend/ios/Runner/Info.plist`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: modelos de domínio, repositórios, estado (Cubit) e a tela de mapa base — usados pelas 3 user stories

**⚠️ CRITICAL**: nenhuma user story pode começar antes desta fase estar completa

- [X] T004 [P] Criar entidade `Venue` em `frontend/lib/features/discovery/domain/venue.dart` (`id`, `name`, `latitude`, `longitude`, `trafficStatus: VenueTrafficStatus`, `isFeatured`) reaproveitando `VenueTrafficStatus` de `frontend/lib/features/traffic/domain/venue_status.dart`, per `data-model.md`
- [X] T005 [P] Estender `EventItem` em `frontend/lib/features/events/domain/event.dart`: substituir `location: String` por `venueId: String` e adicionar `genre: String`, per `data-model.md`
- [X] T006 [P] Criar `FilterCriteria` em `frontend/lib/features/discovery/domain/filter_criteria.dart` (`genres: Set<String>`, `trafficStatuses: Set<VenueTrafficStatus>`, `dateRange: DateTimeRange?`) per `data-model.md`
- [X] T007 [P] Criar `MapMarkerViewModel` em `frontend/lib/features/discovery/domain/map_marker_view_model.dart` (`venue`, `activeEvents`, `isSelected`) per `data-model.md`
- [X] T008 [P] Criar `UserLocation` em `frontend/lib/features/discovery/domain/user_location.dart` (`latitude`, `longitude`, `isPermissionGranted`) per `data-model.md`
- [X] T009 Criar `VenueRepository` (abstract + `VenueRepositoryImpl` mockado) em `frontend/lib/features/discovery/data/venue_repository.dart` com `fetchVenues({required LatLngBounds visibleBounds})` e `fetchVenueById(String id)`, populando venues de exemplo com `latitude`/`longitude` reais, per `contracts/discovery-repository.md` (depende de T004)
- [X] T010 Atualizar `EventRepositoryImpl` em `frontend/lib/features/events/data/event_repository.dart`: adicionar `fetchEventsByVenue(String venueId)` e popular os eventos mockados com `venueId` (referenciando os venues de T009) e `genre`; garantir que `fetchEventsByVenue` não retorne eventos com `endAt` no passado, per `data-model.md`/`contracts/discovery-repository.md` (depende de T005, T009)
- [X] T011 Registrar `VenueRepository`, `EventRepository`, `SearchRepository`, `TrafficRepository` e um serviço de localização (`geolocator`) em `frontend/lib/core/di/service_locator.dart` via `get_it` (depende de T009, T010)
- [X] T012 Criar `DiscoveryCubit`/`DiscoveryState` em `frontend/lib/features/discovery/presentation/cubit/discovery_cubit.dart` combinando: venues/eventos visíveis, filtros ativos, termo de busca, marcador selecionado e localização do usuário — expondo os métodos que as 3 user stories vão consumir; incluir desde já o estado de fallback quando `isPermissionGranted == false` (região padrão), refinado depois em T033 (depende de T004-T011)
- [X] T013 Criar `MapScreen` (esqueleto) em `frontend/lib/features/discovery/presentation/map_screen.dart` renderizando `FlutterMap` + `MarkerClusterLayerWidget`, conectado ao `DiscoveryCubit`, com composição condicional por breakpoint (`LayoutBuilder`) para mobile/desktop — estrutura funcional básica; polimento de UX responsiva fica para T031 — per `research.md` §6; atualizar `frontend/lib/app.dart` para que `HomeScreen` renderize `MapScreen` em vez de `SearchScreen` (depende de T012)

**Checkpoint**: fundação pronta — as user stories podem começar

---

## Phase 3: User Story 1 - Explorar eventos próximos no mapa (Priority: P1) 🎯 MVP

**Goal**: usuário abre o app, vê o mapa com marcadores customizados dos locais com eventos, e ao tocar em um marcador vê os detalhes (local, evento, gênero, horário, nível de movimento) sem sair do mapa.

**Independent Test**: abrir o app na visão de mapa, tocar em qualquer marcador e confirmar que o painel de detalhes surge com as informações exigidas, sem navegação para fora do mapa (ver `quickstart.md` §1).

### Implementation for User Story 1

- [X] T014 [P] [US1] Criar `CrowdLevelIndicator` em `frontend/lib/features/discovery/presentation/widgets/crowd_level_indicator.dart` — mapeia `VenueTrafficStatus` para representação visual (cor/ícone), não apenas texto, seguindo o mapeamento definido em `data-model.md` (`low`→tranquilo, `medium`/`high`→movimentado, `crowded`→muito movimentado), per FR-006
- [X] T015 [P] [US1] Criar `EventMarker` em `frontend/lib/features/discovery/presentation/widgets/event_marker.dart` — widget customizado com estados visuais `isSelected`/relevância (`isFeatured`), usando `CrowdLevelIndicator` (depende de T014)
- [X] T016 [US1] Criar `EventDetailPanel` em `frontend/lib/features/discovery/presentation/widgets/event_detail_panel.dart` — bottom sheet (mobile) / painel lateral (desktop) exibindo nome do local, nome do evento, gênero, data/horário, `CrowdLevelIndicator`, e estado de erro amigável quando o venue não é encontrado (depende de T014)
- [X] T017 [US1] Em `map_screen.dart`, conectar toque no `EventMarker` → `DiscoveryCubit.selectMarker(venueId)` → abrir `EventDetailPanel` mantendo o mapa visível/interativo (depende de T015, T016, T013)
- [X] T018 [US1] Adicionar marcador "EU" (localização do usuário) em `map_screen.dart`, obtido via serviço de localização (`geolocator`) registrado em T011, visualmente distinto dos `EventMarker` (depende de T013)
- [X] T019 [US1] Implementar estado vazio ("nenhum evento próximo") como overlay amigável em `map_screen.dart` quando `DiscoveryCubit` não retorna venues na área visível (depende de T017)
- [X] T020 [P] [US1] Teste de widget: seleção de marcador abre painel com as informações exigidas, em `frontend/test/discovery_map_test.dart` (cobre o contrato de comportamento de `contracts/discovery-repository.md`)

**Checkpoint**: User Story 1 completa e testável de forma independente (MVP)

---

## Phase 4: User Story 2 - Buscar um evento ou local específico (Priority: P2)

**Goal**: usuário digita uma busca e é levado diretamente ao local/evento correspondente no mapa.

**Independent Test**: digitar o nome de um local/evento existente na busca e verificar que o mapa centraliza e destaca o marcador correspondente, com o painel de detalhes já aberto (ver `quickstart.md` §2).

### Implementation for User Story 2

- [X] T021 [P] [US2] Criar `DiscoverySearchBar` em `frontend/lib/features/discovery/presentation/widgets/discovery_search_bar.dart` com resultados em tempo real conforme digitação
- [X] T022 [US2] Estender `SearchRepository` em `frontend/lib/features/search/data/search_repository.dart` para também considerar `genre` e o novo `venueId`/nome de venue na correspondência (FR-007)
- [X] T023 [US2] Conectar seleção de resultado de busca → `DiscoveryCubit` centraliza o mapa no venue e chama `selectMarker` (reaproveitando o fluxo de T017) — em `discovery_search_bar.dart`/`map_screen.dart` (depende de T021, T022, T012, T017)
- [X] T024 [US2] Implementar estado de "nenhum resultado encontrado" em `discovery_search_bar.dart` quando a busca não retorna itens
- [X] T025 [P] [US2] Teste de widget: busca com resultado (centraliza + abre painel) e sem resultado (mensagem clara), em `frontend/test/discovery_search_test.dart`

**Checkpoint**: User Stories 1 e 2 funcionam de forma independente

---

## Phase 5: User Story 3 - Filtrar eventos por gênero musical e outros critérios (Priority: P3)

**Goal**: usuário aplica e combina filtros (gênero musical, nível de movimento) para reduzir os eventos exibidos no mapa.

**Independent Test**: aplicar um filtro de gênero e confirmar que apenas marcadores compatíveis ficam visíveis; adicionar um segundo filtro e confirmar que o resultado é a interseção de ambos (ver `quickstart.md` §3).

### Implementation for User Story 3

- [X] T026 [P] [US3] Criar `FilterPanel` em `frontend/lib/features/discovery/presentation/widgets/filter_panel.dart` — seleção de gênero(s) musical(is) e nível(is) de movimento, com opção de limpar filtros
- [X] T027 [US3] Implementar lógica de combinação de filtros no `DiscoveryCubit` (`frontend/lib/features/discovery/presentation/cubit/discovery_cubit.dart`): AND entre grupos de filtro, OR dentro do mesmo grupo, aplicada sobre venues/eventos visíveis, per `data-model.md` (FilterCriteria) (depende de T012, T006)
- [X] T028 [US3] Conectar `FilterPanel` ao `DiscoveryCubit` e atualizar a visibilidade dos marcadores em `map_screen.dart` (depende de T026, T027)
- [X] T029 [US3] Implementar mensagem clara de "nenhum evento para os critérios selecionados" quando a combinação de filtros não retorna resultados (FR-016)
- [X] T030 [P] [US3] Teste de widget: aplicar filtro único, combinar dois filtros e limpar filtros, em `frontend/test/discovery_filter_test.dart`

**Checkpoint**: todas as user stories funcionam de forma independente

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: refinar responsividade, microinterações e cobrir os edge cases restantes da spec

- [X] T031 [P] Refinar (não introduzir) o layout responsivo já estruturado em T013: substituir o painel básico por `DraggableScrollableSheet` para o `EventDetailPanel`/`FilterPanel` no mobile vs. painel lateral fixo no desktop, per FR-014 e `research.md` §6
- [X] T032 [P] Adicionar transições/microinterações (`AnimatedScale`, `AnimatedSwitcher`, `Hero`) e estados de hover/ativo/desabilitado na seleção de marcador, abertura/fechamento do painel, `discovery_search_bar.dart` e `filter_panel.dart`, per FR-015
- [X] T033 Refinar a UX do fallback de localização negada (mensagem, transição para a região padrão) no `DiscoveryCubit`/`map_screen.dart` — a lógica básica de fallback já existe desde T012; garantir aqui que o comportamento fica claro e amigável ao usuário, per FR-017
- [X] T034 [P] Executar todos os cenários manuais de `quickstart.md` (US1, US2, US3, responsividade, localização negada) e corrigir regressões encontradas
- [X] T035 Rodar `flutter analyze` e `flutter test` em `frontend/` e corrigir eventuais falhas antes de considerar a feature concluída
- [ ] T036 [P] Planejar e conduzir teste de usabilidade com usuários reais validando SC-003 (≥90% identificam o nível de movimento de um local usando apenas o indicador visual, sem ler texto) — documentar resultado. **Roteiro pronto em [validation-plan.md](./validation-plan.md); falta executar com participantes.**
- [X] T037 Validar cenário de alta densidade de marcadores (`quickstart.md` §6) e ajustar comportamento do clustering se necessário, per FR-012/SC-006
- [ ] T038 [P] Revisão de design lado a lado com o mockup de referência: confirmar que a UI final preserva a hierarquia/composição do mockup e não parece um dashboard administrativo genérico, per SC-007. **Tabela de correspondência mockup→implementação em [validation-plan.md](./validation-plan.md); falta a revisão com outra pessoa.**

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: sem dependências — pode começar imediatamente
- **Foundational (Phase 2)**: depende da conclusão do Setup — BLOQUEIA todas as user stories
- **User Stories (Phase 3-5)**: todas dependem da conclusão da Fase 2
  - US1 (P1) não depende de US2/US3
  - US2 (P2) reaproveita o fluxo de seleção de marcador de US1 (T017) — pode ser implementada em paralelo por outra pessoa assim que T017 existir, mas é logicamente uma extensão de US1
  - US3 (P3) depende apenas da Fundação (T006, T012) — independente de US2
- **Polish (Phase 6)**: depende das user stories que forem entregues

### Within Each User Story

- Widgets de apresentação antes da integração ao `map_screen.dart`
- Lógica no `DiscoveryCubit` antes da conexão da UI a ela
- Teste de widget da história ao final, validando o comportamento integrado

### Parallel Opportunities

- T002, T003 (Setup) em paralelo
- T004-T008 (modelos de domínio, Fase 2) em paralelo entre si
- T014 (US1), T021 (US2) e T026 (US3) podem começar em paralelo por desenvolvedores diferentes assim que a Fase 2 terminar, já que tocam arquivos de widget distintos — a integração final em `map_screen.dart` (T017, T023, T028) precisa ser sequenciada por depender do mesmo arquivo
- T020, T025, T030 (testes de widget de cada história) em paralelo entre si, uma vez que cada história esteja implementada
- T031, T032, T034, T036, T038 (Polish) em paralelo — T037 depende da seção 6 de `quickstart.md` estar validada manualmente antes

---

## Parallel Example: User Story 1

```bash
# Em paralelo, após a Fase 2 (Foundational) estar completa:
Task: "Criar CrowdLevelIndicator em frontend/lib/features/discovery/presentation/widgets/crowd_level_indicator.dart"
# (EventMarker depende de CrowdLevelIndicator, então roda em seguida, não em paralelo com ele)

# Em paralelo, após EventMarker e EventDetailPanel existirem, com testes de outras histórias:
Task: "Teste de widget discovery_map_test.dart (US1)"
Task: "Teste de widget discovery_search_test.dart (US2, se US2 já implementada)"
```

---

## Implementation Strategy

### MVP First (User Story 1 apenas)

1. Completar Fase 1: Setup
2. Completar Fase 2: Foundational (CRÍTICO — bloqueia todas as histórias)
3. Completar Fase 3: User Story 1
4. **PARAR e VALIDAR**: rodar o cenário 1 de `quickstart.md` de forma independente
5. Demonstrar/avaliar antes de seguir para US2/US3

### Incremental Delivery

1. Setup + Foundational → fundação pronta
2. US1 → validar independentemente → demo (MVP, mapa navegável com detalhes de evento)
3. US2 → validar independentemente → demo (busca)
4. US3 → validar independentemente → demo (filtros combináveis)
5. Cada história agrega valor sem quebrar as anteriores

### Parallel Team Strategy

Com mais de um desenvolvedor:

1. Time completa Setup + Foundational em conjunto (é a base de tudo — o `MapScreen`/`DiscoveryCubit` compartilhado)
2. Após a Fundação:
   - Dev A: User Story 1 (marcadores + painel de detalhes)
   - Dev B: User Story 3 (filtros) — independente de US1/US2 na lógica, mas precisa coordenar edição de `map_screen.dart` com Dev A
   - User Story 2 (busca) é natural de sequenciar logo após US1, pois reaproveita `selectMarker`
3. Coordenar merges em `map_screen.dart` e `discovery_cubit.dart`, que são tocados por todas as histórias

---

## Notes

- [P] = arquivos diferentes, sem dependências pendentes entre si
- [Story] mapeia a tarefa à user story correspondente para rastreabilidade
- `map_screen.dart` e `discovery_cubit.dart` são tocados por múltiplas histórias — coordenar para evitar conflitos de merge
- Fazer commit após cada tarefa ou grupo lógico de tarefas
- Parar em qualquer checkpoint para validar a história isoladamente antes de seguir
- Evitar: tarefas vagas, conflitos no mesmo arquivo sem necessidade, dependências entre histórias que quebrem a independência
