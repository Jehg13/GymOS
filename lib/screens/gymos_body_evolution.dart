import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/routine_store.dart';

class BodyEvolutionScreen extends StatefulWidget {
  const BodyEvolutionScreen({super.key});

  @override
  State<BodyEvolutionScreen> createState() => _BodyEvolutionScreenState();
}

class _BodyEvolutionScreenState extends State<BodyEvolutionScreen> {
  String _metric = 'Peso';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RoutineStore.instance,
      builder: (context, _) {
        final logs = RoutineStore.instance.bodyLogs;
        final latest = logs.isEmpty ? null : logs.first;
        final first = logs.isEmpty ? null : logs.last;
        final current = (latest?['weight'] as num?)?.toDouble();
        final initial = (first?['weight'] as num?)?.toDouble();
        final change = current != null && initial != null
            ? current - initial
            : 0.0;
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
              'Evolución corporal',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: [
              IconButton(
                tooltip: 'Registrar',
                onPressed: _showAddLog,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              MediaQuery.paddingOf(context).bottom + 110,
            ),
            children: [
              _buildHero(current, change, logs.length),
              const SizedBox(height: 18),
              if (logs.isEmpty)
                _buildEmpty()
              else ...[
                _buildMetricSelector(),
                const SizedBox(height: 12),
                _buildChart(logs),
                const SizedBox(height: 24),
                _sectionTitle('COMPARATIVA VISUAL'),
                const SizedBox(height: 12),
                _buildPhotoComparison(logs),
                const SizedBox(height: 24),
                _sectionTitle('MEDIDAS ACTUALES'),
                const SizedBox(height: 12),
                _buildMeasurements(latest!),
                const SizedBox(height: 24),
                _sectionTitle('HISTORIAL DE REGISTROS'),
                const SizedBox(height: 12),
                ...logs.map(_buildLogTile),
              ],
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddLog,
            backgroundColor: const Color(0xFFFF6B1A),
            foregroundColor: const Color(0xFF08090C),
            icon: const Icon(Icons.add_a_photo_rounded),
            label: const Text(
              'Registrar progreso',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHero(double? current, double change, int count) {
    final hasData = current != null;
    final positive = change > 0;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF172B38), Color(0xFF151820)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFF27D3C2).withValues(alpha: .28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF27D3C2).withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: Color(0xFF27D3C2),
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Tu evolución, medida a medida',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _stat(
                  'PESO ACTUAL',
                  hasData ? '${current.toStringAsFixed(1)} kg' : '--',
                  Icons.monitor_weight_outlined,
                  const Color(0xFFFF6B1A),
                ),
              ),
              Expanded(
                child: _stat(
                  'CAMBIO TOTAL',
                  hasData
                      ? '${positive ? '+' : ''}${change.toStringAsFixed(1)} kg'
                      : '--',
                  positive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  positive ? const Color(0xFFFFB84D) : const Color(0xFF27D3C2),
                ),
              ),
              Expanded(
                child: _stat(
                  'REGISTROS',
                  '$count',
                  Icons.photo_camera_back_rounded,
                  const Color(0xFF9C6BFF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9B9FA8),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
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
      );

  Widget _buildMetricSelector() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: ['Peso', 'Cintura', 'Pecho', 'Brazo', 'Pierna'].map((metric) {
        final selected = _metric == metric;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(metric),
            selected: selected,
            onSelected: (_) => setState(() => _metric = metric),
            selectedColor: const Color(0xFF27D3C2),
            backgroundColor: const Color(0xFF151820),
            labelStyle: TextStyle(
              color: selected
                  ? const Color(0xFF08090C)
                  : const Color(0xFFB7BBC4),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
            side: BorderSide(
              color: selected
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: .08),
            ),
          ),
        );
      }).toList(),
    ),
  );

  Widget _buildChart(List<Map<String, dynamic>> logs) {
    final values = logs.reversed.map(_valueForMetric).toList();
    final spots = values
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    return Container(
      height: 230,
      padding: const EdgeInsets.fromLTRB(16, 18, 18, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151820),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TENDENCIA DE $_metric'.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF9B9FA8),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 13),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: min - (range == 0 ? 1 : range * .25),
                maxY: max + (range == 0 ? 1 : range * .25),
                minX: 0,
                maxX: (spots.length - 1).toDouble().clamp(1, double.infinity),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white.withValues(alpha: .06),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (items) => items
                        .map(
                          (item) => LineTooltipItem(
                            '${item.y.toStringAsFixed(1)} ${_metric == 'Peso' ? 'kg' : 'cm'}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF27D3C2),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: spots.length < 12),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF27D3C2).withValues(alpha: .12),
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

  double _valueForMetric(Map<String, dynamic> log) {
    if (_metric == 'Peso') return (log['weight'] as num?)?.toDouble() ?? 0;
    final key = {
      'Cintura': 'waist',
      'Pecho': 'chest',
      'Brazo': 'arm',
      'Pierna': 'leg',
    }[_metric]!;
    return (log[key] as num?)?.toDouble() ?? 0;
  }

  Widget _buildMeasurements(Map<String, dynamic> log) {
    final data = {
      'Peso': '${_format(log['weight'])} kg',
      'Cintura': '${_format(log['waist'])} cm',
      'Pecho': '${_format(log['chest'])} cm',
      'Brazo': '${_format(log['arm'])} cm',
      'Pierna': '${_format(log['leg'])} cm',
    };
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: data.entries
          .map(
            (entry) => Container(
              width: 155,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF151820),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: .07)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      color: Color(0xFF9B9FA8),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    entry.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildLogTile(Map<String, dynamic> log) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF151820),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: .07)),
      ),
      child: Row(
        children: [
          _photoThumb(log),
          const SizedBox(width: 12),
          const Icon(Icons.calendar_month_rounded, color: Color(0xFF27D3C2)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log['date']?.toString() ?? 'Registro',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_format(log['weight'])} kg · cintura ${_format(log['waist'])} cm',
                  style: const TextStyle(
                    color: Color(0xFF9B9FA8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF6F7682)),
        ],
      ),
    ),
  );

  Widget _photoThumb(Map<String, dynamic> log) {
    final bytes = log['imageBytes'];
    if (bytes is List<int> && bytes.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          Uint8List.fromList(bytes),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF27D3C2).withValues(alpha: .1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.person_outline_rounded, color: Color(0xFF27D3C2)),
    );
  }

  Widget _buildPhotoComparison(List<Map<String, dynamic>> logs) {
    final first = logs.last;
    final latest = logs.first;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151820),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .07)),
      ),
      child: Row(
        children: [
          Expanded(child: _comparisonPhoto(first, 'INICIO')),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.compare_arrows_rounded, color: Color(0xFFFF6B1A)),
          ),
          Expanded(child: _comparisonPhoto(latest, 'ACTUAL')),
        ],
      ),
    );
  }

  Widget _comparisonPhoto(Map<String, dynamic> log, String label) {
    final bytes = log['imageBytes'];
    final hasPhoto = bytes is List<int> && bytes.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9B9FA8),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: .78,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: hasPhoto
                ? Image.memory(Uint8List.fromList(bytes), fit: BoxFit.cover)
                : Container(
                    color: const Color(0xFF1A202A),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_rounded,
                          color: Color(0xFF6F7682),
                          size: 28,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Sin foto',
                          style: TextStyle(
                            color: Color(0xFF9B9FA8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          log['date']?.toString() ?? '',
          style: const TextStyle(color: Color(0xFF9B9FA8), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildEmpty() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: const Color(0xFF151820),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: .07)),
    ),
    child: const Column(
      children: [
        Icon(
          Icons.photo_camera_back_rounded,
          color: Color(0xFF27D3C2),
          size: 52,
        ),
        SizedBox(height: 14),
        Text(
          'Comienza tu transformación',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Registra tu peso y medidas para ver tendencias reales y comparar tu avance.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF9B9FA8), height: 1.4),
        ),
        SizedBox(height: 18),
      ],
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

  String _format(dynamic value) =>
      value is num ? value.toStringAsFixed(1) : '--';

  Future<void> _showAddLog() async {
    final values = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _BodyLogSheet(),
    );
    if (values == null || !mounted) return;
    RoutineStore.instance.addBodyLog({...values, 'date': _today()});
  }

  String _today() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }
}

class _BodyLogSheet extends StatefulWidget {
  const _BodyLogSheet();

  @override
  State<_BodyLogSheet> createState() => _BodyLogSheetState();
}

class _BodyLogSheetState extends State<_BodyLogSheet> {
  final _controllers = <String, TextEditingController>{
    'weight': TextEditingController(),
    'waist': TextEditingController(),
    'chest': TextEditingController(),
    'arm': TextEditingController(),
    'leg': TextEditingController(),
  };
  String? _error;
  Uint8List? _imageBytes;
  final _picker = ImagePicker();

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(22, 10, 22, bottom + 24),
      decoration: const BoxDecoration(
        color: Color(0xFF11151D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27D3C2).withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.straighten_rounded,
                    color: Color(0xFF27D3C2),
                  ),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nuevo registro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Mide tu avance, no solo tu peso',
                        style: TextStyle(color: Color(0xFF9B9FA8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'DATOS DE HOY',
              style: TextStyle(
                color: Color(0xFF9B9FA8),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            _field(
              'weight',
              'Peso corporal',
              'kg',
              Icons.monitor_weight_outlined,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _field(
                    'waist',
                    'Cintura',
                    'cm',
                    Icons.accessibility_new_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(
                    'chest',
                    'Pecho',
                    'cm',
                    Icons.favorite_border_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _field(
                    'arm',
                    'Brazo',
                    'cm',
                    Icons.fitness_center_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(
                    'leg',
                    'Pierna',
                    'cm',
                    Icons.directions_walk_rounded,
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFFF7B72), fontSize: 12),
              ),
            ],
            const SizedBox(height: 22),
            _buildPhotoPicker(),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B1A),
                  foregroundColor: const Color(0xFF08090C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.check_rounded),
                label: const Text(
                  'GUARDAR REGISTRO',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Color(0xFF9B9FA8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String key, String label, String unit, IconData icon) {
    return TextField(
      controller: _controllers[key],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9B9FA8), fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFF27D3C2), size: 20),
        suffixText: unit,
        suffixStyle: const TextStyle(
          color: Color(0xFF27D3C2),
          fontWeight: FontWeight.w900,
        ),
        filled: true,
        fillColor: const Color(0xFF1A202A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 17,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .07)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF27D3C2), width: 1.4),
        ),
      ),
    );
  }

  void _save() {
    final values = <String, dynamic>{};
    for (final entry in _controllers.entries) {
      final value = double.tryParse(
        entry.value.text.trim().replaceAll(',', '.'),
      );
      if (value == null || value <= 0) {
        setState(
          () => _error = 'Completa todos los campos con valores válidos.',
        );
        return;
      }
      values[entry.key] = value;
    }
    if (_imageBytes != null) {
      values['imageBytes'] = _imageBytes!.toList();
    }
    Navigator.pop(context, values);
  }

  Widget _buildPhotoPicker() {
    final hasPhoto = _imageBytes != null;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: _pickImage,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1A202A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF27D3C2).withValues(alpha: .35),
          ),
        ),
        child: hasPhoto
            ? ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(_imageBytes!, fit: BoxFit.cover),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_rounded,
                    color: Color(0xFF27D3C2),
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Añadir foto de progreso',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Opcional · compara tu inicio con tu estado actual',
                    style: TextStyle(color: Color(0xFF9B9FA8), fontSize: 11),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1400,
      imageQuality: 86,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (mounted) setState(() => _imageBytes = bytes);
  }
}
