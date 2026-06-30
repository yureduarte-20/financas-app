import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financas_app/core/widgets/state_widgets.dart';

void main() {
  group('LoadingWidget Tests', () {
    testWidgets('Deve renderizar o CircularProgressIndicator e a mensagem opcional', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(message: 'Carregando dados...'),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Carregando dados...'), findsOneWidget);
    });

    testWidgets('Deve renderizar apenas o CircularProgressIndicator quando a mensagem for nula', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });
  });

  group('ErrorFallbackWidget Tests', () {
    testWidgets('Deve renderizar o titulo, a mensagem e chamar o callback de retry ao clicar', (WidgetTester tester) async {
      // Arrange
      bool retryClicked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorFallbackWidget(
              title: 'Erro de Conexão',
              errorMessage: 'Não foi possível conectar ao servidor.',
              onRetry: () {
                retryClicked = true;
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('Erro de Conexão'), findsOneWidget);
      expect(find.text('Não foi possível conectar ao servidor.'), findsOneWidget);
      expect(find.text('TENTAR NOVAMENTE'), findsOneWidget);

      // Act
      await tester.tap(find.text('TENTAR NOVAMENTE'));
      await tester.pump();

      // Assert
      expect(retryClicked, isTrue);
    });

    testWidgets('Não deve exibir o botão de retry se onRetry não for fornecido', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorFallbackWidget(
              errorMessage: 'Ocorreu um erro silencioso.',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('TENTAR NOVAMENTE'), findsNothing);
      expect(find.text('Ocorreu um erro'), findsOneWidget); // Titulo padrão
      expect(find.text('Ocorreu um erro silencioso.'), findsOneWidget);
    });
  });

  group('EmptyStateWidget Tests', () {
    testWidgets('Deve renderizar o icone, titulo, descricao e chamar callback ao clicar no CTA', (WidgetTester tester) async {
      // Arrange
      bool actionClicked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.star_border,
              title: 'Sem Favoritos',
              description: 'Você ainda não favoritou nenhuma transação.',
              actionLabel: 'Adicionar Favorito',
              onAction: () {
                actionClicked = true;
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(find.text('Sem Favoritos'), findsOneWidget);
      expect(find.text('Você ainda não favoritou nenhuma transação.'), findsOneWidget);
      expect(find.text('ADICIONAR FAVORITO'), findsOneWidget);

      // Act
      await tester.tap(find.text('ADICIONAR FAVORITO'));
      await tester.pump();

      // Assert
      expect(actionClicked, isTrue);
    });

    testWidgets('Não deve exibir botão de ação se actionLabel ou onAction forem nulos', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.star_border,
              title: 'Sem Dados',
              description: 'Nenhum registro encontrado.',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
