## Importante
- Leia @docs antes de continuar
- Faça ou adicione ao arquivo CHANGELOG.MD as alterações nesse projeto, sem exceções.

## Padrões Flutter Obrigatórios

### Convenções de Nomenclatura
- **Arquivos:** `snake_case` (ex: `transaction_card_widget.dart`)
- **Classes/Tipos:** `PascalCase` (ex: `CreateTransactionUseCase`)
- **Variáveis/Métodos:** `camelCase` (ex: `currentBalance`)
- **Widgets:** Sufixo `Widget` para widgets reutilizáveis

### Arquitetura (Clean Architecture)
- Projeto segue **Feature-First** com três camadas: `data/`, `domain/`, `presentation/`
- **Domain:** Entidades, interfaces de repositórios, Use Cases — sem dependências externas
- **Data:** Implementações de repositórios, modelos (JSON), data sources
- **Presentation:** Widgets, Riverpod Providers/Notifiers

### Estrutura de Diretórios
```
lib/
├── core/           # Recursos compartilhados (constants, network, theme)
├── features/       # Funcionalidades isoladas (auth, dashboard, transactions, categories)
└── main.dart       # Ponto de entrada
```

### Gerenciamento de Estado
- Usar **Riverpod** para injeção de dependências e reatividade
- Providers devem ser definidos na camada `presentation/`

### Pacotes — Regras
- **Preferir pacotes oficiais do Flutter/Dart** (pub.dev com badge "Flutter Favorite" ou publicados pelo time Flutter)
- Antes de adicionar qualquer pacote, verificar se há solução oficial ou do time Flutter
- Pacotes essenciais do projeto: `riverpod`, `dio`, `fl_chart`, `flutter_dotenv`
- Evitar pacotes com pouca manutenção, muitas issues abertas ou sem null-safety

### Commits
- Seguir **Conventional Commits**: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`

### Diretrizes de Testes (TDD)
- Seguir a abordagem **TDD First** (Red-Green-Refactor).
- **Mocks**: Utilizar o pacote oficial `mockito` (via `build_runner`) para simular dependências externas (ex: Repositórios, Cliente HTTP Dio). O acesso externo real **nunca** deve ser feito em testes unitários.
- **Cobertura Crítica**: A camada `domain` (Entidades e Casos de Uso) exige ampla cobertura de cenários de sucesso e falha.
- **Padrão AAA**: Estruturar todos os testes nas etapas de *Arrange* (Preparação), *Act* (Ação) e *Assert* (Verificação).
- **Documentação Base**: Consultar rigorosamente as especificações do sistema em `docs/specs.md` e o plano de testes em `docs/testing.md` antes e durante o desenvolvimento.
