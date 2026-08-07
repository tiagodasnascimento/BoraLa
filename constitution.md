# Constituição do Projeto BoraLá

## 1. Propósito e visão

O projeto BoraLá é uma plataforma que conecta usuários a eventos em bares e restaurantes, oferecendo agendas diárias de eventos e informações em tempo real sobre status de movimentação. A solução deve priorizar experiência do usuário, confiabilidade operacional, arquitetura evolutiva e segurança desde o início do desenvolvimento.

A plataforma deve ser concebida para atender aos seguintes objetivos:

- conectar pessoas a experiências sociais em locais de entretenimento;
- disponibilizar informações confiáveis sobre eventos e movimentação em tempo real;
- suportar picos de demanda nos finais de semana com alta disponibilidade;
- manter a evolução tecnológica sustentável e segura ao longo do ciclo de vida do produto.

## 2. Diretrizes de arquitetura

### 2.1 Frontend: Flutter (Dart)

O frontend mobile nativo deve ser implementado em Flutter, seguindo boas práticas de arquitetura e componentização.

- A aplicação deve usar padrões de projeto claros para gerenciamento de estado, com escolha explícita e consistente entre abordagens como BLoC, Riverpod, Provider ou outras soluções adequadas ao contexto da aplicação.
- Deve haver separação estrita entre UI, regras de negócio, estado e infraestrutura.
- A camada de apresentação não deve conter lógica de domínio complexa.
- Componentes devem ser altamente reutilizáveis, desacoplados e testáveis.
- O código deve seguir princípios de responsabilidade única, baixo acoplamento e alta coesão.
- A arquitetura deve permitir evolução incremental, sem acoplamento excessivo entre módulos.
- Todas as telas devem ser construídas com componentes padronizados, seguindo design system e consistência visual.

### 2.2 Backend: Elixir

O backend deve ser implementado em Elixir, aproveitando ao máximo as capacidades da BEAM.

- O sistema deve explorar o modelo de atores, concorrência e resiliência nativa da VM BEAM.
- O código deve empregar padrões de design funcionais, priorizando pureza, imutabilidade e composição.
- Domínios de negócio devem ser isolados em contextos delimitados, evitando acoplamento excessivo entre áreas.
- Cada contexto deve ter responsabilidades bem definidas, como autenticação, eventos, locais, movimentação, agendamento, notificações e relatórios.
- O sistema deve ser resiliente a falhas parciais e tolerante a picos de demanda.
- A comunicação entre módulos deve ser explícita, estável e orientada a contratos.
- O backend deve priorizar processamento concorrente e assíncrono sempre que o cenário exigir.

### 2.3 Arquitetura geral

- A solução deve ser pensada em camadas bem definidas: interface, aplicação, domínio e infraestrutura.
- O desenho do sistema deve facilitar manutenção, escalabilidade e evolução incremental.
- A arquitetura deve admitir múltiplas instâncias em ambientes conteinerizados com balanceamento de carga.
- O código deve ser modular, com interfaces bem definidas entre módulos e serviços.
- Componentes compartilhados devem ser reduzidos ao mínimo, priorizando independência e isolamento.

## 3. Qualidade de código

### 3.1 Modularidade e escalabilidade

- Todo código deve ser modular e organizado por responsabilidade.
- Módulos e funções devem ter escopo pequeno, nomes claros e intenção explícita.
- A estrutura deve facilitar a evolução do produto sem gerar regressões em áreas já estáveis.
- O design deve permitir adicionar novos recursos sem reescrever grandes blocos de código.
- O projeto deve utilizar convenções consistentes para organização de arquivos, pastas, testes e documentação.

### 3.2 Manutenibilidade

- O código deve ser simples, legível e de fácil entendimento.
- Nomes de variáveis, funções, módulos e tipos devem ser expressivos e coerentes com o domínio.
- Comentários devem ser usados apenas quando realmente necessários; a clareza do código deve prevalecer.
- Reduções de complexidade são exigidas; funções longas ou com múltiplas responsabilidades devem ser refatoradas.
- O projeto deve evitar antipadrões, duplicação excessiva e acoplamento desnecessário.

### 3.3 Testes automatizados

- Todo código gerado deve ser coberto por testes automatizados.
- O projeto deve incluir testes unitários, de integração e, quando aplicável, testes de contrato e comportamento.
- Os testes devem validar regras de negócio, fluxos críticos e integrações externas.
- Casos de borda e cenários de falha devem ser cobertos explicitamente.
- O conjunto de testes deve ser executado em cada mudança de código, de forma automatizada.
- A qualidade da suíte de testes é requisito estrutural do projeto, não uma atividade complementar.

### 3.4 Documentação de API e contratos

- A documentação de APIs deve ser clara, objetiva e orientada a contratos rígidos.
- Cada endpoint deve possuir definição explícita de requisição, resposta, status, erros e regras de negócio.
- O contrato da API deve ser versionado quando necessário, com compatibilidade e migração previstas.
- O código deve validar entradas e saídas de forma explícita e consistente.
- O projeto deve priorizar documentação viva, alinhada com o código e atualizada junto com as mudanças.

## 4. Segurança

### 4.1 Segurança por design

- A segurança deve ser considerada desde o início do desenvolvimento, não adicionada apenas no fim.
- O sistema deve seguir princípios de mínimo privilégio, defesa em profundidade e validação explícita de entradas.
- Dados sensíveis devem ser tratados com proteção adequada em trânsito e em repouso.
- Autenticação e autorização devem ser implementadas de forma robusta e verificável.
- O projeto deve evitar exposição indevida de dados, vazamentos de informações e falhas de validação.

### 4.2 Proteções de aplicação

- Todas as entradas externas devem ser validadas e sanitizadas.
- O backend deve tratar falhas de forma segura, sem vazamento de detalhes internos para clientes.
- O sistema deve ser resistente a abuso, sobrecarga e padrões comuns de ataque, como injeção, brute force e abuso de endpoints.
- Logs e observabilidade devem proteger informações sensíveis, sem expor segredos ou dados privados.

### 4.3 Segurança no ciclo de desenvolvimento

- Validações automatizadas de segurança devem fazer parte do pipeline de CI/CD.
- Dependências devem ser monitoradas e atualizadas de forma proativa.
- O projeto deve acompanhar boas práticas de segurança em código e infraestrutura.
- Vulnerabilidades críticas devem ser tratadas com prioridade máxima.

## 5. DevSecOps e infraestrutura

### 5.1 Conteinerização e disponibilidade

- A aplicação deve ser projetada desde o início para rodar em ambientes conteinerizados com Docker.
- O desenho da infraestrutura deve facilitar deploys em ambientes isolados e reproduzíveis.
- O sistema deve ser preparado para alta disponibilidade durante picos de acesso, especialmente em finais de semana.
- A arquitetura deve considerar escalabilidade horizontal, balanceamento de carga e tolerância a falhas.
- Processos críticos devem ser distribuídos e dimensionados para manter continuidade operacional mesmo sob carga elevada.

### 5.2 Integração contínua e entrega contínua

- A solução deve facilitar integração contínua e entrega contínua.
- Cada submissão de código deve disparar validações automáticas, incluindo:
  - lint;
  - análise estática;
  - testes unitários;
  - testes de integração;
  - validações de segurança;
  - checagens de build.
- O pipeline deve bloquear entregas que não atendam aos critérios mínimos de qualidade.
- O processo de deploy deve ser automatizado, repetível e seguro.

### 5.3 Observabilidade e operação

- O sistema deve emitir métricas, logs e traces adequados para operação e monitoramento.
- O ambiente deve permitir diagnóstico rápido de falhas e anomalias de desempenho.
- O projeto deve incluir mecanismos de monitoramento de saúde, disponibilidade e uso de recursos.
- A observabilidade deve ser tratada como parte integrante da arquitetura, não como atividade posterior.

## 6. Padrões de governança do projeto

### 6.1 Engenharia e qualidade

- A equipe deve manter padrões claros de revisão de código, arquitetura e qualidade.
- Mudanças que impactem contratos, domínio ou infraestrutura devem ser revisadas com atenção especial.
- O projeto deve priorizar compatibilidade, estabilidade e segurança sobre velocidade sem controle.
- O processo de desenvolvimento deve ser baseado em entregas incrementais e verificáveis.

### 6.2 Evolução contínua

- O produto deve evoluir com foco em experiência do usuário, resiliência, segurança e escalabilidade.
- Novos recursos só devem entrar no sistema quando alinhados a arquitetura e aos princípios da constituição do projeto.
- A arquitetura deve ser revisada periodicamente para garantir continuidade da adequação tecnológica.

## 7. Conclusão

A constituição do projeto BoraLá estabelece que o sistema deve ser construído com foco em qualidade, segurança, resiliência e escalabilidade. O Flutter e o Elixir são escolhidos para atender às necessidades do produto com padrões arquiteturais sólidos, testes automatizados e infraestrutura pronta para ambientes conteinerizados e de alta demanda.

O cumprimento destas diretrizes é essencial para garantir que o BoraLá seja uma plataforma confiável, segura e preparada para crescer com o produto e com a demanda real dos usuários.
