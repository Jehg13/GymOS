import 'package:flutter/material.dart';
import '../data/app_preferences.dart';
import '../data/routine_store.dart';

void main() {
  runApp(const GymOSApp());
}

class GymOSApp extends StatelessWidget {
  const GymOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymOS Onboarding',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GymOSTheme.bgMain,
      ),
      home: const OnboardingFlowScreen(),
    );
  }
}

// ==========================================
// TOKENS DE DISEÑO - GYMOS DESIGN SYSTEM
// ==========================================
abstract class GymOSTheme {
  static const Color bgMain = Color(0xFF08090C);
  static const Color bgSec = Color(0xFF0F1116);
  static const Color surfaceBase = Color(0xFF151820);
  static const Color surfaceElevated = Color(0xFF1B1F28);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9B9FA8);
  static const Color orangeElectric = Color(0xFFFF6B1A);
  static const Color violetElectric = Color(0xFF8B5CF6);
}

// ==========================================
// FLUJO DE ONBOARDING
// ==========================================
class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key, this.onFinished});

  final VoidCallback? onFinished;

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  int _currentStep = 1;
  final int _totalSteps = 10;

  // Datos del Perfil Deportivo
  String _nombre = '';
  double _edad = 25;
  double _peso = 75.0;
  double _altura = 175.0;
  String _experiencia = 'Intermedio';
  String _objetivo = 'Ganar fuerza';
  final Set<String> _diasSeleccionados = {'Lun', 'Mié', 'Vie'};
  final Set<String> _gruposMusculares = {'Pecho', 'Espalda', 'Piernas'};
  String _equipamiento = 'Gimnasio completo';

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymOSTheme.bgMain,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -100,
              child: _GlowOrb(
                color: GymOSTheme.violetElectric.withValues(alpha: 0.16),
                size: 300,
              ),
            ),
            Positioned(
              bottom: 80,
              left: -160,
              child: _GlowOrb(
                color: GymOSTheme.orangeElectric.withValues(alpha: 0.10),
                size: 330,
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                      child: Row(
                        children: [
                          _currentStep > 1
                              ? _HeaderIconButton(
                                  icon: Icons.arrow_back_rounded,
                                  onPressed: _prevStep,
                                )
                              : const SizedBox(width: 42),
                          const Spacer(),
                          const _BrandMark(),
                          const Spacer(),
                          Text(
                            '${(_currentStep / _totalSteps * 100).round()}%',
                            style: const TextStyle(
                              color: GymOSTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'CONFIGURA TU PERFIL',
                                style: TextStyle(
                                  color: GymOSTheme.textSecondary.withValues(
                                    alpha: 0.75,
                                  ),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.8,
                                ),
                              ),
                              Text(
                                'PASO $_currentStep / $_totalSteps',
                                style: const TextStyle(
                                  color: GymOSTheme.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _currentStep / _totalSteps,
                              minHeight: 5,
                              backgroundColor: GymOSTheme.surfaceElevated,
                              valueColor: const AlwaysStoppedAnimation(
                                GymOSTheme.orangeElectric,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.04, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: KeyedSubtree(
                            key: ValueKey(_currentStep),
                            child: _buildStepContent(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [
                                GymOSTheme.orangeElectric,
                                Color(0xFFFF8A3D),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: GymOSTheme.orangeElectric.withValues(
                                  alpha: 0.24,
                                ),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: GymOSTheme.bgMain,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _currentStep == _totalSteps
                                ? _finishOnboarding
                                : _nextStep,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentStep == _totalSteps
                                      ? 'COMENZAR'
                                      : 'CONTINUAR',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.arrow_forward_rounded),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishOnboarding() async {
    await AppPreferences.instance.saveProfile(
      name: _nombre.trim().isEmpty ? 'Atleta' : _nombre.trim(),
      goal: _objetivo,
      experience: _experiencia,
      unit: 'Métrico',
      equipment: _equipamiento,
      days: _diasSeleccionados.toList(),
      muscles: _gruposMusculares.toList(),
    );
    RoutineStore.instance.applyOnboardingPlan(
      goal: _objetivo,
      equipment: _equipamiento,
      days: _diasSeleccionados.toList(),
      muscles: _gruposMusculares.toList(),
    );
    if (!mounted) return;
    widget.onFinished?.call();
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStepLayout(
          title: 'Información básica',
          subtitle:
              'Ingresa tu nombre para personalizar tu sistema de entrenamiento.',
          child: Column(
            children: [
              const SizedBox(height: 32),
              TextField(
                onChanged: (v) => _nombre = v,
                style: const TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintText: 'Tu nombre o alias',
                  hintStyle: TextStyle(
                    color: GymOSTheme.textSecondary.withValues(alpha: 0.4),
                  ),
                  filled: true,
                  fillColor: GymOSTheme.surfaceBase,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: GymOSTheme.orangeElectric,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case 2:
        return _buildStepLayout(
          title: 'Edad',
          subtitle:
              'Calcula tu tasa metabólica y coeficientes de recuperación.',
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                '${_edad.toInt()} AÑOS',
                style: const TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Slider(
                value: _edad,
                min: 14,
                max: 80,
                activeColor: GymOSTheme.orangeElectric,
                inactiveColor: GymOSTheme.surfaceElevated,
                onChanged: (v) => setState(() => _edad = v),
              ),
            ],
          ),
        );

      case 3:
        return _buildStepLayout(
          title: 'Peso actual',
          subtitle:
              'Utilizado para calcular tu tonelaje y progresión de fuerza.',
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                '${_peso.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Slider(
                value: _peso,
                min: 40.0,
                max: 160.0,
                activeColor: GymOSTheme.orangeElectric,
                inactiveColor: GymOSTheme.surfaceElevated,
                onChanged: (v) => setState(() => _peso = v),
              ),
            ],
          ),
        );

      case 4:
        return _buildStepLayout(
          title: 'Altura',
          subtitle:
              'Permite determinar tus palancas mecánicas e índice biológico.',
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                '${_altura.toInt()} cm',
                style: const TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Slider(
                value: _altura,
                min: 130,
                max: 220,
                activeColor: GymOSTheme.orangeElectric,
                inactiveColor: GymOSTheme.surfaceElevated,
                onChanged: (v) => setState(() => _altura = v),
              ),
            ],
          ),
        );

      case 5:
        return _buildStepLayout(
          title: 'Nivel de experiencia',
          subtitle: 'Adaptamos el volumen semanal e intensidad recomendada.',
          child: Column(
            children:
                [
                      'Principiante (< 1 año)',
                      'Intermedio (1 - 3 años)',
                      'Avanzado (> 3 años)',
                      'Atleta de Élite',
                    ]
                    .map(
                      (item) => _buildSelectCard(
                        label: item,
                        isSelected: _experiencia == item,
                        onTap: () => setState(() => _experiencia = item),
                      ),
                    )
                    .toList(),
          ),
        );

      case 6:
        return _buildStepLayout(
          title: 'Objetivo principal',
          subtitle: 'Optimizaremos las curvas de progresión de tu plan.',
          child: Column(
            children: [
              _buildSelectCard(
                label: 'Ganar músculo',
                icon: Icons.fitness_center,
                isSelected: _objetivo == 'Ganar músculo',
                onTap: () => setState(() => _objetivo = 'Ganar músculo'),
              ),
              _buildSelectCard(
                label: 'Ganar fuerza',
                icon: Icons.bolt,
                isSelected: _objetivo == 'Ganar fuerza',
                onTap: () => setState(() => _objetivo = 'Ganar fuerza'),
              ),
              _buildSelectCard(
                label: 'Perder grasa',
                icon: Icons.local_fire_department,
                isSelected: _objetivo == 'Perder grasa',
                onTap: () => setState(() => _objetivo = 'Perder grasa'),
              ),
              _buildSelectCard(
                label: 'Recomposición',
                icon: Icons.sync,
                isSelected: _objetivo == 'Recomposición',
                onTap: () => setState(() => _objetivo = 'Recomposición'),
              ),
              _buildSelectCard(
                label: 'Mantener',
                icon: Icons.straighten,
                isSelected: _objetivo == 'Mantener',
                onTap: () => setState(() => _objetivo = 'Mantener'),
              ),
            ],
          ),
        );

      case 7:
        final dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
        return _buildStepLayout(
          title: 'Días disponibles',
          subtitle: 'Selecciona los días que planeas entrenar.',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: dias.map((dia) {
              final isSel = _diasSeleccionados.contains(dia);
              return ChoiceChip(
                label: Text(dia),
                selected: isSel,
                selectedColor: GymOSTheme.orangeElectric,
                backgroundColor: GymOSTheme.surfaceBase,
                labelStyle: TextStyle(
                  color: isSel ? GymOSTheme.bgMain : GymOSTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (selected) {
                  setState(() {
                    selected
                        ? _diasSeleccionados.add(dia)
                        : _diasSeleccionados.remove(dia);
                  });
                },
              );
            }).toList(),
          ),
        );

      case 8:
        final grupos = [
          'Pecho',
          'Espalda',
          'Piernas',
          'Hombros',
          'Bíceps',
          'Tríceps',
          'Core',
        ];
        return _buildStepLayout(
          title: 'Grupos prioritarios',
          subtitle: '¿Qué áreas te interesa enfocar en tu planificación?',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: grupos.map((grupo) {
              final isSel = _gruposMusculares.contains(grupo);
              return FilterChip(
                label: Text(grupo),
                selected: isSel,
                selectedColor: GymOSTheme.orangeElectric,
                backgroundColor: GymOSTheme.surfaceBase,
                labelStyle: TextStyle(
                  color: isSel ? GymOSTheme.bgMain : GymOSTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (selected) {
                  setState(() {
                    selected
                        ? _gruposMusculares.add(grupo)
                        : _gruposMusculares.remove(grupo);
                  });
                },
              );
            }).toList(),
          ),
        );

      case 9:
        return _buildStepLayout(
          title: 'Equipamiento disponible',
          subtitle:
              'Filtraremos los ejercicios según tu entorno real de entrenamiento.',
          child: Column(
            children:
                [
                      'Gimnasio completo',
                      'Gimnasio básico',
                      'Casa',
                      'Peso corporal',
                      'Personalizado',
                    ]
                    .map(
                      (eq) => _buildSelectCard(
                        label: eq,
                        isSelected: _equipamiento == eq,
                        onTap: () => setState(() => _equipamiento = eq),
                      ),
                    )
                    .toList(),
          ),
        );

      case 10:
        return _buildStepLayout(
          title: 'Resumen de perfil',
          subtitle: 'Confirma la configuración de tu motor deportivo.',
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GymOSTheme.surfaceBase,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  'NOMBRE',
                  _nombre.isEmpty ? 'No indicado' : _nombre,
                ),
                _buildSummaryRow('OBJETIVO', _objetivo),
                _buildSummaryRow('DÍAS', _diasSeleccionados.join(', ')),
                _buildSummaryRow('EXPERIENCIA', _experiencia),
                _buildSummaryRow('PESO', '${_peso.toStringAsFixed(1)} kg'),
                _buildSummaryRow('ALTURA', '${_altura.toInt()} cm'),
                _buildSummaryRow('EQUIPO', _equipamiento),
              ],
            ),
          ),
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildStepLayout({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: GymOSTheme.textPrimary,
              fontSize: 30,
              height: 1.05,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              color: GymOSTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }

  Widget _buildSelectCard({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? GymOSTheme.orangeElectric.withValues(alpha: 0.12)
              : GymOSTheme.surfaceBase,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? GymOSTheme.orangeElectric
                : Colors.white.withValues(alpha: 0.06),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected
                    ? GymOSTheme.orangeElectric
                    : GymOSTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? GymOSTheme.textPrimary
                    : GymOSTheme.textSecondary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: GymOSTheme.orangeElectric,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: GymOSTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: GymOSTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            gradient: const LinearGradient(
              colors: [GymOSTheme.orangeElectric, Color(0xFFFF9D63)],
            ),
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: GymOSTheme.bgMain,
            size: 19,
          ),
        ),
        const SizedBox(width: 9),
        const Text(
          'GYMOS',
          style: TextStyle(
            color: GymOSTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GymOSTheme.surfaceElevated.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: GymOSTheme.textPrimary, size: 20),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
