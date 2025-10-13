import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common/theme/app_colors.dart'; // Asegúrate de que este import sea correcto
import '../../../common/theme/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/custom_input_field.dart';

class NewTransactionModal extends StatefulWidget {
  const NewTransactionModal({super.key});

  @override
  State<NewTransactionModal> createState() => _NewTransactionModalState();
}

class _NewTransactionModalState extends State<NewTransactionModal> {
  String _selectedType = 'gasto';
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  final List<String> _categories = [
    'Alimentación', 'Transporte', 'Ocio', 'Hogar', 'Salud', 'Educación'
  ];

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text('Nueva Transacción', style: AppTextStyles.heading)),
            const SizedBox(height: 24),
            
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ... (Todo el contenido del formulario que ya teníamos está bien)
                    Text('Tipo', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ToggleButtons(
                      isSelected: [_selectedType == 'gasto', _selectedType == 'ingreso'],
                      onPressed: (index) { setState(() { _selectedType = index == 0 ? 'gasto' : 'ingreso'; }); },
                      borderRadius: BorderRadius.circular(30.0),
                      fillColor: _selectedType == 'gasto' ? Colors.red.shade400 : Colors.green.shade400,
                      selectedColor: Colors.white,
                      constraints: BoxConstraints(minWidth: (MediaQuery.of(context).size.width - 52) / 2, minHeight: 40),
                      children: const [Text('Gasto'), Text('Ingreso')],
                    ),
                    const SizedBox(height: 20),
                    if (_selectedType == 'gasto') ...[
                      Text('Categoría *', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        hint: const Text('Selecciona una categoría'),
                        onChanged: (String? newValue) { setState(() { _selectedCategory = newValue; }); },
                        items: _categories.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                        decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text('Monto *', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    CustomInputField(controller: _amountController, labelText: '0.00', prefixIcon: Icons.attach_money, keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    Text('Fecha', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(DateFormat('MMMM d, y').format(_selectedDate)),
                      onPressed: () => _selectDate(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Nota (opcional)', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    CustomInputField(controller: _noteController, labelText: 'Añade una descripción...', maxLines: 3),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    onPressed: () {
                    print('Guardando transacción...');
                    
                    // Simplemente cierra el modal y devuelve 'true' para indicar éxito.
                    Navigator.pop(context, true); 
                  }, 
                  text: 'Guardar',
                )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}