import 'package:flutter/material.dart';
import '../constants/color_tokens.dart';
import '../constants/dimension_tokens.dart';

/// Um widget de carregamento padronizado com anotações de acessibilidade.
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: message ?? 'Carregando dados',
        value: 'Em andamento',
        liveRegion: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ColorTokens.primary),
            ),
            if (message != null) ...[
              const SizedBox(height: DimensionTokens.paddingMedium),
              Text(
                message!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Um widget de erro padronizado para exibir falhas com opção de tentar novamente.
class ErrorFallbackWidget extends StatelessWidget {
  final String errorMessage;
  final String? title;
  final VoidCallback? onRetry;

  const ErrorFallbackWidget({
    super.key,
    required this.errorMessage,
    this.title,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = title ?? 'Ocorreu um erro';
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(DimensionTokens.paddingLarge),
        child: Semantics(
          label: '$displayTitle: $errorMessage',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: ColorTokens.error,
                size: 64,
              ),
              const SizedBox(height: DimensionTokens.paddingMedium),
              Text(
                displayTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DimensionTokens.paddingSmall),
              Text(
                errorMessage,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: DimensionTokens.paddingLarge),
                Semantics(
                  button: true,
                  label: 'Tentar carregar os dados novamente',
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTokens.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: DimensionTokens.paddingLarge,
                        vertical: DimensionTokens.paddingMedium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DimensionTokens.radiusMedium),
                      ),
                    ),
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text(
                      'TENTAR NOVAMENTE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Um widget de estado vazio padronizado para incentivar a ação do usuário.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(DimensionTokens.paddingLarge),
        child: Semantics(
          label: '$title: $description',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(DimensionTokens.paddingLarge),
                decoration: BoxDecoration(
                  color: ColorTokens.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 72,
                  color: ColorTokens.primary,
                ),
              ),
              const SizedBox(height: DimensionTokens.paddingLarge),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DimensionTokens.paddingSmall),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(height: DimensionTokens.paddingLarge),
                Semantics(
                  button: true,
                  label: actionLabel,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTokens.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: DimensionTokens.paddingLarge,
                        vertical: DimensionTokens.paddingMedium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DimensionTokens.radiusMedium),
                      ),
                    ),
                    onPressed: onAction,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(
                      actionLabel!.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
