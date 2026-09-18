import 'package:flutter/material.dart';

import 'data/database.dart';
import 'data/app_preferences.dart';
import 'screens/gymos_auth_flow.dart';
import 'screens/gymos_dashboard.dart';
import 'screens/gymos_onboarding.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GymDatabase.instance.initialize();
  await AppPreferences.instance.initialize();
  runApp(const GymOsApp());
}

class GymOsApp extends StatelessWidget {
  const GymOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymOs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B1A),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF08090C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF08090C),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
          iconTheme: IconThemeData(color: Colors.white, size: 22),
          actionsIconTheme: IconThemeData(color: Colors.white, size: 22),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF151820),
          surfaceTintColor: Colors.transparent,
          elevation: 24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
          contentTextStyle: const TextStyle(
            color: Color(0xFFB7BBC4),
            fontSize: 14,
            height: 1.4,
          ),
          alignment: Alignment.center,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF11151D),
          modalBackgroundColor: Color(0xFF11151D),
          surfaceTintColor: Colors.transparent,
          showDragHandle: true,
          dragHandleColor: Color(0xFF596273),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF242B38),
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        useMaterial3: true,
      ),
      home: const AppStartupFlow(),
    );
  }
}

class AppStartupFlow extends StatefulWidget {
  const AppStartupFlow({super.key});

  @override
  State<AppStartupFlow> createState() => _AppStartupFlowState();
}

class _AppStartupFlowState extends State<AppStartupFlow> {
  bool _showSplash = true;
  bool _preferencesReady = false;

  @override
  void initState() {
    super.initState();
    _preparePreferences();
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  Future<void> _preparePreferences() async {
    await AppPreferences.instance.initialize();
    if (mounted) {
      setState(() => _preferencesReady = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash || !_preferencesReady) {
      return const GymOSSyncLoadingScreen();
    }

    if (AppPreferences.instance.hasSession) {
      return DashboardScreen(onLogout: _logout);
    }

    if (AppPreferences.instance.onboardingCompleted) {
      return LoginScreen(onAuthenticated: _openDashboard);
    }

    return OnboardingFlowScreen(
      onFinished: () async {
        await AppPreferences.instance.completeOnboarding();
        if (!context.mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => LoginScreen(onAuthenticated: _openDashboard),
          ),
        );
      },
    );
  }

  Future<void> _openDashboard(BuildContext loginContext) async {
    await AppPreferences.instance.startSession();
    if (!loginContext.mounted) return;
    Navigator.of(loginContext).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => DashboardScreen(onLogout: _logout),
      ),
      (route) => false,
    );
  }

  Future<void> _logout(BuildContext dashboardContext) async {
    await AppPreferences.instance.closeSession();
    if (!dashboardContext.mounted) return;
    Navigator.of(dashboardContext).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LoginScreen(onAuthenticated: _openDashboard),
      ),
      (route) => false,
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GymOs'),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Configuración',
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Panel principal',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Organiza tus entrenamientos y registra tu progreso.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.fitness_center,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenido a GymOs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('Tu base de datos local está lista.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _SummaryCard(label: 'Rutinas', value: '0'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(label: 'Ejercicios', value: '0'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Crear primera rutina'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
