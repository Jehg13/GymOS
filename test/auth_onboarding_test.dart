import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_os/screens/gymos_auth_flow.dart';
import 'package:gym_os/screens/gymos_onboarding.dart';

void main() {
  testWidgets('login muestra validación accesible para datos incompletos', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen(onAuthenticated: (_) {})),
    );

    await tester.tap(find.text('INICIAR SESIÓN'));
    await tester.pump();

    expect(find.text('Ingresa un email y contraseña válidos'), findsOneWidget);
    expect(find.bySemanticsLabel('Email'), findsWidgets);
  });

  testWidgets('onboarding comienza en información básica', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingFlowScreen()));

    expect(find.text('Información básica'), findsOneWidget);
    expect(find.text('CONTINUAR'), findsOneWidget);
  });
}
