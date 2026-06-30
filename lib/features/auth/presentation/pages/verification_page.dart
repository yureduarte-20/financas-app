import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/dimension_tokens.dart';
import '../../../../core/constants/color_tokens.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_providers.dart';
import 'login_page.dart';

class VerificationPage extends ConsumerStatefulWidget {
  const VerificationPage({super.key});

  @override
  ConsumerState<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends ConsumerState<VerificationPage> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: ColorTokens.error),
        );
      } else if (next.status == AuthStatus.authenticated) {
        // Redireciona para Dashboard (quando implementado)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Autenticado com sucesso!'), backgroundColor: ColorTokens.income),
        );
      } else if (next.status == AuthStatus.unauthenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificação 2FA'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          onPressed: () {
            ref.read(authNotifierProvider.notifier).cancelVerification();
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DimensionTokens.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.mark_email_read_outlined, size: 64, color: ColorTokens.primary),
                    const SizedBox(height: DimensionTokens.paddingLarge),
                    Text(
                      'Insira o código de 6 dígitos que enviamos para o e-mail:',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DimensionTokens.paddingSmall),
                    Text(
                      authState.email ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DimensionTokens.paddingLarge),
                    TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: 'Código de Verificação',
                        helperText: 'O código expira em 10 minutos',
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: ColorTokens.primary, width: 2.5),
                          borderRadius: BorderRadius.circular(DimensionTokens.radiusMedium),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                          borderRadius: BorderRadius.circular(DimensionTokens.radiusMedium),
                        ),
                        counterText: '',
                      ),
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                      validator: (v) => v == null || v.length != 6 ? 'O código deve ter 6 dígitos' : null,
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
                            ref.read(authNotifierProvider.notifier).verifyCode(
                                  code: _codeController.text.trim(),
                                  deviceName: 'App Mobile',
                                );
                          }
                        },
                  child: authState.status == AuthStatus.loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: ColorTokens.surface, strokeWidth: 2),
                        )
                      : const Text('VERIFICAR', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: DimensionTokens.paddingMedium),
                TextButton(
                  onPressed: authState.status == AuthStatus.loading
                      ? null
                      : () {
                          ref.read(authNotifierProvider.notifier).resendCode();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Código reenviado!')),
                          );
                        },
                  child: const Text('Reenviar código'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
  }
}
