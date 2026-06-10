# Changelog

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
