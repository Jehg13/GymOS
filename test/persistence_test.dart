import 'package:flutter_test/flutter_test.dart';
import 'package:gym_os/data/database.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async => '.dart_tool';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('persiste y recupera colecciones JSON', () async {
    PathProviderPlatform.instance = _FakePathProvider();
    await GymDatabase.instance.initialize();
    const key = 'test_persistence_collection';
    final values = [
      {'title': 'Rutina de prueba', 'sets': 12},
    ];

    await GymDatabase.instance.writeCollection(key, values);
    final restored = await GymDatabase.instance.readCollection(key);

    expect(restored, hasLength(1));
    expect(restored.single['title'], 'Rutina de prueba');
    expect(restored.single['sets'], 12);
  });
}
