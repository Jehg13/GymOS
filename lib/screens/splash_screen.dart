import 'package:flutter/material.dart';

void main() {
  runApp(const GymOSApp());
}

class GymOSApp extends StatelessWidget {
  const GymOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GymOSColors.bgMain,
      ),
      home: const GymOSSyncLoadingScreen(),
    );
  }
}

// ==========================================
// TOKENS DEL DESIGN SYSTEM (PALETA GYMOS)
// ==========================================
abstract class GymOSColors {
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
// PANTALLA PRINCIPAL DE CARGA Y SINCRONIZACIÓN
// ==========================================
class GymOSSyncLoadingScreen extends StatefulWidget {
  const GymOSSyncLoadingScreen({super.key});

  @override
  State<GymOSSyncLoadingScreen> createState() => _GymOSSyncLoadingScreenState();
}

class _GymOSSyncLoadingScreenState extends State<GymOSSyncLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymOSColors.bgMain,
      body: SafeArea(
        child: Stack(
          children: [
            // Capa de fondo con Skeleton pasivo del Dashboard
            const Positioned.fill(
              child: Opacity(opacity: 0.15, child: DashboardSkeletonLayout()),
            ),

            // Capa frontal con el estado activo de sincronización
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Anillo de progreso personalizado con pulso y gradiente
                    RotationTransition(
                      turns: _rotationController,
                      child: const GlowingProgressRing(
                        size: 72.0,
                        strokeWidth: 3.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Título del estado
                    const Text(
                      'Sincronizando tus datos',
                      style: TextStyle(
                        color: GymOSColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Indicador de estado de base de datos local (SQLite)
                    const Text(
                      'Actualizando registros locales...',
                      style: TextStyle(
                        color: GymOSColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Marca inferior discreta
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'GYMOS ENGINE v1.0',
                  style: TextStyle(
                    color: GymOSColors.textSecondary.withValues(alpha: 0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
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
// COMPONENTE: ANILLO DE CARGA CON ACCENTO
// ==========================================
class GlowingProgressRing extends StatelessWidget {
  final double size;
  final double strokeWidth;

  const GlowingProgressRing({
    super.key,
    required this.size,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _RingPainter(strokeWidth: strokeWidth)),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double strokeWidth;

  _RingPainter({required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Pista base (oscura)
    final trackPaint = Paint()
      ..color = GymOSColors.surfaceElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // Arco activo (Naranja Ámbar / Orange Electric)
    final activePaint = Paint()
      ..shader = const SweepGradient(
        colors: [Colors.transparent, GymOSColors.orangeElectric],
        stops: [0.2, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      4.5, // ~260 grados
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// LAYOUT DE SKELETON (SHIMMER ANIMADO)
// ==========================================
class DashboardSkeletonLayout extends StatelessWidget {
  const DashboardSkeletonLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // Header Skeleton
          Row(
            children: [
              SkeletonBlock(width: 44, height: 44, borderRadius: 22),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBlock(width: 130, height: 16),
                  SizedBox(height: 6),
                  SkeletonBlock(width: 80, height: 12),
                ],
              ),
            ],
          ),
          SizedBox(height: 32),

          // Stat Card Hero
          SkeletonBlock(width: double.infinity, height: 140, borderRadius: 12),
          SizedBox(height: 16),

          // Grid de Métricas
          Row(
            children: [
              Expanded(
                child: SkeletonBlock(
                  width: double.infinity,
                  height: 90,
                  borderRadius: 12,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SkeletonBlock(
                  width: double.infinity,
                  height: 90,
                  borderRadius: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Chart Card Skeleton
          SkeletonBlock(width: double.infinity, height: 180, borderRadius: 12),
        ],
      ),
    );
  }
}

// ==========================================
// BLOQUE INDIVIDUAL DE SKELETON ANIMADO
// ==========================================
class SkeletonBlock extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBlock({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  State<SkeletonBlock> createState() => _SkeletonBlockState();
}

class _SkeletonBlockState extends State<SkeletonBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.2,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: GymOSColors.surfaceElevated.withValues(
              alpha: _animation.value,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.04),
              width: 1,
            ),
          ),
        );
      },
    );
  }
}
