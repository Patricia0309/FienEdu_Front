// lib/features/transactions/widgets/new_transaction_modal.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/custom_input_field.dart';
import '../../../data/services/category_service.dart';
import '../../../data/services/transaction_service.dart';
import '../../../features/inicial_setup/models/category_model.dart';
import '../../../features/transactions/models/transaction_model.dart';
import '../../../common/utils/show_snackbar.dart';

class NewTransactionModal extends StatefulWidget {
  const NewTransactionModal({super.key});

  @override
  State<NewTransactionModal> createState() => _NewTransactionModalState();
}

class _NewTransactionModalState extends State<NewTransactionModal> {
  final _formKey = GlobalKey<FormState>();
  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();

  // State variables
  String _selectedType = 'gasto';
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryService.getCategories();
  }

  Future<void> _handleSave() async {
    // Validamos que los campos obligatorios estén llenos
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _transactionService.createTransaction(
          amount: double.parse(_amountController.text),
          type: _selectedType == 'gasto'
              ? TransactionType.gasto
              : TransactionType.ingreso,
          // Si es un ingreso, tu API debería manejar un ID nulo o especial. Enviamos 1 por defecto si no es gasto.
          categoryId: _selectedType == 'gasto' ? _selectedCategoryId! : 1,
          date: _selectedDate,
          note: _noteController.text,
        );
        // Devolvemos 'true' para que MainScreen muestre el SnackBar
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          showErrorSnackBar(
            context,
            e.toString().replaceFirst('Exception: ', ''),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // --- Función para mostrar el DatePicker ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text('Nueva Transacción', style: AppTextStyles.heading),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tipo',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ToggleButtons(
                        isSelected: [
                          _selectedType == 'gasto',
                          _selectedType == 'ingreso',
                        ],
                        onPressed: (index) {
                          setState(() {
                            _selectedType = index == 0 ? 'gasto' : 'ingreso';
                          });
                        },
                        borderRadius: BorderRadius.circular(30.0),
                        fillColor: _selectedType == 'gasto'
                            ? Colors.red.shade400
                            : Colors.green.shade400,
                        selectedColor: Colors.white,
                        constraints: BoxConstraints(
                          minWidth:
                              (MediaQuery.of(context).size.width - 52) / 2,
                          minHeight: 40,
                        ),
                        children: const [Text('Gasto'), Text('Ingreso')],
                      ),
                      const SizedBox(height: 20),
                      if (_selectedType == 'gasto') ...[
                        Text(
                          'Categoría *',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<List<Category>>(
                          future: _categoriesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return const Text(
                                'No se pudieron cargar las categorías',
                              );
                            }
                            final categories = snapshot.data!;
                            return DropdownButtonFormField<int>(
                              value: _selectedCategoryId,
                              hint: const Text('Selecciona una categoría'),
                              onChanged: (int? newValue) {
                                setState(() {
                                  _selectedCategoryId = newValue;
                                });
                              },
                              items: categories.map<DropdownMenuItem<int>>((
                                Category category,
                              ) {
                                return DropdownMenuItem<int>(
                                  value: category.id,
                                  child: Text(category.title),
                                );
                              }).toList(),
                              validator: (value) => value == null
                                  ? 'Por favor selecciona una categoría'
                                  : null,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                      Text(
                        'Monto *',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomInputField(
                        controller: _amountController,
                        labelText: '0.00',
                        prefixIcon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Por favor ingresa un monto'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Fecha',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            DateFormat('MMMM d, y').format(_selectedDate),
                          ),
                          onPressed: () => _selectDate(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Nota (opcional)',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomInputField(
                        controller: _noteController,
                        labelText: 'Añade una descripción...',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(
                      onPressed: _isLoading ? null : _handleSave,
                      text: _isLoading ? 'Guardando...' : 'Guardar',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
