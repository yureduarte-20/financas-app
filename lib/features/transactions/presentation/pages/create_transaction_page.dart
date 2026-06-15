import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/constants/dimension_tokens.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../providers/transaction_providers.dart';
import '../../domain/entities/transaction.dart';

class CreateTransactionPage extends ConsumerStatefulWidget {
  const CreateTransactionPage({super.key});

  @override
  ConsumerState<CreateTransactionPage> createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends ConsumerState<CreateTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Transação'),
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
                // Segmented Button
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Receita'),
                      icon: Icon(Icons.add_circle_outline),
                    ),
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Despesa'),
                      icon: Icon(Icons.remove_circle_outline),
                    ),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (set) {
                    setState(() {
                      _selectedType = set.first;
                    });
                  },
                ),
                const SizedBox(height: DimensionTokens.paddingMedium),

                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Título obrigatório' : null,
                ),
                const SizedBox(height: DimensionTokens.paddingMedium),

                // Amount field
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Valor (R\$)',
                    border: OutlineInputBorder(),
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Valor obrigatório';
                    final parsed = double.tryParse(v.replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) return 'Valor deve ser maior que zero';
                    return null;
                  },
                ),
                const SizedBox(height: DimensionTokens.paddingMedium),

                // Category selection dropdown
                categoriesAsync.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Nenhuma categoria encontrada. Crie uma categoria primeiro.',
                          style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                        ),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(),
                      ),
                      items: list.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedCategoryId = v;
                        });
                      },
                      validator: (v) => v == null ? 'Selecione uma categoria' : null,
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => const Text(
                    'Erro ao carregar categorias',
                    style: TextStyle(color: ColorTokens.error),
                  ),
                ),
                const SizedBox(height: DimensionTokens.paddingMedium),

                // Date selection
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DimensionTokens.radiusSmall),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: ListTile(
                    title: Text(
                      'Data: ${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.calendar_today, color: ColorTokens.primary),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: DimensionTokens.paddingMedium),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (Opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: DimensionTokens.paddingLarge * 1.5),

                // Submit button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: DimensionTokens.paddingMedium),
                    backgroundColor: ColorTokens.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DimensionTokens.radiusMedium),
                    ),
                  ),
                  onPressed: _isLoading ? null : _saveTransaction,
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

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) return;

    setState(() {
      _isLoading = true;
    });

    final amountStr = _amountController.text.replaceAll(',', '.');
    final result = await ref.read(createTransactionUseCaseProvider)(
      title: _titleController.text.trim(),
      amount: double.parse(amountStr),
      type: _selectedType,
      categoryId: _selectedCategoryId!,
      date: _selectedDate,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
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
            content: Text('Transação salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(transactionListProvider);
        Navigator.of(context).pop();
      },
    );
  }
}
