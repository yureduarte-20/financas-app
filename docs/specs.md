# Especificações Técnicas — FinançasPessoais Mobile

> Referência: `docs/description.md`

---

## 1. Core — Infraestrutura Compartilhada

### 1.1 Theme

```
lib/core/theme/app_theme.dart
- ação: criar
- Define ThemeData para Light Mode e Dark Mode
- Cores primária, secundária, erro, fundo e superfície extraídas de Design Tokens

pseudocódigo:
  classe AppTheme {
    estático ThemeData light() {
      retornar ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: ColorTokens.primary,
        useMaterial3: true,
        fontFamily: 'Inter',
      )
    }

    estático ThemeData dark() {
      retornar ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: ColorTokens.primary,
        useMaterial3: true,
        fontFamily: 'Inter',
      )
    }
  }
```

### 1.2 Constants

```
lib/core/constants/color_tokens.dart
- ação: criar
- Design Tokens de cores usados em todo o app
- Valores imutáveis (const)

pseudocódigo:
  classe ColorTokens {
    estático const primary    = Color(0xFF6C63FF)
    estático const secondary  = Color(0xFF03DAC6)
    estático const error      = Color(0xFFB00020)
    estático const background = Color(0xFFF5F5F5)
    estático const surface    = Color(0xFFFFFFFF)
    estático const income     = Color(0xFF4CAF50)
    estático const expense    = Color(0xFFF44336)
  }
```

```
lib/core/constants/dimension_tokens.dart
- ação: criar
- Espaçamentos, raios de borda e tamanhos de fonte padronizados

pseudocódigo:
  classe DimensionTokens {
    estático const paddingSmall  = 8.0
    estático const paddingMedium = 16.0
    estático const paddingLarge  = 24.0
    estático const radiusSmall   = 8.0
    estático const radiusMedium  = 12.0
    estático const radiusLarge   = 16.0
  }
```

```
lib/core/constants/api_paths.dart
- ação: criar
- Centraliza todos os endpoints da API REST

pseudocódigo:
  classe ApiPaths {
    estático const base       = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000/api')
    estático const register   = '/auth/register'
    estático const login      = '/auth/login'
    estático const verifyCode = '/auth/verify-code'
    estático const resendCode = '/auth/resend-code'
    estático const me         = '/auth/user'
    estático const logout     = '/auth/logout'
    estático const transactions = '/transactions'
    estático const categories = '/categories'
    estático const uploadDoc  = '/documents/upload'
  }
```

### 1.3 Network

```
lib/core/network/dio_client.dart
- ação: criar
- Instância singleton de Dio com configuração base (baseUrl, timeout, headers)
- Adiciona AuthInterceptor automaticamente

pseudocódigo:
  classe DioClient {
    final Dio _dio

    construtor DioClient() {
      _dio = Dio(BaseOptions(
        baseUrl: ApiPaths.base,
        connectTimeout: Duration(milliseconds: API_TIMEOUT),
        receiveTimeout: Duration(milliseconds: API_TIMEOUT),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      ))
      _dio.interceptors.add(AuthInterceptor())
      _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true))
    }

    Dio get instance => _dio
  }
```

```
lib/core/network/auth_interceptor.dart
- ação: criar
- Interceptor que injeta token JWT no header Authorization
- Em erro 401, dispara logout automático

pseudocódigo:
  classe AuthInterceptor extends Interceptor {
    final AuthLocalDataSource localDataSource

    sobrescrever onRequest(options, handler) {
      token = localDataSource.getToken()
      se token != nulo {
        options.headers['Authorization'] = 'Bearer $token'
      }
      handler.next(options)
    }

    sobrescrever onError(error, handler) {
      se error.response?.statusCode == 401 {
        localDataSource.clearToken()
        // Redirecionar para tela de login via NavigatorKey
      }
      handler.next(error)
    }
  }
```

### 1.4 Environment

```
lib/core/config/env_config.dart
- ação: criar
- Lê variáveis de .env via flutter_dotenv
- Expõe getters tipados para cada variável

pseudocódigo:
  classe EnvConfig {
    estático Future<void> load() async {
      await dotenv.load(fileName: '.env')
    }

    estático String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api/v1'
    estático int get apiTimeout => int.parse(dotenv.env['API_TIMEOUT'] ?? '5000')
    estático String get appEnv => dotenv.env['APP_ENV'] ?? 'development'
  }
```

---

## 2. Feature: Auth

### 2.1 Domain

```
lib/features/auth/domain/entities/user.dart
- ação: criar
- Entidade pura, sem dependência de JSON ou pacotes externos

pseudocódigo:
  classe User {
    final String id
    final String name
    final String email

    construtor User({required this.id, required this.name, required this.email})
  }
```

```
lib/features/auth/domain/repositories/auth_repository.dart
- ação: criar
- Contrato (interface abstrata) do repositório de autenticação com fluxo 2FA

pseudocódigo:
  abstrata classe AuthRepository {
    Future<Either<Failure, void>> login({required String email, required String password})
    Future<Either<Failure, void>> register({required String name, required String email, required String password})
    Future<Either<Failure, User>> verifyCode({required String email, required String code, required String deviceName})
    Future<Either<Failure, void>> resendCode({required String email, required String type})
    Future<Either<Failure, void>> logout()
    Future<Either<Failure, User>> getProfile()
  }
```

```
lib/features/auth/domain/usecases/login_usecase.dart
- ação: criar
- Executa login (fase 1) solicitando envio do código por e-mail

pseudocódigo:
  classe LoginUseCase {
    final AuthRepository repository

    construtor LoginUseCase(this.repository)

    Future<Either<Failure, void>> call({required String email, required String password}) {
      // Validações de entrada
      se email está vazio ou não corresponde a regex retornar Left(ValidationFailure('E-mail inválido ou vazio'))
      se password.length < 6 retornar Left(ValidationFailure('Senha mínima 6 caracteres'))

      retornar repository.login(email: email, password: password)
    }
  }
```

```
lib/features/auth/domain/usecases/register_usecase.dart
- ação: criar
- Executa autocadastro (UC01) solicitando envio do código por e-mail

pseudocódigo:
  classe RegisterUseCase {
    final AuthRepository repository

    construtor RegisterUseCase(this.repository)

    Future<Either<Failure, void>> call({required String name, required String email, required String password}) {
      se name está vazio retornar Left(ValidationFailure('Nome obrigatório'))
      se email não corresponde a regex retornar Left(ValidationFailure('E-mail inválido'))
      se password.length < 6 retornar Left(ValidationFailure('Senha mínima 6 caracteres'))

      retornar repository.register(name: name, email: email, password: password)
    }
  }
```

```
lib/features/auth/domain/usecases/verify_code_usecase.dart
- ação: criar
- Executa confirmação do código 2FA (fase 2) retornando o usuário logado

pseudocódigo:
  classe VerifyCodeUseCase {
    final AuthRepository repository

    construtor VerifyCodeUseCase(this.repository)

    Future<Either<Failure, User>> call({required String email, required String code, required String deviceName}) {
      se email está vazio retornar Left(ValidationFailure('E-mail obrigatório'))
      se code.length != 6 retornar Left(ValidationFailure('Código deve ter 6 dígitos'))
      se deviceName está vazio retornar Left(ValidationFailure('Nome do dispositivo obrigatório'))

      retornar repository.verifyCode(email: email, code: code, deviceName: deviceName)
    }
  }
```

```
lib/features/auth/domain/usecases/resend_code_usecase.dart
- ação: criar
- Executa solicitação de reenvio de código 2FA (registro ou login)

pseudocódigo:
  classe ResendCodeUseCase {
    final AuthRepository repository

    construtor ResendCodeUseCase(this.repository)

    Future<Either<Failure, void>> call({required String email, required String type}) {
      se email está vazio retornar Left(ValidationFailure('E-mail obrigatório'))
      se type está vazio retornar Left(ValidationFailure('Tipo obrigatório'))

      retornar repository.resendCode(email: email, type: type)
    }
  }
```

```
lib/features/auth/domain/usecases/logout_usecase.dart
- ação: criar
- Executa logout e limpa token local

pseudocódigo:
  classe LogoutUseCase {
    final AuthRepository repository

    Future<Either<Failure, void>> call() {
      retornar repository.logout()
    }
  }
```

### 2.2 Data

```
lib/features/auth/data/models/user_model.dart
- ação: criar
- Modelo que estende User com serialização JSON e suporte ao token Sanctum

pseudocódigo:
  classe UserModel extends User {
    final String token

    UserModel({required id, required name, required email, required this.token}) : super(id: id, name: name, email: email)

    fábrica UserModel.fromJson(Map<String, dynamic> json) {
      userJson = json['user'] ?? json
      retornar UserModel(
        id: userJson['id'].toString(),
        name: userJson['name'],
        email: userJson['email'],
        token: json['token'] ?? '',
      )
    }

    Map<String, dynamic> toJson() {
      retornar {'id': id, 'name': name, 'email': email, 'token': token}
    }
  }
```

```
lib/features/auth/data/datasources/auth_remote_datasource.dart
- ação: criar
- Comunicação HTTP com endpoints /api/auth/* adaptada para fluxo 2FA

pseudocódigo:
  abstrata classe AuthRemoteDataSource {
    Future<void> login(String email, String password)
    Future<void> register(String name, String email, String password)
    Future<UserModel> verifyCode(String email, String code, String deviceName)
    Future<void> resendCode(String email, String type)
    Future<void> logout()
    Future<UserModel> getProfile()
  }

  classe AuthRemoteDataSourceImpl implementa AuthRemoteDataSource {
    final Dio dio

    construtor AuthRemoteDataSourceImpl(this.dio)

    Future<void> login(email, password) async {
      await dio.post(ApiPaths.login, data: {'email': email, 'password': password})
    }

    Future<void> register(name, email, password) async {
      await dio.post(ApiPaths.register, data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password
      })
    }

    Future<UserModel> verifyCode(email, code, deviceName) async {
      response = await dio.post(ApiPaths.verifyCode, data: {
        'email': email,
        'code': code,
        'device_name': deviceName
      })
      retornar UserModel.fromJson(response.data)
    }

    Future<void> resendCode(email, type) async {
      await dio.post(ApiPaths.resendCode, data: {
        'email': email,
        'type': type
      })
    }

    Future<void> logout() async {
      await dio.post(ApiPaths.logout)
    }

    Future<UserModel> getProfile() async {
      response = await dio.get(ApiPaths.me)
      retornar UserModel.fromJson(response.data)
    }
  }
```

```
lib/features/auth/data/datasources/auth_local_datasource.dart
- ação: criar
- Armazena/recupera token JWT via SharedPreferences

pseudocódigo:
  classe AuthLocalDataSource {
    final SharedPreferences prefs

    Future<void> saveToken(String token) async {
      await prefs.setString('auth_token', token)
    }

    String? getToken() {
      retornar prefs.getString('auth_token')
    }

    Future<void> clearToken() async {
      await prefs.remove('auth_token')
    }
  }
```

```
lib/features/auth/data/repositories/auth_repository_impl.dart
- ação: criar
- Implementa AuthRepository, delega a RemoteDataSource, trata exceções e gerencia token local

pseudocódigo:
  classe AuthRepositoryImpl implementa AuthRepository {
    final AuthRemoteDataSource remote
    final AuthLocalDataSource local

    Future<Either<Failure, void>> login(email, password) async {
      tentar {
        await remote.login(email, password)
        retornar Right(null)
      } em DioException capturar (e) {
        retornar Left(ServerFailure(e.message))
      }
    }

    Future<Either<Failure, void>> register(name, email, password) async {
      tentar {
        await remote.register(name, email, password)
        retornar Right(null)
      } em DioException capturar (e) {
        retornar Left(ServerFailure(e.message))
      }
    }

    Future<Either<Failure, User>> verifyCode(email, code, deviceName) async {
      tentar {
        userModel = await remote.verifyCode(email, code, deviceName)
        await local.saveToken(userModel.token)
        retornar Right(userModel)
      } em DioException capturar (e) {
        retornar Left(ServerFailure(e.message))
      }
    }

    Future<Either<Failure, void>> resendCode(email, type) async {
      tentar {
        await remote.resendCode(email, type)
        retornar Right(null)
      } em DioException capturar (e) {
        retornar Left(ServerFailure(e.message))
      }
    }

    Future<Either<Failure, void>> logout() async {
      tentar {
        await remote.logout()
        await local.clearToken()
        retornar Right(null)
      } em DioException capturar (e) {
        retornar Left(ServerFailure(e.message))
      }
    }

    Future<Either<Failure, User>> getProfile() async {
      tentar {
        userModel = await remote.getProfile()
        retornar Right(userModel)
      } em DioException capturar (e) {
        retornar Left(ServerFailure(e.message))
      }
    }
  }
```

### 2.3 Presentation

```
lib/features/auth/presentation/providers/auth_provider.dart
- ação: criar
- StateNotifier que gerencia estado de autenticação (loading, codeSent, authenticated, unauthenticated, error)

pseudocódigo:
  enum AuthStatus { initial, loading, codeSent, authenticated, unauthenticated, error }

  classe AuthState {
    final AuthStatus status
    final User? user
    final String? email
    final String? verificationType // 'registration' ou 'api_login'
    final String? errorMessage

    construtor AuthState({
      this.status = AuthStatus.initial,
      this.user,
      this.email,
      this.verificationType,
      this.errorMessage,
    })
  }

  classe AuthNotifier extends StateNotifier<AuthState> {
    final LoginUseCase loginUseCase
    final RegisterUseCase registerUseCase
    final VerifyCodeUseCase verifyCodeUseCase
    final ResendCodeUseCase resendCodeUseCase
    final LogoutUseCase logoutUseCase

    construtor AuthNotifier({
      required this.loginUseCase,
      required this.registerUseCase,
      required this.verifyCodeUseCase,
      required this.resendCodeUseCase,
      required this.logoutUseCase,
    })

    Future<void> login(email, password) async {
      state = AuthState(status: AuthStatus.loading)
      resultado = await loginUseCase(email: email, password: password)
      resultado.fold(
        (failure) => state = AuthState(status: AuthStatus.error, errorMessage: failure.message),
        (_) => state = AuthState(status: AuthStatus.codeSent, email: email, verificationType: 'api_login'),
      )
    }

    Future<void> register(name, email, password) async {
      state = AuthState(status: AuthStatus.loading)
      resultado = await registerUseCase(name: name, email: email, password: password)
      resultado.fold(
        (failure) => state = AuthState(status: AuthStatus.error, errorMessage: failure.message),
        (_) => state = AuthState(status: AuthStatus.codeSent, email: email, verificationType: 'registration'),
      )
    }

    Future<void> verifyCode(code, deviceName) async {
      se state.email == nulo {
        state = AuthState(status: AuthStatus.error, errorMessage: 'E-mail não encontrado para verificação')
        retornar
      }
      emailSalvo = state.email!
      typeSalvo = state.verificationType
      state = AuthState(status: AuthStatus.loading, email: emailSalvo, verificationType: typeSalvo)
      resultado = await verifyCodeUseCase(email: emailSalvo, code: code, deviceName: deviceName)
      resultado.fold(
        (failure) => state = AuthState(status: AuthStatus.error, errorMessage: failure.message, email: emailSalvo, verificationType: typeSalvo),
        (user) => state = AuthState(status: AuthStatus.authenticated, user: user),
      )
    }

    Future<void> resendCode() async {
      se state.email == nulo retornar
      await resendCodeUseCase(email: state.email!, type: state.verificationType ?? 'api_login')
    }

    Future<void> cancelVerification() async {
      state = AuthState(status: AuthStatus.unauthenticated)
    }

    Future<void> logout() async {
      await logoutUseCase()
      state = AuthState(status: AuthStatus.unauthenticated)
    }
  }
```

```
lib/features/auth/presentation/providers/auth_providers.dart
- ação: criar
- Providers Riverpod que injetam dependências (DataSource → Repository → UseCase → Notifier)

pseudocódigo:
  final dioProvider = Provider((ref) => DioClient().instance)

  final authRemoteDataSourceProvider = Provider((ref) => AuthRemoteDataSourceImpl(ref.read(dioProvider)))
  final authLocalDataSourceProvider = Provider((ref) => AuthLocalDataSource())

  final authRepositoryProvider = Provider((ref) => AuthRepositoryImpl(
    remote: ref.read(authRemoteDataSourceProvider),
    local: ref.read(authLocalDataSourceProvider),
  ))

  final loginUseCaseProvider = Provider((ref) => LoginUseCase(ref.read(authRepositoryProvider)))
  final registerUseCaseProvider = Provider((ref) => RegisterUseCase(ref.read(authRepositoryProvider)))
  final verifyCodeUseCaseProvider = Provider((ref) => VerifyCodeUseCase(ref.read(authRepositoryProvider)))
  final resendCodeUseCaseProvider = Provider((ref) => ResendCodeUseCase(ref.read(authRepositoryProvider)))
  final logoutUseCaseProvider = Provider((ref) => LogoutUseCase(ref.read(authRepositoryProvider)))

  final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(
    loginUseCase: ref.read(loginUseCaseProvider),
    registerUseCase: ref.read(registerUseCaseProvider),
    verifyCodeUseCase: ref.read(verifyCodeUseCaseProvider),
    resendCodeUseCase: ref.read(resendCodeUseCaseProvider),
    logoutUseCase: ref.read(logoutUseCaseProvider),
  ))
```

```
lib/features/auth/presentation/pages/login_page.dart
- ação: criar
- Tela de login com campos de e-mail e senha
- Observa authNotifierProvider para reagir a mudanças de estado

pseudocódigo:
  classe LoginPage extends ConsumerWidget {
    campo emailController = TextEditingController()
    campo passwordController = TextEditingController()
    campo formKey = GlobalKey<FormState>()

    Widget build(context, ref) {
      authState = ref.watch(authNotifierProvider)

      retornar Scaffold(
        body: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(controller: emailController, validator: validadorEmail),
              TextFormField(controller: passwordController, obscureText: true, validator: validadorSenha),
              ElevatedButton(
                onPressed: () {
                  se formKey.currentState.validate() {
                    ref.read(authNotifierProvider.notifier).login(
                      email: emailController.text,
                      password: passwordController.text,
                    )
                  }
                },
                child: authState.status == AuthStatus.loading ? CircularProgressIndicator() : Text('Entrar'),
              ),
              TextButton(onPressed: () => navegarParaRegister(), child: Text('Criar conta')),
            ],
          ),
        ),
      )
    }
  }
```

```
lib/features/auth/presentation/pages/register_page.dart
- ação: criar
- Tela de autocadastro (UC01) com campos: Nome, E-mail, Senha
- Validação em cada campo antes do envio

pseudocódigo:
  classe RegisterPage extends ConsumerWidget {
    campo nameController, emailController, passwordController
    campo formKey = GlobalKey<FormState>()

    Widget build(context, ref) {
      authState = ref.watch(authNotifierProvider)

      retornar Scaffold(
        body: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(controller: nameController, validator: (v) => v.isEmpty ? 'Obrigatório' : null),
              TextFormField(controller: emailController, validator: validadorEmail),
              TextFormField(controller: passwordController, obscureText: true, validator: (v) => v.length < 6 ? 'Mínimo 6 caracteres' : null),
              ElevatedButton(
                onPressed: () {
                  se formKey.currentState.validate() {
                    ref.read(authNotifierProvider.notifier).register(
                      name: nameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                    )
                  }
                },
                child: authState.status == AuthStatus.loading ? CircularProgressIndicator() : Text('Cadastrar'),
              ),
            ],
          ),
        ),
      )
    }
  }
```

```
lib/features/auth/presentation/pages/verification_page.dart
- ação: criar
- Tela de verificação de código 2FA de 6 dígitos enviado por e-mail
- Permite confirmar o código ou solicitar reenvio

pseudocódigo:
  classe VerificationPage extends ConsumerWidget {
    campo codeController = TextEditingController()
    campo formKey = GlobalKey<FormState>()

    Widget build(context, ref) {
      authState = ref.watch(authNotifierProvider)

      retornar Scaffold(
        appBar: AppBar(title: Text('Verificação 2FA')),
        body: Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.all(DimensionTokens.paddingMedium),
            child: Column(
              children: [
                Text('Um código de verificação foi enviado para ${authState.email ?? ""}'),
                TextFormField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.length != 6 ? 'O código deve ter 6 dígitos' : null,
                ),
                ElevatedButton(
                  onPressed: () {
                    se formKey.currentState.validate() {
                      ref.read(authNotifierProvider.notifier).verifyCode(
                        codeController.text,
                        'Dispositivo Mobile',
                      )
                    }
                  },
                  child: authState.status == AuthStatus.loading ? CircularProgressIndicator() : Text('Verificar Código'),
                ),
                TextButton(
                  onPressed: () => ref.read(authNotifierProvider.notifier).resendCode(),
                  child: Text('Reenviar Código'),
                ),
                TextButton(
                  onPressed: () => ref.read(authNotifierProvider.notifier).cancelVerification(),
                  child: Text('Voltar para o Login'),
                ),
              ],
            ),
          ),
        ),
      )
    }
  }
```

---

## 3. Feature: Categories

### 3.1 Domain

```
lib/features/categories/domain/entities/category.dart
- ação: criar
- Entidade pura de Categoria

pseudocódigo:
  classe Category {
    final String id
    final String name
    final String icon   // nome do ícone Material
    final String color  // hex da cor

    construtor Category({required this.id, required this.name, required this.icon, required this.color})
  }
```

```
lib/features/categories/domain/repositories/category_repository.dart
- ação: criar

pseudocódigo:
  abstrata classe CategoryRepository {
    Future<Either<Failure, List<Category>>> getAll()
    Future<Either<Failure, Category>> getById(String id)
    Future<Either<Failure, Category>> create(String name, String icon, String color)
    Future<Either<Failure, Category>> update(String id, String name, String icon, String color)
    Future<Either<Failure, void>> delete(String id)
  }
```

```
lib/features/categories/domain/usecases/get_categories_usecase.dart
- ação: criar

pseudocódigo:
  classe GetCategoriesUseCase {
    final CategoryRepository repository

    Future<Either<Failure, List<Category>>> call() {
      retornar repository.getAll()
    }
  }
```

```
lib/features/categories/domain/usecases/create_category_usecase.dart
- ação: criar

pseudocódigo:
  classe CreateCategoryUseCase {
    final CategoryRepository repository

    Future<Either<Failure, Category>> call({required String name, required String icon, required String color}) {
      se name está vazio retornar Left(ValidationFailure('Nome da categoria obrigatório'))
      retornar repository.create(name, icon, color)
    }
  }
```

### 3.2 Data

```
lib/features/categories/data/models/category_model.dart
- ação: criar

pseudocódigo:
  classe CategoryModel extends Category {
    fábrica CategoryModel.fromJson(Map<String, dynamic> json) {
      retornar CategoryModel(id: json['id'].toString(), name: json['name'], icon: json['icon'], color: json['color'])
    }

    Map<String, dynamic> toJson() {
      retornar {'name': name, 'icon': icon, 'color': color}
    }
  }
```

```
lib/features/categories/data/datasources/category_remote_datasource.dart
- ação: criar
- CRUD contra /api/categories

pseudocódigo:
  classe CategoryRemoteDataSourceImpl {
    final Dio dio

    Future<List<CategoryModel>> getAll() async {
      response = await dio.get(ApiPaths.categories)
      retornar (response.data['data'] como List).map((j) => CategoryModel.fromJson(j)).toList()
    }

    Future<CategoryModel> create(name, icon, color) async {
      response = await dio.post(ApiPaths.categories, data: {'name': name, 'icon': icon, 'color': color})
      retornar CategoryModel.fromJson(response.data['data'])
    }

    Future<CategoryModel> update(id, name, icon, color) async {
      response = await dio.put('${ApiPaths.categories}/$id', data: {'name': name, 'icon': icon, 'color': color})
      retornar CategoryModel.fromJson(response.data['data'])
    }

    Future<void> delete(id) async {
      await dio.delete('${ApiPaths.categories}/$id')
    }
  }
```

```
lib/features/categories/data/repositories/category_repository_impl.dart
- ação: criar
- Implementa CategoryRepository, trata DioException

pseudocódigo:
  classe CategoryRepositoryImpl implementa CategoryRepository {
    final CategoryRemoteDataSource remote

    Future<Either<Failure, List<Category>>> getAll() async {
      tentar {
        models = await remote.getAll()
        retornar Right(models)
      } em DioException capturar (e) {
        retornar Left(ServerFailure(e.message))
      }
    }
    // ... demais métodos seguindo o mesmo padrão
  }
```

### 3.3 Presentation

```
lib/features/categories/presentation/providers/category_providers.dart
- ação: criar

pseudocódigo:
  final categoryRemoteDataSourceProvider = Provider((ref) => CategoryRemoteDataSourceImpl(ref.read(dioProvider)))
  final categoryRepositoryProvider = Provider((ref) => CategoryRepositoryImpl(remote: ref.read(categoryRemoteDataSourceProvider)))
  final getCategoriesUseCaseProvider = Provider((ref) => GetCategoriesUseCase(ref.read(categoryRepositoryProvider)))
  final createCategoryUseCaseProvider = Provider((ref) => CreateCategoryUseCase(ref.read(categoryRepositoryProvider)))

  final categoryListProvider = FutureProvider<List<Category>>((ref) async {
    useCase = ref.read(getCategoriesUseCaseProvider)
    resultado = await useCase()
    retornar resultado.fold((f) => throw f, (list) => list)
  })
```

```
lib/features/categories/presentation/pages/categories_page.dart
- ação: criar
- Lista categorias existentes
- Botão FAB para adicionar nova categoria

pseudocódigo:
  classe CategoriesPage extends ConsumerWidget {
    Widget build(context, ref) {
      categoriesAsync = ref.watch(categoryListProvider)

      retornar Scaffold(
        appBar: AppBar(title: Text('Categorias')),
        body: categoriesAsync.when(
          data: (list) => ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) => ListTile(
              leading: Icon(parseIcon(list[i].icon)),
              title: Text(list[i].name),
              trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => deletar(ref, list[i].id)),
            ),
          ),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro: $e')),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => navegarParaCreateCategory(),
          child: Icon(Icons.add),
        ),
      )
    }
  }
```

```
lib/features/categories/presentation/pages/create_category_page.dart
- ação: criar
- Formulário para cadastrar categoria com campos de Nome, seleção de ícones Material e paleta de cores.

lib/features/categories/presentation/pages/edit_category_page.dart
- ação: criar
- Formulário para editar categoria existente com campos pré-carregados, seleção de ícones Material e paleta de cores.
```

---

## 4. Feature: Transactions

### 4.1 Domain

```
lib/features/transactions/domain/entities/transaction.dart
- ação: criar
- Entidade pura de Transação

pseudocódigo:
  enum TransactionType { income, expense }

  classe Transaction {
    final String id
    final String title
    final double amount
    final TransactionType type
    final String categoryId
    final DateTime date
    final String? description

    construtor Transaction({required this.id, required this.title, required this.amount, required this.type, required this.categoryId, required this.date, this.description})
  }
```

```
lib/features/transactions/domain/repositories/transaction_repository.dart
- ação: criar

pseudocódigo:
  abstrata classe TransactionRepository {
    Future<Either<Failure, List<Transaction>>> getAll({DateTime? startDate, DateTime? endDate})
    Future<Either<Failure, Transaction>> getById(String id)
    Future<Either<Failure, Transaction>> create(Transaction transaction)
    Future<Either<Failure, Transaction>> update(Transaction transaction)
    Future<Either<Failure, void>> delete(String id)
    Future<Either<Failure, double>> getBalance()
  }
```

```
lib/features/transactions/domain/usecases/create_transaction_usecase.dart
- ação: criar
- UC02 — Lançamento de Transação Manual

pseudocódigo:
  classe CreateTransactionUseCase {
    final TransactionRepository repository

    Future<Either<Failure, Transaction>> call({
      required String title,
      required double amount,
      required TransactionType type,
      required String categoryId,
      required DateTime date,
      String? description,
    }) {
      se title está vazio retornar Left(ValidationFailure('Título obrigatório'))
      se amount <= 0 retornar Left(ValidationFailure('Valor deve ser maior que zero'))
      se categoryId está vazio retornar Left(ValidationFailure('Categoria obrigatória'))

      transaction = Transaction(
        id: '', // gerado pelo backend
        title: title,
        amount: amount,
        type: type,
        categoryId: categoryId,
        date: date,
        description: description,
      )

      retornar repository.create(transaction)
    }
  }
```

```
lib/features/transactions/domain/usecases/get_transactions_usecase.dart
- ação: criar

pseudocódigo:
  classe GetTransactionsUseCase {
    final TransactionRepository repository

    Future<Either<Failure, List<Transaction>>> call({DateTime? startDate, DateTime? endDate}) {
      retornar repository.getAll(startDate: startDate, endDate: endDate)
    }
  }
```

```
lib/features/transactions/domain/usecases/delete_transaction_usecase.dart
- ação: criar

pseudocódigo:
  classe DeleteTransactionUseCase {
    final TransactionRepository repository

    Future<Either<Failure, void>> call({required String id}) {
      retornar repository.delete(id)
    }
  }
```

### 4.2 Data

```
lib/features/transactions/data/models/transaction_model.dart
- ação: criar

pseudocódigo:
  classe TransactionModel extends Transaction {
    fábrica TransactionModel.fromJson(Map<String, dynamic> json) {
      retornar TransactionModel(
        id: json['id'].toString(),
        title: json['title'],
        amount: (json['amount'] as num).toDouble(),
        type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
        categoryId: json['category_id'].toString(),
        date: DateTime.parse(json['date']),
        description: json['description'],
      )
    }

    Map<String, dynamic> toJson() {
      retornar {
        'title': title,
        'amount': amount,
        'type': type == TransactionType.income ? 'income' : 'expense',
        'category_id': categoryId,
        'date': date.toIso8601String(),
        'description': description,
      }
    }
  }
```

```
lib/features/transactions/data/datasources/transaction_remote_datasource.dart
- ação: criar
- CRUD contra /api/transactions

pseudocódigo:
  classe TransactionRemoteDataSourceImpl {
    final Dio dio

    Future<List<TransactionModel>> getAll({DateTime? startDate, DateTime? endDate}) async {
      params = <String, dynamic>{}
      se startDate != nulo params['start_date'] = startDate.toIso8601String()
      se endDate != nulo params['end_date'] = endDate.toIso8601String()
      response = await dio.get(ApiPaths.transactions, queryParameters: params)
      retornar (response.data['data'] como List).map((j) => TransactionModel.fromJson(j)).toList()
    }

    Future<TransactionModel> create(TransactionModel transaction) async {
      response = await dio.post(ApiPaths.transactions, data: transaction.toJson())
      retornar TransactionModel.fromJson(response.data['data'])
    }

    Future<TransactionModel> update(TransactionModel transaction) async {
      response = await dio.put('${ApiPaths.transactions}/${transaction.id}', data: transaction.toJson())
      retornar TransactionModel.fromJson(response.data['data'])
    }

    Future<void> delete(String id) async {
      await dio.delete('${ApiPaths.transactions}/$id')
    }
  }
```

```
lib/features/transactions/data/repositories/transaction_repository_impl.dart
- ação: criar

pseudocódigo:
  classe TransactionRepositoryImpl implementa TransactionRepository {
    final TransactionRemoteDataSource remote

    Future<Either<Failure, List<Transaction>>> getAll({DateTime? startDate, DateTime? endDate}) async {
      tentar {
        models = await remote.getAll(startDate: startDate, endDate: endDate)
        retornar Right(models)
      } em DioException capturar (e) {
        retornar Left(ServerFailure(e.message))
      }
    }
    // ... demais métodos seguindo o mesmo padrão DioException → Left(ServerFailure)
  }
```

### 4.3 Presentation

```
lib/features/transactions/presentation/providers/transaction_providers.dart
- ação: criar

pseudocódigo:
  final transactionRemoteDataSourceProvider = Provider((ref) => TransactionRemoteDataSourceImpl(ref.read(dioProvider)))
  final transactionRepositoryProvider = Provider((ref) => TransactionRepositoryImpl(remote: ref.read(transactionRemoteDataSourceProvider)))
  final getTransactionsUseCaseProvider = Provider((ref) => GetTransactionsUseCase(ref.read(transactionRepositoryProvider)))
  final createTransactionUseCaseProvider = Provider((ref) => CreateTransactionUseCase(ref.read(transactionRepositoryProvider)))
  final deleteTransactionUseCaseProvider = Provider((ref) => DeleteTransactionUseCase(ref.read(transactionRepositoryProvider)))

  final transactionListProvider = FutureProvider.autoDispose<List<Transaction>>((ref) async {
    useCase = ref.read(getTransactionsUseCaseProvider)
    resultado = await useCase()
    retornar resultado.fold((f) => throw f, (list) => list)
  })
```

```
lib/features/transactions/presentation/pages/transactions_page.dart
- ação: criar
- Lista transações do usuário com pull-to-refresh
- Swipe para deletar

pseudocódigo:
  classe TransactionsPage extends ConsumerWidget {
    Widget build(context, ref) {
      transactionsAsync = ref.watch(transactionListProvider)

      retornar Scaffold(
        appBar: AppBar(title: Text('Transações')),
        body: RefreshIndicator(
          onRefresh: () => ref.refresh(transactionListProvider.future),
          child: transactionsAsync.when(
            data: (list) => ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) => Dismissible(
                key: Key(list[i].id),
                onDismissed: (_) => ref.read(deleteTransactionUseCaseProvider)(id: list[i].id),
                child: TransactionCardWidget(transaction: list[i]),
              ),
            ),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => navegarParaCreateTransaction(),
          child: Icon(Icons.add),
        ),
      )
    }
  }
```

```
lib/features/transactions/presentation/pages/create_transaction_page.dart
- ação: criar
- UC02 — Formulário para adicionar receita ou despesa
- Seleção de tipo (income/expense), categoria (dropdown), data (DatePicker)

pseudocódigo:
  classe CreateTransactionPage extends ConsumerWidget {
    campo titleController, amountController, descriptionController
    campo formKey = GlobalKey<FormState>()
    campo selectedType = TransactionType.expense
    campo selectedCategoryId = ''
    campo selectedDate = DateTime.now()

    Widget build(context, ref) {
      categoriesAsync = ref.watch(categoryListProvider)
      authState = ref.watch(authNotifierProvider)

      retornar Scaffold(
        appBar: AppBar(title: Text('Nova Transação')),
        body: Form(
          key: formKey,
          child: ListView(
            children: [
              // Tipo: SegmentedButton income/expense
              SegmentedButton<TransactionType>(
                segments: [ButtonSegment(value: TransactionType.income, label: Text('Receita')), ButtonSegment(value: TransactionType.expense, label: Text('Despesa'))],
                selected: {selectedType},
                onSelectionChanged: (set) => selectedType = set.first,
              ),
              TextFormField(controller: titleController, validator: (v) => v.isEmpty ? 'Obrigatório' : null),
              TextFormField(controller: amountController, keyboardType: TextInputType.number, validator: (v) => double.parse(v) <= 0 ? 'Valor inválido' : null),
              // Dropdown categorias
              categoriesAsync.when(
                data: (list) => DropdownButtonFormField<String>(
                  items: list.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => selectedCategoryId = v!,
                  validator: (v) => v == null ? 'Selecione uma categoria' : null,
                ),
                loading: () => CircularProgressIndicator(),
                error: (e, _) => Text('Erro ao carregar categorias'),
              ),
              // DatePicker
              ListTile(
                title: Text('Data: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2100))
                  se picked != nulo selectedDate = picked
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  se formKey.currentState.validate() {
                    resultado = await ref.read(createTransactionUseCaseProvider)(
                      title: titleController.text,
                      amount: double.parse(amountController.text),
                      type: selectedType,
                      categoryId: selectedCategoryId,
                      date: selectedDate,
                      description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                    )
                    resultado.fold(
                      (failure) => mostrarSnackBarErro(failure.message),
                      (_) {
                        ref.invalidate(transactionListProvider)
                        voltar()
                      },
                    )
                  }
                },
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      )
    }
  }
```

```
lib/features/transactions/presentation/widgets/transaction_card_widget.dart
- ação: criar
- Card reutilizável que exibe título, valor (com cor income/expense), categoria e data

pseudocódigo:
  classe TransactionCardWidget extends StatelessWidget {
    final Transaction transaction

    Widget build(context) {
      retornar Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: transaction.type == TransactionType.income ? ColorTokens.income : ColorTokens.expense,
            child: Icon(transaction.type == TransactionType.income ? Icons.arrow_downward : Icons.arrow_upward),
          ),
          title: Text(transaction.title),
          subtitle: Text('${transaction.date.day}/${transaction.date.month}/${transaction.date.year}'),
          trailing: Text(
            'R\$ ${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(color: transaction.type == TransactionType.income ? ColorTokens.income : ColorTokens.expense, fontWeight: FontWeight.bold),
          ),
        ),
      )
    }
  }
```

```
lib/features/transactions/presentation/pages/edit_transaction_page.dart
- ação: criar
- Formulário para editar transação existente com campos pré-carregados de tipo, título, valor, categoria, data e descrição.
```

---

## 5. Feature: Dashboard

### 5.1 Domain

```
lib/features/dashboard/domain/entities/dashboard_summary.dart
- ação: criar
- Agrega saldo total, total de receitas, total de despesas, distribuição por categoria e lista de transações

pseudocódigo:
  classe CategorySummary {
    final String categoryId
    final String categoryName
    final String categoryColor
    final double total
    final int count

    construtor CategorySummary({required this.categoryId, required this.categoryName, required this.categoryColor, required this.total, required this.count})
  }

  classe DashboardTransaction {
    final String id
    final String name
    final double value
    final String type
    final DateTime expenseDate
    final String categoryId

    construtor DashboardTransaction({required this.id, required this.name, required this.value, required this.type, required this.expenseDate, required this.categoryId})
  }

  classe DashboardSummary {
    final double balance
    final double totalIncome
    final double totalExpense
    final List<CategorySummary> categoryBreakdown
    final List<DashboardTransaction> transactions

    construtor DashboardSummary({required this.balance, required this.totalIncome, required this.totalExpense, required this.categoryBreakdown, required this.transactions})
  }
```

```
lib/features/dashboard/domain/repositories/dashboard_repository.dart
- ação: criar
- Contrato do repositório para buscar consolidado de dados

pseudocódigo:
  interface DashboardRepository {
    Future<Either<Failure, DashboardSummary>> getSummary({String? startDate, String? endDate})
  }
```

```
lib/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart
- ação: criar
- UC03 — Visualização Consolidada
- Chama o DashboardRepository para obter os dados processados pelo backend

pseudocódigo:
  classe GetDashboardSummaryUseCase {
    final DashboardRepository repository

    construtor GetDashboardSummaryUseCase(this.repository)

    Future<Either<Failure, DashboardSummary>> call({String? startDate, String? endDate}) async {
      retornar repository.getSummary(startDate: startDate, endDate: endDate)
    }
  }
```

### 5.2 Data

```
lib/features/dashboard/data/models/dashboard_summary_model.dart
- ação: criar
- Mapeamento JSON do response de /api/reports

lib/features/dashboard/data/datasources/dashboard_remote_datasource.dart
- ação: criar
- Realiza requisição HTTP GET /api/reports via Dio

lib/features/dashboard/data/repositories/dashboard_repository_impl.dart
- ação: criar
- Implementação concreta do repositório gerenciando exceções HTTP (DioException)
```

### 5.3 Presentation

```
lib/features/dashboard/presentation/providers/dashboard_providers.dart
- ação: criar

pseudocódigo:
  final dashboardRemoteDataSourceProvider = Provider((ref) => DashboardRemoteDataSourceImpl(ref.read(dioProvider)))
  final dashboardRepositoryProvider = Provider((ref) => DashboardRepositoryImpl(ref.read(dashboardRemoteDataSourceProvider)))
  final getDashboardSummaryUseCaseProvider = Provider((ref) => GetDashboardSummaryUseCase(ref.read(dashboardRepositoryProvider)))

  final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((ref) async {
    useCase = ref.read(getDashboardSummaryUseCaseProvider)
    resultado = await useCase()
    retornar resultado.fold((f) => throw f, (summary) => summary)
  })
```

```
lib/features/dashboard/presentation/pages/dashboard_page.dart
- ação: criar
- UC03 — Exibe saldo, totais de receita/despesa e gráfico de pizza
- Usa fl_chart para PieChart com breakdown por categoria

pseudocódigo:
  classe DashboardPage extends ConsumerWidget {
    Widget build(context, ref) {
      summaryAsync = ref.watch(dashboardSummaryProvider)
      authState = ref.watch(authNotifierProvider)

      retornar Scaffold(
        appBar: AppBar(
          title: Text('Olá, ${authState.user?.name ?? ''}'),
          actions: [IconButton(icon: Icon(Icons.logout), onPressed: () => ref.read(authNotifierProvider.notifier).logout())],
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardSummaryProvider.future),
          child: summaryAsync.when(
            data: (summary) => ListView(
              children: [
                // Card Saldo
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(DimensionTokens.paddingLarge),
                    child: Column(
                      children: [
                        Text('Saldo Atual', style: TextStyle(fontSize: 16)),
                        Text('R\$ ${summary.balance.toStringAsFixed(2)}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                // Row Receita / Despesa
                Row(
                  children: [
                    Expanded(child: _buildTile('Receitas', summary.totalIncome, ColorTokens.income)),
                    Expanded(child: _buildTile('Despesas', summary.totalExpense, ColorTokens.expense)),
                  ],
                ),
                // PieChart
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: summary.categoryBreakdown.map((cs) => PieChartSectionData(
                        value: cs.total,
                        title: cs.categoryName,
                        color: Color(int.parse('0xFF${cs.categoryColor}')),
                        radius: 80,
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
          ),
        ),
      )
    }
  }
```

---

## 6. App Entry Point

```
lib/main.dart
- ação: criar
- Inicializa WidgetsFlutterBinding, EnvConfig, SharedPreferences
- Define MaterialApp com tema, rotas e ConsumerWidget raiz que decide Authenticated vs Unauthenticated vs CodeSent

pseudocódigo:
  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized()
    await EnvConfig.load()
    runApp(ProviderScope(child: MyApp()))
  }

  classe MyApp extends ConsumerWidget {
    Widget build(context, ref) {
      authState = ref.watch(authNotifierProvider)

      retornar MaterialApp(
        title: 'FinançasPessoais',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: authState.status == AuthStatus.authenticated
          ? DashboardPage()
          : authState.status == AuthStatus.codeSent
            ? VerificationPage()
            : LoginPage(),
      )
    }
  }
```

---

## 7. Tratamento de Erros (Core)

```
lib/core/error/failures.dart
- ação: criar
- Classe base Failure e subtipos para padronização de erros

pseudocódigo:
  abstrata classe Failure {
    final String message
    construtor Failure(this.message)
  }

  classe ServerFailure extends Failure {
    ServerFailure(super.message)
  }

  classe ValidationFailure extends Failure {
    ValidationFailure(super.message)
  }

  classe CacheFailure extends Failure {
    CacheFailure(super.message)
  }
```

---

## 8. Padrões de Interface, Responsividade e Acessibilidade

### 8.1 Padronização de Design System e Componentes Core
Para garantir a consistência de layout e a manutenibilidade do código, todas as telas do aplicativo devem utilizar os seguintes componentes globais localizados em `lib/core/widgets/state_widgets.dart` para tratamento de estados assíncronos:
- **`LoadingWidget`**: Exibido durante operações pendentes de API/Banco de dados. Deve possuir uma mensagem amigável opcional e a marcação semântica correspondente.
- **`ErrorFallbackWidget`**: Exibido quando uma operação falha. Deve exibir um ícone vermelho de erro, a mensagem detalhada e disponibilizar um botão de ação "TENTAR NOVAMENTE" que revalida o provider ou reinicia o fluxo.
- **`EmptyStateWidget`**: Exibido quando não há dados salvos. Deve conter um ícone ilustrativo central, título descritivo do estado vazio e um botão de chamada para ação (CTA) que redireciona o usuário para a tela de criação pertinente.

### 8.2 Diretrizes de Responsividade
Para que o aplicativo se adapte harmoniosamente a múltiplos tamanhos de tela (como celulares de diferentes resoluções, tablets e telas web):
1. **Formulários de Fluxo (Login, Autocadastro, Confirmação 2FA)**:
   - Devem conter restrição de largura máxima de `500.0` pixels lógicos no container centralizado para evitar esticamento excessivo dos campos e botões em tablets e monitores amplos.
2. **Dashboard Adaptativo**:
   - **Telas Estreitas (< 600px)**: Cards de resumo (Saldo, Receita e Despesa) dispostos em lista vertical de uma única coluna. Legendas do gráfico exibidas abaixo da representação visual do gráfico de pizza.
   - **Telas Amplas (>= 600px)**: Cards de resumo dispostos lado a lado em linha horizontal (`Row` com 3 colunas). O gráfico de pizza e a legenda de categorias dispostos lado a lado.

### 8.3 Diretrizes de Acessibilidade (A11y)
1. **Anotações Semânticas**:
   - Elementos interativos (como botões e links) que dependem de ícones sem texto adjacente visível devem ter anotações explícitas usando o widget `Semantics` com o atributo `label` correspondente em português e `button: true`.
2. **Narração Unificada de Listas**:
   - No card de transação (`TransactionCardWidget`), os textos de título, data e valor devem ser encapsulados por um único widget `Semantics` que unifique a informação em um texto corrido legível por softwares de leitura de tela (ex: TalkBack/VoiceOver). O parâmetro `excludeSemantics: true` deve ser utilizado nos widgets filhos para evitar repetição excessiva de elementos soltos pelo leitor de tela.
3. **Regiões Dinâmicas (Live Regions)**:
   - Mensagens de progresso ou conclusão de ações críticas devem ser definidas com `liveRegion: true` no widget de Semantics ou anunciadas via `SemanticsService.announce` para garantir o feedback imediato aos usuários deficientes visuais.

```
