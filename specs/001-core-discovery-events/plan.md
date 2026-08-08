# Implementation Plan: Descoberta de Eventos, Agenda Diária e Status de Movimentação

**Branch**: `001-core-discovery-events` | **Date**: 2026-08-07 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-core-discovery-events/spec.md`

## Summary

Plataforma mobile de descoberta de eventos em bares e restaurantes, com agenda diária,
busca com filtros, detalhe de evento e local, e status de movimentação em tempo
aproximado. App em Flutter organizado por feature com camadas `data`/`domain`/
`presentation`; API em Elixir/Phoenix organizada em contextos delimitados sobre
PostgreSQL, com processos supervisionados para consolidação de movimentação e envio de
notificações. Toda comunicação entre app e API passa por contratos HTTP/JSON explícitos,
validados por testes de contrato.

## Technical Context

**Language/Version**: Elixir ~> 1.16 (backend) e Dart/Flutter (frontend)

**Primary Dependencies**: Phoenix ~> 1.7.11, Ecto SQL ~> 3.5, Postgrex ~> 0.17,
Jason ~> 1.4, Plug Cowboy ~> 2.0, Phoenix PubSub ~> 2.1 no backend; Flutter SDK no
frontend, com abordagem de gerenciamento de estado a definir (ver Fase 0)

**Storage**: PostgreSQL como banco transacional, com índices para consulta por data,
localização, categoria e geolocalização

**Testing**: ExUnit no backend (incluindo testes de contrato de API);
`flutter_test` no frontend (unitários e de widget)

**Target Platform**: aplicativo mobile iOS e Android, com backend em containers Linux

**Project Type**: mobile app + API (monorepo com `frontend/` e `backend/`)

**Performance Goals**: agenda do dia em < 1s no p95 e busca filtrada em < 1,5s no p95,
medidos no cliente (SC-002, SC-003)

**Constraints**: disponibilidade de 99,5% mensal e 99,9% em janela de pico (SC-006);
degradação segura da movimentação para último valor conhecido (FR-019); sem vazamento
de detalhe interno em erros (FR-049)

**Scale/Scope**: 8 user stories, 49 requisitos funcionais, 12 entidades de domínio,
9 contextos no backend, ~6 fluxos de tela no app; carga concentrada em sexta e sábado
à noite

## Constitution Check

*GATE: deve passar antes da Fase 0 e ser reavaliado após o desenho da Fase 1.*

| Princípio | Gate | Status |
|-----------|------|--------|
| I. Separação estrita de camadas | Nenhum controller acessa `Repo`; nenhuma tela contém regra de negócio; toda feature Flutter tem `data/`, `domain/`, `presentation/` | ⚠️ Verificar — controllers atuais precisam ser auditados |
| II. Contextos delimitados | Cada domínio em contexto próprio com API pública explícita; sem chamada cruzada a schemas alheios | ⚠️ Verificar — falta o contexto `events` e `venues` como contextos de domínio |
| III. Testes automatizados | Toda regra de negócio com teste unitário; todo endpoint com teste de contrato; fluxos críticos com teste de integração | ⚠️ Parcial — existe suíte, mas sem cobertura completa de contrato |
| IV. Contratos de API rígidos | Todo endpoint documentado com entrada, saída, status e erros; entradas validadas; datas em ISO 8601 e status como enums nomeados | ❌ Pendente — contratos não documentados formalmente |
| V. Resiliência | Integrações e trabalho de fundo sob supervision tree; movimentação degrada para último valor; stateless para escala horizontal | ❌ Pendente — supervision tree não implementada |
| VI. Segurança por design | Autorização verificada no backend em toda operação sensível; papéis distintos; erros sem detalhe interno; segredos fora do repositório | ❌ Pendente — autorização por perfil e gestão de segredos não implementadas |
| VII. Observabilidade | Logs estruturados, métricas por endpoint e alertas nos sinais críticos | ❌ Pendente |

**Resultado do gate**: o plano prossegue, mas os itens ❌ são bloqueantes para
produção e estão traduzidos em tarefas nas fases Foundational e Polish de
[tasks.md](./tasks.md). Nenhuma violação exige justificativa em Complexity Tracking —
todas são lacunas de implementação, não desvios de princípio.

## Project Structure

### Documentation (this feature)

```text
specs/001-core-discovery-events/
├── spec.md              # Especificação da feature
├── plan.md              # Este arquivo
├── research.md          # Saída da Fase 0 (decisões técnicas em aberto)
├── data-model.md        # Saída da Fase 1 (modelo de dados)
├── quickstart.md        # Saída da Fase 1 (como rodar e validar)
├── contracts/           # Saída da Fase 1 (contratos de API por domínio)
└── tasks.md             # Saída da Fase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
backend/
├── lib/
│   └── bora_la/
│       ├── application.ex          # Supervision tree raiz
│       ├── repo.ex
│       ├── accounts/               # Autenticação, usuários, perfis e papéis
│       ├── events/                 # Eventos, publicação e aprovação (a criar)
│       ├── venues/                 # Estabelecimentos e categorias (a criar)
│       ├── traffic/                # Status de movimentação e histórico
│       ├── favorites/
│       ├── notifications/
│       ├── recommendations/
│       ├── search/
│       ├── admin/                  # Moderação e métricas operacionais (a criar)
│       ├── shared/                 # Validadores, erros e utilitários (a criar)
│       └── web/
│           ├── endpoint.ex
│           ├── router.ex
│           └── controllers/        # Camada fina: valida entrada, chama contexto
├── priv/repo/migrations/
├── config/
└── test/
    ├── bora_la/                    # Testes de contexto e regra de negócio
    └── bora_la_web/                # Testes de contrato de API

frontend/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── di/                     # Service locator
│   │   ├── theme/                  # Design system (a criar)
│   │   └── widgets/                # Componentes reutilizáveis (a criar)
│   └── features/
│       ├── events/                 # data/ domain/ presentation/
│       ├── venues/                 # (a criar)
│       ├── traffic/
│       ├── search/
│       ├── favorites/
│       ├── notifications/
│       └── auth/
└── test/

docker-compose.yml                  # PostgreSQL + backend + frontend para dev local
.github/workflows/ci.yml            # Pipeline de qualidade
```

**Structure Decision**: monorepo com `frontend/` (Flutter) e `backend/` (Elixir),
conforme a estrutura já estabelecida no repositório. No backend, cada contexto de
domínio é um diretório sob `backend/lib/bora_la/`, com controllers finos em
`backend/lib/bora_la/web/controllers/` que apenas traduzem HTTP para chamadas de
contexto. No frontend, cada feature em `frontend/lib/features/<feature>/` com as três
camadas `data/`, `domain/` e `presentation/`, e o que for compartilhado em
`frontend/lib/core/`. Os contextos `events`, `venues`, `admin` e `shared` e a feature
`venues` ainda não existem e são criados nas fases correspondentes.

## Complexity Tracking

> Nenhuma violação de princípio constitucional a justificar. Os itens marcados como
> pendentes no Constitution Check são lacunas de implementação já mapeadas em tarefas,
> não desvios arquiteturais deliberados.
