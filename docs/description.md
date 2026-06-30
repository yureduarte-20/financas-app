# Documento de Descrição do Projeto: FinançasPessoais Mobile

## 1. Arquitetura e Organização do Código

Para garantir escalabilidade, testabilidade e separação de conceitos, o aplicativo adota a **Clean Architecture** organizada por funcionalidades (**Feature-First**), utilizando o **Riverpod** para gerenciamento de estado e injeção de dependências.

### Camadas da Arquitetura:
* **Presentation:** Telas (Widgets) e Notifiers (Riverpod) focados na UI e em reagir ao estado.
* **Domain:** Entidades (`Transaction`, `Category`, `User`), interfaces dos repositórios e Casos de Uso (*Use Cases*). Livre de dependências externas.
* **Data:** Repositórios concretos, serializadores/modelos JSON e fontes de dados (*Data Sources* - Dio ou local).

### Estrutura do Diretório `lib/`:
```text
lib/
├── core/                        # Recursos compartilhados (constants, network, theme)
└── features/                    # Funcionalidades (auth, dashboard, transactions, categories)
    ├── data/                    # Fontes de dados e Modelos (JSON)
    ├── domain/                  # Entidades e Casos de Uso (regras de negócio puras)
    └── presentation/            # Widgets de UI e Notifiers do Riverpod
```

### Convenções de Nomenclatura:
* **Arquivos:** `snake_case` (ex: `transaction_card_widget.dart`).
* **Classes e Tipos:** `PascalCase` (ex: `CreateTransactionUseCase`).
* **Variáveis e Métodos:** `camelCase` (ex: `currentBalance`).
* **Estilo & Linter:** Commits no padrão *Conventional Commits* e regras estritas do `flutter_lints`.

---

## 2. Stack Tecnológica e Serviços de Integração

A stack de tecnologia garante desacoplamento e robustez na comunicação:
* **Core:** Flutter & Dart com cliente HTTP **Dio** (configurado com timeout, tratamento de erros e interceptadores de autenticação JWT/Sanctum).
* **Gráficos:** `fl_chart` para resumos visuais.
* **Configuração:** `flutter_dotenv` para variáveis do arquivo `.env` (ex: `API_BASE_URL` e `API_TIMEOUT`).

### Endpoints de Integração:
O aplicativo consome os serviços da API REST do Laravel via cabeçalhos comuns (`Accept: application/json` e `Authorization: Bearer <token>`):
* **Autenticação:** `/api/auth/register`, `/api/auth/login`, `/api/auth/verify-code`, `/api/auth/resend-code`, `/api/auth/user`, `/api/auth/logout`.
* **Transações:** `/api/transactions` (CRUD de lançamentos manuais).
* **Categorias:** `/api/categories` (CRUD de classificação).
* **Auxiliares:** `/api/documents/upload` (envio de fotos de recibos para OCR/IA no backend).

---

## 3. Definição de Usuários, Casos de Uso e Regras de Validação

### Nível de Acesso:
* **Cliente (Usuário Final):** Dono da conta financeira. Realiza autocadastro, gerencia suas transações/categorias e visualiza relatórios.

### Casos de Uso e Regras de Negócio:

#### UC01 - Autocadastro de Cliente & Login (Fluxo com 2FA)
Permite a criação e o login de contas. O autocadastro exige o preenchimento de **Nome**, **E-mail** e **Senha** (o campo CPF foi removido por não constar no contrato da API externa).
* **Validação de E-mail (Regex Obrigatória):** O campo e-mail deve seguir estritamente o formato padrão da regex `r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"` (aplicado tanto na validação do formulário na tela quanto na validação dos Casos de Uso de domínio).
* **Validação de Senha:** Mínimo de 6 caracteres.
* **Validação de Nome:** Obrigatório (não pode estar em branco).
* **Fluxo 2FA:** A validação correta inicia o envio do código de 6 dígitos ao e-mail cadastrado (estado `codeSent`). O acesso só é concedido após verificação bem-sucedida do código de 6 dígitos digitado na tela de verificação.

#### UC02 - Lançamento e Controle de Transação Manual
Permite registrar receitas e despesas informando:
* **Tipo:** Segmentação entre receita (`income`) ou despesa (`out`).
* **Título:** Obrigatório e não vazio.
* **Valor:** Obrigatório e maior que zero.
* **Categoria:** Seleção obrigatória via dropdown.
* **Data:** Selecionada via DatePicker.
A listagem suporta exclusão via gesto *Swipe* (`Dismissible`) e atualização sob demanda com *pull-to-refresh*.

#### UC03 - Visualização Consolidada (Dashboard)
Apresenta o saldo de forma exata ($\text{Receitas} - \text{Despesas}$), totais isolados e gráfico de pizza da distribuição de gastos por categoria.