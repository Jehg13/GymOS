import 'package:flutter/material.dart';

void main() {
  runApp(const GymOSApp());
}

class GymOSApp extends StatelessWidget {
  const GymOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymOS Exercise Library',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GymOSTheme.bgMain,
      ),
      home: const ExerciseLibraryScreen(),
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
// PANTALLA PRINCIPAL: CATÁLOGO DE EJERCICIOS
// ==========================================
class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  String _selectedCategory = 'Pecho';
  final List<String> _categories = [
    'Pecho',
    'Espalda',
    'Piernas',
    'Hombros',
    'Bíceps',
    'Tríceps',
    'Core',
  ];
  final List<String> _filters = [
    'Músculo',
    'Equipo',
    'Dificultad',
    'Favoritos',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymOSTheme.bgMain,
      appBar: AppBar(
        backgroundColor: GymOSTheme.bgMain,
        elevation: 0,
        title: const Text(
          'Ejercicios',
          style: TextStyle(
            color: GymOSTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Buscador Premium
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: GymOSTheme.surfaceBase,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
                child: const TextField(
                  style: TextStyle(color: GymOSTheme.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Buscar ejercicio...',
                    hintStyle: TextStyle(
                      color: GymOSTheme.textSecondary,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: GymOSTheme.textSecondary,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Chips de Filtros Rápidos
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: _filters.map((filter) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: GymOSTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          filter,
                          style: const TextStyle(
                            color: GymOSTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 14,
                          color: GymOSTheme.textSecondary,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 18),

            // Selector de Categorías (Músculos Principales)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: _categories.map((cat) {
                  final isSel = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSel
                            ? GymOSTheme.orangeElectric
                            : GymOSTheme.surfaceBase,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cat.toUpperCase(),
                        style: TextStyle(
                          color: isSel
                              ? GymOSTheme.bgMain
                              : GymOSTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Lista de Ejercicios
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildExerciseTile(
                    context,
                    name: 'Press Banca',
                    primaryMuscle: 'Pecho',
                    equipment: 'Barra',
                  ),
                  _buildExerciseTile(
                    context,
                    name: 'Press Inclinado con Mancuernas',
                    primaryMuscle: 'Pecho',
                    equipment: 'Mancuernas',
                  ),
                  _buildExerciseTile(
                    context,
                    name: 'Aperturas en Polea',
                    primaryMuscle: 'Pecho',
                    equipment: 'Polea',
                  ),
                  _buildExerciseTile(
                    context,
                    name: 'Fondos en Paralelas',
                    primaryMuscle: 'Pecho',
                    equipment: 'Peso Corporal',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseTile(
    BuildContext context, {
    required String name,
    required String primaryMuscle,
    required String equipment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExerciseDetailScreen(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: GymOSTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _MetaBadge(label: primaryMuscle, isPrimary: true),
                        const SizedBox(width: 6),
                        _MetaBadge(label: equipment, isPrimary: false),
                      ],
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: GymOSTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// PANTALLA DETALLE: PRESS BANCA
// ==========================================
class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymOSTheme.bgMain,
      appBar: AppBar(
        backgroundColor: GymOSTheme.bgMain,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: GymOSTheme.textPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.star_border_rounded,
              color: GymOSTheme.orangeElectric,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ejercicio añadido a favoritos')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ILUSTRACIÓN / VISUALIZACIÓN TÉCNICA DE ALTA CALIDAD
                    Container(
                      height: 190,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: GymOSTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fitness_center_rounded,
                                  size: 56,
                                  color: GymOSTheme.orangeElectric.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'ILUSTRACIÓN ANATÓMICA',
                                  style: TextStyle(
                                    color: GymOSTheme.textSecondary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: GymOSTheme.bgMain.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '3D ANATOMY',
                                style: TextStyle(
                                  color: GymOSTheme.orangeElectric,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // TÍTULO Y MAPA MUSCULAR
                    const Text(
                      'PRESS BANCA',
                      style: TextStyle(
                        color: GymOSTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // FICHA TÉCNICA
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: GymOSTheme.surfaceBase,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            label: 'Músculo Principal',
                            value: 'Pecho',
                            isHighlight: true,
                          ),
                          const Divider(
                            height: 20,
                            color: GymOSTheme.surfaceElevated,
                          ),
                          _DetailRow(
                            label: 'Secundarios',
                            value: 'Tríceps, Deltoides anterior',
                          ),
                          const Divider(
                            height: 20,
                            color: GymOSTheme.surfaceElevated,
                          ),
                          _DetailRow(label: 'Equipo', value: 'Barra'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // HISTORIAL DEL ATLETA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TU HISTORIAL',
                          style: TextStyle(
                            color: GymOSTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: GymOSTheme.orangeElectric.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PR: 82.5 kg',
                            style: TextStyle(
                              color: GymOSTheme.orangeElectric,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // CONTENEDOR DE SERIES DEL HISTORIAL
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: GymOSTheme.surfaceBase,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                      child: Column(
                        children: const [
                          _HistorySetRow(
                            setNumber: '1',
                            weight: '70 kg',
                            reps: '10',
                          ),
                          SizedBox(height: 10),
                          _HistorySetRow(
                            setNumber: '2',
                            weight: '75 kg',
                            reps: '9',
                          ),
                          SizedBox(height: 10),
                          _HistorySetRow(
                            setNumber: '3',
                            weight: '80 kg',
                            reps: '8',
                          ),
                          SizedBox(height: 10),
                          _HistorySetRow(
                            setNumber: '4',
                            weight: '82.5 kg',
                            reps: '7',
                            isPR: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // BOTÓN DE ACCIÓN FIJO EN PARTE INFERIOR
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GymOSTheme.orangeElectric,
                    foregroundColor: GymOSTheme.bgMain,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Guía de técnica próximamente disponible',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text(
                    'AÑADIR A RUTINA',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// COMPONENTES AUXILIARES
// ==========================================
class _MetaBadge extends StatelessWidget {
  final String label;
  final bool isPrimary;

  const _MetaBadge({required this.label, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPrimary
            ? GymOSTheme.orangeElectric.withValues(alpha: 0.12)
            : GymOSTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPrimary
              ? GymOSTheme.orangeElectric
              : GymOSTheme.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: GymOSTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight
                ? GymOSTheme.orangeElectric
                : GymOSTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _HistorySetRow extends StatelessWidget {
  final String setNumber;
  final String weight;
  final String reps;
  final bool isPR;

  const _HistorySetRow({
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.isPR = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: GymOSTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  setNumber,
                  style: const TextStyle(
                    color: GymOSTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$weight × $reps',
              style: TextStyle(
                color: isPR
                    ? GymOSTheme.orangeElectric
                    : GymOSTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (isPR)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: GymOSTheme.orangeElectric.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'MÁXIMO',
              style: TextStyle(
                color: GymOSTheme.orangeElectric,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}
