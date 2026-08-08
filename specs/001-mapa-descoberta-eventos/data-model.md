# Data Model: Mapa Interativo de Descoberta de Eventos

**Input**: [spec.md](./spec.md) Key Entities · [research.md](./research.md)

Modelos de domínio (camada `domain/`) usados pela UI de descoberta. Não há persistência local nesta feature — os dados vêm de repositórios (hoje mockados; ver `research.md` §7).

## Venue (Local)

Representa um estabelecimento exibido no mapa.

| Campo | Tipo | Regras |
|---|---|---|
| `id` | `String` | obrigatório, único |
| `name` | `String` | obrigatório, não vazio |
| `latitude` | `double` | obrigatório, -90..90 |
| `longitude` | `double` | obrigatório, -180..180 |
| `trafficStatus` | `VenueTrafficStatus` (enum: `low`, `medium`, `high`, `crowded`) | obrigatório — mapeia para os 3 níveis exigidos pela FR-006 (`low`→tranquilo, `medium`/`high`→movimentado, `crowded`→muito movimentado) |
| `isFeatured` | `bool` | opcional, default `false` — usado para destacar relevância do marcador (FR-003) |

**Relacionamentos**: um `Venue` possui 0..N `Event` ativos/futuros no período consultado.

*Nota*: `VenueTrafficStatus` já existe em `features/traffic/domain/venue_status.dart`; será reaproveitado/estendido, não recriado.

## Event (Evento)

Representa uma ocorrência associada a um `Venue`.

| Campo | Tipo | Regras |
|---|---|---|
| `id` | `String` | obrigatório, único |
| `venueId` | `String` | obrigatório, referencia `Venue.id` |
| `name` | `String` | obrigatório, não vazio |
| `genre` | `String` | obrigatório — usado no filtro por gênero musical (FR-009) |
| `startAt` | `DateTime` | obrigatório |
| `endAt` | `DateTime` | obrigatório, posterior a `startAt` |

**Regra de estado derivado**: um evento é "acontecendo agora" quando `startAt <= now < endAt`; "em breve" quando `startAt > now`. Eventos com `endAt <= now` não são exibidos como ativos (ver edge case da spec sobre transição de estado).

*Nota*: estende o `EventItem` já existente em `features/events/domain/event.dart` (que hoje usa `location: String` solto) — passa a referenciar `venueId` em vez de um texto livre, e ganha o campo `genre`.

## UserLocation (Localização do Usuário)

Representa a posição do usuário na sessão atual — não persistida, apenas em memória/estado da tela.

| Campo | Tipo | Regras |
|---|---|---|
| `latitude` | `double` | obrigatório quando permissão concedida |
| `longitude` | `double` | obrigatório quando permissão concedida |
| `isPermissionGranted` | `bool` | obrigatório |

**Regra**: quando `isPermissionGranted == false`, a UI usa uma região padrão pré-definida como centro do mapa (FR-017), e este objeto não é exibido como marcador "EU".

## FilterCriteria (Filtro)

Representa o estado combinado de filtros ativos.

| Campo | Tipo | Regras |
|---|---|---|
| `genres` | `Set<String>` | vazio = nenhum filtro de gênero ativo (todos os gêneros passam) |
| `trafficStatuses` | `Set<VenueTrafficStatus>` | vazio = nenhum filtro de lotação ativo |
| `dateRange` | `DateTimeRange?` | opcional; `null` = sem filtro de data |

**Regra de combinação**: um `Event`/`Venue` é exibido somente se atender a **todos** os grupos de filtro ativos simultaneamente (AND entre grupos); dentro do mesmo grupo (ex.: múltiplos gêneros selecionados), basta atender a **um** dos valores (OR dentro do grupo) — reflete FR-010.

## MapMarkerViewModel (estado de apresentação do marcador)

Modelo derivado (não é uma entidade de negócio, é view-state) que combina `Venue` + eventos ativos + estado de seleção para renderização do marcador.

| Campo | Tipo | Regras |
|---|---|---|
| `venue` | `Venue` | obrigatório |
| `activeEvents` | `List<Event>` | eventos do venue que passam pelo `FilterCriteria` atual |
| `isSelected` | `bool` | controla o estado visual de destaque do marcador (FR-003) |

## Diagrama de relacionamento

```
Venue (1) ──── (0..N) Event
  │
  └── trafficStatus: VenueTrafficStatus

FilterCriteria ──(filtra)──> Venue + Event ──(compõe)──> MapMarkerViewModel
UserLocation ──(centraliza)──> visão inicial do mapa
```
