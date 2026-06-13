# Documento de Visão Preliminar e Casos de Uso: Sistema de Ordens de Serviços Mobile

---

## 1. Visão Geral do Produto

O **Sistema de Ordens de Serviços Mobile** é uma solução de software voltada para prestadores de serviços e técnicos que necessitam gerenciar seus atendimentos de forma ágil, integrada e em tempo real. O aplicativo visa substituir processos manuais ou descentralizados por um fluxo de trabalho estruturado, permitindo o registro, controle de status e análise visual das ordens de serviço (OS) diretamente de um dispositivo móvel.

### 1.1 Declaração do Problema

Profissionais autônomos e equipes técnicas frequentemente enfrentam dificuldades para rastrear o andamento de seus serviços, associar orçamentos a clientes de forma organizada e extrair métricas básicas de produtividade diária ou mensal.

### 1.2 Posição do Produto

O aplicativo mobile atua como o terminal do prestador em campo, operando sob uma arquitetura desacoplada e reativa (Clean Architecture + Riverpod). Ele consome serviços de uma API REST de forma segura por meio de autenticação de dois fatores (2FA) e interceptores de segurança.

---

## 2. Perfis de Usuários

* **Usuário (Prestador de Serviço / Técnico):** O profissional final que executa as ordens de serviço. Ele é responsável por realizar seu próprio autocadastro no aplicativo, abrir novos atendimentos, gerenciar os dados dos clientes atendidos, atualizar os status das OSs e acompanhar seus indicadores através do dashboard.

---

## 3. Casos de Uso Principais

```
+-----------------------------------------------------------------+
|                                                                 |
|   +-------------------+       ( UC01: Autocadastro de Usuário ) |
|   |                   |-------/                                 |
|   |                   |                                         |
|   |      Usuário      |-------( UC02: Lançamento de OS Manual ) |
|   |     (Técnico)     |                                         |
|   |                   |-------\                                 |
|   +-------------------+       ( UC03: Visualização Consolidada) |
|                                                                 |
+-----------------------------------------------------------------+

```

### UC01 – Autocadastro de Usuário

* **Atores:** Usuário (Técnico).
* **Descrição:** Permite que um novo profissional crie suas credenciais de acesso para utilizar o sistema.
* **Fluxo Principal:**
1. O usuário acessa a tela de cadastro e informa Nome, E-mail, CPF/CNPJ e Senha.
2. O sistema valida os campos localmente com regras estritas (ex: senha de no mínimo 6 caracteres).
3. O sistema dispara uma solicitação para a API e envia um código de segurança de 6 dígitos para o e-mail informado.
4. O aplicativo redireciona o usuário para a tela de verificação (2FA).
5. O usuário insere o código de 6 dígitos recebido e o dispositivo é autenticado, liberando o token JWT para as requisições subsequentes.



### UC02 – Lançamento de Ordem de Serviço Manual

* **Atores:** Usuário (Técnico).
* **Descrição:** Permite a abertura e o registro formal de uma nova prestação de serviço.
* **Fluxo Principal:**
1. O usuário aciona a opção de adicionar nova OS a partir da listagem ou do dashboard.
2. O usuário preenche os dados obrigatórios: Título do serviço, valor cobrado, cliente vinculado, data agendada e uma descrição detalhada do problema ou solicitação.
3. O sistema valida se o valor inserido é maior que zero e se os campos obrigatórios foram preenchidos.
4. O usuário confirma a gravação; os dados são enviados para o backend via cliente HTTP (Dio) e armazenados na base sincronizada do servidor.



### UC03 – Visualização Consolidada (Dashboard)

* **Atores:** Usuário (Técnico).
* **Descrição:** Apresenta uma visão panorâmica e reativa sobre a saúde financeira e operacional dos atendimentos do profissional.
* **Fluxo Principal:**
1. Ao autenticar-se ou acessar a tela inicial, o aplicativo consome o endpoint de relatórios consolidados (`/api/reports`).
2. O sistema calcula o saldo em aberto/recebido e agrupa o volume de ordens de serviço por tipo ou status.
3. A tela renderiza cards informativos com os valores totais e plota dinamicamente um gráfico de pizza analítico (utilizando a biblioteca `fl_chart`) com a distribuição percentual das demandas por categoria ou situação.
4. O usuário pode realizar um gesto de *pull-to-refresh* para forçar a reatualização dos dados operacionais instantaneamente.
