import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const GymOSApp());
}

class GymOSApp extends StatelessWidget {
  const GymOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymOS Strength System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GymOSTheme.bgMain,
      ),
      home: const StrengthLevelScreen(),
    );
  }
}

// ==========================================
// TOKENS DE DISEÑO - GYMOS DESIGN SYSTEM
// ==========================================
abstract class GymOSTheme {
  static const Color bgMain = Color(0xFF08090C);
  static const Color surfaceBase = Color(0xFF151820);
  static const Color surfaceElevated = Color(0xFF1B1F28);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9B9FA8);

  // Paleta de Estado y Rendimiento Deportivo
  static const Color orangeElectric = Color(0xFFFF6B1A); // Acento/Nivel Actual
  static const Color violetElectric = Color(0xFF8B5CF6); // Métrica Secundaria
  static const Color textMuted = Color(0xFF4B5563);
}

// ==========================================
// PANTALLA PRINCIPAL: SISTEMA DE NIVELES
// ==========================================
class StrengthLevelScreen extends StatelessWidget {
  const StrengthLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final levels = ['BEGINNER', 'NOVICE', 'INTERMEDIATE', 'ADVANCED', 'ELITE'];
    const currentLevelIndex = 3; // ADVANCED

    return Scaffold(
      backgroundColor: GymOSTheme.bgMain,
      appBar: AppBar(
        backgroundColor: GymOSTheme.bgMain,
        elevation: 0,
        foregroundColor: GymOSTheme.textPrimary,
        iconTheme: const IconThemeData(color: GymOSTheme.textPrimary),
        title: const Text(
          'Nivel de Fuerza',
          style: TextStyle(
            color: GymOSTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // CARDA PRINCIPAL: PRESS BANCA & MÉTRICAS DE RELACIÓN
              _buildMainBenchmarkCard(),

              const SizedBox(height: 20),

              // INDICADOR DE PROGRESIÓN DE NIVEL
              _buildLevelProgression(levels, currentLevelIndex),

              const SizedBox(height: 24),

              // GRÁFICA DE DISTRIBUCIÓN Y PERCENTIL
              _buildDistributionCard(),

              const SizedBox(height: 20),

              // PRÓXIMO NIVEL / OBJETIVO
              _buildNextGoalCard(),

              const SizedBox(height: 28),

              // FUERZA POR GRUPO MUSCULAR
              const Text(
                'FUERZA POR GRUPO MUSCULAR',
                style: TextStyle(
                  color: GymOSTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _buildMuscleGroupBreakdown(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainBenchmarkCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GymOSTheme.orangeElectric.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PRESS BANCA',
                style: TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: GymOSTheme.orangeElectric.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ADVANCED',
                  style: TextStyle(
                    color: GymOSTheme.orangeElectric,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '82.5 kg',
            style: TextStyle(
              color: GymOSTheme.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _MetricItem(label: '1RM ESTIMADO', value: '92 kg'),
              _MetricItem(label: 'PESO CORPORAL', value: '91.3 kg'),
              _MetricItem(
                label: 'RELACIÓN',
                value: '1.01× BW',
                highlightColor: GymOSTheme.orangeElectric,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgression(List<String> levels, int activeIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: levels.asMap().entries.map((entry) {
            final idx = entry.key;
            final isReached = idx <= activeIndex;
            final isCurrent = idx == activeIndex;

            return Expanded(
              child: Column(
                children: [
                  Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isReached
                          ? GymOSTheme.orangeElectric
                          : GymOSTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.value,
                    style: TextStyle(
                      color: isCurrent
                          ? GymOSTheme.orangeElectric
                          : (isReached
                                ? GymOSTheme.textPrimary
                                : GymOSTheme.textMuted),
                      fontSize: 8,
                      fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDistributionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'PERCENTIL APROXIMADO',
                style: TextStyle(
                  color: GymOSTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'P',
                      style: TextStyle(
                        color: GymOSTheme.orangeElectric,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '82',
                      style: TextStyle(
                        color: GymOSTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: 90, child: _buildGaussianChart()),
          const SizedBox(height: 12),
          const Text(
            'Comparación basada en levantadores comparables.',
            style: TextStyle(
              color: GymOSTheme.textSecondary,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaussianChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 0.1),
              FlSpot(1, 0.4),
              FlSpot(2, 1.2),
              FlSpot(3, 2.8),
              FlSpot(4, 4.0), // Cúspide
              FlSpot(5, 2.8),
              FlSpot(6, 1.2),
              FlSpot(7, 0.4),
              FlSpot(8, 0.1),
            ],
            isCurved: true,
            color: GymOSTheme.textMuted,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: GymOSTheme.surfaceElevated.withValues(alpha: 0.5),
            ),
          ),
          // Indicador de posición actual (Percentil 82)
          LineChartBarData(
            spots: const [FlSpot(5.8, 0.0), FlSpot(5.8, 1.8)],
            isCurved: false,
            color: GymOSTheme.orangeElectric,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                if (index == 1) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: GymOSTheme.orangeElectric,
                    strokeWidth: 0,
                  );
                }
                return FlDotCirclePainter(radius: 0, color: Colors.transparent);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextGoalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceElevated.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'PRÓXIMO NIVEL: ELITE',
                style: TextStyle(
                  color: GymOSTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Objetivo: 105 kg',
                style: TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: GymOSTheme.violetElectric.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Faltan: 13 kg',
              style: TextStyle(
                color: GymOSTheme.violetElectric,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleGroupBreakdown() {
    final List<Map<String, String>> muscleData = [
      {'muscle': 'Pecho', 'level': 'Advanced'},
      {'muscle': 'Espalda', 'level': 'Intermediate'},
      {'muscle': 'Piernas', 'level': 'Advanced'},
      {'muscle': 'Hombros', 'level': 'Intermediate'},
      {'muscle': 'Bíceps', 'level': 'Novice'},
      {'muscle': 'Tríceps', 'level': 'Intermediate'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        children: muscleData.map((data) {
          final isAdvanced = data['level'] == 'Advanced';
          final isIntermediate = data['level'] == 'Intermediate';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['muscle']!,
                  style: const TextStyle(
                    color: GymOSTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  data['level']!,
                  style: TextStyle(
                    color: isAdvanced
                        ? GymOSTheme.orangeElectric
                        : (isIntermediate
                              ? GymOSTheme.violetElectric
                              : GymOSTheme.textSecondary),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? highlightColor;

  const _MetricItem({
    required this.label,
    required this.value,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: GymOSTheme.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: highlightColor ?? GymOSTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
