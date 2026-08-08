# Contract: Repositórios de Descoberta (Venue/Event)

Esta feature é um app Flutter cliente-somente-de-mock nesta fase (sem API externa real — ver `research.md` §7). O "contrato" relevante é a **interface Dart** entre a camada de apresentação (`presentation/`) e a camada de dados (`data/`), que qualquer implementação futura (mock atual ou API real do backend Elixir) deve cumprir.

## `VenueRepository`

```dart
abstract class VenueRepository {
  /// Retorna todos os locais visíveis na região atual do mapa.
  Future<List<Venue>> fetchVenues({required LatLngBounds visibleBounds});

  /// Retorna um único local pelo id (usado ao abrir o painel de detalhes).
  Future<Venue?> fetchVenueById(String id);
}
```

**Pré-condições**: `visibleBounds` é uma área geográfica válida (min <= max em cada eixo).
**Pós-condições**: lista pode ser vazia (nenhum local na área); nunca lança exceção para "sem resultados" — apenas para falhas reais de obtenção de dados.

## `EventRepository` (extensão do existente)

```dart
abstract class EventRepository {
  /// Eventos ativos ou futuros dentro da janela de tempo relevante (ex.: hoje).
  Future<List<EventItem>> fetchEventsByVenue(String venueId);

  Future<List<EventItem>> fetchFeaturedEvents(); // já existe hoje
}
```

**Pós-condições**: eventos retornados sempre pertencem ao `venueId` informado; eventos com `endAt` no passado não são retornados por padrão.

## `SearchRepository` (já existente, contrato mantido)

```dart
abstract class SearchRepository {
  Future<List<SearchResult>> searchEvents(String query);
}
```

**Pós-condições**: string vazia retorna todos os resultados disponíveis (comportamento já implementado); busca é case-insensitive e por substring no nome (comportamento já implementado, a estender para também considerar gênero musical — FR-007).

## `TrafficRepository` (já existente, contrato mantido)

```dart
abstract class TrafficRepository {
  Future<VenueTraffic> fetchVenueStatus(String venueId);
}
```

## Contrato de UI: seleção de marcador → painel de detalhes

Não há uma "API" nesse fluxo, mas há um contrato de comportamento observável (testável via widget tests) exigido pela spec:

1. **Input**: usuário toca em um marcador com `venueId = X`.
2. **Output esperado**: um painel de detalhes é exibido (bottom sheet no mobile / painel lateral no desktop) contendo nome do local, nome do evento, gênero, data/horário e nível de movimento — sem que o `MapScreen` subjacente seja removido da árvore de widgets (o mapa permanece interativo/visível).
3. **Erro**: se `fetchVenueById(X)` falhar ou retornar `null`, o painel exibe um estado de erro amigável e permite fechar sem travar a navegação do mapa.

Este contrato de comportamento deve ser coberto por testes de widget equivalentes aos já existentes em `frontend/test/` (`search_test.dart`, `favorites_test.dart` etc.).
