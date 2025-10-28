// lib/features/dashboard/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../data/services/transaction_service.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/budget_service.dart'; // Import BudgetService
import '../../../features/profile/models/student_model.dart';
import '../../../features/transactions/models/transaction_model.dart';
import '../../../features/budgets/models/budget_status_model.dart'; // Import BudgetStatus
import '../widgets/dashboard_actions_grid.dart';
import '../widgets/perfil_financiero_card.dart';
import '../widgets/total_mes_card.dart';
import '../widgets/budget_card.dart';
import '../widgets/set_budget_modal.dart';

class DashboardScreen extends StatefulWidget {
  // Add the key parameter needed for GlobalKey
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  // Make the State class public
  DashboardScreenState createState() => DashboardScreenState();
}

// Make the State class public
class DashboardScreenState extends State<DashboardScreen> {
  final TransactionService _transactionService = TransactionService();
  final UserService _userService = UserService();
  final BudgetService _budgetService = BudgetService();

  // --- 1. State Variables ---
  Student? _studentData;
  List<Transaction>? _transactionsData;
  BudgetStatus? _budgetStatusData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData(); // Load data initially
  }

  // --- 2. Combined Fetch Function ---
  Future<void> _fetchDashboardData() async {
    // Only show full loading spinner if there's no data yet
    if (_studentData == null) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      // If refreshing, maybe show a smaller indicator or just update
      // For simplicity, we'll just reload without a full screen spinner
      setState(() {
        _error = null;
      }); // Reset error on refresh attempt
    }

    try {
      final results = await Future.wait([
        _userService.getMe(),
        _transactionService.getTransactions(),
        // Budget status fetch is separate as it might return 404 (null)
      ]);

      BudgetStatus? budgetStatus;
      try {
        budgetStatus = await _budgetService.getBudgetStatus();
      } catch (e) {
        print("No budget status found or error: $e");
        budgetStatus = null;
      }

      if (mounted) {
        setState(() {
          _studentData = results[0] as Student;
          _transactionsData = results[1] as List<Transaction>;
          _budgetStatusData = budgetStatus; // Store budget status (can be null)
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  // --- 3. Public Refresh Method ---
  void refreshData() {
    print("DashboardScreen: Refreshing data via refreshData()...");
    _fetchDashboardData(); // Call the fetch function again
  }

  // Function to show budget modal (needs budgetStatus)
  void _showSetBudgetModal(BudgetStatus? currentStatus) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SetBudgetModal(initialBudgetStatus: currentStatus),
    );
    // If saved, refresh the dashboard data
    if (saved == true) {
      refreshData();
    }
  }

  // Process Transaction Data function (remains the same)
  Map<String, dynamic> _processTransactionData(List<Transaction> transactions) {
    double totalIngresos = 0;
    double totalGastos = 0;
    Map<int, double> dailyExpenses = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    for (var t in transactions) {
      if (t.type == TransactionType.ingreso) {
        totalIngresos += t.amount;
      } else {
        totalGastos += t.amount;
        // Consider only recent expenses for the simple bar chart
        if (t.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))) {
          dailyExpenses[t.date.weekday - 1] =
              (dailyExpenses[t.date.weekday - 1] ?? 0) + t.amount;
        }
      }
    }

    final List<BarChartGroupData> chartData = [];
    dailyExpenses.forEach((day, total) {
      // Create BarChartGroupData only if total > 0 to avoid empty bars
      if (total > 0) {
        chartData.add(
          BarChartGroupData(
            x: day,
            barRods: [
              BarChartRodData(
                toY: total,
                color: AppColors.primary,
                width: 15,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }
    });

    // Ensure chartData has entries for all days if needed, or handle empty state in chart widget
    // For now, it will only contain days with expenses.

    return {
      'totalIngresos': totalIngresos,
      'totalGastos': totalGastos,
      'chartData': chartData, // This is potentially sparse
    };
  }

  @override
  Widget build(BuildContext context) {
    // --- 4. Build UI based on State ---
    return Scaffold(
      // AppBar needs data, so we build it inside _buildContent
      // backgroundColor: AppColors.backgroundInApp, // Set in MainScreen
      body: _buildContent(),
    );
  }

  // Helper to build the main content based on state
  Widget _buildContent() {
    if (_isLoading && _studentData == null) {
      // Show loading only on initial load
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error al cargar el dashboard: $_error'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: refreshData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (_studentData != null && _transactionsData != null) {
      final student = _studentData!;
      final transactions = _transactionsData!;
      // Process data *here* now that we know we have it
      final processedData = _processTransactionData(transactions);

      return Scaffold(
        // Return a full Scaffold here
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: AppColors.element, // Use correct color
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          title: Padding(
            // Added padding
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hola,',
                  style: AppTextStyles.body.copyWith(color: Colors.white70),
                ),
                Text(
                  '${student.displayName ?? 'Usuario'} 👋',
                  style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              // Added logo
              padding: const EdgeInsets.only(right: 24.0),
              child: SvgPicture.asset(
                'assets/img/svg/Logo.1.svg', // Ensure path is correct
                height: 40,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
          titleSpacing: 0,
        ),
        body: SingleChildScrollView(
          child: Container(
            color: AppColors.background, // Use correct background
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TotalMesCard(
                  budgetStatus: _budgetStatusData, // Pass the fetched status
                ),
                const SizedBox(height: 16),
                BudgetCard(
                  budgetStatus: _budgetStatusData, // Pass the fetched status
                  onSetBudgetTap: () => _showSetBudgetModal(_budgetStatusData),
                ),
                const SizedBox(height: 16),
                const PerfilFinancieroCard(),
                const SizedBox(height: 16),
                const DashboardActionsGrid(),
              ],
            ),
          ),
        ),
      );
    }
    // Fallback if data is null after loading (shouldn't happen with correct logic)
    return const Center(child: Text('No se pudieron cargar los datos.'));
  }
}
