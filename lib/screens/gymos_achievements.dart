import 'package:flutter/material.dart';

import '../data/routine_store.dart';
import 'muscle_strength_ranges.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _Achievement {
  const _Achievement({
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.target,
    required this.progress,
  });

  final String title;
  final String description;
  final String category;
  final IconData icon;
  final int target;
  final int progress;

  bool get unlocked => progress >= target;
  double get ratio => (progress / target).clamp(0, 1).toDouble();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  String _filter = 'Todos';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RoutineStore.instance,
      builder: (context, _) {
        final history = RoutineStore.instance.workoutHistory;
        final achievements = _buildAchievements(history);
        final unlocked = achievements.where((item) => item.unlocked).length;
        final filtered = _filter == 'Todos'
            ? achievements
            : achievements.where((item) => item.category == _filter).toList();
        final next = achievements.where((item) => !item.unlocked).toList()
          ..sort((a, b) => (b.ratio).compareTo(a.ratio));

        return Scaffold(
          backgroundColor: const Color(0xFF08090C),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              tooltip: 'Volver',
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
            ),
            title: const Text(
              'Logros',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: [
              IconButton(
                tooltip: 'Información',
                onPressed: () => _showInfo(context),
                icon: const Icon(Icons.info_outline_rounded),
              ),
            ],
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              MediaQuery.paddingOf(context).bottom + 32,
            ),
            children: [
              _buildHero(unlocked, achievements.length, history.length),
              const SizedBox(height: 18),
              _buildStrengthAnalysisShortcut(context),
              const SizedBox(height: 18),
              if (next.isNotEmpty) _buildNextGoal(next.first),
              if (next.isNotEmpty) const SizedBox(height: 24),
              const Text(
                'TU COLECCIÓN',
                style: TextStyle(
                  color: Color(0xFF9B9FA8),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Todos', 'Consistencia', 'Volumen', 'Variedad']
                      .map(
                        (filter) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: _filter == filter,
                            onSelected: (_) => setState(() => _filter = filter),
                            selectedColor: const Color(0xFFFF6B1A),
                            backgroundColor: const Color(0xFF151820),
                            labelStyle: TextStyle(
                              color: _filter == filter
                                  ? const Color(0xFF08090C)
                                  : const Color(0xFFB7BBC4),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                            side: BorderSide(
                              color: _filter == filter
                                  ? Colors.transparent
                                  : Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 14),
              if (filtered.isEmpty)
                _emptyState()
              else
                ...filtered.map((item) => _buildAchievement(item)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStrengthAnalysisShortcut(BuildContext context) {
    return Material(
      color: const Color(0xFF151820),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MuscleStrengthRangesScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFF39D9FF).withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: Color(0xFF39D9FF),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analiza tu nivel por músculo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rangos orientativos basados en tus pesos registrados',
                      style: TextStyle(color: Color(0xFF9B9FA8), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF6F7682),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_Achievement> _buildAchievements(List<Map<String, dynamic>> history) {
    final sessions = history.length;
    final volume = history.fold<double>(
      0,
      (sum, item) => sum + ((item['volume'] as num?)?.toDouble() ?? 0),
    );
    final muscleGroups = <String>{};
    for (final session in history) {
      muscleGroups.addAll(
        (session['muscleGroups'] as List<dynamic>? ?? const []).map(
          (value) => value.toString(),
        ),
      );
    }
    return [
      _Achievement(
        title: 'Primer paso',
        description: 'Completa tu primera sesión',
        category: 'Consistencia',
        icon: Icons.play_arrow_rounded,
        target: 1,
        progress: sessions,
      ),
      _Achievement(
        title: 'Ritmo constante',
        description: 'Completa 5 sesiones',
        category: 'Consistencia',
        icon: Icons.local_fire_department_rounded,
        target: 5,
        progress: sessions,
      ),
      _Achievement(
        title: 'Imparable',
        description: 'Completa 25 sesiones',
        category: 'Consistencia',
        icon: Icons.bolt_rounded,
        target: 25,
        progress: sessions,
      ),
      _Achievement(
        title: 'Primera tonelada',
        description: 'Acumula 1,000 kg de volumen',
        category: 'Volumen',
        icon: Icons.scale_rounded,
        target: 1000,
        progress: volume.round(),
      ),
      _Achievement(
        title: 'Motor de fuerza',
        description: 'Acumula 10,000 kg de volumen',
        category: 'Volumen',
        icon: Icons.trending_up_rounded,
        target: 10000,
        progress: volume.round(),
      ),
      _Achievement(
        title: 'Cuerpo completo',
        description: 'Trabaja 5 grupos musculares',
        category: 'Variedad',
        icon: Icons.accessibility_new_rounded,
        target: 5,
        progress: muscleGroups.length,
      ),
      _Achievement(
        title: 'Explorador',
        description: 'Entrena 8 grupos musculares',
        category: 'Variedad',
        icon: Icons.explore_rounded,
        target: 8,
        progress: muscleGroups.length,
      ),
      _Achievement(
        title: 'Semana completa',
        description: 'Completa 7 sesiones',
        category: 'Consistencia',
        icon: Icons.calendar_view_week_rounded,
        target: 7,
        progress: sessions,
      ),
      _Achievement(
        title: 'Disciplina de hierro',
        description: 'Completa 50 sesiones',
        category: 'Consistencia',
        icon: Icons.shield_rounded,
        target: 50,
        progress: sessions,
      ),
      _Achievement(
        title: 'Diez toneladas',
        description: 'Acumula 25,000 kg de volumen',
        category: 'Volumen',
        icon: Icons.workspace_premium_rounded,
        target: 25000,
        progress: volume.round(),
      ),
      _Achievement(
        title: 'Sin excusas',
        description: 'Completa 100 sesiones',
        category: 'Consistencia',
        icon: Icons.emoji_events_rounded,
        target: 100,
        progress: sessions,
      ),
    ];
  }

  Widget _buildHero(int unlocked, int total, int sessions) {
    final ratio = total == 0 ? 0.0 : unlocked / total;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF26203B), Color(0xFF151820)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFF9C6BFF).withValues(alpha: .35),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C6BFF).withValues(alpha: .14),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            height: 82,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withValues(alpha: .08),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B1A)),
                ),
                Center(
                  child: Text(
                    '${(ratio * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NIVEL DE ATLETA',
                  style: TextStyle(
                    color: Color(0xFFFFB38A),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  unlocked == 0
                      ? 'Tu historia comienza'
                      : 'Vas construyendo historia',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$unlocked de $total logros · $sessions sesiones registradas',
                  style: const TextStyle(
                    color: Color(0xFFB7BBC4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextGoal(_Achievement item) {
    return _Panel(
      child: Row(
        children: [
          const Icon(Icons.flag_rounded, color: Color(0xFFFF6B1A), size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SIGUIENTE META',
                  style: TextStyle(
                    color: Color(0xFF9B9FA8),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: item.ratio,
                    minHeight: 7,
                    backgroundColor: Colors.white.withValues(alpha: .08),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B1A)),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${item.progress} / ${item.target}',
                  style: const TextStyle(
                    color: Color(0xFF9B9FA8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievement(_Achievement item) {
    final color = item.unlocked
        ? const Color(0xFFFF6B1A)
        : const Color(0xFF5D6470);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFF151820),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showAchievement(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: .12),
                    border: Border.all(color: color.withValues(alpha: .55)),
                  ),
                  child: Icon(
                    item.unlocked ? item.icon : Icons.lock_rounded,
                    color: color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: item.unlocked
                              ? Colors.white
                              : const Color(0xFF858B96),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: const TextStyle(
                          color: Color(0xFF9B9FA8),
                          fontSize: 12,
                        ),
                      ),
                      if (!item.unlocked) ...[
                        const SizedBox(height: 9),
                        LinearProgressIndicator(
                          value: item.ratio,
                          minHeight: 4,
                          backgroundColor: Colors.white.withValues(alpha: .07),
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF9C6BFF),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.progress}/${item.target}',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 52),
    child: Center(
      child: Text(
        'No hay logros en esta categoría.',
        style: TextStyle(color: Color(0xFF9B9FA8)),
      ),
    ),
  );

  void _showAchievement(_Achievement item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF151820),
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.unlocked ? item.icon : Icons.lock_rounded,
              color: item.unlocked
                  ? const Color(0xFFFF6B1A)
                  : const Color(0xFF6F7682),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.unlocked
                  ? '¡Logro desbloqueado!'
                  : '${item.description}. Vas ${item.progress} de ${item.target}.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFB7BBC4)),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF151820),
      title: const Text(
        'Cómo se calculan',
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        'Los logros se actualizan automáticamente con tus sesiones completadas, volumen y grupos musculares registrados.',
        style: TextStyle(color: Color(0xFFB7BBC4)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF151820),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: .07)),
    ),
    child: child,
  );
}
