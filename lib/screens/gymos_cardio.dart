import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/routine_store.dart';

void main() {
  runApp(const GymOSApp());
}

class GymOSApp extends StatelessWidget {
  const GymOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymOS Cardio System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GymOSTheme.bgMain,
      ),
      home: const CardioScreen(),
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

  // Acentos de Rendimiento Deportivo
  static const Color orangeElectric = Color(0xFFFF6B1A);
  static const Color violetElectric = Color(0xFF8B5CF6);
  static const Color textMuted = Color(0xFF374151);
}

// ==========================================
// PANTALLA PRINCIPAL: CARDIO
// ==========================================
class CardioScreen extends StatefulWidget {
  const CardioScreen({super.key});

  @override
  State<CardioScreen> createState() => _CardioScreenState();
}

class _CardioScreenState extends State<CardioScreen> {
  String _selectedChartMetric = 'Distancia';

  final List<Map<String, dynamic>> _cardioTypes = [
    {'name': 'Caminadora', 'icon': Icons.directions_walk_rounded},
    {'name': 'Correr', 'icon': Icons.directions_run_rounded},
    {'name': 'Bicicleta', 'icon': Icons.directions_bike_rounded},
    {'name': 'Elíptica', 'icon': Icons.fitness_center_rounded},
    {'name': 'Escaladora', 'icon': Icons.stairs_rounded},
    {'name': 'HIIT', 'icon': Icons.bolt_rounded},
    {'name': 'Otro', 'icon': Icons.more_horiz_rounded},
  ];

  final List<Map<String, String>> _sessionHistory = [
    {
      'type': 'CAMINADORA',
      'date': 'HOY, 18 SEP',
      'duration': '35:42',
      'distance': '6.2 km',
      'calories': '320 kcal',
    },
    {
      'type': 'CORRER',
      'date': '16 SEP 2026',
      'duration': '28:15',
      'distance': '5.0 km',
      'calories': '310 kcal',
    },
    {
      'type': 'BICICLETA',
      'date': '14 SEP 2026',
      'duration': '45:00',
      'distance': '18.4 km',
      'calories': '420 kcal',
    },
    {
      'type': 'HIIT',
      'date': '12 SEP 2026',
      'duration': '20:00',
      'distance': 'N/A',
      'calories': '250 kcal',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymOSTheme.bgMain,
      appBar: AppBar(
        backgroundColor: GymOSTheme.bgMain,
        elevation: 0,
        title: const Text(
          'CARDIO',
          style: TextStyle(
            color: GymOSTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        leading: Navigator.canPop(context)
            ? const BackButton(color: GymOSTheme.textPrimary)
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            24 + MediaQuery.of(context).viewPadding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // BOTÓN DE NUEVA SESIÓN Y TIPOS DE CARDIO
              Text(
                'NUEVA SESIÓN',
                style: TextStyle(
                  color: GymOSTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _buildCardioTypeSelector(),

              const SizedBox(height: 24),

              // ÚLTIMA SESIÓN REGISTRADA
              const Text(
                'ÚLTIMA SESIÓN REGISTRADA',
                style: TextStyle(
                  color: GymOSTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _buildLatestSessionCard(),

              const SizedBox(height: 28),

              // ANÁLISIS DE RENDIMIENTO Y GRÁFICAS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MÉTRICAS Y EVOLUCIÓN',
                    style: TextStyle(
                      color: GymOSTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  _buildMetricSelector(),
                ],
              ),
              const SizedBox(height: 12),
              _buildAnalyticsChartCard(),

              const SizedBox(height: 28),

              // HISTORIAL DE SESIONES
              const Text(
                'HISTORIAL DE SESIONES',
                style: TextStyle(
                  color: GymOSTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _buildSessionHistoryList(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardioTypeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _cardioTypes.map((item) {
          return Container(
            margin: const EdgeInsets.only(right: 10),
            child: Material(
              color: GymOSTheme.surfaceBase,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () {
                  _showLogSessionDialog(item['name'] as String);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item['icon'],
                        size: 18,
                        color: GymOSTheme.orangeElectric,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item['name'],
                        style: const TextStyle(
                          color: GymOSTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showLogSessionDialog(String type) {
    final duration = TextEditingController(text: '30');
    final distance = TextEditingController(text: '5');
    final calories = TextEditingController(text: '250');
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GymOSTheme.surfaceElevated,
        title: Text(
          'Registrar $type',
          style: const TextStyle(color: GymOSTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _numberField(duration, 'Minutos'),
            _numberField(distance, 'Distancia (km)'),
            _numberField(calories, 'Calorías'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () {
              final now = DateTime.now();
              RoutineStore.instance.addWorkoutHistory({
                'type': type.toUpperCase(),
                'date': now,
                'duration': '${duration.text}:00',
                'distance': '${distance.text} km',
                'calories': '${calories.text} kcal',
                'kind': 'cardio',
              });
              Navigator.pop(dialogContext);
              setState(() {});
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: GymOSTheme.textPrimary),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _buildLatestSessionCard() {
    final sessions = RoutineStore.instance.workoutHistory
        .where((session) => session['kind'] == 'cardio')
        .toList();
    if (sessions.isEmpty) {
      return const _EmptyCardioCard(
        message:
            'Aún no hay sesiones. Toca un tipo arriba para registrar la primera.',
      );
    }
    final session = sessions.first;
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
              Text(
                '${session['type']}',
                style: TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: GymOSTheme.orangeElectric.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'COMPLETADO',
                  style: TextStyle(
                    color: GymOSTheme.orangeElectric,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MetricItem(label: 'TIEMPO', value: '${session['duration']}'),
              _MetricItem(label: 'DISTANCIA', value: '${session['distance']}'),
              _MetricItem(
                label: 'CALORÍAS',
                value: '${session['calories']}',
                highlightColor: GymOSTheme.orangeElectric,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSelector() {
    final metrics = ['Distancia', 'Tiempo', 'Frecuencia', 'Calorías'];
    return Row(
      children: metrics.map((metric) {
        final isSel = _selectedChartMetric == metric;
        return GestureDetector(
          onTap: () => setState(() => _selectedChartMetric = metric),
          child: Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSel ? GymOSTheme.surfaceElevated : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSel ? GymOSTheme.orangeElectric : Colors.transparent,
              ),
            ),
            child: Text(
              metric,
              style: TextStyle(
                color: isSel
                    ? GymOSTheme.textPrimary
                    : GymOSTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnalyticsChartCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HISTÓRICO DE ${_selectedChartMetric.toUpperCase()}',
            style: const TextStyle(
              color: GymOSTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 4.2),
                      FlSpot(1, 5.0),
                      FlSpot(2, 4.8),
                      FlSpot(3, 5.5),
                      FlSpot(4, 6.2),
                    ],
                    isCurved: true,
                    color: GymOSTheme.violetElectric,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: GymOSTheme.violetElectric,
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: GymOSTheme.violetElectric.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionHistoryList() {
    final stored = RoutineStore.instance.workoutHistory
        .where((session) => session['kind'] == 'cardio')
        .map(
          (session) => <String, String>{
            'type': '${session['type']}',
            'date': _formatDate(session['date']),
            'duration': '${session['duration']}',
            'distance': '${session['distance']}',
            'calories': '${session['calories']}',
          },
        );
    final sessions = stored.isEmpty ? _sessionHistory : stored.toList();
    if (sessions.isEmpty) {
      return const _EmptyCardioCard(message: 'Tu historial aparecerá aquí.');
    }
    return Column(
      children: sessions.map((session) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: GymOSTheme.surfaceBase,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session['type']!,
                    style: const TextStyle(
                      color: GymOSTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session['date']!,
                    style: const TextStyle(
                      color: GymOSTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _HistoryMetricBadge(value: session['duration']!),
                  const SizedBox(width: 8),
                  _HistoryMetricBadge(value: session['distance']!),
                  const SizedBox(width: 8),
                  _HistoryMetricBadge(
                    value: session['calories']!,
                    isHighlight: true,
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(dynamic value) {
    if (value is! DateTime) return '$value';
    return '${value.day} ${_months[value.month - 1]} ${value.year}';
  }

  static const _months = [
    'ENE',
    'FEB',
    'MAR',
    'ABR',
    'MAY',
    'JUN',
    'JUL',
    'AGO',
    'SEP',
    'OCT',
    'NOV',
    'DIC',
  ];
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
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _HistoryMetricBadge extends StatelessWidget {
  final String value;
  final bool isHighlight;

  const _HistoryMetricBadge({required this.value, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight
            ? GymOSTheme.orangeElectric.withValues(alpha: 0.12)
            : GymOSTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: isHighlight
              ? GymOSTheme.orangeElectric
              : GymOSTheme.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EmptyCardioCard extends StatelessWidget {
  const _EmptyCardioCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: GymOSTheme.surfaceBase,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      message,
      style: const TextStyle(color: GymOSTheme.textSecondary),
    ),
  );
}
