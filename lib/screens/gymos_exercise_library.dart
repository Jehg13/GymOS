import 'package:flutter/material.dart';

import '../data/exercise_catalog.dart';
import '../data/exercise_details.dart';
import '../data/routine_store.dart';

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
  String _search = '';
  String _selectedEquipment = 'Todos';
  String _selectedDifficulty = 'Todos';
  bool _favoritesOnly = false;
  final List<String> _categories = [
    'Pecho',
    'Espalda',
    'Piernas',
    'Glúteos',
    'Hombros',
    'Bíceps',
    'Tríceps',
    'Core',
    'Antebrazo',
    'Pantorrillas',
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
                child: TextField(
                  onChanged: (value) => setState(() => _search = value.trim()),
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
                  final active = switch (filter) {
                    'Equipo' => _selectedEquipment != 'Todos',
                    'Dificultad' => _selectedDifficulty != 'Todos',
                    'Favoritos' => _favoritesOnly,
                    _ => false,
                  };
                  return GestureDetector(
                    onTap: () => _openFilter(filter),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? GymOSTheme.orangeElectric.withValues(alpha: .16)
                            : GymOSTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            filter,
                            style: TextStyle(
                              color: active
                                  ? GymOSTheme.orangeElectric
                                  : GymOSTheme.textSecondary,
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
              child: AnimatedBuilder(
                animation: RoutineStore.instance,
                builder: (context, _) => ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  physics: const BouncingScrollPhysics(),
                  children: _filteredExercises.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.only(top: 48),
                            child: Center(
                              child: Text(
                                'No encontramos ejercicios con esos filtros.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: GymOSTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ]
                      : _filteredExercises
                            .map(
                              (exercise) => _buildExerciseTile(
                                context,
                                name: exercise['name']!,
                                primaryMuscle: exercise['muscle']!,
                                equipment: exercise['equipment']!,
                                difficulty: exercise['difficulty']!,
                              ),
                            )
                            .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> get _filteredExercises {
    final query = _search.toLowerCase();
    return ExerciseCatalog.all.where((exercise) {
      final matchesCategory = exercise['muscle'] == _selectedCategory;
      final matchesEquipment =
          _selectedEquipment == 'Todos' ||
          exercise['equipment'] == _selectedEquipment;
      final matchesDifficulty =
          _selectedDifficulty == 'Todos' ||
          exercise['difficulty'] == _selectedDifficulty;
      final matchesFavorite =
          !_favoritesOnly ||
          RoutineStore.instance.favoriteExercises.contains(exercise['name']);
      final matchesSearch =
          query.isEmpty ||
          exercise.values.any((value) => value.toLowerCase().contains(query));
      return matchesCategory &&
          matchesEquipment &&
          matchesDifficulty &&
          matchesFavorite &&
          matchesSearch;
    }).toList();
  }

  Future<void> _openFilter(String filter) async {
    if (filter == 'Favoritos') {
      setState(() => _favoritesOnly = !_favoritesOnly);
      return;
    }
    final options = filter == 'Equipo'
        ? ['Todos', 'Barra', 'Mancuernas', 'Polea', 'Máquina', 'Peso corporal']
        : ['Todos', 'Principiante', 'Intermedio', 'Avanzado'];
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: GymOSTheme.surfaceElevated,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (option) => ListTile(
                  title: Text(option),
                  trailing: Icon(
                    (filter == 'Equipo'
                                ? _selectedEquipment
                                : _selectedDifficulty) ==
                            option
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: GymOSTheme.orangeElectric,
                  ),
                  onTap: () => Navigator.pop(context, option),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (!mounted || selected == null) return;
    setState(() {
      if (filter == 'Equipo') {
        _selectedEquipment = selected;
      } else {
        _selectedDifficulty = selected;
      }
    });
  }

  Widget _buildExerciseTile(
    BuildContext context, {
    required String name,
    required String primaryMuscle,
    required String equipment,
    required String difficulty,
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
                builder: (context) => ExerciseDetailScreen(
                  exercise: ExerciseCatalog.all.firstWhere(
                    (item) => item['name'] == name,
                  ),
                ),
              ),
            );
            RoutineStore.instance.recordExerciseUse(name);
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
                        const SizedBox(width: 6),
                        _MetaBadge(label: difficulty, isPrimary: false),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Favorito',
                      onPressed: () =>
                          RoutineStore.instance.toggleFavorite(name),
                      icon: Icon(
                        RoutineStore.instance.favoriteExercises.contains(name)
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 20,
                        color: GymOSTheme.orangeElectric,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: GymOSTheme.textSecondary,
                    ),
                  ],
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
  const ExerciseDetailScreen({super.key, required this.exercise});

  final Map<String, String> exercise;

  @override
  Widget build(BuildContext context) {
    final details = ExerciseDetails.forExercise(exercise);
    final isFavorite = RoutineStore.instance.favoriteExercises.contains(
      exercise['name'],
    );
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
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: GymOSTheme.orangeElectric,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? 'Ejercicio eliminado de favoritos'
                        : 'Ejercicio añadido a favoritos',
                  ),
                ),
              );
              RoutineStore.instance.toggleFavorite(exercise['name']!);
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
                                Text(
                                  '${exercise['muscle']!.toUpperCase()} · ANATOMÍA',
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
                                'MOVIMIENTO',
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
                    Text(
                      exercise['name']!.toUpperCase(),
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
                            value: exercise['muscle']!,
                            isHighlight: true,
                          ),
                          const Divider(
                            height: 20,
                            color: GymOSTheme.surfaceElevated,
                          ),
                          _DetailRow(
                            label: 'Secundarios',
                            value: details['secondary'] as String,
                          ),
                          const Divider(
                            height: 20,
                            color: GymOSTheme.surfaceElevated,
                          ),
                          _DetailRow(
                            label: 'Equipo',
                            value: exercise['equipment']!,
                          ),
                          const Divider(
                            height: 20,
                            color: GymOSTheme.surfaceElevated,
                          ),
                          _DetailRow(
                            label: 'Dificultad',
                            value: exercise['difficulty']!,
                          ),
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
                    _detailSection(
                      title: 'TÉCNICA Y EJECUCIÓN',
                      child: Text(
                        details['description'] as String,
                        style: const TextStyle(
                          color: GymOSTheme.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _detailSection(
                      title: 'ERRORES FRECUENTES',
                      child: Column(
                        children: (details['errors'] as List<String>)
                            .map(
                              (error) => Padding(
                                padding: const EdgeInsets.only(bottom: 9),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Color(0xFFFFB347),
                                      size: 17,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        error,
                                        style: const TextStyle(
                                          color: GymOSTheme.textSecondary,
                                          fontSize: 12,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _detailSection(
                      title: 'VARIACIONES Y SUSTITUCIONES',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (details['variations'] as List<String>)
                            .map(
                              (item) =>
                                  _MetaBadge(label: item, isPrimary: false),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _detailSection(
                      title: 'RECOMENDACIÓN',
                      child: Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: const Color(0xFF39D9FF),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${details['tip']} Tempo sugerido: ${details['tempo']}.',
                              style: const TextStyle(
                                color: GymOSTheme.textSecondary,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
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

  Widget _detailSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: .04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: GymOSTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
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
