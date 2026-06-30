# 🔐 Relatório de Inspeção de Segurança — FinançasPessoais Mobile

> **Projeto:** `financas_app` (Flutter)
> **Versão auditada:** 1.5.0+1
> **Data:** 2026-06-30
> **Nível de profundidade:** PROFUNDA
> **Escopo:** `/lib/` (completo), `/android/`, `pubspec.yaml`, `.env`, `.gitignore`

---

## 📊 Resumo Executivo

| Severidade | Quantidade |
|---|---|
| 🔴 Crítica | 2 |
| 🟠 Alta | 4 |
| 🟡 Média | 5 |
| 🔵 Baixa | 4 |
| **Total** | **15** |

---

## ⚡ As 5 Ações Mais Urgentes

1. **[CRÍTICO]** Substituir `SharedPreferences` por `flutter_secure_storage` para armazenamento do token JWT — dados sensíveis estão atualmente em plain text acessíveis por apps maliciosos com root/backup.
2. **[CRÍTICO]** Remover o arquivo `.env` da lista de assets do Flutter (`pubspec.yaml`) — o arquivo com a URL de produção é empacotado dentro do APK e pode ser extraído por qualquer pessoa com acesso ao binário.
3. **[ALTO]** Desabilitar o `LogInterceptor` com `requestBody: true` e `responseBody: true` em builds de produção — logs de requisição/resposta podem expor tokens JWT e dados financeiros.
4. **[ALTO]** Adicionar validação do campo `deviceName` no `VerifyCodeUseCase` e na tela de verificação — atualmente é hardcoded como `'App Mobile'`, impedindo identificação de sessões em caso de comprometimento.
5. **[ALTO]** Implementar SSL Pinning (certificate pinning) para proteção contra ataques Man-in-the-Middle em redes não confiáveis.

---

## 📋 Vulnerabilidades Detalhadas

---

### VUL-01 — Token JWT Armazenado em SharedPreferences (Plain Text)

- **Categoria OWASP:** A04 – Cryptographic Failures / A07 – Authentication Failures
- **Severidade:** 🔴 Crítica
- **Arquivo:** [auth_local_datasource.dart](file:///home/yure/Documentos/php/financas-app/lib/features/auth/data/datasources/auth_local_datasource.dart) — Linhas 8–18

**Descrição:**
O token JWT de autenticação Sanctum é armazenado usando `SharedPreferences`, que persiste dados em texto plano em um arquivo XML no armazenamento interno do Android (e equivalente no iOS). Em dispositivos com root/jailbreak ou durante backups não criptografados, esse arquivo pode ser lido por qualquer processo com privilégios elevados. O próprio contrato da API (linha 112) exige `Keychain (iOS) / EncryptedSharedPreferences (Android)`, mas isso não foi implementado.

**Evidência:**
```dart
// auth_local_datasource.dart — linhas 8–18
Future<void> saveToken(String token) async {
  await prefs.setString('auth_token', token); // plaintext storage
}

String? getToken() {
  return prefs.getString('auth_token'); // plaintext retrieval
}
```

**Impacto Potencial:**
- Roubo de sessão via backup ADB sem criptografia ou dispositivo rooteado.
- Acesso completo à conta: visualizar e modificar todos os dados financeiros do usuário.

**Recomendação:**
```yaml
# pubspec.yaml — adicionar
dependencies:
  flutter_secure_storage: ^9.2.2
```

```dart
// auth_local_datasource.dart — versão corrigida
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDataSource {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static const _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
```

> [!CAUTION]
> Alterar `getToken()` para async quebra a cadeia de chamadas. É necessário atualizar `AuthInterceptor.onRequest()` para ser async ou usar um cache em memória pós-autenticação.

**Referências:**
- CWE-312: Cleartext Storage of Sensitive Information
- CWE-922: Insecure Storage of Sensitive Information
- OWASP Mobile Top 10: M9 – Insecure Data Storage

---

### VUL-02 — Arquivo `.env` Empacotado como Asset do APK

- **Categoria OWASP:** A02 – Security Misconfiguration / A04 – Cryptographic Failures
- **Severidade:** 🔴 Crítica
- **Arquivo:** [pubspec.yaml](file:///home/yure/Documentos/php/financas-app/pubspec.yaml) — Linha 70 / [.env](file:///home/yure/Documentos/php/financas-app/.env)

**Descrição:**
O arquivo `.env` está declarado como asset Flutter (`assets: - .env`), o que o embute **dentro do APK/IPA**. Qualquer pessoa com acesso ao binário pode extraí-lo com `apktool` ou `unzip`. O arquivo expõe a URL de produção da API e o ambiente (`APP_ENV=production`).

**Evidência:**
```yaml
# pubspec.yaml — linha 69–71
assets:
  - .env  # empacotado no APK
```

```
# .env
API_BASE_URL=https://financa.yure.tec.br/api
APP_ENV=production
```

**Impacto Potencial:**
- Exposição do endpoint de produção facilita reconhecimento, fuzzing e ataques direcionados ao backend.
- Futuras chaves de API adicionadas ao `.env` serão automaticamente expostas.

**Recomendação:**
Usar `String.fromEnvironment()` via `--dart-define` no build, eliminando `flutter_dotenv` e o `.env` como asset:

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://financa.yure.tec.br/api \
  --dart-define=API_TIMEOUT=5000 \
  --dart-define=APP_ENV=production
```

```dart
// env_config.dart — sem flutter_dotenv
class EnvConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL', defaultValue: 'https://localhost:8000/api/v1');
  static const apiTimeout = int.fromEnvironment(
    'API_TIMEOUT', defaultValue: 5000);
  static const appEnv = String.fromEnvironment(
    'APP_ENV', defaultValue: 'development');
}
```

Remover as entradas de `assets: - .env` do `pubspec.yaml` e `await EnvConfig.load()` do `main.dart`.

**Referências:**
- CWE-312: Cleartext Storage of Sensitive Information
- CWE-200: Exposure of Sensitive Information to an Unauthorized Actor

---

### VUL-03 — LogInterceptor com Corpo Completo Habilitado em Produção

- **Categoria OWASP:** A09 – Security Logging and Alerting Failures
- **Severidade:** 🟠 Alta
- **Arquivo:** [dio_client.dart](file:///home/yure/Documentos/php/financas-app/lib/core/network/dio_client.dart) — Linha 17

**Descrição:**
O `LogInterceptor` está configurado com `requestBody: true` e `responseBody: true` sem verificação de ambiente. Em produção, isso loga tokens JWT, credenciais e dados financeiros no Logcat. Qualquer app com permissão `READ_LOGS` (concedida a ferramentas de debug em Android) pode capturar esses dados.

**Evidência:**
```dart
// dio_client.dart — linha 17
_dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
// loga: "Authorization: Bearer 1|abcdef..." e todos os dados da resposta
```

**Impacto Potencial:**
- Token JWT exposto no Logcat.
- Dados financeiros (saldo, transações) visíveis em logs.
- Ferramentas de crash report (ex: Firebase Crashlytics) podem coletar e transmitir esses logs.

**Recomendação:**
```dart
// dio_client.dart — versão corrigida
DioClient() {
  _dio = Dio(BaseOptions(/* ... */));

  // Logs APENAS em modo debug (bloco assert é removido em release builds)
  assert(() {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: false, // nunca logar Authorization header
    ));
    return true;
  }());
}
```

**Referências:**
- CWE-532: Insertion of Sensitive Information into Log File

---

### VUL-04 — Ausência de SSL Pinning

- **Categoria OWASP:** A02 – Security Misconfiguration / A07 – Authentication Failures
- **Severidade:** 🟠 Alta
- **Arquivo:** [dio_client.dart](file:///home/yure/Documentos/php/financas-app/lib/core/network/dio_client.dart)

**Descrição:**
O cliente Dio não implementa SSL Pinning. O app aceita qualquer certificado TLS válido emitido por qualquer CA confiável. Em redes públicas ou corporativas, um atacante que instale um CA root no dispositivo (via MDM ou engenharia social) pode interceptar todo o tráfego HTTPS, incluindo tokens e dados financeiros.

**Evidência:**
```dart
// dio_client.dart — sem configuração de certificado
_dio = Dio(BaseOptions(
  baseUrl: EnvConfig.apiBaseUrl,
  // sem TrustManager customizado, sem pinning
));
```

**Impacto Potencial:**
- Ataques Man-in-the-Middle em redes Wi-Fi não confiáveis.
- Interceptação de tokens, modificação de respostas (ex: alterar saldo exibido).

**Recomendação:**
```dart
// Adicionar no DioClient com o certificado do servidor
Future<void> _configureCertificatePinning() async {
  final certBytes = await rootBundle.load('assets/cert/server.pem');
  final secContext = SecurityContext()
    ..setTrustedCertificatesBytes(certBytes.buffer.asUint8List());
  _dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () => HttpClient(context: secContext),
  );
}
```

**Referências:**
- CWE-295: Improper Certificate Validation
- OWASP Mobile Top 10: M3 – Insecure Communication

---

### VUL-05 — Inconsistência e Fallback HTTP em Configuração de URL Base

- **Categoria OWASP:** A02 – Security Misconfiguration / A06 – Insecure Design
- **Severidade:** 🟠 Alta
- **Arquivos:** [api_paths.dart](file:///home/yure/Documentos/php/financas-app/lib/core/constants/api_paths.dart) — Linha 2 e [env_config.dart](file:///home/yure/Documentos/php/financas-app/lib/core/config/env_config.dart) — Linha 8

**Descrição:**
Existem dois sistemas paralelos de configuração de URL base com valores padrão inconsistentes. `ApiPaths.base` usa `String.fromEnvironment()` com fallback `http://localhost:8000/api` (sem HTTPS, sem `/v1`). `EnvConfig.apiBaseUrl` usa `flutter_dotenv` com fallback `http://localhost:8000/api/v1`. Em builds sem `--dart-define`, o fallback expõe comunicação não criptografada via HTTP.

**Evidência:**
```dart
// api_paths.dart — linha 2
static const base = String.fromEnvironment(
  'API_BASE_URL', defaultValue: 'http://localhost:8000/api'); // HTTP sem /v1

// env_config.dart — linha 8
static String get apiBaseUrl =>
  dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api/v1'; // HTTP com /v1
```

**Impacto Potencial:**
- Builds sem `--dart-define` usam `http://` para comunicação, expondo dados em texto claro.
- Dois sistemas de configuração paralelos aumentam o risco de regressões de segurança.

**Recomendação:**
Consolidar em uma única fonte usando `String.fromEnvironment()` com fallback `https://`:

```dart
// Único ponto de verdade
static const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL', defaultValue: 'https://localhost:8000/api/v1');
```

---

### VUL-06 — Mensagens de Erro Interno Propagadas para a UI

- **Categoria OWASP:** A10 – Mishandling of Exceptional Conditions
- **Severidade:** 🟠 Alta
- **Arquivos:** [auth_repository_impl.dart](file:///home/yure/Documentos/php/financas-app/lib/features/auth/data/repositories/auth_repository_impl.dart) — Linhas 21–24 / [dashboard_page.dart](file:///home/yure/Documentos/php/financas-app/lib/features/dashboard/presentation/pages/dashboard_page.dart) — Linhas 453–457

**Descrição:**
O `catch (e)` genérico converte exceções Dart em mensagens de erro via `e.toString()`, expondo stack traces internos. Adicionalmente, a `DashboardPage` exibe o erro bruto `$err` em um `Text()` widget.

**Evidência:**
```dart
// auth_repository_impl.dart — linhas 22–24
} catch (e) {
  return Left(ServerFailure(e.toString())); // stack trace exposto
}

// dashboard_page.dart — linha 453–456
error: (err, _) => Center(
  child: Text('Erro ao carregar dashboard: $err'), // err = stack trace
),
```

**Impacto Potencial:**
- Information disclosure: stack traces revelam estrutura interna do app.
- Facilita planejamento de ataques mais elaborados.

**Recomendação:**
```dart
} catch (e, st) {
  assert(() { debugPrint('Internal error: $e\n$st'); return true; }());
  return Left(ServerFailure('Erro interno. Por favor, tente novamente.'));
}

// Dashboard
error: (_, __) => const Center(
  child: Text('Não foi possível carregar os dados. Tente novamente.'),
),
```

**Referências:**
- CWE-209: Generation of Error Message Containing Sensitive Information

---

### VUL-07 — Ausência de Rate Limiting Local no Reenvio de Código 2FA

- **Categoria OWASP:** A07 – Authentication Failures
- **Severidade:** 🟡 Média
- **Arquivo:** [verification_page.dart](file:///home/yure/Documentos/php/financas-app/lib/features/auth/presentation/pages/verification_page.dart) — Linhas 135–145

**Descrição:**
O botão "Reenviar código" não implementa cooldown no cliente, permitindo disparar inúmeras requisições ao endpoint `/auth/resend-code`. O servidor possui rate limiting (HTTP 429), mas o cliente não fornece feedback visual de espera.

**Evidência:**
```dart
// verification_page.dart — linhas 135–145
TextButton(
  onPressed: authState.status == AuthStatus.loading
      ? null
      : () {
          ref.read(authNotifierProvider.notifier).resendCode();
          // sem cooldown
        },
  child: const Text('Reenviar código'),
),
```

**Impacto Potencial:**
- Spam de e-mails para a vítima.
- Consumo excessivo do servidor de e-mail.

**Recomendação:**
Implementar cooldown local de 60 segundos com `Timer.periodic()`, desabilitando o botão e exibindo contagem regressiva.

**Referências:**
- CWE-307: Improper Restriction of Excessive Authentication Attempts
- CWE-799: Improper Control of Interaction Frequency

---

### VUL-08 — `deviceName` Hardcoded na Verificação 2FA

- **Categoria OWASP:** A07 – Authentication Failures / A06 – Insecure Design
- **Severidade:** 🟡 Média
- **Arquivo:** [verification_page.dart](file:///home/yure/Documentos/php/financas-app/lib/features/auth/presentation/pages/verification_page.dart) — Linha 122

**Descrição:**
O campo `device_name` enviado ao Sanctum é sempre `'App Mobile'`, impossibilitando a identificação e revogação de sessões específicas por dispositivo.

**Evidência:**
```dart
// verification_page.dart — linha 122
deviceName: 'App Mobile', // hardcoded
```

**Recomendação:**
```dart
import 'dart:io';
// ou usar device_info_plus para nome real do dispositivo
final deviceName = '${Platform.operatingSystem}-${DateTime.now().millisecondsSinceEpoch}';
```

---

### VUL-09 — Ausência de Limite de Comprimento em Campos de Texto Livre

- **Categoria OWASP:** A05 – Injection / A06 – Insecure Design
- **Severidade:** 🟡 Média
- **Arquivos:** [create_transaction_page.dart](file:///home/yure/Documentos/php/financas-app/lib/features/transactions/presentation/pages/create_transaction_page.dart) — Linhas 78–85, 177–184 / [create_category_page.dart](file:///home/yure/Documentos/php/financas-app/lib/features/categories/presentation/pages/create_category_page.dart) — Linhas 69–76

**Descrição:**
Campos "Título" de transações, "Descrição" e "Nome" de categorias não têm `maxLength` definido. Payloads excessivamente longos podem causar problemas no backend (ReDoS, truncagem silenciosa, overflow).

**Evidência:**
```dart
// create_transaction_page.dart — sem maxLength
TextFormField(
  controller: _titleController,
  // sem maxLength
  validator: (v) => v == null || v.trim().isEmpty ? 'Título obrigatório' : null,
),

TextFormField(
  controller: _descriptionController,
  maxLines: 2,
  // sem maxLength — entrada ilimitada
),
```

**Recomendação:**
```dart
TextFormField(
  controller: _titleController,
  maxLength: 100,
  maxLengthEnforcement: MaxLengthEnforcement.enforced,
  validator: (v) {
    if (v == null || v.trim().isEmpty) return 'Título obrigatório';
    if (v.trim().length > 100) return 'Máximo de 100 caracteres';
    return null;
  },
),
```

**Referências:**
- CWE-20: Improper Input Validation
- CWE-400: Uncontrolled Resource Consumption

---

### VUL-10 — Parsing de Cor Hexadecimal sem Validação

- **Categoria OWASP:** A10 – Mishandling of Exceptional Conditions
- **Severidade:** 🟡 Média
- **Arquivo:** [dashboard_page.dart](file:///home/yure/Documentos/php/financas-app/lib/features/dashboard/presentation/pages/dashboard_page.dart) — Linhas 218, 251, 396, 426

**Descrição:**
`Color(int.parse('0xFF${cs.categoryColor}'))` lança `FormatException` não tratada se `categoryColor` vier inválido do servidor, derrubando o dashboard inteiro.

**Evidência:**
```dart
// dashboard_page.dart — linha 218, 251, 396, 426
color: Color(int.parse('0xFF${cs.categoryColor}')),
// se categoryColor = 'invalid' -> FormatException não tratada -> crash
```

**Recomendação:**
```dart
Color _safeColor(String hex) {
  final s = hex.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
  if (s.length != 6) return const Color(0xFF90A4AE);
  return Color(int.parse('0xFF$s'));
}
// Uso: color: _safeColor(cs.categoryColor),
```

**Referências:**
- CWE-20: Improper Input Validation
- CWE-248: Uncaught Exception

---

### VUL-11 — Logout Imediato sem Confirmação

- **Categoria OWASP:** A01 – Broken Access Control
- **Severidade:** 🟡 Média
- **Arquivo:** [dashboard_page.dart](file:///home/yure/Documentos/php/financas-app/lib/features/dashboard/presentation/pages/dashboard_page.dart) — Linha 29

**Descrição:**
O botão de logout executa imediatamente sem confirmar a intenção do usuário. Toque acidental ou acesso físico momentâneo podem resultar em logout indesejado.

**Evidência:**
```dart
// dashboard_page.dart — linha 29
onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
// sem dialog de confirmação
```

**Recomendação:**
Adicionar um `AlertDialog` de confirmação antes de chamar `logout()`.

---

### VUL-12 — `.env` Pode Estar no Histórico Git

- **Categoria OWASP:** A04 – Cryptographic Failures / A08 – Data Integrity Failures
- **Severidade:** 🟡 Média
- **Arquivo:** [.gitignore](file:///home/yure/Documentos/php/financas-app/.gitignore) — Linha 46

**Descrição:**
O `.env` está no `.gitignore` (linha 46), impedindo futuros commits. Porém, se foi commitado antes, permanece recuperável no histórico Git.

**Recomendação:**
```bash
# Verificar histórico
git log --all --full-history -- .env

# Remover do histórico se necessário
git filter-repo --path .env --invert-paths
git push --force --all
```

**Referências:**
- CWE-312: Cleartext Storage of Sensitive Information
- CWE-540: Inclusion of Sensitive Information in Source Code

---

### VUL-13 — Ausência de FLAG_SECURE (Screenshots por Outros Apps)

- **Categoria OWASP:** A04 – Cryptographic Failures
- **Severidade:** 🔵 Baixa
- **Arquivo:** [AndroidManifest.xml](file:///home/yure/Documentos/php/financas-app/android/app/src/main/AndroidManifest.xml)

**Descrição:**
`FLAG_SECURE` não está definido no `AndroidManifest.xml`. Isso permite que outros apps (com permissão `READ_FRAME_BUFFER` ou apps de gravação de tela) capturem screenshots do dashboard com dados financeiros.

**Recomendação:**
```dart
// main.dart — em initState ou via plugin flutter_windowmanager
if (!kDebugMode) {
  await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
}
```

**Referências:**
- CWE-200: Exposure of Sensitive Information

---

### VUL-14 — Build de Produção sem Obfuscação de Código

- **Categoria OWASP:** A08 – Software or Data Integrity Failures
- **Severidade:** 🔵 Baixa

**Descrição:**
Sem `--obfuscate --split-debug-info`, o APK contém nomes de classes e métodos Dart em texto legível, facilitando engenharia reversa e identificação da lógica de autenticação e endpoints.

**Recomendação:**
```bash
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

---

### VUL-15 — Ausência de Autenticação Biométrica Local

- **Categoria OWASP:** A07 – Authentication Failures
- **Severidade:** 🔵 Baixa
- **Arquivo:** [main.dart](file:///home/yure/Documentos/php/financas-app/lib/main.dart) — Linhas 38–40

**Descrição:**
O app autentica o usuário automaticamente ao iniciar via `checkAuthStatus()`. Não há verificação biométrica local, permitindo acesso a todos os dados financeiros a qualquer pessoa com o dispositivo desbloqueado em mãos.

**Evidência:**
```dart
// main.dart — linhas 38–40
WidgetsBinding.instance.addPostFrameCallback((_) {
  ref.read(authNotifierProvider.notifier).checkAuthStatus();
  // autentica automaticamente sem biometria
});
```

**Recomendação:**
Usar `local_auth` para verificar biometria/PIN antes de exibir dados.

**Referências:**
- OWASP Mobile Top 10: M4 – Insecure Authentication

---

## 📑 Mapeamento OWASP × Vulnerabilidades

| OWASP | Vulnerabilidades |
|---|---|
| A01 – Broken Access Control | VUL-07, VUL-11 |
| A02 – Security Misconfiguration | VUL-03, VUL-04, VUL-05 |
| A03 – Software Supply Chain | VUL-09 |
| A04 – Cryptographic Failures | VUL-01, VUL-02, VUL-03, VUL-05, VUL-12, VUL-13 |
| A05 – Injection | VUL-09, VUL-10 |
| A06 – Insecure Design | VUL-05, VUL-08, VUL-11, VUL-15 |
| A07 – Authentication Failures | VUL-01, VUL-04, VUL-07, VUL-08, VUL-15 |
| A08 – Data Integrity Failures | VUL-12, VUL-14 |
| A09 – Logging and Alerting | VUL-03, VUL-06 |
| A10 – Exceptional Conditions | VUL-06, VUL-10 |

---

## ✅ Pontos Positivos

1. **2FA bem implementado** — fluxo de dois fatores com `LoginUseCase` + `VerifyCodeUseCase` funcionando corretamente.
2. **Token limpo no logout** — `AuthRepositoryImpl.logout()` limpa o token local mesmo em caso de erro de rede (linha 72).
3. **Validação na camada de domínio** — `LoginUseCase`, `RegisterUseCase` e `CreateTransactionUseCase` validam inputs.
4. **Tratamento de 401 automático** — `AuthInterceptor.onError()` limpa token em respostas não autorizadas.
5. **`.env` no `.gitignore`** — impede futuros commits com segredos.
6. **Sem credenciais hardcoded** — nenhuma senha ou chave API encontrada no código.
7. **HTTPS em produção** — URL de produção usa `https://`.

---

*Relatório gerado em 2026-06-30 | Profundidade: PROFUNDA | Antigravity AI Security Audit*
