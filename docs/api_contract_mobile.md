# Contrato de Integração da API Finanças Pessoais

Este documento serve como contrato de especificação das rotas da API REST do sistema de Finanças Pessoais. Foi elaborado especificamente para orientar o desenvolvimento e a integração de clientes móveis.

---

## ⚙️ Diretrizes Gerais

1. **Formato dos Dados**: Todos os payloads de envio e recebimento devem ser em formato **JSON**. A nomenclatura utilizada é **snake_case**.
2. **Cabeçalhos Comuns**:
   - `Accept: application/json` (Obrigatório em todas as requisições para garantir o retorno de erros no formato JSON).
   - `Content-Type: application/json` (Obrigatório para requisições do tipo `POST`, `PUT`, `PATCH`).
   - `Authorization: Bearer <token>` (Obrigatório para todas as rotas protegidas).

---

## 🔒 Fluxo de Autenticação (Com 2FA)

### 1. Registrar Usuário
Cria a conta do usuário e dispara o envio do código de verificação para o e-mail cadastrado.
* **Método / URL**: `POST /api/auth/register`
* **Requisição:**
```json
{
  "name": "João Silva",
  "email": "joao@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```
* **Resposta de Sucesso (201 Created):**
```json
{
  "message": "Usuário registrado com sucesso. Por favor, verifique seu e-mail com o código enviado.",
  "user": {
    "id": "9c1c9ff5-5858-45bf-97c3-bc7948a4c84d",
    "name": "João Silva",
    "email": "joao@example.com"
  }
}
```
* **Resposta de Erro (422 Unprocessable Content - Validação):**
```json
{
  "message": "O campo email já está em uso. (and other validation messages)",
  "errors": {
    "email": [
      "O campo email já está sendo utilizado."
    ]
  }
}
```

---

### 2. Iniciar Login (Fase 1)
Valida as credenciais. Se válidas, gera e envia o código 2FA por e-mail.
* **Método / URL**: `POST /api/auth/login`
* **Requisição:**
```json
{
  "email": "joao@example.com",
  "password": "password123"
}
```
* **Resposta de Sucesso (200 OK):**
```json
{
  "message": "Código de verificação enviado para o seu e-mail.",
  "email": "joao@example.com"
}
```
* **Resposta de Erro (401 Unauthorized - Credenciais inválidas):**
```json
{
  "message": "Credenciais inválidas."
}
```
* **Observações para o Mobile**: A interface do aplicativo deve prosseguir para a tela de inserção do código 2FA somente após receber a resposta 200 desta rota.

---

### 3. Confirmar Código 2FA (Fase 2)
Verifica o código e retorna o token de acesso Sanctum.
* **Método / URL**: `POST /api/auth/verify-code`
* **Requisição:**
```json
{
  "email": "joao@example.com",
  "code": "123456",
  "device_name": "Celular do João"
}
```
* **Resposta de Sucesso (200 OK):**
```json
{
  "message": "Autenticação realizada com sucesso.",
  "token": "1|abcdefghijklmnop...",
  "user": {
    "id": "9c1c9ff5-5858-45bf-97c3-bc7948a4c84d",
    "name": "João Silva",
    "email": "joao@example.com"
  }
}
```
* **Resposta de Erro (422 Unprocessable Content - Código inválido/expirado):**
```json
{
  "message": "Código de verificação inválido ou expirado."
}
```
* **Observações para o Mobile**: O `token` retornado deve ser armazenado localmente de forma segura (Keychain no iOS / EncryptedSharedPreferences no Android). Ele expira após 1 hora se não for utilizado.

---

### 4. Reenviar Código 2FA
Solicita um novo código caso o usuário não tenha recebido ou o anterior tenha expirado.
* **Método / URL**: `POST /api/auth/resend-code`
* **Requisição:**
```json
{
  "email": "joao@example.com",
  "type": "api_login"
}
```
> Nota: O campo `type` aceita os valores `"registration"` (registro de nova conta) ou `"api_login"` (fluxo de login).

* **Resposta de Sucesso (200 OK):**
```json
{
  "message": "Novo código de verificação enviado para o seu e-mail."
}
```

---

### 5. Obter Dados do Usuário Autenticado
Retorna os dados cadastrais do usuário logado.
* **Método / URL**: `GET /api/auth/user`
* **Headers**:
  - `Authorization: Bearer 1|abcdefghijklmnop...`
* **Resposta de Sucesso (200 OK):**
```json
{
  "user": {
    "id": "9c1c9ff5-5858-45bf-97c3-bc7948a4c84d",
    "name": "João Silva",
    "email": "joao@example.com",
    "telegram_chat_id": null,
    "created_at": "2026-06-09T19:40:00.000000Z",
    "updated_at": "2026-06-09T19:40:00.000000Z"
  }
}
```
* **Resposta de Erro (401 Unauthorized):**
```json
{
  "message": "Unauthenticated."
}
```
* **Observações para o Mobile**: Ao receber um erro 401 nesta ou em qualquer outra rota protegida, limpe o token salvo e direcione o usuário de volta à tela de login.

---

### 6. Efetuar Logout
Invalida o token atual do dispositivo.
* **Método / URL**: `POST /api/auth/logout`
* **Headers**:
  - `Authorization: Bearer 1|abcdefghijklmnop...`
* **Resposta de Sucesso (200 OK):**
```json
{
  "message": "Logout realizado com sucesso."
}
```

---

## 📁 Gerenciamento de Categorias (CRUD)

> Todas as rotas abaixo requerem o header `Authorization: Bearer <token>`.

### 1. Listar Categorias
* **Método / URL**: `GET /api/categories`
* **Resposta de Sucesso (200 OK):**
```json
{
  "data": [
    {
      "id": "a9ef52eb-5460-449e-b9ef-dcd41bb0b793",
      "name": "Alimentação",
      "description": "Supermercado e restaurantes",
      "user_id": "9c1c9ff5-5858-45bf-97c3-bc7948a4c84d",
      "created_at": "2026-06-09T19:40:00.000000Z",
      "updated_at": "2026-06-09T19:40:00.000000Z"
    },
    {
      "id": "e229e061-0b86-4fb4-8975-d91d17983637",
      "name": "Transporte",
      "description": "Combustível e aplicativos de corrida",
      "user_id": "9c1c9ff5-5858-45bf-97c3-bc7948a4c84d",
      "created_at": "2026-06-09T19:40:00.000000Z",
      "updated_at": "2026-06-09T19:40:00.000000Z"
    }
  ]
}
```
* **Observações para o Mobile**: Esta lista pode ser cacheada localmente para carregamento offline rápido. Atualize-a puxando novas atualizações via pull-to-refresh.

---

### 2. Criar Categoria
* **Método / URL**: `POST /api/categories`
* **Requisição:**
```json
{
  "name": "Saúde",
  "description": "Farmácia, consultas e exames"
}
```
* **Resposta de Sucesso (201 Created):**
```json
{
  "message": "Categoria criada com sucesso.",
  "data": {
    "id": "b110e061-0b86-4fb4-8975-d91d17983637",
    "name": "Saúde",
    "description": "Farmácia, consultas e exames",
    "user_id": "9c1c9ff5-5858-45bf-97c3-bc7948a4c84d",
    "created_at": "2026-06-09T20:00:00.000000Z",
    "updated_at": "2026-06-09T20:00:00.000000Z"
  }
}
```

---

### 3. Detalhes de Categoria
* **Método / URL**: `GET /api/categories/{id}`
* **Resposta de Sucesso (200 OK):**
```json
{
  "data": {
    "id": "b110e061-0b86-4fb4-8975-d91d17983637",
    "name": "Saúde",
    "description": "Farmácia, consultas e exames",
    "user_id": "9c1c9ff5-5858-45bf-97c3-bc7948a4c84d",
    "created_at": "2026-06-09T20:00:00.000000Z",
    "updated_at": "2026-06-09T20:00:00.000000Z"
  }
}
```
* **Resposta de Erro (403 Forbidden - Tentativa de ver recurso alheio):**
```json
{
  "message": "This action is unauthorized."
}
```

---

### 4. Atualizar Categoria
* **Método / URL**: `PUT /api/categories/{id}`
* **Requisição:**
```json
{
  "name": "Saúde & Farmácia",
  "description": "Gastos hospitalares e farmácia"
}
```
* **Resposta de Sucesso (200 OK):**
```json
{
  "message": "Categoria atualizada com sucesso.",
  "data": {
    "id": "b110e061-0b86-4fb4-8975-d91d17983637",
    "name": "Saúde & Farmácia",
    "description": "Gastos hospitalares e farmácia",
    "user_id": "9c1c9ff5-5858-45bf-97c3-bc7948a4c84d",
    "created_at": "2026-06-09T20:00:00.000000Z",
    "updated_at": "2026-06-09T20:10:00.000000Z"
  }
}
```

---

### 5. Excluir Categoria
* **Método / URL**: `DELETE /api/categories/{id}`
* **Resposta de Sucesso (200 OK):**
```json
{
  "message": "Categoria excluída com sucesso."
}
```

---

## 💸 Gerenciamento de Transações (CRUD)

> Todas as rotas abaixo requerem o header `Authorization: Bearer <token>`.

### 1. Listar Transações
Retorna as receitas (`income`) e despesas (`out`) registradas pelo usuário atual, ordenadas de forma decrescente pela data.
* **Método / URL**: `GET /api/transactions`
* **Query Parameters (Opcionais):**
  - `type`: Filtra por tipo de transação. Valores aceitos: `"out"` (despesa) ou `"income"` (receita).
* **Resposta de Sucesso (200 OK):**
```json
{
  "data": [
    {
      "id": "e440e061-0b86-4fb4-8975-d91d17983637",
      "name": "Supermercado",
      "value": "350.20",
      "type": "out",
      "expense_date": "2026-06-09T00:00:00.000000Z",
      "description": "Compras do mês",
      "status": "published",
      "category_id": "a9ef52eb-5460-449e-b9ef-dcd41bb0b793",
      "category": {
        "id": "a9ef52eb-5460-449e-b9ef-dcd41bb0b793",
        "name": "Alimentação",
        "description": "Supermercado e restaurantes"
      }
    }
  ]
}
```

---

### 2. Criar Transação
* **Método / URL**: `POST /api/transactions`
* **Requisição:**
```json
{
  "type": "out",
  "name": "Uber para escritório",
  "value": 25.50,
  "expense_date": "2026-06-09",
  "category_id": "e229e061-0b86-4fb4-8975-d91d17983637",
  "description": "Reunião de negócios"
}
```
* **Resposta de Sucesso (201 Created):**
```json
{
  "message": "Transação criada com sucesso.",
  "data": {
    "id": "f550e061-0b86-4fb4-8975-d91d17983637",
    "name": "Uber para escritório",
    "value": 25.5,
    "type": "out",
    "expense_date": "2026-06-09T00:00:00.000000Z",
    "category_id": "e229e061-0b86-4fb4-8975-d91d17983637",
    "description": "Reunião de negócios",
    "status": "published",
    "user_id": "9c1c9ff5-5858-45bf-97c3-bc7948a4c84d",
    "updated_at": "2026-06-09T20:45:00.000000Z",
    "created_at": "2026-06-09T20:45:00.000000Z"
  }
}
```
* **Resposta de Erro (422 Unprocessable Content - Categoria inexistente ou de outro usuário):**
```json
{
  "message": "O campo category_id selecionado é inválido.",
  "errors": {
    "category_id": [
      "O campo category_id selecionado é inválido."
    ]
  }
}
```

---

### 3. Detalhes da Transação
* **Método / URL**: `GET /api/transactions/{id}`
* **Resposta de Sucesso (200 OK):**
```json
{
  "data": {
    "id": "f550e061-0b86-4fb4-8975-d91d17983637",
    "name": "Uber para escritório",
    "value": "25.50",
    "type": "out",
    "expense_date": "2026-06-09T00:00:00.000000Z",
    "description": "Reunião de negócios",
    "status": "published",
    "category_id": "e229e061-0b86-4fb4-8975-d91d17983637",
    "category": {
      "id": "e229e061-0b86-4fb4-8975-d91d17983637",
      "name": "Transporte"
    }
  }
}
```

---

### 4. Atualizar Transação
* **Método / URL**: `PUT /api/transactions/{id}`
* **Requisição:**
```json
{
  "name": "Uber Volta Escritório",
  "value": 30.00,
  "expense_date": "2026-06-09",
  "category_id": "e229e061-0b86-4fb4-8975-d91d17983637",
  "description": "Gasto corrigido"
}
```
* **Resposta de Sucesso (200 OK):**
```json
{
  "message": "Transação atualizada com sucesso.",
  "data": {
    "id": "f550e061-0b86-4fb4-8975-d91d17983637",
    "name": "Uber Volta Escritório",
    "value": 30,
    "type": "out",
    "expense_date": "2026-06-09T00:00:00.000000Z",
    "category_id": "e229e061-0b86-4fb4-8975-d91d17983637",
    "description": "Gasto corrigido"
  }
}
```

---

### 5. Excluir Transação
* **Método / URL**: `DELETE /api/transactions/{id}`
* **Resposta de Sucesso (200 OK):**
```json
{
  "message": "Transação excluída com sucesso."
}
```

---

## 📊 Relatórios Financeiros

Compila o consolidado do usuário para gráficos e resumos.
> Requer o header `Authorization: Bearer <token>`.

### 1. Obter Relatório Financeiro
* **Método / URL**: `GET /api/reports`
* **Query Parameters (Opcionais):**
  - `start_date`: Data de início do intervalo do relatório (formato `YYYY-MM-DD`).
  - `end_date`: Data de término do intervalo (formato `YYYY-MM-DD`). Deve ser igual ou posterior à `start_date`.
  - `category_id`: Filtra o relatório por uma categoria específica (UUID).
  - `type`: Filtra o relatório por tipo (`"out"` ou `"income"`).
* **Resposta de Sucesso (200 OK):**
```json
{
  "data": {
    "summary": {
      "total_income": 3500.0,
      "total_expense": 1225.5,
      "balance": 2274.5
    },
    "breakdown": [
      {
        "category_id": "a9ef52eb-5460-449e-b9ef-dcd41bb0b793",
        "category_name": "Alimentação",
        "total": 1200.0,
        "count": 4
      },
      {
        "category_id": "e229e061-0b86-4fb4-8975-d91d17983637",
        "category_name": "Transporte",
        "total": 25.5,
        "count": 1
      }
    ],
    "transactions": [
      {
        "id": "f550e061-0b86-4fb4-8975-d91d17983637",
        "name": "Uber para escritório",
        "value": "25.50",
        "type": "out",
        "expense_date": "2026-06-09T00:00:00.000000Z",
        "category_id": "e229e061-0b86-4fb4-8975-d91d17983637"
      }
    ]
  }
}
```
* **Resposta de Erro (422 Unprocessable Content - Intervalo de datas inconsistente):**
```json
{
  "message": "O campo end_date deve ser uma data posterior ou igual a start_date.",
  "errors": {
    "end_date": [
      "O campo end_date deve ser uma data posterior ou igual a start_date."
    ]
  }
}
```

---

## 🛠️ Erros Globais e Respostas Genéricas

### 1. Não Autenticado (401 Unauthorized)
Enviado quando o header `Authorization` está ausente, mal formatado ou o token expirou.
```json
{
  "message": "Unauthenticated."
}
```

### 2. Recurso Não Encontrado (404 Not Found)
Enviado quando o UUID informado na rota (categoria ou transação) não existe na base de dados.
```json
{
  "message": "Record not found."
}
```

### 3. Acesso Negado (403 Forbidden)
Enviado quando o usuário tenta visualizar, editar ou deletar uma categoria ou transação que pertence a outro usuário do sistema.
```json
{
  "message": "This action is unauthorized."
}
```

### 4. Limite de Requisições Excedido (429 Too Many Requests)
Retornado quando o cliente excede as cotas de rate limiting (configurado nas rotas de login/registro).
```json
{
  "message": "Too Many Attempts."
}
```
* **Observações para o Mobile**: Trate este erro exibindo uma mensagem informativa como "Muitas tentativas. Por favor, aguarde alguns minutos antes de tentar novamente" e desabilite temporariamente os botões de ação na tela.
