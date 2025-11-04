// lib/features/analysis/screens/analysis_screen.dart

import 'package:flutter/material.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
// Importa todos los servicios y modelos que usaremos
import '../../../data/services/analytics_service.dart';
import '../../../data/services/budget_service.dart';
import '../../../data/services/transaction_service.dart';
import '../../../data/services/user_service.dart';
import '../../inicial_setup/models/category_model.dart';
import '../../profile/models/student_model.dart';
import '../../transactions/models/transaction_model.dart';
import '../../budgets/models/income_period_model.dart';
import '../models/apriori_rule_model.dart';
import '../models/profile_response_model.dart';
import '../models/budget_tendency_model.dart';
// Importa el widget de la tarjeta que vamos a reutilizar
import '../../dashboard/widgets/perfil_financiero_card.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => AnalysisScreenState();
}

class AnalysisScreenState extends State<AnalysisScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  final UserService _userService = UserService();
  final TransactionService _transactionService = TransactionService();
  final BudgetService _budgetService = BudgetService();

  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadAnalysisData();
  }

  // Función para cargar todos los datos en paralelo
  Future<Map<String, dynamic>> _loadAnalysisData() async {
    // Usamos 'Future.wait' para ejecutar todas las llamadas al mismo tiempo
    // Usamos 'catchError' en las opcionales para que no fallen todas si una falla
    final results = await Future.wait([
      _analyticsService.getProfile().catchError(
        (e) => ProfileResponse(
          profile: "Error",
          justification: e.toString(),
          recommendation: "",
        ),
      ), // 0
      _analyticsService.getRules().catchError((e) => <AprioriRule>[]), // 1
      _analyticsService.getTendency().catchError(
        (e) => BudgetTendency(percentageChange: 0.0),
      ), // 2
      _userService.getMe(), // 3
      _transactionService.getTransactions(), // 4
      _budgetService.getBudgetHistory().catchError(
        (e) => <IncomePeriod>[],
      ), // 5
    ]);
    return {
      'profile': results[0],
      'rules': results[1],
      'tendency': results[2],
      'student': results[3],
      'transactions': results[4],
      'budgetHistory': results[5],
    };
  }

  // Función de refresco (para el botón de pull-to-refresh)
  Future<void> _refresh() async {
    setState(() {
      _dataFuture = _loadAnalysisData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(context, onRefresh: _refresh),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _dataFuture,
              builder: (context, snapshot) {
                // --- ESTADO DE CARGA ---
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // --- ESTADO DE ERROR (Si una llamada obligatoria falló) ---
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error al cargar análisis: ${snapshot.error}'),
                  );
                }
                // --- ESTADO DE ÉXITO ---
                if (snapshot.hasData) {
                  // Obtenemos todos los datos
                  final profile = snapshot.data!['profile'] as ProfileResponse;
                  final rules = snapshot.data!['rules'] as List<AprioriRule>;
                  final tendency = snapshot.data!['tendency'] as BudgetTendency;
                  final student = snapshot.data!['student'] as Student;
                  final transactions =
                      snapshot.data!['transactions'] as List<Transaction>;
                  final budgetHistory =
                      snapshot.data!['budgetHistory'] as List<IncomePeriod>;

                  // Procesamos los datos para la Tarjeta 3 (Gastos por Cat. Favorita)
                  final totalGastos = transactions
                      .where((t) => t.type == TransactionType.gasto)
                      .fold(0.0, (sum, t) => sum + t.amount);
                  final Set<int> favoriteCategoryIds = student
                      .favoriteCategories
                      .map((c) => c.id)
                      .toSet();
                  final totalGastosFavoritos = transactions
                      .where(
                        (t) =>
                            t.type == TransactionType.gasto &&
                            favoriteCategoryIds.contains(t.categoryId),
                      )
                      .fold(0.0, (sum, t) => sum + t.amount);
                  final double porcentajeFavorito = totalGastos > 0
                      ? (totalGastosFavoritos / totalGastos) * 100
                      : 0.0;

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Tarjeta 1: Perfil Financiero
                          PerfilFinancieroCard(
                            profileName: profile.profile,
                            description:
                                profile.justification, // Usamos 'justification'
                          ),
                          const SizedBox(height: 16),

                          // Tarjeta 2: Historial de Presupuesto
                          _buildBudgetHistoryCard(budgetHistory),
                          const SizedBox(height: 16),

                          // Tarjeta 3: Gastos por Categoría Favorita
                          _buildFavCategoryCard(
                            totalGastosFavoritos,
                            porcentajeFavorito,
                          ),
                          const SizedBox(height: 16),

                          // Tarjeta 4: Tendencia de Gasto
                          _buildTendencyCard(tendency),
                          const SizedBox(height: 16),

                          // Tarjeta 5: Reglas Identificadas
                          _buildRulesCard(rules),
                        ],
                      ),
                    ),
                  );
                }
                return const Center(child: Text('No hay datos.'));
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS HELPER PARA CONSTRUIR LA PANTALLA ---

  Widget _buildHeader(BuildContext context, {required VoidCallback onRefresh}) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Análisis Financiero',
            style: AppTextStyles.title.copyWith(color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: onRefresh,
          ),
        ],
      ),
    );
  }

  // Tarjeta 2: Historial Presupuesto
  Widget _buildBudgetHistoryCard(List<IncomePeriod> history) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Historial de Presupuestos', style: AppTextStyles.heading),
          const SizedBox(height: 16),
          if (history.isEmpty)
            Text(
              'Aún no tienes historial de presupuestos.',
              style: AppTextStyles.body,
            )
          else
            // Placeholder para la gráfica
            Container(
              height: 150,
              child: Center(
                child: Text(
                  'Aquí va la gráfica con ${history.length} períodos.',
                  style: AppTextStyles.body,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Tarjeta 3: Gastos en Cat. Favoritas
  Widget _buildFavCategoryCard(double totalGastos, double porcentaje) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gastos en Favoritas', style: AppTextStyles.heading),
          const SizedBox(height: 16),
          Text(
            '\$${totalGastos.toStringAsFixed(0)}',
            style: AppTextStyles.subtitle.copyWith(color: AppColors.primary),
          ),
          Text(
            '${porcentaje.toStringAsFixed(0)}% de tus gastos totales',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }

  // Tarjeta 4: Tendencia
  Widget _buildTendencyCard(BudgetTendency tendency) {
    final bool isUp = tendency.percentageChange >= 0;
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isUp ? Icons.trending_up : Icons.trending_down,
            color: isUp ? Colors.red : Colors.green,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tendencia', style: AppTextStyles.heading),
                Text(
                  '${isUp ? '↑' : '↓'} ${tendency.percentageChange.abs().toStringAsFixed(0)}%',
                  style: AppTextStyles.subtitle.copyWith(
                    color: isUp ? Colors.red : Colors.green,
                  ),
                ),
                Text(
                  'Tus gastos ${isUp ? 'aumentaron' : 'disminuyeron'} ${tendency.percentageChange.abs().toStringAsFixed(0)}% respecto al período anterior',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta 5: Reglas
  Widget _buildRulesCard(List<AprioriRule> rules) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rule, size: 24),
              const SizedBox(width: 12),
              Text('Reglas identificadas', style: AppTextStyles.heading),
            ],
          ),
          const SizedBox(height: 16),
          if (rules.isEmpty)
            Text(
              'Aún no hay suficientes datos para identificar reglas.',
              style: AppTextStyles.body,
            )
          else
            ...rules
                .map(
                  (rule) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildRuleRow(
                      'Si gastas en ${rule.antecedent}, tiendes a gastar en ${rule.consequent}',
                    ),
                  ),
                )
                .toList(),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(fontSize: 16, color: AppColors.secondary),
        ),
        Expanded(child: Text(text, style: AppTextStyles.body)),
      ],
    );
  }
}
