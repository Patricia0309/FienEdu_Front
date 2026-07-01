// lib/features/analysis/widgets/gastos_categoria_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../data/services/analytics_service.dart';
import '../models/category_spending_model.dart';
import '../../budgets/models/income_period_history_model.dart';

class GastosCategoriaCard extends StatefulWidget {
  final List<IncomePeriodHistory> history;

  const GastosCategoriaCard({super.key, required this.history});

  @override
  State<GastosCategoriaCard> createState() => _GastosCategoriaCardState();
}

class _GastosCategoriaCardState extends State<GastosCategoriaCard> {
  final AnalyticsService _analyticsService = AnalyticsService();
  final PageController _pageController = PageController();
  final Map<int, CategorySpendingResponse> _cachedReports = {};

  List<IncomePeriodHistory> _sortedHistory = []; // Nueva lista ordenada
  int _currentIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 1. Ordenamos el historial del más RECIENTE al más VIEJO
    _sortedHistory = List.from(widget.history);
    _sortedHistory.sort((a, b) => b.startDate.compareTo(a.startDate));

    // 2. Cargamos el Presente (Índice 0)
    _fetchReportForIndex(0);
  }

  Future<void> _fetchReportForIndex(int index) async {
    if (_cachedReports.containsKey(index)) return;

    setState(() => _isLoading = true);
    try {
      CategorySpendingResponse? report;
      if (index == 0) {
        report = await _analyticsService.getActiveCategorySpending();
      } else {
        // Ahora usamos nuestra lista ordenada: index 1 es el periodo pasado más cercano
        final int periodId = _sortedHistory[index - 1].incomePeriodId;
        report = await _analyticsService.getPastCategorySpending(periodId);
      }

      if (report != null) {
        setState(() => _cachedReports[index] = report!);
      }
    } catch (e) {
      print("❌ Error en reporte: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LÓGICA DE COLORES ---
  Color _getProgressBarColor(double percentage) {
    if (percentage >= 1.0) return Colors.red.shade700; // 100% o más: Crítico
    if (percentage >= 0.70) return Colors.orangeAccent; // 70%: Advertencia
    if (percentage >= 0.40) return Colors.amber; // 40%: Moderado
    return AppColors.element; // Menos de 40%: Tu verde/azul
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages = 1 + _sortedHistory.length;

    return Container(
      height: 380,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(totalPages),
          const SizedBox(height: 16),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalPages,
              onPageChanged: (newIndex) {
                setState(() => _currentIndex = newIndex);
                _fetchReportForIndex(newIndex);
              },
              itemBuilder: (context, index) {
                final report = _cachedReports[index];

                if (_isLoading && report == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (report == null || report.categories.isEmpty) {
                  return Center(
                    child: Text(
                      "Sin gastos en este periodo",
                      style: AppTextStyles.small,
                    ),
                  );
                }

                return ListView.builder(
                  physics:
                      const NeverScrollableScrollPhysics(), // <-- 1. Libera el scroll vertical para que la pantalla no se atore
                  shrinkWrap:
                      true, // <-- 2. Hace que use solo el espacio necesario
                  itemCount: report.categories.length,
                  itemBuilder: (context, catIndex) {
                    return _buildCategoryRow(report.categories[catIndex]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int totalPages) {
    String dateRange = "Periodo Actual";
    if (_currentIndex > 0) {
      final h = _sortedHistory[_currentIndex - 1];
      dateRange =
          "${DateFormat('dd/MM').format(h.startDate)} - ${DateFormat('dd/MM').format(h.endDate)}";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Gastos por categoría', style: AppTextStyles.heading),
            ),
            // Flecha Izquierda: Va al PASADO (Aumenta el índice)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: _currentIndex < totalPages - 1
                    ? AppColors.primary
                    : Colors.grey,
              ),
              onPressed: _currentIndex < totalPages - 1
                  ? () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            // Flecha Derecha: Viene al PRESENTE (Baja el índice)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: _currentIndex > 0 ? AppColors.primary : Colors.grey,
              ),
              onPressed: _currentIndex > 0
                  ? () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          dateRange,
          style: AppTextStyles.small.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(CategorySpendingItem cat) {
    final double normalizedPercentage = cat.percentage > 1.0
        ? cat.percentage / 100
        : cat.percentage;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(cat.categoryName, style: AppTextStyles.body),
              Text(
                '\$${cat.amount.toStringAsFixed(0)}',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20), // ¡Bordes bien redondos!
            child: LinearProgressIndicator(
              value: normalizedPercentage.clamp(
                0.0,
                1.0,
              ), // Evita que la barra truene si se pasan del 100%
              backgroundColor: Colors.grey.shade100,
              color: _getProgressBarColor(normalizedPercentage),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}
