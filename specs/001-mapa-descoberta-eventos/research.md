# Research: Mapa Interativo de Descoberta de Eventos

**Input**: [spec.md](./spec.md) · **Feature**: `001-mapa-descoberta-eventos`

Este documento resolve as incógnitas técnicas necessárias para transformar os requisitos da spec em uma implementação Flutter, dado que o projeto já existe em `frontend/` com uma estrutura por feature (`data/domain/presentation`) e dependências iniciais (`flutter_bloc`, `get_it`, `equatable`) ainda não utilizadas em código real.

## 1. Motor de mapa (map rendering)

**Decision**: `flutter_map` (baseado em OpenStreetMap/tiles vetoriais ou raster via `flutter_map` + provedor de tiles) para os marcadores e camada de mapa, com marcadores implementados como **widgets Flutter nativos** (não bitmaps).

**Rationale**: O requisito central da spec é que os marcadores tenham "identidade visual própria", estados de seleção, indicador de lotação não-textual e microinterações (FR-003, FR-006, FR-015). Isso exige marcadores compostos por widgets Flutter completos (ícones, badges, animações de estado), não apenas ícones estáticos. `flutter_map` permite que cada `Marker` seja um `Widget` Flutter comum, reconstruído normalmente pela árvore de widgets — o que viabiliza `AnimatedContainer`/`AnimatedScale` por marcador sem custo de rasterização. Também não exige chave de API paga nem tela de billing para prototipagem (diferente do Google Maps), o que reduz atrito para um projeto acadêmico/MVP.

**Alternatives considered**:
- `google_maps_flutter`: mapa de altíssima qualidade e familiar aos usuários, mas customização de marcadores exige converter widgets em `BitmapDescriptor` (captura de imagem), o que dificulta estados dinâmicos (seleção, animação, hover em web/desktop) e adiciona complexidade desnecessária para o nível de customização exigido.
- `mapbox_maps_flutter`: estilos de mapa muito customizáveis nativamente, mas exige conta/token Mapbox, tem footprint maior e curva de aprendizado maior para o ganho necessário aqui (a customização pedida é nos marcadores/UI sobreposta, não no estilo do tile em si).

## 2. Localização do usuário ("EU" no mockup)

**Decision**: pacote `geolocator` para obter/observar a posição do usuário e checar/solicitar permissão, com fallback explícito para uma região padrão quando a permissão é negada (cobrindo FR-017 e o edge case correspondente).

**Rationale**: É o pacote padrão de facto no ecossistema Flutter para geolocalização multiplataforma (Android/iOS/Web/Desktop), com API de permissão explícita que mapeia diretamente para o fluxo "solicitar → conceder/negar → fallback" exigido pela spec.

**Alternatives considered**: implementar canais de plataforma customizados — descartado por reinventar algo já resolvido de forma madura pela dependência padrão.

## 3. Agrupamento de marcadores em alta densidade (clustering)

**Decision**: agrupamento de marcadores (clustering) via `flutter_map_marker_cluster`, plugin oficial do ecossistema `flutter_map`, com transição animada ao expandir/contrair clusters.

**Rationale**: FR-012 exige que o mapa permaneça legível em cenários de alta densidade de eventos em diferentes zooms. Implementar clustering manual (particionamento espacial + hit-testing) duplicaria uma solução já madura e testada dentro do mesmo ecossistema escolhido no item 1, mantendo consistência de integração.

**Alternatives considered**: exibir todos os marcadores sempre e apenas reduzir escala visual — rejeitado por não resolver sobreposição/ilegibilidade em zoom out com muitos eventos próximos (edge case explícito da spec).

## 4. Gerenciamento de estado (mapa, busca, filtros)

**Decision**: `flutter_bloc` (já presente no `pubspec.yaml`) com um `Cubit`/`Bloc` por área de estado compartilhado (ex.: `DiscoveryCubit` combinando eventos visíveis + filtros ativos + termo de busca + marcador selecionado), seguindo o padrão `data/domain/presentation` já usado nas demais features do projeto (`auth`, `events`, `search`, `traffic`, `favorites`, `notifications`).

**Rationale**: Mantém consistência com a arquitetura já iniciada no repositório e evita introduzir uma segunda biblioteca de state management. `Cubit` é suficiente aqui pois as transições de estado (busca digitada, filtro alternado, marcador selecionado) são simples eventos síncronos/assíncronos sem necessidade de streams de eventos complexos.

**Alternatives considered**: `Provider`/`Riverpod` — descartados por já existir `flutter_bloc` como dependência não utilizada; introduzir uma segunda abordagem de estado aumentaria a complexidade sem benefício.

## 5. Microinterações e transições (painel de detalhes, estados de marcador)

**Decision**: usar as animações implícitas nativas do Flutter (`AnimatedContainer`, `AnimatedScale`, `AnimatedSwitcher`, `AnimatedPositioned`, `Hero` para a transição marcador → painel de detalhes) e `DraggableScrollableSheet`/`showModalBottomSheet` customizado para o painel de detalhes/filtros no mobile.

**Rationale**: Os requisitos de microinteração (FR-015, SC-002) são bem atendidos pelas animações implícitas do SDK, sem necessidade de uma dependência de animação adicional. Isso mantém o bundle enxuto e reduz superfície de manutenção, priorizando qualidade de composição sobre quantidade de dependências — alinhado à diretriz de UI "com personalidade própria" via composição customizada, não plugins prontos.

**Alternatives considered**: pacotes como `flutter_animate` — trazem conveniência de sintaxe, mas não são necessários para o conjunto de animações exigido; podem ser adotados depois se a complexidade de orquestração aumentar.

## 6. Layout responsivo (desktop vs. mobile)

**Decision**: um único `MapScreen` com composição condicional por breakpoint (via `LayoutBuilder`/`MediaQuery`): em telas largas (desktop/tablet), busca e filtros aparecem como painel lateral fixo sobre o mapa; em telas estreitas (mobile), busca/filtro ficam como barra compacta sobreposta ao mapa e o painel de detalhes/filtros usa `DraggableScrollableSheet` (bottom sheet retrátil), conforme FR-014.

**Rationale**: Atende ao requisito explícito de que, no mobile, os controles não podem obstruir permanentemente o mapa, reaproveitando a mesma árvore de widgets e apenas recompondo o layout — evita duas implementações paralelas de tela.

**Alternatives considered**: telas completamente separadas para mobile e desktop — rejeitado por duplicar lógica de estado/composição sem necessidade, já que a diferença é primariamente de disposição espacial, não de funcionalidade.

## 7. Origem dos dados (venues/eventos) para esta feature

**Decision**: manter os dados mockados em repositórios locais (seguindo o padrão já existente em `EventRepositoryImpl`, `SearchRepository`, `TrafficRepository`), estendendo os modelos de domínio para incluir coordenadas geográficas (`latitude`/`longitude`) e gênero musical no `Venue`/`EventItem`, sem integração com o backend Elixir nesta feature.

**Rationale**: Consistente com a suposição documentada na spec ("dados de locais e eventos são fornecidos por um serviço já existente ou a ser especificado separadamente"; integração com backend está fora de escopo). Isso permite validar toda a experiência de UI/UX do mapa de forma independente, sem bloquear no desenvolvimento paralelo da API.

**Alternatives considered**: integrar diretamente com o backend Elixir agora — rejeitado por expandir o escopo desta feature para além do que a spec define (a spec é sobre a experiência de descoberta no frontend).

## Resumo das decisões

| Área | Decisão |
|---|---|
| Mapa | `flutter_map` com marcadores como widgets Flutter customizados |
| Localização do usuário | `geolocator` com fallback para região padrão |
| Clustering | `flutter_map_marker_cluster` |
| Estado | `flutter_bloc` (Cubit por área: descoberta/mapa, busca, filtros) |
| Microinterações | Animações implícitas nativas do Flutter + bottom sheet customizado |
| Responsividade | Um único `MapScreen` com composição condicional por breakpoint |
| Dados | Repositórios mockados locais, estendidos com coordenadas e gênero musical |

Nenhuma incógnita [NEEDS CLARIFICATION] permanece em aberto.
