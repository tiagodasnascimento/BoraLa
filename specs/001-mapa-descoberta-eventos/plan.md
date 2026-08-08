# Implementation Plan: Mapa Interativo de Descoberta de Eventos

**Branch**: `001-mapa-descoberta-eventos` | **Date**: 2026-08-07 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-mapa-descoberta-eventos/spec.md`

## Summary

Transformar a tela inicial do app Flutter `BoraLá` (hoje uma lista/busca genérica) em uma experiência de mapa interativo como elemento central, com marcadores customizados por local/evento, painel de detalhes sobreposto (sem sair do mapa), busca, filtros combináveis (incluindo gênero musical) e indicador visual de nível de movimento — seguindo a hierarquia e estrutura do mockup desenhado à mão fornecido, com layout responsivo entre mobile (bottom sheet) e desktop (painel lateral). Abordagem técnica: `flutter_map` com marcadores como widgets Flutter nativos (não bitmaps) para permitir customização e estados de interação ricos, `geolocator` para localização do usuário, `flutter_map_marker_cluster` para densidade de marcadores, e `flutter_bloc` (já dependência do projeto) para o estado de descoberta/filtros/busca — ver `research.md` para o detalhamento das decisões.

## Technical Context

**Language/Version**: Dart / Flutter SDK `>=3.3.0 <4.0.0` (conforme `frontend/pubspec.yaml`)

**Primary Dependencies**: `flutter_bloc` e `get_it` (já no projeto); novas: `flutter_map`, `flutter_map_marker_cluster`, `latlong2`, `geolocator` (ver `research.md`)

**Storage**: N/A — dados servidos por repositórios mockados em memória nesta feature (sem persistência local nem integração com o backend Elixir; ver Assumptions em `spec.md`)

**Testing**: `flutter_test` (testes de widget/unit), seguindo o padrão já existente em `frontend/test/` (`search_test.dart`, `favorites_test.dart`, `auth_test.dart`, `notifications_test.dart`)

**Target Platform**: multiplataforma Flutter (Android/iOS como alvo principal mobile; Web/desktop — já escaldados no repo — usados para validar o layout responsivo desktop exigido pela spec)

**Project Type**: mobile-app (Flutter único codebase, já estruturado por feature em `frontend/lib/features/*/{data,domain,presentation}`)

**Performance Goals**: interações de pan/zoom do mapa e seleção de marcador fluidas (~60fps); abertura do painel de detalhes perceptível como instantânea (≤ ~300ms de transição), alinhado a SC-001/SC-002

**Constraints**: sem chamadas de rede reais nesta feature (dados mockados); UI deve permanecer utilizável sem permissão de localização (FR-017); painel de detalhes nunca pode ocultar totalmente o mapa (FR-004/FR-014)

**Scale/Scope**: 1 tela principal (mapa) compondo ~4 novos widgets de UI (marcador customizado, painel de detalhes, barra de busca, painel de filtros) + extensão de 2 modelos de domínio existentes (`EventItem`, `VenueTrafficStatus`) + 1 novo modelo (`Venue`); dezenas de marcadores simultâneos em cena com clustering

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

`.specify/memory/constitution.md` ainda está no template inicial (placeholders `[PRINCIPLE_1_NAME]` etc., não ratificado) — não há princípios concretos registrados para este projeto no momento. Portanto este gate não tem critérios formais para verificar e é tratado como **não bloqueante** para esta feature. Nenhuma violação a registrar em Complexity Tracking.

Se o time quiser princípios de arquitetura/qualidade obrigatórios (ex.: cobertura de testes mínima, camadas obrigatórias), recomenda-se rodar `/speckit-constitution` antes de `/speckit-tasks`; isso não bloqueia o avanço deste plano.

**Re-check pós Fase 1**: sem mudanças — constitution segue não ratificada; nenhuma nova violação introduzida pelo design em `data-model.md`/`contracts/`.

## Project Structure

### Documentation (this feature)

```text
specs/001-mapa-descoberta-eventos/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
│   └── discovery-repository.md
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

O repositório já é um monorepo `frontend/` (Flutter) + `backend/` (Elixir, fora do escopo desta feature). O `frontend/` já segue uma estrutura por feature (`data/domain/presentation`); esta feature estende esse padrão em vez de introduzir um novo.

```text
frontend/
├── lib/
│   ├── app.dart                          # MaterialApp — HomeScreen passa a renderizar MapScreen
│   ├── main.dart
│   ├── core/
│   │   └── di/service_locator.dart       # registro dos repositórios via get_it
│   └── features/
│       ├── discovery/                    # NOVA feature: composição do mapa
│       │   ├── data/
│       │   │   └── venue_repository.dart        # implementa contrato em contracts/discovery-repository.md
│       │   ├── domain/
│       │   │   ├── venue.dart
│       │   │   ├── filter_criteria.dart
│       │   │   └── map_marker_view_model.dart
│       │   └── presentation/
│       │       ├── map_screen.dart              # tela raiz — responsiva mobile/desktop
│       │       ├── cubit/discovery_cubit.dart    # flutter_bloc: estado combinado de mapa+filtro+busca
│       │       └── widgets/
│       │           ├── event_marker.dart          # marcador customizado + estados (selecionado/relevante)
│       │           ├── event_detail_panel.dart     # bottom sheet (mobile) / painel lateral (desktop)
│       │           ├── discovery_search_bar.dart
│       │           ├── filter_panel.dart
│       │           └── crowd_level_indicator.dart  # indicador visual (não textual) de lotação
│       ├── events/                       # EXISTENTE — domain/event.dart estendido com venueId + genre
│       ├── search/                       # EXISTENTE — search_repository.dart estendido p/ considerar gênero
│       ├── traffic/                      # EXISTENTE — venue_status.dart reaproveitado como base de VenueTrafficStatus
│       ├── favorites/                    # EXISTENTE — fora de escopo desta feature
│       ├── notifications/                # EXISTENTE — fora de escopo desta feature
│       └── auth/                         # EXISTENTE — fora de escopo desta feature
└── test/
    ├── discovery_map_test.dart           # NOVO — seleção de marcador → painel de detalhes
    ├── discovery_search_test.dart        # NOVO — busca com/sem resultado dentro do fluxo de mapa
    ├── discovery_filter_test.dart        # NOVO — combinação de filtros
    ├── search_test.dart                  # EXISTENTE
    ├── favorites_test.dart               # EXISTENTE
    ├── notifications_test.dart           # EXISTENTE
    └── auth_test.dart                    # EXISTENTE
```

**Structure Decision**: reaproveitar o monorepo Flutter existente (`frontend/`) e seu padrão por feature. Cria-se a feature `discovery` para a composição do mapa/busca/filtro/painel (o elemento novo e central desta spec), e estende-se os modelos de domínio já existentes em `events`, `search` e `traffic` em vez de duplicá-los — mantendo uma única fonte de verdade para `EventItem` e `VenueTrafficStatus`. O backend Elixir (`backend/`) não é tocado por esta feature.

## Complexity Tracking

*Sem violações do Constitution Check a justificar — a constitution do projeto ainda não foi ratificada (ver seção acima), portanto não há gates formais a violar.*
