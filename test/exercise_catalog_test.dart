import 'package:flutter_test/flutter_test.dart';
import 'package:gym_os/data/exercise_catalog.dart';

void main() {
  test('el catálogo cubre grupos periféricos y ofrece variedad amplia', () {
    final muscles = ExerciseCatalog.all
        .map((exercise) => exercise['muscle'])
        .whereType<String>()
        .toSet();

    expect(ExerciseCatalog.all.length, greaterThanOrEqualTo(150));
    expect(muscles, contains('Antebrazo'));
    expect(muscles, contains('Pantorrillas'));
  });
}
