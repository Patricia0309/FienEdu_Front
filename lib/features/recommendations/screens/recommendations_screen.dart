// lib/features/recommendations/screens/recommendations_screen.dart
import 'package:flutter/material.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../data/services/analytics_service.dart';
import '../../analysis/models/recommendation_model.dart'; // Importa el modelo
import 'package:flutter_svg/flutter_svg.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  // Define una ruta estática para la navegación
  static const String routeName = '/recommendations';

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  late Future<List<Recommendation>> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    _recommendationsFuture = _analyticsService.getRecommendations();
  }

  // --- Función para refrescar los datos ---
  Future<void> _refresh() async {
    setState(() {
      _recommendationsFuture = _analyticsService.getRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Asigna el color de fondo beige/crema de tu imagen
      // (Ajusta este color si tienes uno definido en AppColors)
      backgroundColor: const Color(0xFFFBF9F6),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            // 2. Este es el nuevo encabezado verde
            SliverToBoxAdapter(child: _buildHeader()),
            _buildSubtitle(),

            // 3. Este FutureBuilder ahora construye "Slivers"
            FutureBuilder<List<Recommendation>>(
              future: _recommendationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 64.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text('No hay recomendaciones por ahora.'),
                    ),
                  );
                }

                final recommendations = snapshot.data!;

                // 4. Construye la lista de tarjetas
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _buildRecommendationCard(recommendations[index]);
                  }, childCount: recommendations.length),
                );
              },
            ),
            // Espacio al final de la lista
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            'Recomendaciones',
            style: AppTextStyles.subtitle.copyWith(color: AppColors.primary),
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

  Widget _buildSubtitle() {
    return SliverToBoxAdapter(
      child: Padding(
        // Añadimos padding para separarlo del header y de las tarjetas
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 20,
              color: Colors.grey.shade700, // Un color más sutil
            ),
            const SizedBox(width: 8),
            Text(
              'Consejos personalizados para ti',
              style: AppTextStyles.body.copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget helper para la tarjeta de recomendación ---
  Widget _buildRecommendationCard(Recommendation recommendation) {
    IconData icon;

    // Asigna un ícono basado en el 'type' que viene de tu API
    // (Estoy adivinando los 'type' basado en la imagen)
    switch (recommendation.type) {
      case 'ahorro': // Para "Aumenta tu ahorro"
        icon = Icons.savings_outlined;
        break;
      case 'gastos': // Para "Reduce gastos"
        icon = Icons.trending_down;
        break;
      case 'metas': // Para "Establece metas"
        icon = Icons.track_changes_outlined;
        break;
      default: // 'general' o cualquier otro
        icon = Icons.info_outline;
    }

    return Card(
      // Márgenes para separar las tarjetas
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      color: Colors.white, // Fondo blanco para la tarjeta
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contenedor del ícono
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100, // Fondo gris claro
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.grey.shade700, size: 28),
                ),
                // Etiqueta "Nuevo"
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Nuevo',
                    style: AppTextStyles.small.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Título
            Text(
              recommendation.title,
              style: AppTextStyles.heading.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            // Cuerpo
            Text(
              recommendation.body,
              style: AppTextStyles.body.copyWith(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
