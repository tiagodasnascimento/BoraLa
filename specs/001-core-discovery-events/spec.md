# Feature Specification: Descoberta de Eventos, Agenda Diária e Status de Movimentação

**Feature Branch**: `001-core-discovery-events`

**Created**: 2026-08-07

**Status**: Draft

**Input**: Migração da especificação funcional original (`spec.md` na raiz do repositório) para o formato spec-kit.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Descobrir o que está acontecendo hoje por perto (Priority: P1)

Uma pessoa abre o aplicativo sem destino definido e quer saber, de imediato, quais
eventos acontecem hoje em bares e restaurantes próximos. Ela vê uma agenda do dia
ordenada por proximidade, com nome do evento, local, horário e distância estimada,
e consegue navegar entre os dias seguintes.

**Why this priority**: é a proposta de valor central do produto. Sem esta jornada não
existe produto — todas as demais funcionalidades são amplificadores desta.

**Independent Test**: com um conjunto de eventos e locais cadastrados e uma
localização de usuário conhecida, abrir o app e verificar que a agenda do dia retorna
os eventos corretos, ordenados por proximidade, com distância exibida. Entrega valor
sozinha, mesmo sem busca, favoritos ou movimentação.

**Acceptance Scenarios**:

1. **Given** o usuário concedeu permissão de localização e existem eventos hoje na
   região dele, **When** ele abre o app, **Then** o sistema exibe a lista de eventos
   do dia ordenada por proximidade, cada um com nome, local, horário e distância.
2. **Given** o usuário negou permissão de localização, **When** ele abre o app,
   **Then** o sistema solicita uma localidade (cidade ou bairro) e exibe a agenda
   daquela localidade, sem bloquear o uso do app.
3. **Given** o usuário está na agenda de hoje, **When** ele navega para o dia seguinte,
   **Then** o sistema exibe os eventos programados para aquele dia.
4. **Given** não há eventos na região e data selecionadas, **When** a agenda carrega,
   **Then** o sistema exibe um estado vazio explicativo com ação para ampliar o raio
   ou mudar a data — nunca uma lista em branco sem contexto.
5. **Given** eventos em andamento e eventos futuros no mesmo dia, **When** a agenda
   carrega, **Then** os eventos em andamento são visualmente distinguíveis dos futuros.

---

### User Story 2 - Decidir para onde ir com base na movimentação (Priority: P1)

Antes de sair, a pessoa quer saber se o local está vazio, animado ou lotado. Ela vê um
indicador simples de movimentação em cada local, com a informação de quão recente é
aquele dado, e usa isso para escolher o lugar e a hora.

**Why this priority**: é o diferencial do produto frente a listas de eventos genéricas.
Junto com US1 forma o MVP.

**Independent Test**: com um local que tenha status de movimentação registrado,
consultar o local no app e verificar que o nível correto é exibido com o indicador
visual correspondente e o horário da última atualização.

**Acceptance Scenarios**:

1. **Given** um local com movimentação registrada recentemente, **When** o usuário vê o
   local na agenda ou no detalhe, **Then** o sistema exibe o nível (baixa, média, alta
   ou lotado) com indicador visual consistente e o momento da última atualização.
2. **Given** um local sem dado de movimentação, **When** o usuário o visualiza, **Then**
   o sistema indica explicitamente "sem informação" em vez de omitir o campo ou exibir
   um valor padrão enganoso.
3. **Given** o dado de movimentação de um local está defasado além do limite aceitável,
   **When** o usuário o visualiza, **Then** o sistema exibe o último valor conhecido
   marcado como desatualizado, e não um erro.
4. **Given** um estabelecimento atualiza o status do seu local, **When** a atualização é
   aceita, **Then** o novo nível fica disponível para os usuários dentro do intervalo de
   atualização definido.
5. **Given** um estabelecimento envia um nível fora dos valores válidos, **When** a
   atualização é submetida, **Then** o sistema rejeita a operação com erro de validação
   e mantém o valor anterior.

---

### User Story 3 - Buscar e filtrar até encontrar o evento certo (Priority: P2)

A pessoa tem uma intenção mais específica — "samba na quinta", "algo perto da Savassi",
"até R$ 50" — e usa busca textual e filtros para reduzir a agenda ao que interessa.

**Why this priority**: aumenta muito a taxa de sucesso da descoberta, mas a US1 já
entrega valor sem ela.

**Independent Test**: com uma base de eventos variados, aplicar cada filtro
isoladamente e uma busca textual, verificando que o conjunto retornado corresponde
exatamente ao critério.

**Acceptance Scenarios**:

1. **Given** existem eventos de várias categorias, **When** o usuário busca por texto
   livre, **Then** o sistema retorna eventos cujo nome, estabelecimento ou tipo de
   experiência correspondem ao termo.
2. **Given** o usuário aplica filtros de categoria, data, localidade, faixa de preço e
   tipo de ambiente, **When** a busca é executada, **Then** apenas eventos que
   satisfazem todos os filtros são retornados.
3. **Given** o usuário aplicou filtros, **When** ele altera o critério de ordenação
   entre relevância, proximidade, popularidade e horário, **Then** o conjunto filtrado é
   reordenado sem perder os filtros.
4. **Given** uma busca sem resultados, **When** ela é executada, **Then** o sistema exibe
   estado vazio com sugestão de relaxar filtros.

---

### User Story 4 - Ver os detalhes antes de decidir (Priority: P2)

A pessoa seleciona um evento e vê tudo que precisa para decidir: descrição, atrações,
horário de início e fim, faixa etária, preço, regras de entrada, dados do
estabelecimento, endereço com rota, e o status de movimentação do local.

**Why this priority**: converte a descoberta em decisão. Depende de US1 existir.

**Independent Test**: abrir o detalhe de um evento completo e verificar que todos os
campos especificados são exibidos, e que a rota abre para o endereço correto.

**Acceptance Scenarios**:

1. **Given** um evento publicado, **When** o usuário abre seu detalhe, **Then** o sistema
   exibe descrição, atrações, horário de início e fim, faixa etária, informação de preço
   ou entrada gratuita, e regras de entrada quando existirem.
2. **Given** um evento publicado, **When** o usuário abre seu detalhe, **Then** o sistema
   exibe nome, endereço, categoria, fotos e contato do estabelecimento, além do status de
   movimentação do local.
3. **Given** o detalhe de um evento aberto, **When** o usuário solicita rota, **Then** o
   sistema abre a navegação para o endereço do estabelecimento.
4. **Given** um campo opcional não preenchido pelo parceiro, **When** o detalhe é
   exibido, **Then** o campo é omitido de forma limpa, sem placeholder vazio ou erro.

---

### User Story 5 - Parceiro publica e mantém sua agenda (Priority: P2)

O estabelecimento faz login, cadastra um evento com fotos, descrição, categoria, preço
e horário, e mantém a agenda e o status de movimentação do seu local atualizados.

**Why this priority**: é a fonte de suprimento de conteúdo. Sem ela a plataforma
depende de carga manual, mas o MVP pode ser validado com dados semeados.

**Independent Test**: autenticar como parceiro, publicar um evento e verificar que ele
aparece na agenda pública após aprovação; editar e verificar a propagação.

**Acceptance Scenarios**:

1. **Given** um parceiro autenticado, **When** ele cadastra um evento com todos os campos
   obrigatórios válidos, **Then** o evento é registrado e entra na fila de aprovação.
2. **Given** um evento submetido com dados inválidos ou incompletos, **When** o parceiro
   tenta publicar, **Then** o sistema rejeita com mensagens de validação por campo e não
   registra o evento.
3. **Given** um evento aprovado, **When** a aprovação é concluída, **Then** ele passa a
   aparecer na agenda pública do app.
4. **Given** um parceiro autenticado, **When** ele edita horário ou status do seu local,
   **Then** a alteração é refletida para os usuários.
5. **Given** um parceiro autenticado, **When** ele tenta editar evento de outro
   estabelecimento, **Then** o sistema nega a operação.

---

### User Story 6 - Guardar preferências e receber recomendações (Priority: P3)

A pessoa salva eventos e estabelecimentos como favoritos, consulta o que já visitou, e
passa a receber sugestões alinhadas ao seu histórico e localização.

**Why this priority**: aumenta retenção, mas não é necessária para a primeira visita
ter valor.

**Independent Test**: favoritar itens, verificar persistência entre sessões, e conferir
que as recomendações refletem o histórico registrado.

**Acceptance Scenarios**:

1. **Given** um usuário autenticado, **When** ele favorita um evento ou estabelecimento,
   **Then** o item passa a constar na sua lista de favoritos e persiste entre sessões.
2. **Given** um item favoritado, **When** o usuário o remove dos favoritos, **Then** ele
   deixa de constar na lista.
3. **Given** um usuário com histórico de eventos visitados ou marcados, **When** ele abre
   as recomendações, **Then** o sistema apresenta sugestões relacionadas ao seu histórico
   e à sua localização.
4. **Given** um usuário sem histórico, **When** ele abre as recomendações, **Then** o
   sistema apresenta sugestões baseadas em popularidade e proximidade, sem estado vazio.

---

### User Story 7 - Ser lembrado do que importa (Priority: P3)

A pessoa é avisada quando um evento que marcou está próximo de começar, ou quando algo
relevante muda nesse evento, e controla a frequência desses avisos.

**Why this priority**: melhora o comparecimento efetivo, mas depende de US6 existir.

**Independent Test**: marcar um evento, simular a aproximação do horário, e verificar
que o lembrete é gerado respeitando as preferências configuradas.

**Acceptance Scenarios**:

1. **Given** um usuário com evento marcado, **When** o horário de início se aproxima da
   antecedência configurada, **Then** o sistema envia um lembrete.
2. **Given** um evento marcado sofre mudança relevante de horário ou cancelamento,
   **When** a mudança é publicada, **Then** o sistema notifica os usuários que o marcaram.
3. **Given** um usuário ajusta suas preferências de notificação, **When** as preferências
   são salvas, **Then** os envios seguintes respeitam a nova configuração.
4. **Given** um usuário desativou um tipo de notificação, **When** o gatilho ocorre,
   **Then** nenhuma notificação daquele tipo é enviada.

---

### User Story 8 - Administrar conteúdo e operação (Priority: P4)

A equipe da plataforma revisa e aprova eventos antes da publicação, gerencia parceiros,
locais e categorias, e acompanha eventos ativos e métricas de uso.

**Why this priority**: necessária para operar em escala e garantir confiabilidade, mas
pode ser suprida manualmente nas primeiras fases.

**Independent Test**: autenticar como administrador, aprovar e rejeitar eventos
pendentes, e verificar que apenas os aprovados aparecem na agenda pública.

**Acceptance Scenarios**:

1. **Given** eventos pendentes de aprovação, **When** o administrador acessa o painel,
   **Then** ele vê a fila de eventos pendentes com os dados necessários para decidir.
2. **Given** um evento pendente, **When** o administrador o aprova, **Then** o evento
   passa a aparecer na agenda pública.
3. **Given** um evento pendente, **When** o administrador o rejeita com justificativa,
   **Then** o evento não é publicado e o parceiro é informado do motivo.
4. **Given** um usuário sem perfil administrativo, **When** ele tenta acessar o painel,
   **Then** o acesso é negado.

---

### Edge Cases

- O que acontece quando o usuário está em região sem nenhum estabelecimento cadastrado?
- Como o sistema se comporta quando a permissão de localização é concedida mas o GPS
  não retorna posição a tempo?
- O que acontece com um evento que cruza a meia-noite — em qual dia da agenda ele aparece?
- Como o sistema trata fusos horários e horário de verão na agenda diária?
- O que acontece quando duas fontes atualizam a movimentação do mesmo local em
  sequência com valores conflitantes?
- Como o sistema se comporta quando o parceiro apaga um evento que usuários já
  favoritaram ou marcaram?
- O que acontece com eventos aprovados cujo estabelecimento é posteriormente
  desativado?
- Como a busca se comporta com termos acentuados, com erro de digitação ou muito curtos?
- O que acontece quando o usuário perde conectividade no meio da navegação?
- Como o sistema evita que um parceiro infle artificialmente a popularidade do seu evento?

## Requirements *(mandatory)*

### Functional Requirements

**Descoberta e agenda**

- **FR-001**: O sistema MUST exibir a lista de eventos disponíveis para um dia
  selecionado.
- **FR-002**: O sistema MUST permitir navegação entre dias na agenda.
- **FR-003**: O sistema MUST distinguir visualmente eventos em andamento, próximos e
  futuros.
- **FR-004**: O sistema MUST exibir, para cada evento na listagem, nome, local, horário,
  descrição curta, imagem e categoria.
- **FR-005**: O sistema MUST destacar eventos de alta demanda ou marcados como destaque.

**Localização e proximidade**

- **FR-006**: O sistema MUST usar a localização do usuário, quando autorizada, para
  ordenar e sugerir eventos próximos.
- **FR-007**: O sistema MUST permitir busca de eventos por cidade, bairro ou região
  quando a localização não estiver disponível.
- **FR-008**: O sistema MUST exibir a distância estimada entre o usuário e o local do
  evento.
- **FR-009**: O sistema MUST permitir consulta dos eventos em formato de lista e de mapa.
- **FR-010**: O sistema MUST considerar eventos dentro de um raio de
  [NEEDS CLARIFICATION: raio padrão de proximidade não especificado — 5 km, 10 km,
  configurável pelo usuário?] como "próximos".

**Busca e filtros**

- **FR-011**: Usuários MUST conseguir buscar eventos por nome de evento, estabelecimento
  ou tipo de experiência.
- **FR-012**: O sistema MUST permitir filtrar por categoria, data, localidade, faixa de
  preço e tipo de ambiente.
- **FR-013**: O sistema MUST permitir ordenar por relevância, proximidade, popularidade
  ou horário.
- **FR-014**: O sistema MUST preservar os filtros aplicados ao alterar a ordenação.

**Status de movimentação**

- **FR-015**: O sistema MUST classificar a movimentação de cada local em faixas
  nomeadas: baixa, média, alta e lotado.
- **FR-016**: O sistema MUST rejeitar atualizações de movimentação com valores fora das
  faixas válidas.
- **FR-017**: O sistema MUST exibir o momento da última atualização junto ao nível de
  movimentação.
- **FR-018**: O sistema MUST indicar explicitamente a ausência de informação de
  movimentação, em vez de assumir um valor padrão.
- **FR-019**: O sistema MUST manter o último valor conhecido, sinalizado como
  desatualizado, quando a fonte de movimentação falhar.
- **FR-020**: O sistema MUST registrar histórico de movimentação por janela temporal,
  retendo os dados por [NEEDS CLARIFICATION: período de retenção do histórico não
  especificado].
- **FR-021**: O sistema MUST atualizar o status de movimentação em intervalo de
  [NEEDS CLARIFICATION: intervalo de atualização e mecanismo não especificados — push
  em tempo real, polling, qual periodicidade?].
- **FR-022**: A movimentação MUST ser originada por [NEEDS CLARIFICATION: fonte do dado
  não especificada — informe manual do estabelecimento, sensor/integração, inferência a
  partir de uso do app, ou combinação?].

**Detalhe de evento e local**

- **FR-023**: O sistema MUST exibir detalhes completos do evento: descrição, atrações,
  horário de início e fim, tipo de público, faixa etária e regras.
- **FR-024**: O sistema MUST exibir dados do estabelecimento: nome, endereço, categoria,
  fotos e contato.
- **FR-025**: O sistema MUST informar se há reserva, fila, entrada gratuita ou
  restrições de acesso.
- **FR-026**: O sistema MUST oferecer rota até o endereço do estabelecimento.
- **FR-027**: O sistema MUST exibir avaliações e destaques do local quando disponíveis.

**Contas e personalização**

- **FR-028**: O sistema MUST autenticar usuários, parceiros e administradores por
  [NEEDS CLARIFICATION: método de autenticação não decidido — email/senha, OAuth social,
  ambos?].
- **FR-029**: O sistema MUST distinguir e aplicar os perfis de usuário final, parceiro e
  administrador em toda operação sensível.
- **FR-030**: Usuários MUST conseguir salvar e remover eventos e estabelecimentos dos
  favoritos, com persistência entre sessões.
- **FR-031**: O sistema MUST registrar histórico de eventos visitados ou marcados.
- **FR-032**: O sistema MUST gerar recomendações a partir do histórico e da localização
  do usuário.
- **FR-033**: O sistema MUST oferecer recuperação de senha para contas com credencial
  própria.

**Notificações**

- **FR-034**: O sistema MUST enviar lembrete de eventos marcados quando o início se
  aproxima.
- **FR-035**: O sistema MUST notificar mudanças relevantes em eventos marcados pelo
  usuário.
- **FR-036**: Usuários MUST conseguir ajustar frequência e tipos de notificação que
  recebem.
- **FR-037**: O sistema MUST entregar notificações via [NEEDS CLARIFICATION: canal de
  entrega não definido — push remoto, notificação local no dispositivo, email?].

**Gestão de conteúdo e administração**

- **FR-038**: Parceiros MUST conseguir cadastrar e atualizar eventos do seu
  estabelecimento, incluindo fotos, descrição, faixa de preço, categoria e horário.
- **FR-039**: O sistema MUST validar as informações do evento antes de permitir a
  publicação.
- **FR-040**: O sistema MUST submeter eventos a um fluxo de aprovação antes da
  publicação na agenda pública.
- **FR-041**: Parceiros MUST conseguir atualizar o status de movimentação do seu local.
- **FR-042**: O sistema MUST impedir que um parceiro altere dados de estabelecimento
  que não lhe pertence.
- **FR-043**: Administradores MUST conseguir aprovar, rejeitar e editar eventos
  pendentes, com justificativa em caso de rejeição.
- **FR-044**: Administradores MUST conseguir gerenciar parceiros, locais e categorias.
- **FR-045**: O sistema MUST oferecer à administração uma visão de eventos ativos e
  métricas de uso, popularidade e desempenho.
- **FR-046**: O sistema MUST expor sinais de integridade operacional: volume de acesso,
  taxa de erro e disponibilidade dos serviços críticos.

**Comportamento transversal**

- **FR-047**: O sistema MUST tratar explicitamente os estados de carregamento, vazio e
  erro em toda listagem e tela de detalhe.
- **FR-048**: O sistema MUST validar toda entrada externa antes de processá-la.
- **FR-049**: O sistema MUST retornar erros ao cliente sem expor detalhes internos de
  implementação.

### Key Entities

- **Usuário**: pessoa que descobre eventos. Possui perfil, preferências de notificação,
  favoritos, histórico e localização corrente ou preferida.
- **Parceiro**: representante de um estabelecimento, com permissão sobre os locais e
  eventos daquele estabelecimento.
- **Administrador**: operador da plataforma, com permissão de moderação e gestão.
- **Estabelecimento (Local)**: bar ou restaurante. Possui nome, endereço, coordenadas,
  categoria, fotos, contato e avaliações. Agrega eventos e registros de movimentação.
- **Evento**: acontecimento em um estabelecimento em uma janela de tempo. Possui nome,
  descrição, atrações, categoria, faixa de preço, faixa etária, regras de entrada,
  imagem, horário de início e fim, e status de publicação.
- **Categoria**: classificação de eventos e estabelecimentos, usada em filtros.
- **Status de Movimentação**: nível de ocupação de um estabelecimento em um instante.
  Possui local, nível (baixa/média/alta/lotado), momento da medição e origem do dado.
- **Favorito**: vínculo entre um usuário e um evento ou estabelecimento.
- **Histórico**: registro dos eventos visitados ou marcados por um usuário.
- **Recomendação**: sugestão de evento para um usuário, derivada de histórico,
  localização e popularidade.
- **Notificação**: mensagem destinada a um usuário, com tipo, gatilho e estado de envio.
- **Preferência de Notificação**: configuração por usuário de quais tipos recebe e com
  qual antecedência.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Um usuário novo consegue ver a agenda de eventos do dia na sua região em
  até 10 segundos após abrir o app pela primeira vez, incluindo a concessão de permissão
  de localização.
- **SC-002**: A listagem de eventos do dia responde em menos de 1 segundo no percentil 95,
  medido no cliente.
- **SC-003**: A busca com filtros aplicados retorna resultados em menos de 1,5 segundo no
  percentil 95.
- **SC-004**: 90% dos usuários que abrem o app concluem ao menos uma visualização de
  detalhe de evento na primeira sessão.
- **SC-005**: O sistema sustenta o pico de sexta e sábado à noite sem degradação de
  latência acima de 20% em relação à mediana semanal.
- **SC-006**: A disponibilidade dos endpoints de agenda, busca e movimentação é de no
  mínimo 99,5% medida mensalmente, e de 99,9% nas janelas de pico.
- **SC-007**: O status de movimentação exibido reflete a última medição disponível com
  defasagem máxima igual ao intervalo definido em FR-021, em 99% das consultas.
- **SC-008**: Nenhuma consulta exibe movimentação sem indicar sua idade ou sua ausência.
- **SC-009**: Um parceiro consegue publicar um evento completo em até 5 minutos a partir
  do login, sem consultar documentação externa.
- **SC-010**: 95% dos eventos submetidos por parceiros passam pela validação sem erro de
  formato na primeira tentativa.
- **SC-011**: Eventos aprovados aparecem na agenda pública em menos de 1 minuto após a
  aprovação.
- **SC-012**: Toda regra de negócio e todo endpoint público têm cobertura de teste
  automatizado, verificada no pipeline.
- **SC-013**: Nenhuma resposta de erro ao cliente contém stack trace, query ou nome de
  estrutura interna.

## Assumptions

- O escopo desta feature é a plataforma completa descrita na especificação original;
  as user stories P1 e P2 constituem o MVP e as demais são incrementos posteriores.
- Usuários acessam o app majoritariamente em dispositivos móveis, com conectividade
  intermitente aceitável para navegação, mas online para carregar dados.
- A operação inicial é geograficamente limitada a uma região, o que permite ignorar
  múltiplos fusos horários na primeira versão — a suposição deve ser revista antes da
  expansão.
- Estabelecimentos têm interesse e capacidade de manter sua agenda atualizada; a
  qualidade do conteúdo depende dessa colaboração.
- Avaliações de estabelecimento são exibidas a partir de dados já existentes na
  plataforma; a criação de um sistema próprio de avaliação não faz parte desta feature.
- Roteamento e navegação até o endereço são delegados ao aplicativo de mapas do
  dispositivo, não implementados internamente.
- Moderação de conteúdo é humana e assistida por validação automática de formato; não há
  moderação por aprendizado de máquina nesta feature.
