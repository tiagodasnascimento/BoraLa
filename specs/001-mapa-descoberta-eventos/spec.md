# Feature Specification: Mapa Interativo de Descoberta de Eventos

**Feature Branch**: `001-mapa-descoberta-eventos`

**Created**: 2026-08-07

**Status**: Draft

**Input**: User description: "Quero que o frontend seja desenvolvido seguindo fielmente a proposta visual do mockup desenhado à mão que estou fornecendo como referência. O objetivo é criar uma experiência moderna, elegante e visualmente marcante [...] A aplicação terá como principal elemento um mapa interativo, onde serão exibidos os locais que possuem eventos acontecendo [...] Funcionalidades principais: mapa interativo, marcadores personalizados, busca por eventos e locais, filtros combináveis (incluindo gênero musical), informações de cada evento (local, nome, gênero, data/horário, nível de movimento). UI premium, moderna, intuitiva, fluida, responsiva, com microinterações. Mapa como parte central da experiência, com marcadores de identidade visual própria, estados de seleção, diferentes níveis de zoom e densidade. Fluxo de leitura: onde é → o que está tocando → quando → quão movimentado. Responsivo em desktop e mobile, com bottom sheets/painéis no mobile. Não deve parecer um dashboard administrativo ou template genérico — deve parecer um produto real, seguindo a identidade visual do mockup fornecido."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Explorar eventos próximos no mapa (Priority: P1)

Como usuário que quer decidir onde sair agora, abro o aplicativo e vejo um mapa interativo centralizado na minha localização, com marcadores visualmente diferenciados indicando os locais que têm eventos acontecendo. Ao tocar em um marcador, vejo as informações essenciais do evento (local, nome, gênero musical, horário e nível de movimento) sem perder a visão do mapa.

**Why this priority**: É o núcleo de valor do produto — sem essa jornada, não existe experiência de descoberta. Todo o resto (busca, filtros) existe para refinar esta jornada central.

**Independent Test**: Pode ser testada abrindo o app diretamente na visão de mapa, tocando em qualquer marcador de evento e confirmando que um painel de detalhes surge com as informações exigidas, sem navegação para fora do mapa.

**Acceptance Scenarios**:

1. **Given** o usuário abre o aplicativo com localização disponível, **When** o mapa carrega, **Then** os locais com eventos ativos ou próximos são exibidos como marcadores visualmente distintos dos demais elementos do mapa.
2. **Given** o mapa está exibindo marcadores, **When** o usuário toca em um marcador, **Then** um painel de detalhes é exibido com nome do local, nome do evento, gênero musical, data/horário e nível de movimento, mantendo o mapa visível e navegável.
3. **Given** um painel de detalhes está aberto, **When** o usuário toca em outro marcador ou fora do painel, **Then** o painel atualiza ou se fecha de forma fluida, sem recarregar a tela.

---

### User Story 2 - Buscar um evento ou local específico (Priority: P2)

Como usuário que já sabe (ou tem ideia) do nome de um local ou evento, quero digitar uma busca e ser levado diretamente até ele no mapa, sem precisar explorar manualmente.

**Why this priority**: Complementa a exploração livre (P1) para usuários com intenção específica, aumentando a eficiência de uso, mas o produto continua funcional sem ela.

**Independent Test**: Pode ser testada digitando o nome de um local/evento existente na busca e verificando que o mapa centraliza e destaca o marcador correspondente.

**Acceptance Scenarios**:

1. **Given** o usuário digita um termo de busca, **When** existem locais/eventos correspondentes, **Then** uma lista de resultados relevantes é exibida em tempo real conforme a digitação.
2. **Given** uma lista de resultados de busca, **When** o usuário seleciona um resultado, **Then** o mapa centraliza no local correspondente e o painel de detalhes daquele evento é exibido automaticamente.
3. **Given** o usuário digita um termo sem correspondência, **When** a busca é executada, **Then** o sistema informa de forma clara que nenhum resultado foi encontrado.

---

### User Story 3 - Filtrar eventos por gênero musical e outros critérios (Priority: P3)

Como usuário com preferências específicas, quero aplicar filtros (por exemplo, gênero musical) para reduzir a quantidade de eventos exibidos apenas aos que me interessam, podendo combinar mais de um filtro ao mesmo tempo.

**Why this priority**: Refina a descoberta para usuários com critérios claros; é valioso mas depende da existência do mapa (P1) para fazer sentido.

**Independent Test**: Pode ser testada aplicando um filtro de gênero musical e confirmando que apenas os marcadores compatíveis permanecem visíveis no mapa; em seguida, aplicando um segundo filtro e confirmando que o resultado é a interseção de ambos.

**Acceptance Scenarios**:

1. **Given** o usuário abre o painel de filtros, **When** seleciona um ou mais gêneros musicais, **Then** o mapa passa a exibir apenas os marcadores de eventos compatíveis com os gêneros selecionados.
2. **Given** um filtro de gênero já aplicado, **When** o usuário adiciona um segundo critério de filtro, **Then** o mapa exibe apenas os eventos que atendem a todos os critérios combinados simultaneamente.
3. **Given** filtros aplicados, **When** o usuário limpa os filtros, **Then** todos os eventos disponíveis voltam a ser exibidos no mapa.
4. **Given** uma combinação de filtros sem nenhum evento correspondente, **When** os filtros são aplicados, **Then** o sistema informa de forma clara que não há eventos para os critérios selecionados, sem deixar a tela vazia sem explicação.

---

### Edge Cases

- O que acontece quando o usuário nega a permissão de localização? O mapa deve continuar funcional, centralizado em uma região padrão, em vez de bloquear o uso do app.
- Como o sistema se comporta em áreas com alta densidade de eventos próximos (muitos marcadores sobrepostos em um mesmo ponto do mapa)?
- O que acontece quando não há nenhum evento próximo à localização atual do usuário?
- Como o sistema exibe um local que possui mais de um evento acontecendo ao mesmo tempo?
- O que acontece quando o usuário está usando uma tela muito pequena e o painel de detalhes precisa coexistir com o mapa e a busca/filtros?
- Como o sistema trata um evento que já terminou ou está prestes a começar (transição de estado de "próximo" para "acontecendo agora")?
- O que acontece se a busca ou os filtros forem usados enquanto o mapa ainda está carregando os dados iniciais?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O sistema MUST exibir um mapa interativo como elemento central e principal da aplicação.
- **FR-002**: O sistema MUST exibir cada local com evento ativo ou próximo como um marcador visualmente personalizado e distinto de elementos genéricos de mapa.
- **FR-003**: Os marcadores MUST comunicar visualmente, sem depender apenas de texto, quando um local está selecionado e quando possui maior relevância (por exemplo, maior nível de movimento).
- **FR-004**: Os usuários MUST poder selecionar um marcador para visualizar informações detalhadas do evento sem perder o contexto do mapa (sem navegação para uma tela separada que oculte o mapa).
- **FR-005**: As informações detalhadas de um evento selecionado MUST incluir, no mínimo: nome do local, nome do evento, gênero/estilo musical, data e horário, e nível de movimento/lotação atual.
- **FR-006**: O nível de movimento/lotação MUST ser representado com pelo menos três estados (ex.: tranquilo, movimentado, muito movimentado) e MUST ser distinguível visualmente (cor, ícone ou forma), não apenas por texto.
- **FR-007**: Os usuários MUST poder buscar eventos e locais por nome ou palavra-chave.
- **FR-008**: Ao selecionar um resultado de busca, o sistema MUST posicionar o mapa no local correspondente e exibir suas informações.
- **FR-009**: Os usuários MUST poder filtrar os eventos exibidos, incluindo, no mínimo, filtro por gênero/estilo musical.
- **FR-010**: Os usuários MUST poder combinar múltiplos filtros simultaneamente, e o mapa MUST refletir a interseção de todos os critérios ativos.
- **FR-011**: O sistema MUST indicar a localização atual do usuário no mapa de forma visualmente distinta dos marcadores de eventos.
- **FR-012**: O sistema MUST suportar diferentes níveis de zoom e MUST manter o mapa legível e utilizável em cenários de alta densidade de marcadores (ex.: agrupamento visual de marcadores próximos).
- **FR-013**: A aplicação MUST oferecer uma experiência totalmente utilizável tanto em telas desktop quanto em dispositivos móveis.
- **FR-014**: Em telas estreitas (mobile), os controles de busca e filtro MUST NOT obstruir permanentemente o mapa, e os detalhes do evento MUST ser exibidos por meio de um painel retrátil/deslizante que preserve o acesso ao mapa.
- **FR-015**: O sistema MUST fornecer feedback visual claro para estados de interação (ativo, selecionado, hover, desabilitado) em marcadores, busca e filtros.
- **FR-016**: O sistema MUST informar o usuário de forma clara quando uma busca ou combinação de filtros não retornar nenhum evento.
- **FR-017**: O sistema MUST permanecer utilizável mesmo quando o usuário nega o acesso à sua localização, oferecendo uma visão padrão do mapa.

### Key Entities

- **Local (Venue)**: representa um estabelecimento (bar, restaurante etc.) exibido no mapa; possui nome, posição geográfica e nível de movimento/lotação atual.
- **Evento**: representa uma ocorrência associada a um Local; possui nome, gênero/estilo musical, data e horário, e está sempre vinculado a um Local.
- **Localização do Usuário**: posição atual do usuário no mapa, usada apenas para orientação visual durante a sessão.
- **Filtro**: critério selecionável pelo usuário (ex.: gênero musical) que pode ser combinado com outros critérios para restringir os eventos exibidos.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Usuários conseguem identificar e selecionar um evento próximo no mapa em até 5 segundos após abrir o aplicativo.
- **SC-002**: Após tocar em um marcador, o usuário consegue visualizar local, nome do evento, gênero, horário e nível de movimento em até 2 segundos, sem sair da tela de mapa.
- **SC-003**: Em teste de usabilidade, pelo menos 90% dos usuários conseguem identificar corretamente o nível de movimento de um local (tranquilo/movimentado/muito movimentado) usando apenas o indicador visual, sem precisar ler texto.
- **SC-004**: Usuários conseguem reduzir a lista de eventos visíveis combinando pelo menos dois filtros em menos de 15 segundos.
- **SC-005**: O mapa, a busca e os filtros permanecem totalmente funcionais e sem sobreposição indevida de elementos em tamanhos de tela desktop e mobile.
- **SC-006**: Em cenários de alta densidade de eventos, os usuários conseguem distinguir marcadores individuais/agrupamentos e acessar detalhes sem confusão visual, validado em revisão de usabilidade dedicada a esse cenário.
- **SC-007**: Em avaliação qualitativa comparando a interface final ao mockup de referência, a experiência é percebida como um produto com identidade visual própria — não como um dashboard administrativo ou template genérico.

## Assumptions

- Os dados de locais e eventos (criação, cadastro e atualização) são fornecidos por um serviço/fonte já existente ou a ser especificado separadamente; esta especificação cobre apenas a experiência de descoberta/consulta pelo usuário final.
- O nível de movimento/lotação é fornecido como um dado já calculado por local no momento da consulta; o mecanismo de atualização em tempo real está fora do escopo desta especificação.
- A busca considera nome do local, nome do evento e gênero/estilo musical como critérios de correspondência.
- Não é necessária uma visão em lista dedicada — o mapa com painel de detalhes sobreposto é a interface primária, conforme o mockup de referência fornecido.
- O mockup desenhado à mão (busca no topo, filtro no canto superior, marcador de localização do usuário, marcadores de local com indicador de pessoas/lotação, callout de informações do local) define a estrutura e hierarquia base a serem refinadas em uma UI profissional, mantendo a essência do layout.
- Usuários podem navegar e descobrir eventos sem necessidade de login/conta; autenticação, caso necessária, é tratada como funcionalidade separada.
- Fora do escopo desta especificação: cadastro/gestão de eventos por donos de estabelecimento, contas de usuário, avaliações/reviews, ingressos/pagamentos e recursos sociais.
