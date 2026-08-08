# Research: Decisões Técnicas em Aberto

**Feature**: 001-core-discovery-events | **Fase**: 0 | **Data**: 2026-08-07

Este documento reúne as decisões que precisam ser tomadas antes ou durante a
implementação. Cada item em aberto corresponde a um marcador
`[NEEDS CLARIFICATION]` em [spec.md](./spec.md) ou a uma escolha técnica que a
constituição exige que seja explícita.

Use `/speckit-clarify` para resolver os itens em aberto de forma estruturada; ao
fechar cada um, atualize o requisito correspondente no spec e mova o item para
"Decisões tomadas".

---

## Itens em aberto

### R-001: Fonte do dado de movimentação — FR-022

**Pergunta**: de onde vem o nível de movimentação de um local?

**Opções**:

| Opção | Prós | Contras |
|-------|------|---------|
| Informe manual do estabelecimento | Simples, sem integração, disponível no MVP | Depende de disciplina do parceiro; sujeito a viés e a dado velho |
| Sensor ou integração de terceiros | Objetivo e contínuo | Custo, dependência externa, cobertura limitada de estabelecimentos |
| Inferência a partir do uso do app | Sem custo por local | Só funciona com massa crítica de usuários; frio no lançamento |
| Combinação com precedência definida | Cobertura ampla e degradação natural | Exige regra de conflito entre fontes (ver Edge Cases do spec) |

**Impacto se não resolvido**: bloqueia US2, que é P1. Define o modelo de dados de
`Status de Movimentação` (campo de origem) e a regra de resolução de conflito.

**Decisão**: _pendente_

---

### R-002: Intervalo e mecanismo de atualização da movimentação — FR-021

**Pergunta**: com que frequência e por qual mecanismo o app recebe movimentação nova?

**Opções**: polling do cliente em intervalo fixo; WebSocket/Phoenix Channels com push
do servidor; atualização apenas ao abrir a tela.

**Considerações**: Phoenix Channels sobre a PubSub já declarada em `mix.exs` torna o
push viável sem dependência nova. Contra: consumo de bateria e conexão persistente no
mobile. O intervalo escolhido determina diretamente SC-007, que promete uma defasagem
máxima.

**Impacto se não resolvido**: bloqueia US2 e a formulação de SC-007.

**Decisão**: _pendente_

---

### R-003: Retenção do histórico de movimentação — FR-020

**Pergunta**: por quanto tempo o histórico por janela temporal é retido?

**Considerações**: o spec promete "histórico em intervalos curtos". Retenção define
volume de dados, estratégia de particionamento e se há agregação em janelas maiores
após certo tempo. Também tem implicação de privacidade quando cruzada com presença de
usuários.

**Impacto se não resolvido**: afeta o modelo de dados e a política de expurgo.

**Decisão**: _pendente_

---

### R-004: Método de autenticação — FR-028

**Pergunta**: email/senha, OAuth social, ou ambos? Vale para os três perfis?

**Considerações**: FR-033 exige recuperação de senha, o que só faz sentido com
credencial própria. Parceiros e administradores podem exigir método mais forte que
usuários finais. A constituição (Princípio VI) exige papéis distintos e verificação no
backend, independentemente do método.

**Impacto se não resolvido**: bloqueia US5, US6, US7 e US8. Define o modelo de sessão
e refresh token.

**Decisão**: _pendente_

---

### R-005: Canal de entrega de notificações — FR-037

**Pergunta**: push remoto, notificação local no dispositivo, email, ou combinação?

**Considerações**: push remoto exige serviço externo e trabalho de fundo no backend
(coerente com o Princípio V, sob supervision tree). Notificação local resolve lembrete
de evento marcado sem infraestrutura, mas não cobre FR-035 (mudanças publicadas pelo
parceiro), que precisa alcançar o dispositivo sem o app aberto.

**Impacto se não resolvido**: bloqueia US7.

**Decisão**: _pendente_

---

### R-006: Raio padrão de proximidade — FR-010

**Pergunta**: qual raio define "próximo", e ele é fixo, configurável ou adaptativo à
densidade de eventos da região?

**Considerações**: raio fixo é simples mas produz estado vazio em região de baixa
densidade — exatamente o cenário do Acceptance Scenario 4 da US1. Raio adaptativo
melhora a primeira sessão mas complica a previsibilidade dos resultados.

**Impacto se não resolvido**: afeta a query de listagem e a estratégia de índice
geoespacial.

**Decisão**: _pendente_

---

### R-007: Gerenciamento de estado no Flutter

**Pergunta**: BLoC, Riverpod, Provider ou outra abordagem?

**Considerações**: a constituição exige escolha **explícita e consistente** em todo o
app — o que importa mais que a opção específica. O app já tem um service locator em
`frontend/lib/core/di/service_locator.dart`, o que sugere injeção manual; a decisão
deve ser compatível com ele ou substituí-lo deliberadamente.

**Impacto se não resolvido**: cada feature nova arrisca adotar um padrão diferente,
violando o Princípio I.

**Decisão**: _pendente_

---

### R-008: Estratégia de índice geoespacial

**Pergunta**: PostGIS, ou cálculo de distância com índice B-tree sobre bounding box?

**Considerações**: PostGIS resolve proximidade e distância de forma correta e
performática, ao custo de uma extensão a mais no PostgreSQL e na imagem Docker. A
alternativa por bounding box é suficiente para raio pequeno e volume moderado.
SC-002 exige agenda em < 1s no p95, com ordenação por proximidade — este é o caminho
crítico dessa métrica.

**Impacto se não resolvido**: afeta migrations, imagem Docker e desempenho de US1.

**Decisão**: _pendente_

---

### R-009: Tratamento de fuso horário e eventos que cruzam a meia-noite

**Pergunta**: em qual dia da agenda aparece um evento que começa 23h e termina 3h?
Como datas são armazenadas e comparadas?

**Considerações**: caso de borda listado no spec, e crítico para um produto de vida
noturna — provavelmente a maioria dos eventos cruza a meia-noite. A suposição de região
única no spec permite adiar multi-fuso, mas não adia esta decisão.

**Impacto se não resolvido**: causa erro sistemático na agenda diária, que é US1.

**Decisão**: _pendente_

---

## Decisões tomadas

### D-001: Monorepo com `frontend/` e `backend/`

**Decisão**: manter o repositório único com as duas aplicações lado a lado.

**Justificativa**: mantém spec, plano e tarefas próximos do código dos dois lados, e
permite que uma mudança de contrato de API altere cliente e servidor na mesma
submissão — reforçando o Princípio IV.

**Alternativa rejeitada**: repositórios separados, que desacoplariam os ciclos de
release ao custo de tornar mudanças de contrato coordenadas mais difíceis de revisar.

### D-002: Stack Elixir/Phoenix + Flutter + PostgreSQL

**Decisão**: fixada na constituição, seção Technology Constraints.

**Justificativa**: a BEAM atende ao requisito de concorrência e tolerância a falhas sob
pico (SC-005, SC-006); Flutter entrega app nativo nas duas plataformas com uma base de
código.

**Alternativa rejeitada**: qualquer mudança de stack exige emenda constitucional.
