// lib/features/learn/screens/learn_screen.dart
import 'package:flutter/material.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Importa los servicios y modelos necesarios
import '../../../data/services/analytics_service.dart';
import '../../../data/services/content_service.dart';
import '../../analysis/models/recommendation_model.dart';
import '../models/microcontent_model.dart';

// Importa los widgets que creamos
import '../widgets/tag_accordion_card.dart';
import '../../recommendations/screens/recommendations_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  final ContentService _contentService = ContentService();

  late Future<Map<String, dynamic>> _dataFuture;

  // --- Mapas para los estilos (¡importante!) ---
  final Map<String, IconData> _tagIcons = {
    'ahorro': Icons.account_balance_outlined,
    'presupuesto': Icons.receipt_long_outlined,
    'inversion': Icons.trending_up_outlined,
    'deuda': Icons.credit_card_off_outlined,
    'gastos_hormiga': Icons.coffee_outlined,
    'general': Icons.info_outline,
  };

  final Map<String, String> _tagTitles = {
    'ahorro': 'Ahorro',
    'presupuesto': 'Presupuesto',
    'inversion': 'Inversión',
    'deuda': 'Deuda',
    'gastos_hormiga': 'Gastos Hormiga',
    'general': 'General',
  };

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    final results = await Future.wait([
      _analyticsService.getRecommendations().catchError((e) {
        print('ERROR AL CARGAR RECOMENDACIONES: $e');
        return <Recommendation>[];
      }),
      _contentService.getAllMicrocontent().catchError((e) {
        print('ERROR AL CARGAR MICROCONTENIDO: $e');
        return <Microcontent>[];
      }),
    ]);

    // --- ¡ESTA ES LA LÍNEA QUE FALTABA! ---
    // Debes devolver el mapa que el FutureBuilder espera
    return {
      'recommendations': results[0] as List<Recommendation>,
      'content': results[1] as List<Microcontent>,
    };
  }

  Future<void> _refresh() async {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  Map<String, List<Microcontent>> _groupContent(
    List<Microcontent> contentList,
  ) {
    final Map<String, List<Microcontent>> grouped = {};
    for (final content in contentList) {
      (grouped[content.tag] ??= []).add(content);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6), // Color crema de fondo
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No hay datos.'));
          }

          final recommendations =
              snapshot.data!['recommendations'] as List<Recommendation>;
          final allContent = snapshot.data!['content'] as List<Microcontent>;
          final groupedContent = _groupContent(allContent);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                _buildHeader(),
                _buildLearnSubtitle(),
                _buildRecommendationsCard(recommendations.length),
                _buildLearnSectionTitle(),

                // --- ¡MIRA QUÉ LIMPIO! ---
                // Ahora solo llamamos a nuestro nuevo widget
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final tagKey = groupedContent.keys.elementAt(index);
                    final contentForTag = groupedContent[tagKey]!;

                    return TagAccordionCard(
                      title: _tagTitles[tagKey] ?? 'General',
                      icon: _tagIcons[tagKey] ?? Icons.info_outline,
                      contentList: contentForTag,
                    );
                  }, childCount: groupedContent.length),
                ),

                // --- FIN DE LA PARTE LIMPIA ---
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Widgets de Construcción (Encabezado y Tarjeta de Recomendación) ---
  // (Estos se quedan aquí porque son únicos de esta pantalla)

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        // 1. Padding copiado del estilo de "Análisis"
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        // 2. Decoración copiada del estilo de "Análisis"
        decoration: BoxDecoration(
          color: AppColors.accent2.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        // 3. Layout de Row copiado del estilo de "Análisis"
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment:
              CrossAxisAlignment.center, // Para centrar verticalmente
          children: [
            // 4. Contenido de la izquierda (de "Aprende" pero con el estilo de "Análisis")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      color: AppColors.primary, // Color de "Análisis"
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Aprende',
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.primary,
                      ), // Color de "Análisis"
                    ),
                  ],
                ),
              ],
            ),

            // 5. Contenido de la derecha (el logo, copiado de "Análisis")
            SvgPicture.asset(
              'assets/img/svg/Logo.1.svg', // Asegúrate que la ruta sea correcta
              height: 40, // La altura de tu ejemplo de "Análisis"
              colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnSubtitle() {
    return SliverToBoxAdapter(
      child: Padding(
        // Padding para separarlo del header
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),

        // 1. Envuelto en un Row
        child: Row(
          children: [
            // 2. El ícono que pediste (puedes cambiarlo)
            Icon(
              Icons.description_outlined,
              size: 20,
              color: Colors.grey.shade700,
            ),
            const SizedBox(width: 8), // 3. Espacio
            // 4. Tu texto original
            Text(
              'Microcontenidos de\neducación financiera',
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

  Widget _buildRecommendationsCard(int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecommendationsScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_outline,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recomendaciones',
                          style: AppTextStyles.heading.copyWith(fontSize: 18),
                        ),
                        Text(
                          '$count nuevas',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (count > 0)
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.red,
                      child: Text(
                        count.toString(),
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLearnSectionTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Text('¿Qué quieres aprender?', style: AppTextStyles.title),
      ),
    );
  }
}
