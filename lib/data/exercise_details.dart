class ExerciseDetails {
  const ExerciseDetails._();

  static Map<String, dynamic> forExercise(Map<String, String> exercise) {
    final muscle = exercise['muscle']!;
    final name = exercise['name']!;
    final secondary = switch (muscle) {
      'Pecho' => 'Tríceps, deltoides anterior',
      'Espalda' => 'Bíceps, deltoides posterior, core',
      'Piernas' => 'Glúteos, core',
      'Glúteos' => 'Isquiotibiales, core',
      'Hombros' => 'Trapecio, tríceps',
      'Bíceps' => 'Braquial, antebrazo',
      'Tríceps' => 'Pecho, deltoides anterior',
      'Antebrazo' => 'Bíceps, agarre',
      'Pantorrillas' => 'Sóleo, tibial anterior',
      _ => 'Recto abdominal, oblicuos, lumbar',
    };
    final variations = switch (muscle) {
      'Pecho' => ['Press con mancuernas', 'Flexiones', 'Cruce de poleas'],
      'Espalda' => ['Remo invertido', 'Jalón neutro', 'Dominadas asistidas'],
      'Piernas' => ['Sentadilla goblet', 'Prensa', 'Zancada atrás'],
      'Glúteos' => ['Puente de glúteos', 'Patada en polea', 'Abducción'],
      'Hombros' => ['Press Arnold', 'Elevación lateral', 'Pájaros'],
      'Bíceps' => ['Curl martillo', 'Curl inclinado', 'Curl en polea'],
      'Tríceps' => [
        'Extensión con cuerda',
        'Press cerrado',
        'Fondos asistidos',
      ],
      'Antebrazo' => [
        'Curl de muñeca',
        'Curl de muñeca inverso',
        'Paseo del granjero',
      ],
      'Pantorrillas' => [
        'Elevación de talones de pie',
        'Elevación de talones sentado',
        'Elevación de talones en prensa',
      ],
      _ => ['Dead bug', 'Plancha lateral', 'Pallof press'],
    };
    return {
      'secondary': secondary,
      'errors': [
        'Usar impulso para completar la repetición.',
        'Perder la posición neutra de la espalda.',
        'Sacrificar el rango por levantar más peso.',
      ],
      'variations': variations,
      'tempo': muscle == 'Core' ? 'Controlado · 2-1-2' : '2-0-2',
      'tip':
          'Mantén el abdomen activo y detén la serie si la técnica se deteriora.',
      'description':
          '$name desarrolla $muscle con una ejecución controlada y progresiva.',
      'videoUrl': '',
    };
  }
}
