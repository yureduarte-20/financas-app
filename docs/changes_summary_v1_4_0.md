# Resumo das Alterações — Versão 1.4.0

Este documento sintetiza as atualizações de especificações, testes e implementação realizadas para alinhar a documentação do projeto com o ecossistema real e introduzir validação de e-mail por expressões regulares.

---

## 1. Redução de Redundâncias e Discrepâncias de Especificação

### [description.md](file:///home/sti/Documentos/flutter/financas_app/docs/description.md)
* **Consolidação de Arquitetura & Diretórios:** As antigas seções 1 (Arquitetura), 3 (Estrutura de Diretórios) e 4 (Convenções) foram condensadas em uma única seção mais compacta ("1. Arquitetura e Organização do Código"). Isso eliminou redundâncias textuais e referências repetidas às pastas do padrão Feature-First.
* **Remoção do CPF do Autocadastro:** Corrigida a discrepância no Caso de Uso `UC01 (Autocadastro)`. O campo CPF, que constava erroneamente na descrição prévia mas não está no contrato da API (`docs/api_contract_mobile.md`) nem na base de dados, foi completamente removido. O autocadastro agora especifica apenas **Nome**, **E-mail** e **Senha**.
* **Validação de E-mail via Regex:** Formalizado no documento o requisito de validação robusta para e-mails a partir da expressão regular `r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"`.

---

## 2. Atualização do Plano de Testes

### [testing.md](file:///home/sti/Documentos/flutter/financas_app/docs/testing.md)
* Inserida a classe `RegisterUseCase` no escopo da seção "2.1 Casos de Uso Críticos — Autenticação (Auth)".
* Adicionados novos cenários de testes focados na validação regex de e-mails mal-formados para o `RegisterUseCase` e `LoginUseCase`.
* Mapeados cenários de testes adicionais para cadastro de clientes no domínio.

---

## 3. Alterações de Código (Implementação)

### Casos de Uso (Camada de Domínio)
* **[login_usecase.dart](file:///home/sti/Documentos/flutter/financas_app/lib/features/auth/domain/usecases/login_usecase.dart):** Substituído o validador simples `.contains('@')` por verificação estrita via `RegExp` para garantir o formato correto.
* **[register_usecase.dart](file:///home/sti/Documentos/flutter/financas_app/lib/features/auth/domain/usecases/register_usecase.dart):** Adicionada a mesma verificação via `RegExp`.

### Telas (Camada de Apresentação)
* **[login_page.dart](file:///home/sti/Documentos/flutter/financas_app/lib/features/auth/presentation/pages/login_page.dart):** Campo de formulário TextFormField de e-mail atualizado para usar a mesma expressão regular.
* **[register_page.dart](file:///home/sti/Documentos/flutter/financas_app/lib/features/auth/presentation/pages/register_page.dart):** Campo TextFormField de e-mail atualizado com a mesma regex.

---

## 4. Testes de Unidade Sob TDD

* **[login_usecase_test.dart](file:///home/sti/Documentos/flutter/financas_app/test/features/auth/domain/usecases/login_usecase_test.dart):** Atualizado o teste de e-mail inválido para iterar sobre múltiplos formatos falhos (ex: `user@`, `user@domain`, `@domain.com`, `user@domain.`).
* **[register_usecase_test.dart](file:///home/sti/Documentos/flutter/financas_app/test/features/auth/domain/usecases/register_usecase_test.dart):** [NOVO ARQUIVO] Criados testes de unidade completos sob o padrão AAA para o `RegisterUseCase`, validando comportamento de nome vazio, e-mails mal-formados via regex, tamanho mínimo de senha e sucesso com persistência via repositório.
