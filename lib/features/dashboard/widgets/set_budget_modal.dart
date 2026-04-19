// lib/features/dashboard/widgets/set_budget_modal.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener el import si usas DateFormat
import 'package:table_calendar/table_calendar.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../common/widgets/custom_input_field.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../data/services/budget_service.dart';
import '../../../common/utils/show_snackbar.dart';
import '../../budgets/models/budget_status_model.dart'; // Importa BudgetStatus

class SetBudgetModal extends StatefulWidget {
  // Recibe el estado del presupuesto actual (si existe)
  final BudgetStatus? initialBudgetStatus;

  const SetBudgetModal({super.key, this.initialBudgetStatus});

  @override
  State<SetBudgetModal> createState() => _SetBudgetModalState();
}

class _SetBudgetModalState extends State<SetBudgetModal> {
  final _formKey = GlobalKey<FormState>();
  final BudgetService _budgetService = BudgetService();

  final _amountController = TextEditingController();
  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _focusedDayStart;
  late DateTime _focusedDayEnd;
  bool _isLoading = false;

  // Variable para saber si estamos editando
  bool get _isEditing => widget.initialBudgetStatus != null;
  String? _dateErrorMessage;

  @override
  void initState() {
    super.initState();
    // Si estamos editando, pre-rellena los campos
    if (_isEditing) {
      final status = widget.initialBudgetStatus!;
      // Usamos totalIncome como el monto original del presupuesto
      _amountController.text = status.totalIncome.toStringAsFixed(2);
      _startDate = status.startDate;
      _endDate = status.endDate;
    } else {
      // Valores por defecto si estamos creando uno nuevo
      final now = DateTime.now();
      // Inicio del mes actual
      _startDate = DateTime(now.year, now.month, 1);
      // Fin del mes actual (calculado)
      _endDate = DateTime(now.year, now.month + 1, 0);
    }
    // Inicializa los días enfocados para los calendarios
    _focusedDayStart = _startDate;
    _focusedDayEnd = _endDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveBudget() async {
    setState(() => _dateErrorMessage = null);

    // 1. Validamos el formulario (monto)
    if (!_formKey.currentState!.validate()) return;

    // 2. Validación local de fechas (Normalización)
    final normalizedStartDate = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
    );
    final normalizedEndDate = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
    );

    if (normalizedEndDate.isBefore(normalizedStartDate)) {
      setState(() {
        _dateErrorMessage =
            '⚠️ La fecha de fin no puede ser menor a la de inicio.';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. DECISIÓN: ¿Editar o Crear?
      if (_isEditing && widget.initialBudgetStatus != null) {
        // --- CASO EDITAR (PUT) ---
        // Usamos el ID que viene en el initialBudgetStatus
        await _budgetService.updateIncomePeriod(
          periodId: widget.initialBudgetStatus!.incomePeriodId,
          amount: double.parse(_amountController.text),
          startDate: _startDate,
          endDate: _endDate,
        );
      } else {
        // --- CASO CREAR (POST) ---
        await _budgetService.createIncomePeriod(
          amount: double.parse(_amountController.text),
          startDate: _startDate,
          endDate: _endDate,
        );
      }

      // Si todo sale bien, cerramos y avisamos al Dashboard para refrescar
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          // Limpiamos el mensaje que viene de tu FastAPI para mostrarlo en el modal
          _dateErrorMessage = e
              .toString()
              .replaceAll('Exception: ', '')
              .replaceAll('HttpException: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Título y texto del botón dinámicos
    final String title = _isEditing
        ? 'Editar presupuesto'
        : 'Establecer presupuesto';
    final String buttonText = _isEditing
        ? 'Guardar cambios'
        : 'Guardar presupuesto';

    return Container(
      // Padding que se ajusta si aparece el teclado
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          // Permite scroll si el contenido no cabe
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Hace que la columna tome el mínimo espacio
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Espacio superior
              const SizedBox(height: 16),
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: AppTextStyles.heading), // Título dinámico
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Campo Monto
              Text(
                'Monto del presupuesto *',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CustomInputField(
                controller: _amountController,
                labelText: '\$ 0.00',
                prefixIcon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Por favor ingresa un monto';
                  if (double.tryParse(value) == null)
                    return 'Ingresa un número válido';
                  if (double.parse(value) <= 0)
                    return 'El monto debe ser positivo';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Calendario Inicio
              Text(
                'Fecha de inicio',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildCalendar(
                focusedDay: _focusedDayStart,
                selectedDay: _startDate,
                hasError: _dateErrorMessage != null,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _startDate = selectedDay;
                    _focusedDayStart = focusedDay;
                    _dateErrorMessage = null;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Calendario Fin
              Text(
                'Fecha de fin',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildCalendar(
                focusedDay: _focusedDayEnd,
                selectedDay: _endDate,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _endDate = selectedDay;
                    _focusedDayEnd = focusedDay; // Actualiza el foco también
                  });
                },
              ),
              const SizedBox(height: 30),

              if (_dateErrorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _dateErrorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Botón Guardar
              PrimaryButton(
                text: _isLoading
                    ? 'Guardando...'
                    : buttonText, // Texto dinámico
                onPressed: _isLoading ? null : _handleSaveBudget,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para construir los calendarios
  Widget _buildCalendar({
    required DateTime focusedDay,
    required DateTime selectedDay,
    required Function(DateTime, DateTime) onDaySelected,
    bool hasError = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: hasError ? Colors.red.shade700 : Colors.grey.shade300,
          width: hasError ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TableCalendar(
        locale: 'es_ES', // Locale español
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        calendarFormat: CalendarFormat.month,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        // Actualizamos onPageChanged para el foco del calendario
        onPageChanged: (focused) {
          // No necesitamos setState aquí porque TableCalendar maneja su propio estado interno de foco
          // Si quisiéramos guardar el mes enfocado, lo haríamos aquí
          // _focusedDayStart = focused; o _focusedDayEnd = focused;
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
        availableGestures: AvailableGestures.horizontalSwipe,
      ),
    );
  }
}
