import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/config/env_config.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/verification_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const FinancasApp(),
    ),
  );
}

class FinancasApp extends ConsumerStatefulWidget {
  const FinancasApp({super.key});

  @override
  ConsumerState<FinancasApp> createState() => _FinancasAppState();
}

class _FinancasAppState extends ConsumerState<FinancasApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    Widget homeWidget;
    switch (authState.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        homeWidget = const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
        break;
      case AuthStatus.authenticated:
        homeWidget = const DashboardPage();
        break;
      case AuthStatus.codeSent:
        homeWidget = const VerificationPage();
        break;
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
      default:
        homeWidget = const LoginPage();
        break;
    }

    return MaterialApp(
      title: 'FinançasPessoais',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: homeWidget,
    );
  }
}
