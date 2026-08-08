# Quickstart: Mapa Interativo de Descoberta de Eventos

**Input**: [spec.md](./spec.md) · [data-model.md](./data-model.md) · [contracts/discovery-repository.md](./contracts/discovery-repository.md)

Guia para rodar e validar manualmente esta feature de ponta a ponta após a implementação.

## Pré-requisitos

- Flutter SDK compatível com `>=3.3.0 <4.0.0` (ver `frontend/pubspec.yaml`)
- Dependências novas adicionadas ao `pubspec.yaml`: `flutter_map`, `flutter_map_marker_cluster`, `latlong2`, `geolocator`

## Setup

```bash
cd frontend
flutter pub get
```

## Rodar

```bash
# Mobile (emulador/dispositivo conectado)
flutter run

# Web (útil para validar o layout desktop/responsivo rapidamente)
flutter run -d chrome
```

## Cenários de validação (mapeados às User Stories da spec)

### 1. Explorar eventos no mapa (US1 / P1)

1. Abra o app — o mapa deve carregar como tela inicial (não uma lista).
2. Confirme que locais com eventos aparecem como marcadores customizados (não o pino padrão do mapa).
3. Toque em um marcador → um painel de detalhes deve aparecer com: nome do local, nome do evento, gênero, data/horário e nível de movimento — **o mapa deve permanecer visível e navegável** por trás/ao lado do painel.
4. Confirme visualmente que o nível de movimento é comunicado por cor/ícone, não apenas texto.
5. Toque em outro marcador → o painel atualiza sem reload de tela.

**Aceite**: comportamento bate com Acceptance Scenarios 1–3 da User Story 1 em `spec.md`.

### 2. Buscar um evento/local (US2 / P2)

1. Digite parte do nome de um evento/local existente (ex.: "Jazz") no campo de busca.
2. Confirme que resultados aparecem conforme digita.
3. Selecione um resultado → o mapa deve centralizar no local e abrir automaticamente o painel de detalhes.
4. Digite um termo sem correspondência → confirme mensagem clara de "nenhum resultado encontrado".

**Aceite**: bate com Acceptance Scenarios 1–3 da User Story 2.

### 3. Filtrar por gênero e combinar filtros (US3 / P3)

1. Abra o painel de filtros e selecione um gênero musical.
2. Confirme que apenas marcadores compatíveis permanecem visíveis.
3. Adicione um segundo critério de filtro (ex.: nível de movimento) → confirme que o resultado é a interseção dos dois critérios.
4. Limpe os filtros → todos os eventos voltam a aparecer.
5. Combine filtros de forma que não haja resultado → confirme mensagem clara de "nenhum evento para os critérios selecionados" (sem tela vazia sem explicação).

**Aceite**: bate com Acceptance Scenarios 1–4 da User Story 3.

### 4. Responsividade

1. Rode em `flutter run -d chrome` e redimensione a janela do navegador (ou use as ferramentas de dispositivo do DevTools) entre uma largura "mobile" (< ~600px) e "desktop" (> ~900px).
2. Em largura mobile: confirme que busca/filtro não ocupam permanentemente espaço vertical relevante e que o painel de detalhes aparece como bottom sheet retrátil sobre o mapa.
3. Em largura desktop: confirme que busca/filtro/painel de detalhes aparecem como painel lateral, sem cobrir o mapa por completo.

**Aceite**: bate com FR-013/FR-014 e SC-005.

### 5. Localização negada

1. Negue a permissão de localização quando solicitado (ou simule no emulador).
2. Confirme que o mapa ainda carrega, centralizado em uma região padrão, sem travar o app.

**Aceite**: bate com FR-017 e o edge case correspondente da spec.

### 6. Alta densidade de marcadores (clustering)

1. Simule/posicione múltiplos venues próximos entre si (mesma área do mapa) nos dados mockados.
2. Dê zoom out até que os marcadores próximos se agrupem em cluster.
3. Confirme que o cluster é legível (sem sobreposição confusa) e que dar zoom in ou tocar no cluster expande os marcadores individuais.

**Aceite**: bate com FR-012 e SC-006.

## Testes automatizados

Seguir o padrão já usado em `frontend/test/` (`search_test.dart`, `favorites_test.dart`, etc.) para adicionar testes de widget cobrindo: seleção de marcador → painel de detalhes, busca com/sem resultado, combinação de filtros. Rodar com:

```bash
cd frontend
flutter test
```
