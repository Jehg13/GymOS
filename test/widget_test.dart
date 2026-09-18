import 'package:flutter_test/flutter_test.dart';

import 'package:gym_os/data/app_preferences.dart';
import 'package:gym_os/main.dart';

void main() {
  testWidgets('muestra splash y luego onboarding', (WidgetTester tester) async {
    await AppPreferences.instance.initialize();
    await AppPreferences.instance.clear();
    await tester.pumpWidget(const GymOsApp());

    expect(find.text('Sincronizando tus datos'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.text('Información básica'), findsOneWidget);
    expect(find.text('CONTINUAR'), findsOneWidget);
  });
}
