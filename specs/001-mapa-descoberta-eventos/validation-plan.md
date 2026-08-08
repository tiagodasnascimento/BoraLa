# Plano de Validação Qualitativa

**Feature**: `001-mapa-descoberta-eventos` · **Criado**: 2026-08-08

Os critérios SC-003, SC-006 e SC-007 de [spec.md](./spec.md) dependem de avaliação com pessoas, não de asserção automatizada. As tarefas T036/T037/T038 de [tasks.md](./tasks.md) ficam **abertas** até que estas sessões sejam conduzidas — a implementação está pronta para serem executadas.

## T036 — SC-003: nível de movimento compreendido só pelo visual

**Meta**: ≥90% dos participantes identificam corretamente o nível de movimento de um local usando apenas o indicador visual, sem ler texto.

**Como conduzir**:
1. Recrutar 10 participantes que não conheçam o produto.
2. Apresentar o mapa com marcadores, **sem** abrir o painel de detalhes (nos marcadores o indicador aparece sem rótulo textual).
3. Apontar 3 marcadores, um de cada nível, e pedir: "qual desses lugares está mais cheio? E o mais vazio?".
4. Registrar acertos por nível.

**O que está implementado para suportar isso**: `CrowdLevelIndicator` codifica o nível em **cor + número de barras preenchidas** (1 barra verde = tranquilo, 2 laranja = movimentado, 3 vermelho = muito movimentado), redundância que não depende só de cor — importante para daltonismo. O rótulo textual só aparece no painel de detalhes e nos filtros (`showLabel: true`).

**Critério de falha**: se <90% acertarem, o passo seguinte é aumentar o contraste entre níveis (ex.: variar também a forma/altura das barras, não só a cor).

## T037 — SC-006: legibilidade em alta densidade de marcadores

**Meta**: usuários distinguem marcadores individuais e agrupamentos e acessam detalhes sem confusão visual.

**Como conduzir**: seguir o cenário 6 de [quickstart.md](./quickstart.md).

**O que está implementado**: `VenueRepositoryImpl` posiciona 4 dos 8 venues de exemplo a poucos metros uns dos outros exatamente para exercitar esse caso. O agrupamento usa `flutter_map_marker_cluster` com `maxClusterRadius: 48`, e o cluster é renderizado como um badge circular roxo com a contagem (`_ClusterBadge`) — visualmente distinto dos marcadores individuais.

**Status de verificação manual**: o agrupamento foi confirmado funcionando no emulador Android (badge "4" aparece sobre o grupo denso, marcadores individuais permanecem legíveis ao redor). Falta a rodada com usuários reais.

## T038 — SC-007: identidade visual própria vs. mockup

**Meta**: a interface é percebida como um produto real de descoberta de eventos, não como dashboard administrativo ou template genérico.

**Como conduzir**: revisão de design lado a lado com o mockup desenhado à mão, com pelo menos uma pessoa que não participou da implementação.

**Correspondência com o mockup** (verificada no emulador):

| Elemento do mockup | Implementado como |
|---|---|
| "BUSCA" — barra arredondada no topo com lupa | `DiscoverySearchBar` — pill flutuante sobre o mapa, com sombra e resultados em painel próprio |
| "FILTRO" — ícone no canto superior direito | `_FilterButton` circular, que muda para roxo sólido quando há filtro ativo |
| "EU" — pino da localização do usuário | `_UserLocationMarker` — ponto azul com halo, visualmente distinto dos marcadores de local |
| "LOCAL" — balão com ícone de pessoas indicando lotação | `EventMarker` — balão com cauda desenhada em `CustomPaint`, ícone de grupo + barras de lotação |
| Mapa ocupando a tela inteira | `FlutterMap` em `Stack(fit: StackFit.expand)`, com busca/filtros sobrepostos |

**Decisões que refinam o conceito** (além do desenho): estados de seleção animados nos marcadores, agrupamento em alta densidade, painel de detalhes como bottom sheet arrastável no mobile e painel lateral no desktop, chips de filtro próprios (`SelectableChip`) em vez dos componentes Material crus.

**Critério de falha**: se a revisão apontar "cara de template", os pontos de ataque prioritários são tipografia (hoje usa a fonte padrão do sistema) e a paleta (hoje derivada de um único seed roxo via `ColorScheme.fromSeed`).
