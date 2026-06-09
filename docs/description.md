# Documento de Descrição do Projeto: FinançasPessoais Mobile

## 1. Arquitetura

Para garantir escalabilidade, testabilidade e separação de conceitos (cruciais para um projeto de pós-graduação), o aplicativo adotará a **Clean Architecture** (Arquitetura Limpa), dividida em três camadas principais, utilizando o **Riverpod** para gerenciamento de estado avançado e injeção de dependências.

* **Camada de Apresentação (Presentation):** Contém as telas (Widgets) e os *Notifiers/StateNotifiers* (Riverpod). Focada exclusivamente na UI e em reagir às mudanças de estado.
* **Camada de Domínio (Domain):** O coração da aplicação. Contém as entidades de negócio (ex: `Transaction`, `Category`), os contratos dos repositórios (interfaces) e os casos de uso (*Use Cases*), totalmente independentes de bibliotecas externas.
* **Camada de Dados (Data):** Responsável por buscar e persistir dados. Contém as implementações dos repositórios, os Modelos (para serialização JSON) e os *Data Sources* (comunicação externa via API REST com o Laravel ou cache local).

---

## 2. Plataforma Tecnológica

A stack tecnológica foi desenhada para desacoplar o cliente mobile do servidor backend, garantindo sincronia em tempo real:

* **Framework Mobile:** Flutter (versão estável atual)
* **Linguagem:** Dart
* **Gerenciamento de Estado:** Riverpod (reativo, seguro contra falhas em tempo de compilação)
* **Consumo de API:** Dio (Cliente HTTP avançado com suporte a interceptors para autenticação)
* **Gráficos:** `fl_chart` (para renderização do gráfico de pizza por categorias)
* **Backend & API:** Laravel 12 (com as regras já centralizadas nas *Actions* exposed via API REST)
* **Banco de Dados:** SQLite (gerenciado pelo Laravel no ambiente de servidor)
* **Ambiente de Desenvolvimento (DevOps):** Infraestrutura baseada em contêineres **Docker** para rodar o ecossistema Laravel localmente, com controle de versão via **GitHub**.

---

## 3. Estrutura de Diretórios (Padrão Flutter Feature-First)

A estrutura organiza o projeto por funcionalidades (*features*), facilitando a manutenção:

```text
lib/
├── core/                        # Recursos compartilhados por todo o app
│   ├── constants/               # Cores (Design Tokens), dimensões e caminhos
│   ├── network/                 # Cliente HTTP (Dio) e interceptores de Token
│   └── theme/                   # Configuração de Light/Dark Mode (Semelhante ao Preline UI)
├── features/                    # Funcionalidades isoladas do sistema
│   ├── auth/                    # Autenticação (Login, Cadastro)
│   ├── dashboard/               # Resumo financeiro e Gráficos (fl_chart)
│   ├── transactions/            # CRUD de Transações (Receitas/Despesas)
│   └── categories/              # Gerenciamento de Categorias
│       ├── data/                # Data Sources e Modelos (JSON)
│       ├── domain/              # Entidades e Casos de Uso
│       └── presentation/        # Widgets e Riverpod Providers
└── main.dart                    # Ponto de entrada da aplicação

```

---

## 4. Convenções

Para garantir a consistência do código do projeto de pós-graduação:

* **Nomenclatura de Arquivos:** `snake_case` (ex: `transaction_card_widget.dart`).
* **Classes e Tipos:** `PascalCase` (ex: `CreateTransactionUseCase`).
* **Variáveis e Métodos:** `camelCase` (ex: `currentBalance`).
* **Padrão de Commits:** *Conventional Commits* (`feat:`, `fix:`, `docs:`, `refactor:`).
* **Código Limpo:** Uso obrigatório do `flutter_lints` com regras estritas para evitar acoplamento e garantir tipagem estática forte.

---

## 5. Serviços

O aplicativo mobile consumirá os serviços expostos pelo ecossistema Laravel através dos seguintes contratos (endpoints):

| Serviço Mobile | Endpoint Laravel correspondente | Descrição |
| --- | --- | --- |
| **AuthService** | `/api/auth/*` | Autenticação, login e registro utilizando tokens JWT/Sanctum. |
| **TransactionService** | `/api/transactions` | Sincroniza receitas/despesas, datas e valores vinculados ao usuário. |
| **CategoryService** | `/api/categories` | Lista e vincula as categorias dos gastos. |
| **AIService** | `/api/documents/upload` | Envia fotos de recibos (da câmera/galeria) para processamento da IA Claude no backend. |

---

## 6. Variáveis de Ambiente

O gerenciamento de configurações críticas será feito através de um arquivo `.env` na raiz do projeto Flutter (usando pacotes como `flutter_dotenv` ou `--dart-define`):

```env
API_BASE_URL=http://localhost:8000/api/v1
API_TIMEOUT=5000
APP_ENV=development

```

---

## 7. Definição de Usuários e Casos de Uso

Mapeando as regras de negócio a partir do modelo de controle de acesso solicitado e do banco de dados fornecido:

### Níveis de Acesso

1. **Cliente (Usuário Final):** O dono da conta financeira. Realiza o **autocadastro** diretamente pelo aplicativo mobile. Tem acesso total ao seu dashboard, upload de PDFs/fotos de recibos, controle de despesas e visualização de gráficos.

### Casos de Uso Mapeados para o App

* **UC01 - Autocadastro de Cliente:** Permite que novos usuários criem suas contas informando Nome, E-mail, CPF e Senha.
* **UC02 - Lançamento de Transação Manual:** Formulário com validação de campos para adicionar despesa/receita (Título, valor, categoria, data).
* **UC03 - Visualização Consolidada:** Dashboard reativo com o saldo atualizado e gráfico de pizza gerado pelo `fl_chart`.