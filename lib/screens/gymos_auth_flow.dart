import 'package:flutter/material.dart';

void main() {
  runApp(const GymOSApp());
}

class GymOSApp extends StatelessWidget {
  const GymOSApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'GymOS Auth',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: GymOSTheme.bgMain,
    ),
    home: LoginScreen(onAuthenticated: (_) {}),
  );
}

abstract class GymOSTheme {
  static const bgMain = Color(0xFF08090C);
  static const surfaceBase = Color(0xFF151820);
  static const surfaceElevated = Color(0xFF1B1F28);
  static const surfaceSoft = Color(0xFF10131A);
  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFF9B9FA8);
  static const orangeElectric = Color(0xFFFF6B1A);
  static const cyan = Color(0xFF39D9FF);
  static const violet = Color(0xFF9B7CFF);
}

class _AuthShell extends StatelessWidget {
  const _AuthShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymOSTheme.bgMain,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 860;
            if (!desktop) return child;
            return Row(
              children: [
                const Expanded(flex: 11, child: _AuthStoryPanel()),
                Expanded(
                  flex: 9,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 34),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AuthStoryPanel extends StatelessWidget {
  const _AuthStoryPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B1520), Color(0xFF0E1821), Color(0xFF0B0C11)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -110,
            right: -80,
            child: _glow(260, GymOSTheme.orangeElectric.withValues(alpha: .22)),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: _glow(300, GymOSTheme.violet.withValues(alpha: .16)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(52, 46, 52, 42),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _GymOSBrand(showTagline: true),
                const Spacer(),
                const Text(
                  'TU MEJOR\nVERSIÓN NO\nSE IMPROVISA.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    height: .98,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Entrena con intención. Mide lo que importa. '
                  'Construye una constancia que se note.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .66),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 34),
                Row(
                  children: const [
                    _StoryMetric(value: '01', label: 'PLAN'),
                    SizedBox(width: 30),
                    _StoryMetric(value: '∞', label: 'CONSTANCIA'),
                    SizedBox(width: 30),
                    _StoryMetric(value: '100%', label: 'ENFOQUE'),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: GymOSTheme.orangeElectric.withValues(
                            alpha: .16,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.insights_rounded,
                          color: GymOSTheme.orangeElectric,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Cada sesión cuenta cuando puedes verla evolucionar.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 28)],
    ),
  );
}

class _StoryMetric extends StatelessWidget {
  const _StoryMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: GymOSTheme.orangeElectric,
          fontSize: 19,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: .48),
          fontSize: 9,
          letterSpacing: 1.3,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _GymOSBrand extends StatelessWidget {
  const _GymOSBrand({this.showTagline = false});

  final bool showTagline;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF9A3D), GymOSTheme.orangeElectric],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: GymOSTheme.orangeElectric.withValues(alpha: .28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.bolt_rounded, color: GymOSTheme.bgMain, size: 28),
            Positioned(
              bottom: 7,
              child: SizedBox(
                width: 16,
                child: Divider(color: GymOSTheme.bgMain, thickness: 2),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 13),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.2,
              ),
              children: [
                TextSpan(text: 'GYM'),
                TextSpan(
                  text: 'OS',
                  style: TextStyle(color: GymOSTheme.orangeElectric),
                ),
              ],
            ),
          ),
          if (showTagline)
            const Text(
              'PERFORMANCE SYSTEM',
              style: TextStyle(
                color: GymOSTheme.textSecondary,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
        ],
      ),
    ],
  );
}

class GymOSInput extends StatelessWidget {
  const GymOSInput({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.onChanged,
    this.obscureText,
    this.onToggleVisibility,
  });
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool? obscureText;
  final VoidCallback? onToggleVisibility;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFFD6D8DE),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: .2,
        ),
      ),
      const SizedBox(height: 7),
      TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText ?? isPassword,
        style: const TextStyle(
          color: GymOSTheme.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: GymOSTheme.textSecondary.withValues(alpha: .55),
            fontSize: 13,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(9),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: GymOSTheme.cyan.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: GymOSTheme.cyan, size: 16),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: onToggleVisibility,
                  icon: Icon(
                    (obscureText ?? true)
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: GymOSTheme.textSecondary,
                    size: 19,
                  ),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF11141B),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: .1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: .1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: GymOSTheme.orangeElectric,
              width: 1.5,
            ),
          ),
        ),
      ),
    ],
  );
}

class GymOSPrimaryButton extends StatelessWidget {
  const GymOSPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });
  final String text;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 56,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9A3D), GymOSTheme.orangeElectric],
        ),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: GymOSTheme.orangeElectric.withValues(alpha: .22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: GymOSTheme.bgMain,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    ),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onAuthenticated});
  final ValueChanged<BuildContext> onAuthenticated;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AuthShell(
    child: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _GymOSBrand(),
              SizedBox(height: constraints.maxHeight < 700 ? 22 : 34),
              const Text(
                'Bienvenido de nuevo',
                style: TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Continúa donde dejaste tu entrenamiento.',
                style: TextStyle(color: GymOSTheme.textSecondary, fontSize: 13),
              ),
              SizedBox(height: constraints.maxHeight < 700 ? 20 : 28),
              GymOSInput(
                label: 'Email',
                hint: 'tu@email.com',
                icon: Icons.mail_outline_rounded,
                controller: _email,
              ),
              const SizedBox(height: 14),
              GymOSInput(
                label: 'Contraseña',
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                controller: _password,
                obscureText: _obscure,
                onToggleVisibility: () => setState(() => _obscure = !_obscure),
              ),
              const SizedBox(height: 9),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RecoverPasswordScreen(),
                    ),
                  ),
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: GymOSTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GymOSPrimaryButton(
                text: 'Iniciar sesión',
                onPressed: () => widget.onAuthenticated(context),
              ),
              const Spacer(),
              _socialButton(),
              const SizedBox(height: 12),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    const Text(
                      '¿Nuevo en GymOS? ',
                      style: TextStyle(
                        color: GymOSTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          color: GymOSTheme.orangeElectric,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _socialButton() => SizedBox(
    width: double.infinity,
    height: 48,
    child: OutlinedButton.icon(
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inicio con Google próximamente disponible'),
        ),
      ),
      icon: const Icon(Icons.g_mobiledata_rounded, size: 25),
      label: const Text(
        'Continuar con Google',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: .1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _confirmObscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AuthShell(
    child: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'PASO 01 / 01',
                    style: TextStyle(
                      color: GymOSTheme.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _GymOSBrand(),
              const SizedBox(height: 28),
              const Text(
                'Crea tu perfil',
                style: TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Configura tu acceso y empieza a registrar tu progreso.',
                style: TextStyle(color: GymOSTheme.textSecondary, fontSize: 13),
              ),
              SizedBox(height: constraints.maxHeight < 650 ? 15 : 23),
              GymOSInput(
                label: 'Nombre completo',
                hint: 'Alex Morgan',
                icon: Icons.person_outline_rounded,
                controller: _name,
              ),
              const SizedBox(height: 11),
              GymOSInput(
                label: 'Email',
                hint: 'alex@gymos.app',
                icon: Icons.mail_outline_rounded,
                controller: _email,
              ),
              const SizedBox(height: 11),
              GymOSInput(
                label: 'Contraseña',
                hint: 'Mínimo 8 caracteres',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                controller: _password,
                obscureText: _obscure,
                onToggleVisibility: () => setState(() => _obscure = !_obscure),
              ),
              const SizedBox(height: 8),
              _strengthIndicator(),
              const SizedBox(height: 11),
              GymOSInput(
                label: 'Confirmar contraseña',
                hint: 'Repite tu contraseña',
                icon: Icons.verified_user_outlined,
                isPassword: true,
                controller: _confirm,
                obscureText: _confirmObscure,
                onToggleVisibility: () =>
                    setState(() => _confirmObscure = !_confirmObscure),
              ),
              const Spacer(),
              GymOSPrimaryButton(
                text: 'Crear cuenta',
                onPressed: _createAccount,
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Al continuar aceptas los términos de GymOS.',
                  style: TextStyle(
                    color: GymOSTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _strengthIndicator() {
    final length = _password.text.length;
    final score = length >= 12
        ? 4
        : length >= 8
        ? 3
        : length >= 5
        ? 2
        : length > 0
        ? 1
        : 0;
    return Row(
      children: List.generate(
        4,
        (index) => Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 3 ? 5 : 0),
            decoration: BoxDecoration(
              color: index < score
                  ? (score >= 3
                        ? const Color(0xFF27D3C2)
                        : GymOSTheme.orangeElectric)
                  : GymOSTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }

  void _createAccount() {
    if (_name.text.trim().isEmpty ||
        !_email.text.contains('@') ||
        _password.text.length < 8 ||
        _password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Revisa tus datos y confirma que las contraseñas coincidan',
          ),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          onContinue: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GymOSTheme.bgMain,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
      ),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.lock_reset_rounded,
              color: GymOSTheme.cyan,
              size: 38,
            ),
            const SizedBox(height: 16),
            const Text(
              'Recupera el acceso',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Te enviaremos un código para restablecer tu contraseña.',
              style: TextStyle(color: GymOSTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 28),
            GymOSInput(
              label: 'Email',
              hint: 'tu@email.com',
              icon: Icons.mail_outline_rounded,
              controller: _email,
            ),
            const SizedBox(height: 18),
            GymOSPrimaryButton(
              text: 'Enviar código',
              onPressed: () {
                if (!_email.text.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingresa un email válido')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VerificationCodeScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GymOSTheme.bgMain,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
      ),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.mark_email_read_rounded,
              color: GymOSTheme.cyan,
              size: 38,
            ),
            const SizedBox(height: 16),
            const Text(
              'Verifica tu email',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Introduce el código de 6 dígitos que enviamos a tu correo.',
              style: TextStyle(color: GymOSTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 28),
            GymOSInput(
              label: 'Código de verificación',
              hint: '123456',
              icon: Icons.password_rounded,
              controller: _code,
            ),
            const SizedBox(height: 18),
            GymOSPrimaryButton(
              text: 'Verificar',
              onPressed: () {
                if (_code.text.trim().length != 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El código debe tener 6 dígitos'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GymOSTheme.bgMain,
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [GymOSTheme.orangeElectric, Color(0xFFFFB347)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: GymOSTheme.orangeElectric.withValues(alpha: .3),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: GymOSTheme.bgMain,
                  size: 45,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Cuenta creada',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu perfil está listo. Comienza a registrar tu rendimiento hoy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: GymOSTheme.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              GymOSPrimaryButton(text: 'Continuar', onPressed: onContinue),
            ],
          ),
        ),
      ),
    ),
  );
}
