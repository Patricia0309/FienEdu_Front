import 'package:FinEdu/common/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../data/services/budget_service.dart';
import '../../budgets/models/income_period_history_model.dart';
import '../widgets/budget_history_row.dart'; // El que vamos a crear ahorita

class BudgetHistoryScreen extends StatefulWidget {
  const BudgetHistoryScreen({super.key});

  @override
  State<BudgetHistoryScreen> createState() => _BudgetHistoryScreenState();
}

class _BudgetHistoryScreenState extends State<BudgetHistoryScreen> {
  final BudgetService _budgetService = BudgetService();
  List<IncomePeriodHistory> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final data = await _budgetService.getBudgetHistory();
      setState(() {
        _history = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Aquí podrías mostrar un snackbar de error
    }
  }

  void _confirmDelete(int periodId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("¿Eliminar presupuesto?"),
          content: const Text(
            "Esta acción no se puede deshacer. Se eliminarán permanentemente el periodo y todas las transacciones que registraste en él.",
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context); // Cierra el diálogo
                await _executeDelete(periodId); // Llama a la ejecución
              },
              child: const Text(
                "Sí, eliminar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _executeDelete(int id) async {
    try {
      await _budgetService.deleteIncomePeriod(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Presupuesto eliminado correctamente")),
        );
        _loadHistory(); // Refrescamos la lista
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7EE), // Tu beige de FinEdu
      appBar: AppBar(
        title: const Text('Historial'),
        titleTextStyle: AppTextStyles.subtitle.copyWith(color: Colors.white),
        backgroundColor: AppColors.element,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _history.isEmpty
            ? const Center(child: Text("No hay presupuestos registrados aún."))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return BudgetHistoryRow(
                    budget: item,
                    onDelete: () {
                      _confirmDelete(item.incomePeriodId);
                    },
                  );
                },
              ),
      ),
    );
  }
}
