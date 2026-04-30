class ChampionSetup {
  const ChampionSetup({
    required this.name,
    required this.role,
    required this.power,
    required this.goal,
  });

  final String name;
  final String? role;
  final String? power;
  final String? goal;

  int get completedSteps {
    return [
      name.trim().isNotEmpty,
      role != null,
      power != null,
      goal != null,
    ].where((isDone) => isDone).length;
  }

  int get score => completedSteps * 25;

  bool get isComplete => score == 100;

  String get feedback {
    if (isComplete) {
      return 'Perfil listo: tienes identidad, foco, fortaleza y objetivo.';
    }

    final missingSteps = 4 - completedSteps;
    return 'Faltan $missingSteps pasos para cerrar tu setup de Campeón.';
  }
}

const championRoles = <String>[
  'Dev de agentes',
  'PM curioso',
  'Creador de cursos',
];

const championPowers = <String>[
  'Pedir formatos claros',
  'Cuidar contexto',
  'Medir coste',
];

const championGoals = <String>[
  'Mejorar prompts',
  'Preparar minijuegos',
  'Dominar memoria',
];
