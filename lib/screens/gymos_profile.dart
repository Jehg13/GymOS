import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

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
  int _age = 25;
  double _weight = 75;
  double _height = 175;
  String _equipment = 'Gimnasio completo';
  List<String> _trainingDays = const ['Lun', 'Mié', 'Vie'];
  List<String> _focusMuscles = const ['Pecho', 'Espalda', 'Piernas'];
  Uint8List? _profileImage;

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
      _age = AppPreferences.instance.profileAge;
      _weight = AppPreferences.instance.profileWeight;
      _height = AppPreferences.instance.profileHeight;
      _equipment = AppPreferences.instance.profileEquipment;
      _trainingDays = List<String>.from(AppPreferences.instance.trainingDays);
      _focusMuscles = List<String>.from(AppPreferences.instance.focusMuscles);
      final image = AppPreferences.instance.profileImage;
      _profileImage = image == null ? null : base64Decode(image);
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
        GestureDetector(
          onTap: _pickProfilePhoto,
          child: Container(
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
            child: _profileImage == null
                ? Center(
                    child: Text(
                      _name.isEmpty ? '?' : _name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF08090C),
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                : ClipOval(
                    child: Image.memory(_profileImage!, fit: BoxFit.cover),
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
        const Divider(color: Color(0xFF252B36), height: 22),
        _infoRow(
          Icons.cake_outlined,
          'Edad',
          '$_age años',
          const Color(0xFFFFB347),
        ),
        const Divider(color: Color(0xFF252B36), height: 22),
        _infoRow(
          Icons.monitor_weight_outlined,
          'Peso / altura',
          '${_weight.toStringAsFixed(1)} kg · ${_height.toStringAsFixed(0)} cm',
          const Color(0xFF39D9FF),
        ),
        const Divider(color: Color(0xFF252B36), height: 22),
        _infoRow(
          Icons.fitness_center_rounded,
          'Equipamiento',
          _equipment,
          const Color(0xFF9B7CFF),
        ),
        const Divider(color: Color(0xFF252B36), height: 22),
        _infoRow(
          Icons.event_available_rounded,
          'Días',
          _trainingDays.join(' · '),
          const Color(0xFFFF7A1A),
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
          'Copiar una copia JSON completa',
          _exportData,
        ),
        _divider(),
        _actionTile(
          Icons.upload_file_rounded,
          'Importar copia',
          'Restaurar datos desde JSON',
          _importData,
        ),
        _divider(),
        _actionTile(
          Icons.restart_alt_rounded,
          'Reiniciar plan generado',
          'Eliminar rutinas para generar un plan nuevo',
          _resetPlan,
          color: const Color(0xFFFFB347),
        ),
        _divider(),
        _actionTile(
          Icons.storage_rounded,
          'Datos locales',
          'Rutinas e historial almacenados en este dispositivo',
          _showLocalData,
        ),
        _divider(),
        _actionTile(
          Icons.delete_forever_rounded,
          'Eliminar todos los datos',
          'Borrado local permanente y controlado',
          _deleteAllData,
          color: const Color(0xFFFF6B6B),
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
    final age = TextEditingController(text: '$_age');
    final weight = TextEditingController(text: '$_weight');
    final height = TextEditingController(text: '$_height');
    var goal = _goal;
    var experience = _experience;
    var equipment = _equipment;
    var days = List<String>.from(_trainingDays);
    var muscles = List<String>.from(_focusMuscles);
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
                Row(
                  children: [
                    Expanded(
                      child: _profileField(age, 'Edad', Icons.cake_outlined),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _profileField(
                        weight,
                        'Peso kg',
                        Icons.monitor_weight_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _profileField(
                        height,
                        'Altura cm',
                        Icons.height_rounded,
                      ),
                    ),
                  ],
                ),
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
                const SizedBox(height: 12),
                _dropdown(
                  'Equipamiento',
                  equipment,
                  const [
                    'Gimnasio completo',
                    'Mancuernas',
                    'Peso corporal',
                    'Bandas',
                  ],
                  (value) => setSheetState(() => equipment = value!),
                ),
                const SizedBox(height: 14),
                _selectionWrap(
                  'Días de entrenamiento',
                  const ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'],
                  days,
                  (value) => setSheetState(
                    () => days.contains(value)
                        ? days.remove(value)
                        : days.add(value),
                  ),
                ),
                const SizedBox(height: 14),
                _selectionWrap(
                  'Grupos musculares',
                  const [
                    'Pecho',
                    'Espalda',
                    'Piernas',
                    'Hombros',
                    'Brazos',
                    'Core',
                    'Glúteos',
                    'Antebrazo',
                    'Pantorrillas',
                  ],
                  muscles,
                  (value) => setSheetState(
                    () => muscles.contains(value)
                        ? muscles.remove(value)
                        : muscles.add(value),
                  ),
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
        _age = int.tryParse(age.text) ?? _age;
        _weight = double.tryParse(weight.text) ?? _weight;
        _height = double.tryParse(height.text) ?? _height;
        _equipment = equipment;
        _trainingDays = days;
        _focusMuscles = muscles;
      });
      await AppPreferences.instance.saveProfile(
        name: _name,
        goal: _goal,
        experience: _experience,
        unit: _unit,
        equipment: _equipment,
        days: _trainingDays,
        muscles: _focusMuscles,
        age: _age,
        weight: _weight,
        height: _height,
      );
    }
    name.dispose();
    age.dispose();
    weight.dispose();
    height.dispose();
  }

  Widget _selectionWrap(
    String label,
    List<String> options,
    List<String> selected,
    ValueChanged<String> onTap,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: Color(0xFF9B9FA8), fontSize: 12),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: options
            .map(
              (value) => FilterChip(
                label: Text(value),
                selected: selected.contains(value),
                onSelected: (_) => onTap(value),
                selectedColor: const Color(0xFFFF7A1A).withValues(alpha: .25),
                labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            )
            .toList(),
      ),
    ],
  );

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

  Future<void> _pickProfilePhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    await AppPreferences.instance.saveProfileImage(base64Encode(bytes));
    if (mounted) setState(() => _profileImage = bytes);
  }

  Future<void> _exportData() async {
    final payload = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': {
        'name': _name,
        'goal': _goal,
        'experience': _experience,
        'unit': _unit,
        'equipment': _equipment,
        'days': _trainingDays,
        'muscles': _focusMuscles,
        'age': _age,
        'weight': _weight,
        'height': _height,
      },
      'routines': RoutineStore.instance.routines,
      'workouts': RoutineStore.instance.workoutHistory,
      'bodyLogs': RoutineStore.instance.bodyLogs,
      'goals': RoutineStore.instance.goals,
      'favorites': RoutineStore.instance.favoriteExercises.toList(),
      'exerciseHistory': RoutineStore.instance.exerciseHistory,
    };
    await Clipboard.setData(ClipboardData(text: jsonEncode(payload)));
    _message('Copia JSON preparada y copiada al portapapeles.');
  }

  Future<void> _importData() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF151820),
        title: const Text('Importar copia JSON'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Pega aquí el JSON exportado',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('RESTAURAR'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final decoded = jsonDecode(controller.text) as Map<String, dynamic>;
      final profile = Map<String, dynamic>.from(decoded['profile'] as Map);
      await RoutineStore.instance.clearAllData();
      await AppPreferences.instance.saveProfile(
        name: profile['name']?.toString() ?? _name,
        goal: profile['goal']?.toString() ?? _goal,
        experience: profile['experience']?.toString() ?? _experience,
        unit: profile['unit']?.toString() ?? _unit,
        equipment: profile['equipment']?.toString(),
        days: List<String>.from(profile['days'] as List? ?? _trainingDays),
        muscles: List<String>.from(
          profile['muscles'] as List? ?? _focusMuscles,
        ),
        age: (profile['age'] as num?)?.toInt(),
        weight: (profile['weight'] as num?)?.toDouble(),
        height: (profile['height'] as num?)?.toDouble(),
      );
      final store = RoutineStore.instance;
      for (final item in (decoded['routines'] as List? ?? const [])) {
        await store.add(Map<String, dynamic>.from(item as Map));
      }
      for (final item in (decoded['workouts'] as List? ?? const [])) {
        await store.addWorkoutHistory(Map<String, dynamic>.from(item as Map));
      }
      for (final item in (decoded['bodyLogs'] as List? ?? const [])) {
        await store.addBodyLog(Map<String, dynamic>.from(item as Map));
      }
      for (final item in (decoded['goals'] as List? ?? const [])) {
        await store.addGoal(Map<String, dynamic>.from(item as Map));
      }
      for (final name in (decoded['favorites'] as List? ?? const [])) {
        await store.toggleFavorite(name.toString());
      }
      for (final name in (decoded['exerciseHistory'] as List? ?? const [])) {
        await store.recordExerciseUse(name.toString());
      }
      await _loadProfile();
      _message('Copia restaurada correctamente.');
    } catch (_) {
      _message('La copia no es válida o está incompleta.');
    }
  }

  Future<void> _resetPlan() async {
    await RoutineStore.instance.resetGeneratedPlan();
    _message(
      'Plan reiniciado. Puedes generar uno nuevo desde tus preferencias.',
    );
  }

  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF151820),
        title: const Text('Eliminar todos los datos'),
        content: const Text(
          'Se borrarán rutinas, historial, objetivos, fotos y preferencias. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('ELIMINAR TODO'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await RoutineStore.instance.clearAllData();
    await AppPreferences.instance.clear();
    if (!mounted) return;
    setState(() {
      _profileImage = null;
      _name = 'Jesús';
      _age = 25;
      _weight = 75;
      _height = 175;
    });
    _message('Todos los datos locales fueron eliminados.');
  }

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
