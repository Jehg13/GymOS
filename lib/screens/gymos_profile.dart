import 'package:flutter/material.dart';

import '../data/app_preferences.dart';
import '../data/routine_store.dart';
import 'gymos_cardio.dart';
import 'gymos_exercise_library.dart';
import 'gymos_goals.dart';
import 'gymos_planner.dart';
import 'gymos_recovery.dart';
import 'gymos_strength_level.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onLogout});

  final ValueChanged<BuildContext>? onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Jesús';
  String _goal = 'Ganar músculo';
  String _experience = 'Intermedio';
  String _unit = 'Métrico';
  bool _notifications = true;
  bool _privateProfile = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await AppPreferences.instance.initialize();
    if (!mounted) return;
    setState(() {
      _name = AppPreferences.instance.profileName;
      _goal = AppPreferences.instance.profileGoal;
      _experience = AppPreferences.instance.profileExperience;
      _unit = AppPreferences.instance.profileUnit;
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RoutineStore.instance,
      builder: (context, _) {
        if (!_ready) {
          return const Scaffold(
            backgroundColor: Color(0xFF08090C),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF7A1A)),
            ),
          );
        }
        final history = RoutineStore.instance.workoutHistory;
        final volume = history.fold<double>(
          0,
          (sum, item) => sum + ((item['volume'] as num?)?.toDouble() ?? 0),
        );
        return Scaffold(
          backgroundColor: const Color(0xFF08090C),
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 64,
                  backgroundColor: const Color(0xFF08090C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  title: const Text(
                    'Mi perfil',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Editar perfil',
                      onPressed: _editProfile,
                      icon: const Icon(Icons.edit_rounded),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                    child: _buildHero(history.length, volume),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    MediaQuery.paddingOf(context).bottom + 34,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _sectionTitle('RESUMEN DE RENDIMIENTO'),
                      const SizedBox(height: 12),
                      _buildStats(history),
                      const SizedBox(height: 24),
                      _sectionTitle('MI PERFIL DEPORTIVO'),
                      const SizedBox(height: 12),
                      _buildSportCard(),
                      const SizedBox(height: 24),
                      _sectionTitle('PREFERENCIAS'),
                      const SizedBox(height: 12),
                      _buildPreferences(),
                      const SizedBox(height: 24),
                      _sectionTitle('DATOS Y CUENTA'),
                      const SizedBox(height: 12),
                      _buildDataActions(),
                      const SizedBox(height: 24),
                      _sectionTitle('HERRAMIENTAS GYMOS'),
                      const SizedBox(height: 12),
                      _buildTools(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHero(int sessions, double volume) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF282044), Color(0xFF151820)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFF9B7CFF).withValues(alpha: .35)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF9B7CFF).withValues(alpha: .12),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7A1A), Color(0xFFFFB347)],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: .8),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              _name.isEmpty ? '?' : _name[0].toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF08090C),
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    color: Color(0xFFFFB347),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _experience.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFFFB347),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '$sessions sesiones · ${volume.round()} kg acumulados',
                style: const TextStyle(color: Color(0xFFB7BBC4), fontSize: 11),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Editar',
          onPressed: _editProfile,
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white70,
            size: 17,
          ),
        ),
      ],
    ),
  );

  Widget _buildStats(List<Map<String, dynamic>> history) {
    final minutes = history.fold<int>(
      0,
      (sum, item) => sum + ((item['duration'] as num?)?.toInt() ?? 0),
    );
    return Row(
      children: [
        Expanded(
          child: _stat(
            'SESIONES',
            '${history.length}',
            Icons.fitness_center_rounded,
            const Color(0xFFFF7A1A),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _stat(
            'MINUTOS',
            '$minutes',
            Icons.timer_outlined,
            const Color(0xFF39D9FF),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _stat(
            'RACHA',
            _streak(history),
            Icons.local_fire_department_rounded,
            const Color(0xFFFFB347),
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF151820),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: .22)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 7),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9B9FA8),
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: .6,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );

  Widget _buildSportCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: _boxDecoration(),
    child: Column(
      children: [
        _infoRow(
          Icons.flag_rounded,
          'Objetivo',
          _goal,
          const Color(0xFFFF7A1A),
        ),
        const Divider(color: Color(0xFF252B36), height: 22),
        _infoRow(
          Icons.trending_up_rounded,
          'Experiencia',
          _experience,
          const Color(0xFF9B7CFF),
        ),
        const Divider(color: Color(0xFF252B36), height: 22),
        _infoRow(
          Icons.straighten_rounded,
          'Unidades',
          _unit == 'Métrico' ? 'Kilogramos y centímetros' : 'Libras y pulgadas',
          const Color(0xFF39D9FF),
        ),
      ],
    ),
  );

  Widget _infoRow(IconData icon, String label, String value, Color color) =>
      Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF9B9FA8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_rounded, color: Color(0xFF6F7682), size: 16),
        ],
      );

  Widget _buildPreferences() => Container(
    decoration: _boxDecoration(),
    child: Column(
      children: [
        _switchTile(
          Icons.notifications_none_rounded,
          'Notificaciones',
          'Recordatorios y resumen semanal',
          _notifications,
          (value) => setState(() => _notifications = value),
        ),
        _divider(),
        _actionTile(Icons.straighten_rounded, 'Unidades', _unit, _chooseUnit),
        _divider(),
        _switchTile(
          Icons.lock_outline_rounded,
          'Perfil privado',
          'Oculta tu actividad en el dispositivo',
          _privateProfile,
          (value) => setState(() => _privateProfile = value),
        ),
      ],
    ),
  );

  Widget _buildDataActions() => Container(
    decoration: _boxDecoration(),
    child: Column(
      children: [
        _actionTile(
          Icons.download_rounded,
          'Exportar datos',
          'Crear un resumen de GymOS',
          _exportData,
        ),
        _divider(),
        _actionTile(
          Icons.storage_rounded,
          'Datos locales',
          'Rutinas e historial almacenados en este dispositivo',
          _showLocalData,
        ),
        if (widget.onLogout != null) ...[
          _divider(),
          _actionTile(
            Icons.logout_rounded,
            'Cerrar sesión',
            'Salir de esta cuenta',
            _logout,
            color: const Color(0xFFFF6B6B),
          ),
        ],
      ],
    ),
  );

  Widget _buildTools() => Container(
    decoration: _boxDecoration(),
    child: Column(
      children: [
        _actionTile(
          Icons.calendar_month_rounded,
          'Planificador',
          'Organiza tu semana de entrenamiento',
          () => _open(const PlannerMainNavigation()),
          color: const Color(0xFF9B7CFF),
        ),
        _divider(),
        _actionTile(
          Icons.menu_book_rounded,
          'Biblioteca de ejercicios',
          'Consulta ejercicios y músculos trabajados',
          () => _open(const ExerciseLibraryScreen()),
          color: const Color(0xFF39D9FF),
        ),
        _divider(),
        _actionTile(
          Icons.directions_run_rounded,
          'Cardio',
          'Registra y consulta tu actividad cardiovascular',
          () => _open(const CardioScreen()),
          color: const Color(0xFF27D3C2),
        ),
        _divider(),
        _actionTile(
          Icons.flag_rounded,
          'Objetivos',
          'Consulta tus metas de rendimiento',
          () => _open(const GoalsScreen()),
          color: const Color(0xFFFFB347),
        ),
        _divider(),
        _actionTile(
          Icons.bedtime_rounded,
          'Recuperación',
          'Revisa descanso y recuperación',
          () => _open(const RecoveryScreen()),
          color: const Color(0xFFB794F4),
        ),
        _divider(),
        _actionTile(
          Icons.insights_rounded,
          'Nivel de fuerza',
          'Consulta tus referencias de fuerza',
          () => _open(const StrengthLevelScreen()),
          color: const Color(0xFFFF7A1A),
        ),
      ],
    ),
  );

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: const Color(0xFF151820),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: Colors.white.withValues(alpha: .07)),
  );

  Widget _divider() =>
      const Divider(height: 1, indent: 54, color: Color(0xFF252B36));

  Widget _actionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Color color = const Color(0xFFB7BBC4),
  }) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    leading: Icon(icon, color: color),
    title: Text(
      title,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
    ),
    subtitle: Text(
      subtitle,
      style: const TextStyle(color: Color(0xFF858B96), fontSize: 11),
    ),
    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF6F7682)),
  );

  Widget _switchTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    leading: Icon(icon, color: const Color(0xFFB7BBC4)),
    title: Text(
      title,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
    ),
    subtitle: Text(
      subtitle,
      style: const TextStyle(color: Color(0xFF858B96), fontSize: 11),
    ),
    trailing: Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFFFF7A1A),
    ),
  );

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFF9B9FA8),
      fontSize: 11,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.3,
    ),
  );

  String _streak(List<Map<String, dynamic>> history) =>
      history.isEmpty ? '0 días' : '${history.length} días';

  Future<void> _editProfile() async {
    final name = TextEditingController(text: _name);
    var goal = _goal;
    var experience = _experience;
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(
            22,
            14,
            22,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF11151D),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Editar perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                _profileField(name, 'Nombre', Icons.person_outline_rounded),
                const SizedBox(height: 12),
                _dropdown('Objetivo', goal, [
                  'Ganar músculo',
                  'Perder grasa',
                  'Mejorar fuerza',
                  'Mantenerme',
                ], (value) => setSheetState(() => goal = value!)),
                const SizedBox(height: 12),
                _dropdown(
                  'Experiencia',
                  experience,
                  ['Principiante', 'Intermedio', 'Avanzado'],
                  (value) => setSheetState(() => experience = value!),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetContext, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A1A),
                      foregroundColor: const Color(0xFF08090C),
                    ),
                    child: const Text(
                      'GUARDAR CAMBIOS',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result == true && mounted) {
      setState(() {
        _name = name.text.trim().isEmpty ? _name : name.text.trim();
        _goal = goal;
        _experience = experience;
      });
      await AppPreferences.instance.saveProfile(
        name: _name,
        goal: _goal,
        experience: _experience,
        unit: _unit,
      );
    }
    name.dispose();
  }

  Widget _profileField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) => TextField(
    controller: controller,
    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
    decoration: _inputDecoration(label, icon),
  );

  Widget _dropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) => DropdownButtonFormField<String>(
    initialValue: value,
    dropdownColor: const Color(0xFF1A202A),
    style: const TextStyle(color: Colors.white),
    decoration: _inputDecoration(label, Icons.tune_rounded),
    items: options
        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
        .toList(),
    onChanged: onChanged,
  );

  InputDecoration _inputDecoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9B9FA8)),
        prefixIcon: Icon(icon, color: const Color(0xFF39D9FF)),
        filled: true,
        fillColor: const Color(0xFF1A202A),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .07)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF39D9FF)),
        ),
      );

  void _chooseUnit() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF151820),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Métrico', 'Imperial']
              .map(
                (unit) => ListTile(
                  title: Text(
                    unit,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: _unit == unit
                      ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFFFF7A1A),
                        )
                      : null,
                  onTap: () {
                    setState(() => _unit = unit);
                    AppPreferences.instance.saveProfile(
                      name: _name,
                      goal: _goal,
                      experience: _experience,
                      unit: unit,
                    );
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _exportData() => _message(
    'Resumen preparado. La exportación estará disponible al conectar almacenamiento externo.',
  );
  void _showLocalData() => _message(
    '${RoutineStore.instance.routines.length} rutinas y ${RoutineStore.instance.workoutHistory.length} sesiones guardadas localmente.',
  );
  void _message(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
  void _logout() => widget.onLogout?.call(context);

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}
