// lib/features/analysis/screens/analysis_screen.dart
import 'package:flutter/material.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/services/analytics_service.dart';
import '../../../data/services/budget_service.dart';
import '../../../data/services/transaction_service.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/category_service.dart'; // <-- Asegúrate de tener este import
import '../../inicial_setup/models/category_model.dart';
import '../../profile/models/student_model.dart';
import '../../transactions/models/transaction_model.dart';
import '../../budgets/models/income_period_model.dart';
import '../../budgets/models/income_period_history_model.dart';
import '../models/apriori_rule_model.dart';
import '../models/profile_response_model.dart';
import '../models/budget_tendency_model.dart';
// Importa los widgets de las tarjetas
import '../../dashboard/widgets/perfil_financiero_card.dart';
import '../widgets/budget_history_row.dart';
import '../widgets/tendencia_card.dart';
import '../widgets/rules_card.dart';
import '../widgets/gastos_categoria_card.dart';
//provider
import '../providers/tendency_provider.dart';

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
  final CategoryService _categoryService =
      CategoryService(); // <-- Asegúrate de tener esta línea

  late Future<Map<String, dynamic>> _dataFuture;
  List<IncomePeriodHistory> _historyData = [];

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadAnalysisData();
  }

  // --- FUNCIÓN DE CARGA CORREGIDA ---
  Future<Map<String, dynamic>> _loadAnalysisData() async {
    final results = await Future.wait([
      _analyticsService.getProfile().catchError(
        (e) => ProfileResponse(
          profile: "Error",
          justification: e.toString(),
          recommendation: "",
          isCalculating: false,
          currentCount: 0,
          goal: 15,
        ),
      ), // 0
      _analyticsService.getRules().catchError((e) {
        // --- DEBUG: Imprimimos el error ---
        print('ERROR AL CARGAR REGLAS: $e');
        // --- FIN DEBUG ---

        return <AprioriRule>[]; // Devolvemos la lista vacía como antes
      }),
      _analyticsService.getTendency().catchError((e) {
        // ¡ARREGLADO!
        // Le damos valores por defecto a TODOS los campos requeridos
        return BudgetTendency(
          percentageChange: 0.0,
          direction: 'neutral', // <-- El campo que faltaba
          message:
              'Error al cargar tendencia', // <-- Probablemente también es 'required'

          currentPeriodSpending: 0.0,
          previousPeriodSpending: 0.0,
        );
      }), // 2
      _userService.getMe(), // 3
      _transactionService.getTransactions(), // 4
      _budgetService.getBudgetHistory().catchError(
        (e) => <IncomePeriodHistory>[],
      ), // 5
      _categoryService.getCategories().catchError(
        (e) => <Category>[],
      ), // <-- 6. Carga todas las categorías
    ]);

    _historyData = results[5] as List<IncomePeriodHistory>;

    // Creamos el mapa de categorías aquí
    final categories = results[6] as List<Category>;
    final categoryMap = {
      for (var cat in categories) cat.id: cat,
    }; // <-- Se crea el mapa

    return {
      'profile': results[0],
      'rules': results[1],
      'tendency': results[2],
      'student': results[3],
      'transactions': results[4],
      'budgetHistory': _historyData,
      'categoryMap': categoryMap, // <-- 7. ¡AHORA SÍ SE DEVUELVE EL MAPA!
    };
  }

  // Función de refresco
  Future<void> refreshData() async {
    if (mounted) {
      setState(() {
        _dataFuture = _loadAnalysisData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(context, onRefresh: refreshData),
          Expanded(
            child: RefreshIndicator(
              onRefresh: refreshData,
              color: AppColors.element,
              child: FutureBuilder<Map<String, dynamic>>(
                future: _dataFuture,
                builder: (context, snapshot) {
                  // --- ESTADO DE CARGA ---
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 400, // Un espacio para que se vea el spinner
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  // --- ESTADO DE ERROR ---
                  if (snapshot.hasError) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: 500,
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'Ocurrió un error: ${snapshot.error}\n\nJala hacia abajo para reintentar.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }
                  // --- ESTADO DE ÉXITO ---
                  if (snapshot.hasData) {
                    // Obtenemos todos los datos
                    final profile =
                        snapshot.data!['profile'] as ProfileResponse;
                    final rules = snapshot.data!['rules'] as List<AprioriRule>;
                    final tendency =
                        snapshot.data!['tendency'] as BudgetTendency;
                    final student = snapshot.data!['student'] as Student;
                    final transactions =
                        snapshot.data!['transactions'] as List<Transaction>;
                    final budgetHistory =
                        snapshot.data!['budgetHistory']
                            as List<IncomePeriodHistory>;

                    // --- CORRECCIÓN DEL ERROR ---
                    // Obtenemos el mapa de forma segura
                    final categoryMap =
                        snapshot.data!['categoryMap'] as Map<int, Category>?;

                    // Si el mapa es nulo, es un error fatal (no debería pasar ahora)
                    if (categoryMap == null) {
                      return const Center(
                        child: Text(
                          'Error: No se pudo cargar el mapa de categorías.',
                        ),
                      );
                    }
                    // --- FIN CORRECCIÓN ---

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

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Tarjeta 1: Perfil Financiero
                          PerfilFinancieroCard(
                            profileData:
                                profile, // Ahora pasamos todo el objeto para que la tarjeta decida qué mostrar
                          ),
                          const SizedBox(height: 16),

                          // Tarjeta 3: Gastos por Categoría (Cambié el nombre de la función)
                          GastosCategoriaCard(history: _historyData),
                          const SizedBox(height: 16),

                          // Tarjeta 4: Tendencia de Gasto
                          _buildTendencyCard(tendency),
                          const SizedBox(height: 16),

                          // Tarjeta 5: Reglas Identificadas
                          _buildRulesCard(rules),
                        ],
                      ),
                    );
                  }
                  return const SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Center(child: Text('No hay datos.')),
                  );
                },
              ),
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
        top:
            MediaQuery.of(context).padding.top +
            16, // Espacio para la barra de estado
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent2.withOpacity(
          0.8,
        ), // 1. El color de tu nuevo estilo
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      // 2. Eliminamos la Column y el Dropdown
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 3. Usamos el título de "Análisis" con el estilo de color nuevo
          Text(
            'Análisis\nfinanciero',
            style: AppTextStyles.title.copyWith(color: AppColors.primary),
          ),
          SvgPicture.asset(
            'assets/img/svg/Logo.1.svg', // Asegúrate que la ruta sea correcta
            height: 60,
            colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }

  // Tarjeta 4: Tendencia
  Widget _buildTendencyCard(BudgetTendency tendency) {
    return TendenciaCard(tendencyData: tendency);
  }

  // Tarjeta 5: Reglas
  Widget _buildRulesCard(List<AprioriRule> rules) {
    return RulesCard(rules: rules);
  }

  // Helper para la Tarjeta 5
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
