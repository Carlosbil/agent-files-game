class Quest {
  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.xp,
    required this.phase,
    this.completed = false,
  });

  final String id;
  final String title;
  final String description;
  final int xp;
  final int phase;
  final bool completed;
}

final phaseOneQuests = <Quest>[
  const Quest(
    id: 'f1-01',
    title: 'Setup de Campeón',
    description:
        'Crea tu perfil de Campeón y termina el onboarding interactivo.',
    xp: 80,
    phase: 1,
  ),
  const Quest(
    id: 'f1-02',
    title: 'Ruta de Banderas IA',
    description:
        'Camina por 3 submundos y supera retos de agentes, skills e instrucciones.',
    xp: 120,
    phase: 1,
  ),
];

final phaseTwoQuests = <Quest>[
  const Quest(
    id: 'f2-01',
    title: 'Prompt Surgery v1',
    description: 'Resuelve 3 prompts ambiguos sin pasarte del presupuesto.',
    xp: 150,
    phase: 2,
  ),
  const Quest(
    id: 'f2-02',
    title: 'Context Budget v1',
    description: 'Elige contexto útil con límite de tokens en 2 rondas.',
    xp: 180,
    phase: 2,
  ),
  const Quest(
    id: 'f2-03',
    title: 'Memory Manager v1',
    description: 'Guarda solo memoria útil y evita contaminación.',
    xp: 200,
    phase: 2,
  ),
];
