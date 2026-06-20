
## 1. Descrição Preliminar do Sistema

O **FinançasPessoais Mobile** é um aplicativo de controle financeiro pessoal voltado para o usuário final (Cliente). Ele funciona de forma desacoplada de um servidor backend (Laravel 12), consumindo uma API REST via cliente HTTP avançado (Dio) e gerenciando a segurança por meio de tokens JWT/Sanctum com autenticação em dois fatores (2FA) via e-mail.

### Características Principais:

* **Arquitetura modular:** Organizado em padrão *Feature-First* (funcionalidades isoladas) divididas em três camadas (Apresentação, Domínio e Dados) para garantir alta testabilidade e independência de frameworks.
* **Interface Reativa:** Suporta modos claro e escuro (*Light/Dark Mode*), guiados por Design Tokens de espaçamento e cores, oferecendo feedback visual em tempo real (como *pull-to-refresh* e remoção por gesto *swipe*).
* **Inteligência e Análise:** Além de gráficos de pizza reativos para distribuição de despesas por categoria, o ecossistema prevê integração com inteligência artificial para leitura e processamento de recibos físicos.

---

## 2. Detalhamento dos Casos de Uso

Abaixo estão mapeados os fluxos de negócio identificados nos documentos técnicos, divididos por suas respectivas funcionalidades (*features*):

### 🔑 Funcionalidade: Autenticação (Auth)

#### UC01 – Autocadastro de Cliente

* **Atores:** Cliente (Usuário Final).
* **Descrição:** Permite que um novo usuário crie sua conta diretamente pelo aplicativo mobile.
* **Fluxo Principal:** O usuário insere Nome, E-mail, CPF e Senha. O sistema valida os campos (senha mínima de 6 caracteres e e-mail via regex), envia os dados ao backend Laravel e dispara um código de verificação para o e-mail do usuário, direcionando-o para a tela de 2FA.

#### UC01.1 – Autenticação com Segundo Fator (Fluxo de Login / Confirmação 2FA)

* **Atores:** Cliente.
* **Descrição:** Realiza o login em duas etapas para garantir o acesso seguro à conta financeira.
* **Fase 1 (Solicitação):** O usuário insere e-mail e senha na `LoginPage`. Se válidos, o estado muda para `codeSent` e ele é levado à tela de verificação.
* **Fase 2 (Verificação):** Na `VerificationPage`, o usuário digita o código de 6 dígitos recebido por e-mail. O sistema valida o formato, envia ao servidor, armazena o token JWT localmente via `SharedPreferences` e concede acesso ao Dashboard.
* **Fluxos Alternativos:** O usuário pode solicitar o reenvio do código ou cancelar a verificação para retornar à tela de login.

---

### 💵 Funcionalidade: Transações (Transactions)

#### UC02 – Lançamento de Transação Manual

* **Atores:** Cliente.
* **Descrição:** Permite incluir manualmente uma nova movimentação financeira (Receita ou Despesa) para manter o saldo atualizado.
* **Fluxo Principal:** O usuário preenche o formulário informando: Tipo (Receita/Despesa via botão segmentado), Título, Valor (maior que zero), Categoria (selecionada via *dropdown*) e Data (através de um *DatePicker*). Ao salvar, a lista de transações é invalidada para forçar a atualização dos dados.

#### UC02.1 – Gerenciamento e Exclusão de Transações

* **Atores:** Cliente.
* **Descrição:** Visualização detalhada do histórico financeiro e exclusão rápida.
* **Fluxo Principal:** O usuário navega pela lista de transações (com suporte a *pull-to-refresh* para recarregar). Ele pode utilizar o gesto de *Swipe* (deslizar o card) para acionar a remoção de uma transação via `Dismissible`, atualizando o saldo imediatamente.

---

### 📊 Funcionalidade: Dashboard e Relatórios

#### UC03 – Visualização Consolidada (Dashboard)

* **Atores:** Cliente.
* **Descrição:** Tela inicial que oferece um resumo financeiro integrado e visual sobre a saúde financeira do usuário.
* **Fluxo Principal:** O aplicativo consome o endpoint `/api/reports` para obter o `DashboardSummary`. A tela renderiza:
1. O saldo atual calculado de forma exata ($\text{Receitas} - \text{Despesas}$).
2. Blocos informativos com os totais isolados de receitas e despesas.
3. Um gráfico de pizza (`fl_chart`) demonstrando a distribuição percentual dos gastos agrupados por categoria.



---

### 📂 Funcionalidade: Categorias & IA (Auxiliares)

#### UC04 – Gerenciamento de Categorias de Gastos

* **Atores:** Cliente.
* **Descrição:** Permite personalizar as categorias que classificam os fluxos financeiros.
* **Fluxo Principal:** O usuário visualiza as categorias existentes com seus respectivos ícones e cores. Ele pode criar ou editar registros preenchendo o Nome, selecionando um ícone Material e escolhendo uma cor a partir de uma paleta pré-definida.

