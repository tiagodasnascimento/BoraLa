# Backlog de Tarefas - BoraLá

Status atual: 2026-08-07

Resumo da situação atual:
- [x] Estrutura inicial do frontend Flutter e do backend Phoenix criada.
- [x] Módulos base de autenticação, favoritos, notificações, recomendações e busca implementados.
- [x] Fluxo de busca funcional no app e na API.
- [x] Status de movimentação implementado em domínio e endpoint.
- [x] Suíte de testes do frontend e do backend validada com sucesso.
- [x] Aplicação mínima em execução real: banco PostgreSQL, backend Phoenix e frontend Flutter funcionando.
- [ ] Administração, produção, observabilidade, segurança avançada e integração real com banco/serviços externos ainda pendem.

## 1. Fase 0 - Setup e fundamentos

### 1.1 Inicialização do projeto
- [x] Criar repositório e estrutura base de monorepo ou organização de serviços.
- [x] Definir convenções de branches, commits e pull requests.
- [x] Configurar ambientes de desenvolvimento local e de teste.
- [x] Validar execução mínima real do backend e frontend no ambiente local.
- [ ] Documentar onboarding da equipe.

### 1.2 Configuração de qualidade
- [ ] Configurar lint para Flutter.
- [ ] Configurar formatter e análise estática do Dart.
- [ ] Configurar mix format, credo e dialyzer no Elixir.
- [x] Definir cobertura mínima de testes por módulo.
- [ ] Configurar pre-commit e hooks de validação.

### 1.3 Infraestrutura base
- [x] Definir desenho de containers com Docker.
- [x] Configurar Docker Compose para ambiente local.
- [x] Subir PostgreSQL local para execução da API.
- [x] Validar runtime mínimo do backend Phoenix e do frontend Flutter.
- [ ] Definir variáveis de ambiente e secrets management.
- [x] Preparar estrutura de CI/CD inicial.

## 2. Fase 1 - Fundação arquitetural

### 2.1 Frontend Flutter
- [x] Estruturar arquitetura por features e camadas.
- [x] Implementar navegação principal do app.
- [x] Definir tema visual e design system inicial.
- [ ] Criar widgets reutilizáveis de cards, filtros e botões.
- [x] Implementar gerenciamento de estado consistente.
- [x] Criar camada de dados para consumo de APIs.
- [x] Implementar tratadores de loading, empty state e error state.

### 2.2 Backend Elixir
- [x] Inicializar aplicação Phoenix ou base Elixir adequada.
- [x] Configurar banco de dados e migrations.
- [x] Definir contextos por domínio: eventos, locais, usuários, movimentação, notificações, admin.
- [x] Levantar o servidor Phoenix em execução real.
- [ ] Implementar supervision trees e estrutura de processos.
- [x] Criar versionamento básico da API.
- [x] Definir contratos de request/response para endpoints principais.

## 3. Fase 2 - Módulo de eventos e locais

### 3.1 Gestão de eventos
- [ ] Criar modelo de evento com campos essenciais.
- [ ] Implementar cadastro de eventos por parceiros.
- [ ] Implementar listagem de eventos por data e categoria.
- [x] Implementar busca por texto, local e tipo de experiência.
- [ ] Implementar filtros por preço, localização e horário.
- [ ] Criar endpoint de detalhe do evento.
- [ ] Criar fluxo de aprovação e publicação.

### 3.2 Gestão de locais
- [ ] Criar modelo de estabelecimento/bares/restaurantes.
- [ ] Implementar cadastro e edição de locais.
- [ ] Associar eventos ao local correto.
- [ ] Exibir dados básicos, fotos, endereço e contato.
- [ ] Implementar rota e mapa integrado.

## 4. Fase 3 - Status de movimentação

### 4.1 Coleta e atualização
- [x] Definir estratégia de dados de movimentação.
- [x] Criar modelo de status por local e intervalo de tempo.
- [x] Implementar endpoint para atualização do status.
- [x] Implementar validação de faixas e limites válidos.
- [ ] Definir mecanismos para atualização em tempo real ou por polling.

### 4.2 Exposição ao cliente
- [x] Criar endpoint para consulta de movimentação por local.
- [ ] Implementar histórico de movimentação por janela temporal.
- [x] Exibir nível de movimento na UI.
- [x] Criar indicador visual consistente para baixa, média, alta e lotado.

## 5. Fase 4 - Usuário e personalização

### 5.1 Autenticação e usuários
- [x] Implementar login e cadastro de usuário.
- [ ] Definir fluxo de recuperação de senha.
- [x] Criar autenticação segura para mobile e backend.
- [ ] Implementar autorização por perfil.
- [ ] Criar perfil de usuário com preferências.

### 5.2 Favoritos e histórico
- [x] Implementar salvamento de eventos favoritos.
- [x] Implementar listagem de favoritos.
- [ ] Implementar histórico de eventos visitados.
- [x] Criar recomendações básicas por histórico e localização.

### 5.3 Notificações
- [ ] Definir estratégia de push/local notifications.
- [x] Implementar lembretes de eventos próximos.
- [ ] Permitir configurações de notificação por usuário.
- [ ] Integrar serviço de mensagens ou canais de notificação.

### 5.4 Execução mínima real
- [x] Backend respondendo em runtime local.
- [x] Frontend executando em navegador local.
- [x] Ambiente local de desenvolvimento funcional para validação mínima.

## 6. Fase 5 - Administração e operação

### 6.1 Painel administrativo
- [ ] Criar dashboard de eventos ativos.
- [ ] Implementar gestão de usuários parceiros.
- [ ] Criar módulo de moderação e aprovação de eventos.
- [ ] Implementar dashboard de métricas de uso.
- [ ] Criar painel de monitoramento operacional.

### 6.2 Operação e confiabilidade
- [ ] Configurar logs estruturados.
- [ ] Implementar métricas e alertas.
- [ ] Configurar dashboards de observabilidade.
- [ ] Definir plano de manutenção e rollback.
- [ ] Definir procedimentos de recuperação de falhas.

## 7. Fase 6 - Testes e garantia de qualidade

### 7.1 Testes no frontend
- [x] Cobrir fluxos principais de busca e detalhe de eventos.
- [ ] Testar filtros, favoritos e navegação.
- [ ] Testar estados de carregamento, erro e vazio.
- [ ] Cobrir componentes reutilizáveis.

### 7.2 Testes no backend
- [x] Testar autenticação e autorização.
- [ ] Testar criação, listagem e atualização de eventos.
- [x] Testar regras de movimentação e persistência.
- [ ] Testar integrações com banco e filas.
- [x] Cobrir casos de erro e regressão.

### 7.3 Testes de integração e contrato
- [ ] Validar contratos de API com testes de contrato.
- [ ] Testar os fluxos completos de mobile para backend.
- [ ] Garantir cobertura de cenários críticos em horários de pico.

## 8. Fase 7 - DevSecOps e produção

### 8.1 Segurança
- [ ] Revisar autenticação e controle de acesso.
- [ ] Validar tokens e sessão.
- [ ] Implementar proteção contra abuso de endpoints.
- [ ] Definir política de segredos e chaves.
- [ ] Revisar logs e sensibilidade de dados.

### 8.2 CI/CD
- [x] Configurar build automatizado para Flutter.
- [x] Configurar build automatizado para Elixir.
- [x] Configurar testes em pipeline.
- [ ] Configurar análise estática e security checks.
- [ ] Definir deploy automatizado por ambiente.

### 8.3 Conteinerização e disponibilidade
- [ ] Ajustar imagens Docker para frontend e backend.
- [ ] Definir setup de ambiente em produção.
- [ ] Configurar balanceamento e escalabilidade.
- [ ] Validar alta disponibilidade em cenários de pico.

## 9. Fase 8 - Hardening e otimização

- [ ] Revisar performance de listagens e consultas.
- [ ] Aplicar cache estratégico para consultas frequentes.
- [ ] Otimizar payloads de API.
- [ ] Revisar UX e performance em dispositivos menores.
- [ ] Realizar testes de carga e stress.
- [ ] Validar alertas e SLA operacional.

## 10. Entregas por milestone

### Milestone 1 - MVP
- [x] App com busca, filtros e agenda diária.
- [ ] Detalhes de eventos e locais.
- [x] Base de autenticação.
- [x] APIs básicas de eventos e locais em execução local.

### Milestone 2 - Funcionalidade de decisão em tempo real
- [x] Status de movimentação.
- [x] Favoritos e histórico.
- [x] Notificações básicas.
- [x] Recomendação simples.
- [x] Validação mínima do app e da API em runtime real.

### Milestone 3 - Operação e crescimento
- [ ] Painel administrativo.
- [ ] Integração completa em CI/CD.
- [ ] Monitoramento e observabilidade.
- [ ] Conteinerização e alta disponibilidade.

## 11. Critérios de conclusão

O projeto será considerado pronto para expansão quando:

- [ ] todas as funcionalidades principais do MVP estiverem entregues;
- [x] a suíte de testes automatizados estiver integrada e funcional;
- [x] a arquitetura estiver modular e escalável;
- [ ] a infraestrutura estiver conteinerizada e pronta para produção;
- [ ] o processo de deploy e rollback estiver automatizado;
- [ ] segurança e observabilidade estiverem implementados no fluxo de desenvolvimento.
