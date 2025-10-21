// lib/features/dashboard/widgets/set_budget_modal.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../common/widgets/custom_input_field.dart';
import '../../../common/widgets/primary_button.dart';

class SetBudgetModal extends StatefulWidget {
  const SetBudgetModal({super.key});

  @override
  State<SetBudgetModal> createState() => _SetBudgetModalState();
}

class _SetBudgetModalState extends State<SetBudgetModal> {
  final _amountController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  DateTime _focusedDayStart = DateTime.now();
  DateTime _focusedDayEnd = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Make modal height dynamic based on content
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView( // Make content scrollable if needed
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Establecer presupuesto', style: AppTextStyles.heading),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Amount field
            Text('Monto del presupuesto', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomInputField(
              controller: _amountController,
              labelText: '\$ 0.00',
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Start Date Calendar
            Text('Fecha de inicio', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildCalendar(
              focusedDay: _focusedDayStart,
              selectedDay: _startDate,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _startDate = selectedDay;
                  _focusedDayStart = focusedDay;
                });
              },
            ),
            const SizedBox(height: 20),

            // End Date Calendar
            Text('Fecha de fin', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildCalendar(
              focusedDay: _focusedDayEnd,
              selectedDay: _endDate,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _endDate = selectedDay;
                  _focusedDayEnd = focusedDay;
                });
              },
            ),
            const SizedBox(height: 30),

            // Save Button
            PrimaryButton(
              text: 'Guardar Presupuesto',
              onPressed: () {
                // TODO: Add logic to save the budget
                print('Monto: ${_amountController.text}, Inicio: $_startDate, Fin: $_endDate');
                Navigator.pop(context); // Close the modal
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build the calendar styling
  Widget _buildCalendar({
    required DateTime focusedDay,
    required DateTime selectedDay,
    required Function(DateTime, DateTime) onDaySelected,
  }) {
    return Container(
       decoration: BoxDecoration(
         border: Border.all(color: Colors.grey.shade300),
         borderRadius: BorderRadius.circular(12),
       ),
       child: TableCalendar(
          locale: 'es_ES', // Optional: for Spanish locale
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDay,
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          onDaySelected: onDaySelected,
          headerStyle: HeaderStyle(
            formatButtonVisible: false, // Hide format button (like "Month")
            titleCentered: true,
            titleTextStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
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
          availableGestures: AvailableGestures.horizontalSwipe, // Allows swiping months
       ),
    );
  }
}