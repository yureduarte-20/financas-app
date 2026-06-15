import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/constants/dimension_tokens.dart';
import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';
import 'create_category_page.dart';
import 'edit_category_page.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        backgroundColor: ColorTokens.primary,
        foregroundColor: Colors.white,
      ),
      body: categoriesAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma categoria encontrada.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(DimensionTokens.paddingMedium),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final category = list[i];
              final categoryColor = parseColor(category.color);
              final categoryIcon = parseIcon(category.icon);

              return Card(
                elevation: 1.5,
                margin: const EdgeInsets.only(bottom: DimensionTokens.paddingSmall),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DimensionTokens.radiusMedium),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: categoryColor.withAlpha(26), // soft color background
                    child: Icon(categoryIcon, color: categoryColor),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Cor: #${category.color.toUpperCase()}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EditCategoryPage(category: category),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: ColorTokens.error),
                        onPressed: () => _deleteCategory(context, ref, category),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Erro: $e',
            style: const TextStyle(color: ColorTokens.error),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorTokens.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateCategoryPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteCategory(BuildContext context, WidgetRef ref, Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Categoria'),
        content: Text('Tem certeza que deseja excluir a categoria "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: ColorTokens.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ref.read(deleteCategoryUseCaseProvider)(category.id);
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: ColorTokens.error,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Categoria excluída com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(categoryListProvider);
        },
      );
    }
  }

  IconData parseIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'restaurant':
      case 'food':
      case 'alimentação':
        return Icons.restaurant;
      case 'directions_car':
      case 'transport':
      case 'transporte':
        return Icons.directions_car;
      case 'medical_services':
      case 'health':
      case 'saúde':
        return Icons.medical_services;
      case 'school':
      case 'education':
      case 'educação':
        return Icons.school;
      case 'shopping_bag':
      case 'shopping':
      case 'compras':
        return Icons.shopping_bag;
      case 'work':
      case 'business':
      case 'trabalho':
        return Icons.work;
      case 'home':
      case 'casa':
        return Icons.home;
      case 'attach_money':
      case 'money':
      case 'finance':
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }

  Color parseColor(String hexColor) {
    final cleanHex = hexColor.replaceAll('#', '');
    if (cleanHex.length == 6) {
      return Color(int.parse('0xFF$cleanHex'));
    }
    return ColorTokens.primary;
  }
}
