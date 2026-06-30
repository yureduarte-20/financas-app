import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/dimension_tokens.dart';
import '../../../../core/constants/color_tokens.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_providers.dart';
import 'register_page.dart';
import 'verification_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Redirecionamento baseado no status
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: ColorTokens.error),
        );
      } else if (next.status == AuthStatus.codeSent) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VerificationPage()),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DimensionTokens.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'FinançasPessoais',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: ColorTokens.primary,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DimensionTokens.paddingLarge * 2),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      return v == null || !emailRegex.hasMatch(v) ? 'E-mail inválido' : null;
                    },
                  ),
                  const SizedBox(height: DimensionTokens.paddingMedium),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (v) => v == null || v.length < 6 ? 'Mínimo de 6 caracteres' : null,
                  ),
                  const SizedBox(height: DimensionTokens.paddingLarge),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: DimensionTokens.paddingMedium),
                      backgroundColor: ColorTokens.primary,
                      foregroundColor: ColorTokens.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DimensionTokens.radiusMedium),
                      ),
                    ),
                    onPressed: authState.status == AuthStatus.loading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              ref.read(authNotifierProvider.notifier).login(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  );
                            }
                          },
                    child: authState.status == AuthStatus.loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: ColorTokens.surface, strokeWidth: 2),
                          )
                        : const Text('ENTRAR', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: DimensionTokens.paddingMedium),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: const Text('Não tem uma conta? Crie aqui'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
