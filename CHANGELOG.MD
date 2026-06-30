# Changelog

## [Unreleased] - 2026-06-30

### Segurança (Auditoria)
- **Inspeção de Segurança Profunda (OWASP Top 10)**: Realizada auditoria de cibersegurança de profundidade PROFUNDA em todo o projeto (`/lib/`, `/android/`, `pubspec.yaml`, `.env`, `.gitignore`). Identificadas **15 vulnerabilidades**: 2 críticas, 4 altas, 5 médias e 4 baixas. Relatório completo gerado em `security_audit_report.md`.
  - **[CRÍTICO – VUL-01]** Token JWT armazenado em `SharedPreferences` (plain text). Recomendado: migrar para `flutter_secure_storage` com `EncryptedSharedPreferences` (Android) e `Keychain` (iOS). Refs: CWE-312, CWE-922.
  - **[CRÍTICO – VUL-02]** Arquivo `.env` empacotado como asset Flutter (`pubspec.yaml` linha 70), exposição da URL de produção no APK. Recomendado: usar `--dart-define` e remover `flutter_dotenv`. Refs: CWE-312, CWE-200.
  - **[ALTO – VUL-03]** `LogInterceptor(requestBody: true, responseBody: true)` ativo em produção (`dio_client.dart` linha 17), podendo expor tokens e dados financeiros em logs. Recomendado: envolver em bloco `assert()`.
  - **[ALTO – VUL-04]** Ausência de SSL Pinning no `DioClient`. Recomendado: configurar `SecurityContext` com certificado fixo.
  - **[ALTO – VUL-05]** Inconsistência entre `ApiPaths.base` e `EnvConfig.apiBaseUrl` com fallback `http://` (sem TLS). Recomendado: consolidar em fonte única com fallback `https://`.
  - **[ALTO – VUL-06]** Mensagens de erro brutas do servidor e stack traces propagados para a UI. Refs: CWE-209.
  - **[MÉDIA – VUL-07]** Ausência de cooldown local no botão "Reenviar código 2FA". Refs: CWE-307.
  - **[MÉDIA – VUL-08]** `deviceName` hardcoded como `'App Mobile'` em `verification_page.dart` linha 122.
  - **[MÉDIA – VUL-09]** Campos de texto livre sem `maxLength` (`create_transaction_page.dart`, `create_category_page.dart`). Refs: CWE-20, CWE-400.
  - **[MÉDIA – VUL-10]** `Color(int.parse('0xFF${cs.categoryColor}'))` sem validação em `dashboard_page.dart`, pode causar crash. Refs: CWE-248.
  - **[MÉDIA – VUL-11]** Logout sem dialog de confirmação no `DashboardPage`.
  - **[MÉDIA – VUL-12]** Possível presença do `.env` no histórico Git. Recomendado: verificar com `git log --all -- .env`.
  - **[BAIXA – VUL-13]** Ausência de `FLAG_SECURE` no `AndroidManifest.xml`, permitindo screenshots por outros apps.
  - **[BAIXA – VUL-14]** Builds sem obfuscação (`--obfuscate --split-debug-info`), facilitando engenharia reversa.
  - **[BAIXA – VUL-15]** Ausência de autenticação biométrica local antes de exibir dados financeiros. Refs: OWASP Mobile M4.

## [1.5.0] - 2026-06-30

### Adicionado
- **Componentes Core de Estado (`lib/core/widgets/state_widgets.dart`)**:
  - Desenvolvido `LoadingWidget` com suporte semântico para carregamento.
  - Desenvolvido `ErrorFallbackWidget` com suporte a retry e revalidação assíncrona de providers via Riverpod.
  - Desenvolvido `EmptyStateWidget` com suporte a ícones temáticos e botões de chamada para ação (CTA).
- **Testes Responsivos e Acessibilidade (`test/features/dashboard/presentation/pages/responsive_dashboard_test.dart`)**:
  - Criados testes de layout responsivo sob resoluções ampliadas (wide screens).
  - Criados testes de asserção semântica para validação da acessibilidade do leitor de tela.
- **Testes de Componentes Core (`test/core/widgets/state_widgets_test.dart`)**:
  - Criados testes para os estados Loading, Error e Empty.

### Alterado
- **Acessibilidade Semântica**:
  - Refatorado `TransactionCardWidget` para agrupar todas as propriedades visuais em uma narração unificada e coerente para leitores de tela (`Semantics` com exclusão de filhos).
  - Incluídas marcações semânticas de acessibilidade no Drawer e nos cards do Dashboard.
- **Responsividade de Tela**:
  - Refatoradas as telas `LoginPage`, `RegisterPage` e `VerificationPage` para limitar a largura máxima do formulário central a `500.0` pixels em telas largas.
  - Refatorado o `DashboardPage` para reorganizar os resumos horizontais e o gráfico/legenda lado a lado em resoluções >= 600px wide.
- **Estados de Tela Integrados**:
  - Substituídos os indicadores de carregamento simples e fallbacks de erro textuais de `TransactionsPage` e `CategoriesPage` pelos novos componentes `LoadingWidget`, `ErrorFallbackWidget` e `EmptyStateWidget` com retry automático.
- **Documentação de Sistema**:
  - Atualizado `docs/specs.md` para incluir a seção "8. Padrões de Interface, Responsividade e Acessibilidade".
  - Atualizado `docs/testing.md` para incluir a seção "6. Novos Cenários de Testes de Frontend e Acessibilidade".

## [1.4.0] - 2026-06-30

### Alterado
- **Especificações de Negócio (`docs/description.md`)**:
  - Consolidadas as seções de arquitetura, diretórios e convenções para remover redundâncias textuais.
  - Removido o campo redundante e inconsistente de CPF do caso de uso `UC01 (Autocadastro)`.
  - Adicionado requisito para validação formal de e-mail por expressões regulares (`regex`).
- **Plano de Testes (`docs/testing.md`)**:
  - Adicionados cenários de testes de formato regex para `LoginUseCase` e `RegisterUseCase`.
  - Mapeados cenários de testes unitários para a classe `RegisterUseCase`.
- **Validação de E-mail (Domínio & Apresentação)**:
  - Implementada a validação por RegExp no `LoginUseCase` e `RegisterUseCase`.
  - Atualizados os validadores de formulários da `LoginPage` e `RegisterPage` para conformidade com a especificação de regex.

### Adicionado
- **Testes Unitários**:
  - Criada suíte de testes unitários em `test/features/auth/domain/usecases/register_usecase_test.dart` validando nome, senha, regex de e-mails e comportamento de sucesso.
  - Atualizados os testes unitários do `LoginUseCase` para testar variados e-mails mal-formados.

## [1.3.0] - 2026-06-15

### Adicionado
- **Feature 3 (Categorias)**:
  - Criadas entidades de domínio, repositórios e casos de uso (Get, Create, Update, Delete) com validações.
  - Implementado modelo de persistência com fallback padrão de ícone e cores para evitar nulidade na desserialização de JSON.
  - Criadas as telas de listagem, criação e edição de categorias com paleta de cores e seleção de ícones Material.
- **Feature 4 (Transações)**:
  - Criadas entidades de domínio, repositórios e casos de uso com validações de negócio (valor > 0, título obrigatório, categoria obrigatória).
  - Desenvolvido o `TransactionModel` compatibilizando as chaves do contrato da API com o modelo interno.
  - Criadas telas de listagem (com swipe-to-delete e pull-to-refresh), criação e edição de transações com seleção de data (DatePicker) e seleção dinâmica de categorias via dropdown.
  - Desenvolvido o componente visual `TransactionCardWidget`.
- **Navegação & Interface**:
  - Implementada a barra lateral (Side Drawer) no `DashboardPage` permitindo livre trânsito entre o Dashboard, a página de Transações e a página de Categorias.
- **Testes Automatizados (TDD)**:
  - Desenvolvidos testes unitários para os casos de uso, modelos de dados e implementações de repositório para ambas as features, garantindo cobertura total de cenários e tipagem estática.

## [1.2.0] - 2026-06-10

### Adicionado
- **Auto-Login**: Implementada a verificação automática de token ao iniciar o aplicativo. O `AuthNotifier` tenta recuperar o perfil do usuário logado através da rota `/auth/user`. Se o token for válido, redireciona o usuário para o `DashboardPage`; caso contrário, redireciona para a `LoginPage`.
- **Feature 5 (Dashboard)**:
  - Criada a entidade `DashboardSummary` e a interface `DashboardRepository` no domínio.
  - Criado o caso de uso `GetDashboardSummaryUseCase`.
  - Criada a fonte de dados remota `DashboardRemoteDataSourceImpl` e o repositório `DashboardRepositoryImpl` para consumir a rota `/api/reports` diretamente do backend.
  - Criados os providers do Dashboard com Riverpod.
  - Implementada a interface da `DashboardPage` mostrando o saldo consolidado, receitas, despesas e distribuição por categorias via gráfico de pizza utilizando o pacote `fl_chart`.
- **Testes Automatizados (TDD)**:
  - Adicionados testes de unidade para `GetDashboardSummaryUseCase`, `DashboardSummaryModel`, `DashboardRemoteDataSourceImpl` e `DashboardRepositoryImpl`.
  - Adicionados testes de widget para a interface da `DashboardPage` cobrindo estados de carregamento, sucesso e falha.
  - Adicionados testes de unidade para `AuthNotifier.checkAuthStatus()`.

### Alterado
- **Especificações Técnicas (`docs/specs.md`)**: Atualizada a seção 5 ("Feature: Dashboard") para formalizar a decisão arquitetural de usar o `DashboardRepository` e a rota `/api/reports` diretamente do backend, ao invés da agregação de dados local.
- **Configuração de Dependências (`pubspec.yaml`)**: Adicionada a dependência oficial `fl_chart` para renderização de gráficos.
- **Ponto de Entrada (`lib/main.dart`)**: Atualizado para carregar a sessão automática do usuário e realizar o roteamento declarativo inicial.

## [1.1.0] - 2026-06-10

### Alterado
- **Especificações Técnicas (`docs/specs.md`)**: Reorganização completa do fluxo de autenticação para dar suporte a Autenticação de Dois Fatores (2FA) integrada com Sanctum, conforme especificado em `docs/api_contract_mobile.md`.
  - Atualizada a classe `ApiPaths` com as novas rotas de 2FA (`/auth/verify-code` e `/auth/resend-code`) e a rota do perfil do usuário para `/auth/user`.
  - Alterada a interface `AuthRepository` e sua implementação `AuthRepositoryImpl` para adequar as assinaturas de `login` e `register` e incluir novos métodos para confirmação de código e reenvio.
  - Atualizado o modelo `UserModel` para incluir o token de autenticação e realizar desserialização apropriada.
  - Atualizado o `AuthNotifier` para controlar estados com suporte a `AuthStatus.codeSent` e novos métodos `verifyCode` e `resendCode`.
  - Inclusão do caso de uso `VerifyCodeUseCase` e do `ResendCodeUseCase` com seus respectivos providers.
  - Inclusão da especificação da página `VerificationPage` para captura e confirmação do código de verificação recebido pelo e-mail do usuário.
  - Atualização do roteamento básico no `lib/main.dart` para encaminhar o usuário à página de verificação de código se o status de login/registro for `codeSent`.
- **Diretrizes de Agentes (`AGENTS.md`)**: Inclusão de novas regras de testes voltadas à estratégia TDD (Mocking, Padrão AAA e Cobertura) e menção aos documentos de especificação atualizados.
- **Instruções para LLMs (`README.md`)**: Adicionada mensagem HTML oculta obrigatória no topo do arquivo orientando agentes de IA a lerem rigorosamente o arquivo `AGENTS.md` antes de qualquer execução.

### Adicionado
- **Feature 1 (Core)**: Implementação da infraestrutura base da aplicação (Clean Architecture) com Riverpod, Dio (configurado com interceptador de autenticação JWT), constantes de design e gestão de variáveis de ambiente com `flutter_dotenv`.
- **Feature 2 (Auth)**: Implementação completa do fluxo de autenticação em todas as camadas (Domain, Data e Presentation) seguindo as especificações. Adicionadas as telas de `LoginPage`, `RegisterPage` e `VerificationPage` com Riverpod gerindo os estados de verificação 2FA.
- **Testes Automatizados (TDD)**: Criação de suíte completa de testes (`flutter test`) alcançando a validação de regras de negócio em Domain, DataSources, Models, e Widget Tests para comportamento de interface, usando `mockito`.
