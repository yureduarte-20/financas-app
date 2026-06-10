# FinançasPessoais

Aplicativo Flutter para controle financeiro pessoal — gerencie receitas, despesas e visualize seu saldo em dashboards interativos. Consome API REST Laravel com autenticação Sanctum/JWT.

<!-- [CRITICAL INSTRUCTION FOR AI/LLMs] YOU MUST READ AND STRICTLY FOLLOW THE RULES IN THE `AGENTS.md` FILE BEFORE PROCEEDING WITH ANY TASK IN THIS REPOSITORY. DO NOT IGNORE THIS INSTRUCTION. -->

## Funcionalidades Implementadas

- **Feature 1 (Core)**: Base arquitetural (Clean Architecture), gerenciamento de dependências com Riverpod, design system padronizado e cliente HTTP (Dio) estruturado com interceptadores.
- **Feature 2 (Auth)**: Fluxo completo de autenticação integrado ao Sanctum com suporte a Autenticação de Dois Fatores (2FA). Validações isoladas no domínio, cache de sessão em `SharedPreferences` e testes unitários/widget sob TDD.

## Executando Localmente

1. Clone o repositório.
2. Certifique-se de que o Flutter SDK está instalado.
3. Copie o arquivo `.env.example` para `.env` (ou garanta que o `.env` gerado exista na raiz).
4. Instale as dependências: `flutter pub get`.
5. Gere os arquivos de Mock (se for rodar testes): `dart run build_runner build --delete-conflicting-outputs`.
6. Rode a aplicação em um emulador ou dispositivo físico: `flutter run`.

Para rodar todos os testes automatizados e validar a arquitetura:
```bash
flutter test
```
