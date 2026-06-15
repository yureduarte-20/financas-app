import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/constants/dimension_tokens.dart';
import '../providers/category_providers.dart';

class CreateCategoryPage extends ConsumerStatefulWidget {
  const CreateCategoryPage({super.key});

  @override
  ConsumerState<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends ConsumerState<CreateCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String _selectedIcon = 'restaurant';
  String _selectedColor = 'E57373';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'restaurant', 'icon': Icons.restaurant, 'label': 'Alimentação'},
    {'name': 'directions_car', 'icon': Icons.directions_car, 'label': 'Transporte'},
    {'name': 'medical_services', 'icon': Icons.medical_services, 'label': 'Saúde'},
    {'name': 'school', 'icon': Icons.school, 'label': 'Educação'},
    {'name': 'shopping_bag', 'icon': Icons.shopping_bag, 'label': 'Compras'},
    {'name': 'work', 'icon': Icons.work, 'label': 'Trabalho'},
    {'name': 'home', 'icon': Icons.home, 'label': 'Casa'},
    {'name': 'attach_money', 'icon': Icons.attach_money, 'label': 'Finanças'},
  ];

  final List<String> _availableColors = [
    'E57373', // Light Red
    '81C784', // Light Green
    '64B5F6', // Light Blue
    'BA68C8', // Light Purple
    'FFD54F', // Light Yellow
    'F06292', // Light Pink
    '4DD0E1', // Light Cyan
    'FFB74D', // Light Orange
    'A1887F', // Light Brown
    '90A4AE', // Light Blue Grey
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Categoria'),
        backgroundColor: ColorTokens.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DimensionTokens.paddingMedium),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: DimensionTokens.paddingSmall),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Categoria',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nome da categoria obrigatório' : null,
                ),
                const SizedBox(height: DimensionTokens.paddingLarge),
                
                // Icon Selection
                const Text(
                  'Selecione um Ícone',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: DimensionTokens.paddingSmall),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, index) {
                      final item = _availableIcons[index];
                      final isSelected = item['name'] == _selectedIcon;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIcon = item['name'] as String;
                          });
                        },
                        child: Container(
                          width: 65,
                          margin: const EdgeInsets.only(right: DimensionTokens.paddingSmall),
                          decoration: BoxDecoration(
                            color: isSelected ? ColorTokens.primary.withAlpha(40) : Colors.transparent,
                            borderRadius: BorderRadius.circular(DimensionTokens.radiusMedium),
                            border: Border.all(
                              color: isSelected ? ColorTokens.primary : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                color: isSelected ? ColorTokens.primary : Colors.grey.shade600,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['label'] as String,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isSelected ? ColorTokens.primary : Colors.grey.shade600,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: DimensionTokens.paddingLarge),

                // Color Selection
                const Text(
                  'Selecione uma Cor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: DimensionTokens.paddingSmall),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _availableColors.map((hexColor) {
                    final color = Color(int.parse('0xFF$hexColor'));
                    final isSelected = hexColor == _selectedColor;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = hexColor;
                        });
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(26),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: DimensionTokens.paddingLarge * 1.5),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: DimensionTokens.paddingMedium),
                    backgroundColor: ColorTokens.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DimensionTokens.radiusMedium),
                    ),
                  ),
                  onPressed: _isLoading ? null : _saveCategory,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('SALVAR', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final result = await ref.read(createCategoryUseCaseProvider)(
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
    );

    setState(() {
      _isLoading = false;
    });

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
            content: Text('Categoria criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(categoryListProvider);
        Navigator.of(context).pop();
      },
    );
  }
}
