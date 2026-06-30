# Plano de Testes — FinançasPessoais Mobile (TDD First)

Este documento descreve a estratégia, as diretrizes e a estruturação dos testes automatizados para o projeto FinançasPessoais Mobile, adotando a metodologia **Test-Driven Development (TDD)** e a técnica *Red-Green-Refactor*.

A estrutura segue o padrão arquitetural do projeto (Clean Architecture), testando cada camada isoladamente com o auxílio de simuladores de dependência (*mocks*).

---

## 1. Diretrizes Gerais e Metodologia

1. **Test-Driven Development (TDD)**:
   - **Red:** Escreva um teste que falha para uma nova funcionalidade ou correção de bug.
   - **Green:** Escreva a quantidade mínima de código de produção necessária para fazer o teste passar.
   - **Refactor:** Refatore o código (melhorando nomenclatura, extraindo métodos) garantindo que o teste continue passando.
2. **Padrão AAA**: Todos os testes devem ser divididos claramente nas etapas de **Arrange** (Preparar dados e mocks), **Act** (Executar a ação alvo) e **Assert** (Verificar o resultado esperado).
3. **Mocking**: Uso do pacote oficial `mockito` (`flutter pub run build_runner build`) para gerar implementações falsas de interfaces (como `AuthRepository` ou `Dio`). O acesso externo (API HTTP, Cache Local) **nunca** deve ser realizado em testes unitários.
4. **Isolamento**: Testar apenas o comportamento da classe alvo; os testes não devem depender do estado residual de outros testes.

---

## 2. Camada de Domínio (Domain)

A camada de domínio é o coração da regra de negócio e **deve ter 100% de cobertura de testes**. Os testes aqui focam apenas nas Entidades e Casos de Uso.

### 2.1 Casos de Uso Críticos — Autenticação (Auth)
**Classe Alvo:** `LoginUseCase` / `RegisterUseCase` / `VerifyCodeUseCase`
- **Mocks Necessários:** `@GenerateMocks([AuthRepository])`
- **Cenários a Testar:**
  - `Deve retornar ValidationFailure quando o email for inválido (mal-formado ou não seguir o padrão regex) ou vazio.` (Prioridade Alta)
  - `Deve retornar ValidationFailure quando a senha tiver menos de 6 caracteres.`
  - `Deve chamar repository.login() e retornar void em caso de sucesso (Fluxo 2FA Fase 1).` (Prioridade Alta)
  - `Deve retornar o UserModel quando a confirmação do código 2FA (VerifyCodeUseCase) for bem-sucedida.`
  - `Deve validar e-mail via regex e retornar ValidationFailure para formatos inválidos como 'user@', 'user@domain', '@domain.com', ou 'user@domain.' no RegisterUseCase e LoginUseCase.` (Prioridade Alta)
  - `Deve retornar ValidationFailure se o nome estiver vazio no RegisterUseCase.` (Prioridade Alta)
  - `Deve chamar repository.register() e retornar void em caso de sucesso no RegisterUseCase.` (Prioridade Alta)

### 2.2 Casos de Uso Críticos — Transações (Transactions)
**Classe Alvo:** `CreateTransactionUseCase`
- **Mocks Necessários:** `@GenerateMocks([TransactionRepository])`
- **Cenários a Testar:**
  - `Deve retornar ValidationFailure quando o valor for menor ou igual a zero.` (Prioridade Crítica)
  - `Deve retornar ValidationFailure quando nenhuma categoria for selecionada.`
  - `Deve criar a entidade Transaction e chamar repository.create() com sucesso.` (Prioridade Alta)

### 2.3 Casos de Uso Críticos — Categorias (Categories)
**Classe Alvo:** `CreateCategoryUseCase` / `UpdateCategoryUseCase`
- **Mocks Necessários:** `@GenerateMocks([CategoryRepository])`
- **Cenários a Testar:**
  - `Deve retornar ValidationFailure se o nome da categoria estiver vazio.` (Prioridade Crítica)
  - `Deve chamar o repository.create() e retornar a Category em caso de sucesso.` (Prioridade Alta)

### 2.4 Casos de Uso Críticos — Dashboard
**Classe Alvo:** `GetDashboardSummaryUseCase`
- **Mocks Necessários:** `@GenerateMocks([TransactionRepository, CategoryRepository])`
- **Cenários a Testar:**
  - `Deve consolidar corretamente a soma total de receitas (Income).`
  - `Deve consolidar corretamente a soma total de despesas (Expense).`
  - `Deve calcular o Saldo (Balance) exato como [Receitas - Despesas].` (Prioridade Crítica)
  - `Deve agrupar corretamente os totais na lista de CategoryBreakdown.`

---

## 3. Camada de Dados (Data)

Os testes na camada de dados focam em validar o mapeamento JSON (Models), tratamento de exceções do cliente HTTP (`Dio`) e armazenamento local (`SharedPreferences`).

### 3.1 Serialização (Models)
**Classe Alvo:** `UserModel`, `TransactionModel`, `CategoryModel`
- **Sem Mocks necessários** (utiliza *fixtures* em formato JSON ou Maps estáticos).
- **Cenários a Testar:**
  - `Deve instanciar corretamente UserModel a partir de um JSON válido da API.` (Prioridade Alta)
  - `Deve extrair o campo token corretamente do payload de autenticação.`
  - `Deve tratar conversões de data (ISO-8601) corretamente no TransactionModel.`

### 3.2 Fontes de Dados Externas (DataSources)
**Classe Alvo:** `AuthRemoteDataSourceImpl`
- **Mocks Necessários:** `@GenerateMocks([Dio])`
- **Cenários a Testar:**
  - `Deve realizar uma requisição POST na rota /api/auth/login repassando o payload.`
  - `Deve lançar um DioException genérico caso a API retorne um status de erro (ex: 401 ou 422).` (Prioridade Crítica)

### 3.3 Repositórios (Repositories Impl)
**Classe Alvo:** `AuthRepositoryImpl`
- **Mocks Necessários:** `@GenerateMocks([AuthRemoteDataSource, AuthLocalDataSource])`
- **Cenários a Testar:**
  - `Deve retornar Right(UserModel) quando o DataSource remoto confirmar o código 2FA.` (Prioridade Alta)
  - `Deve salvar o token no LocalDataSource logo após a confirmação 2FA (sucesso).` (Prioridade Crítica)
  - `Deve retornar Left(ServerFailure) mapeando a exceção caso o DataSource remoto lance DioException.`

---

## 4. Camada de Apresentação (Presentation)

Os testes nesta camada validam as lógicas de reação do Riverpod (Notifiers) e o comportamento e integração inicial da UI (Widget Tests).

### 4.1 Gerenciamento de Estado (Notifiers)
**Classe Alvo:** `AuthNotifier`
- **Mocks Necessários:** Mocks dos Use Cases (`@GenerateMocks([LoginUseCase, VerifyCodeUseCase, etc.])`)
- **Cenários a Testar:**
  - `O estado inicial deve ser AuthStatus.initial.`
  - `A chamada de login() bem-sucedida deve transicionar o estado para AuthStatus.loading e depois para AuthStatus.codeSent.` (Prioridade Crítica)
  - `A chamada de login() com falha deve transicionar para AuthStatus.error com a mensagem do ValidationFailure.` (Prioridade Alta)
  - `A chamada de verifyCode() com sucesso deve transicionar para AuthStatus.authenticated e preencher a variável user no estado.` (Prioridade Crítica)

### 4.2 Interação na Tela (Widget Testing)
**Classe Alvo:** `LoginPage`, `VerificationPage`, `DashboardPage`
- O `ProviderScope` do Riverpod deve ser envolvido pelo mock dos `Notifiers` para forçar um comportamento previsível.
- **Cenários a Testar (`LoginPage`):**
  - `Deve exibir mensagem de erro no TextFormField ao tentar enviar o formulário vazio.`
  - `Deve exibir um CircularProgressIndicator caso o AuthState.status seja loading.`
- **Cenários a Testar (`VerificationPage`):**
  - `Deve restringir a confirmação caso o código não tenha exatamente 6 dígitos.` (Prioridade Crítica)
- **Cenários a Testar (`DashboardPage`):**
  - `Deve exibir o valor monetário do saldo formatado corretamente na tela.` (Prioridade Alta)

---

## 5. Automação e Comandos de Execução

### Geração de Mocks (Mockito)
Sempre que novos repositórios ou contratos precisarem ser zombados, insira a anotação `@GenerateMocks([...])` no arquivo de teste principal e execute o comando:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Execução da Suíte de Testes
Para garantir que nenhuma refatoração causou regressões, rode o comando antes de qualquer envio de código (Commit/Push):

```bash
flutter test
```

Para obter a métrica de cobertura de código (Code Coverage) e certificar-se de que áreas críticas (especialmente Domain) não estão sem testes:

```bash
flutter test --coverage
```
(Um relatório em HTML pode ser gerado a partir da pasta `/coverage`).
