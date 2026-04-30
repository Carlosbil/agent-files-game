enum MiniGameWorldId { agents, skills, instructions }

class MiniGameWorld {
  const MiniGameWorld({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final MiniGameWorldId id;
  final String title;
  final String subtitle;
}

class ChallengeOption {
  const ChallengeOption({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;
  final String title;
  final String body;
}

class WorldChallenge {
  const WorldChallenge({
    required this.id,
    required this.worldId,
    required this.level,
    required this.title,
    required this.fileFocus,
    required this.story,
    required this.mission,
    required this.prompt,
    required this.options,
    required this.correctOptionId,
    required this.successText,
    required this.rewardXp,
  });

  final String id;
  final MiniGameWorldId worldId;
  final int level;
  final String title;
  final String fileFocus;
  final String story;
  final String mission;
  final String prompt;
  final List<ChallengeOption> options;
  final String correctOptionId;
  final String successText;
  final int rewardXp;

  bool isCorrect(String optionId) => optionId == correctOptionId;
}

class WorldRouteProgress {
  const WorldRouteProgress(this.completedChallengeIds);

  final Set<String> completedChallengeIds;

  int get totalChallenges => aiWorldRoute.length;

  int get completedCount {
    var count = 0;
    for (final challenge in aiWorldRoute) {
      if (!completedChallengeIds.contains(challenge.id)) {
        break;
      }
      count++;
    }
    return count;
  }

  int get earnedXp {
    return aiWorldRoute
        .take(completedCount)
        .fold<int>(0, (sum, challenge) => sum + challenge.rewardXp);
  }

  double get progressRatio => completedCount / totalChallenges;

  bool get isComplete => completedCount == totalChallenges;

  WorldChallenge? get nextChallenge {
    if (isComplete) {
      return null;
    }
    return aiWorldRoute[completedCount];
  }

  MiniGameWorld get currentWorld {
    final challenge = nextChallenge ?? aiWorldRoute.last;
    return worldFor(challenge.worldId);
  }

  bool isCompleted(String challengeId) {
    final index = indexOfChallenge(challengeId);
    return index >= 0 && index < completedCount;
  }

  bool isCurrent(String challengeId) => nextChallenge?.id == challengeId;

  bool isUnlocked(String challengeId) {
    final index = indexOfChallenge(challengeId);
    return index >= 0 && index <= completedCount;
  }
}

int indexOfChallenge(String challengeId) {
  return aiWorldRoute.indexWhere((challenge) => challenge.id == challengeId);
}

WorldChallenge challengeById(String challengeId) {
  return aiWorldRoute.firstWhere((challenge) => challenge.id == challengeId);
}

MiniGameWorld worldFor(MiniGameWorldId id) {
  return miniGameWorlds.firstWhere((world) => world.id == id);
}

int worldStartIndex(MiniGameWorldId id) {
  return aiWorldRoute.indexWhere((challenge) => challenge.worldId == id);
}

int worldChallengeCount(MiniGameWorldId id) {
  return aiWorldRoute.where((challenge) => challenge.worldId == id).length;
}

const miniGameWorlds = <MiniGameWorld>[
  MiniGameWorld(
    id: MiniGameWorldId.agents,
    title: 'Submundo Agentes',
    subtitle: 'Roles, herramientas y colaboracion',
  ),
  MiniGameWorld(
    id: MiniGameWorldId.skills,
    title: 'Submundo Skills',
    subtitle: 'SKILL.md, referencias y checks',
  ),
  MiniGameWorld(
    id: MiniGameWorldId.instructions,
    title: 'Submundo Instrucciones',
    subtitle: 'Prompts, contexto y jerarquia',
  ),
];

const aiWorldRoute = <WorldChallenge>[
  WorldChallenge(
    id: 'agents-file-rules',
    worldId: MiniGameWorldId.agents,
    level: 1,
    title: 'AGENTS.md operativo',
    fileFocus: 'AGENTS.md',
    story:
        'Encuentras un repo nuevo y una IA lista para ayudar, pero sin mapa. La primera bandera consiste en escribir el archivo que le dira como moverse sin romper nada.',
    mission:
        'Convierte reglas del repo en instrucciones que protegen el trabajo.',
    prompt:
        'Hay cambios ajenos en el worktree y debes editar cerca. ¿Que regla mejora el comportamiento del agente?',
    options: [
      ChallengeOption(
        id: 'respect-worktree',
        title: 'Respetar cambios ajenos',
        body:
            'Leer el estado, tocar solo el alcance pedido y no revertir trabajo del usuario.',
      ),
      ChallengeOption(
        id: 'rewrite-history',
        title: 'Reescribir desde cero',
        body:
            'Limpiar todos los archivos para que el agente empiece con una base conocida.',
      ),
      ChallengeOption(
        id: 'skip-status',
        title: 'Ir directo al parche',
        body: 'Editar sin revisar contexto porque el objetivo ya esta claro.',
      ),
    ],
    correctOptionId: 'respect-worktree',
    successText:
        'El agente conserva el contexto local y evita borrar trabajo existente.',
    rewardXp: 40,
  ),
  WorldChallenge(
    id: 'agents-delegation',
    worldId: MiniGameWorldId.agents,
    level: 2,
    title: 'Delegacion enfocada',
    fileFocus: 'workflow de agentes',
    story:
        'El agente ya entiende el terreno. Ahora necesita aprender cuando llamar refuerzos y cuando seguir caminando por su cuenta.',
    mission: 'Define cuando un agente secundario ayuda sin bloquear el flujo.',
    prompt:
        'Tienes que investigar tests mientras aplicas un cambio simple. ¿Cuando conviene delegar?',
    options: [
      ChallengeOption(
        id: 'parallel-sidecar',
        title: 'Sidecar concreto',
        body:
            'Pedir una busqueda acotada que avance en paralelo y no bloquee el siguiente paso local.',
      ),
      ChallengeOption(
        id: 'delegate-main-path',
        title: 'Camino principal fuera',
        body:
            'Entregar al subagente la decision que necesitas antes de poder continuar.',
      ),
      ChallengeOption(
        id: 'duplicate-work',
        title: 'Duplicar inspeccion',
        body:
            'Hacer que todos revisen los mismos archivos para comparar respuestas.',
      ),
    ],
    correctOptionId: 'parallel-sidecar',
    successText:
        'La delegacion aporta contexto extra sin frenar el avance principal.',
    rewardXp: 40,
  ),
  WorldChallenge(
    id: 'agents-tool-safety',
    worldId: MiniGameWorldId.agents,
    level: 3,
    title: 'Herramientas seguras',
    fileFocus: 'tool policy',
    story:
        'Antes de cruzar al siguiente submundo, mejoras el manual del agente para que inspeccione, edite y verifique con criterio.',
    mission: 'Mejora como el agente decide inspeccionar, editar y verificar.',
    prompt:
        'Antes de tocar una feature desconocida, ¿que secuencia reduce errores?',
    options: [
      ChallengeOption(
        id: 'read-nearby-tests',
        title: 'Leer codigo cercano',
        body: 'Revisar entrada, modelos, tests y estilo local antes de editar.',
      ),
      ChallengeOption(
        id: 'format-first',
        title: 'Formatear primero',
        body:
            'Lanzar formatter global para homogeneizar el repo antes de entenderlo.',
      ),
      ChallengeOption(
        id: 'manual-only',
        title: 'No verificar',
        body: 'Confiar en lectura manual y cerrar sin pruebas ni analisis.',
      ),
    ],
    correctOptionId: 'read-nearby-tests',
    successText:
        'El agente aprende la forma del sistema antes de mover una pieza.',
    rewardXp: 40,
  ),
  WorldChallenge(
    id: 'skills-trigger',
    worldId: MiniGameWorldId.skills,
    level: 4,
    title: 'Trigger de skill',
    fileFocus: 'SKILL.md',
    story:
        'Llegas al taller de skills. Cada skill es una tecnica especializada, pero solo debe entrar en escena cuando aporta algo real.',
    mission: 'Haz que las skills entren solo cuando aportan conocimiento real.',
    prompt:
        'El usuario pide tests unitarios en Flutter. ¿Que mejora haces en las instrucciones?',
    options: [
      ChallengeOption(
        id: 'named-or-matching',
        title: 'Activacion clara',
        body:
            'Usar la skill si el usuario la nombra o si la tarea encaja con su descripcion.',
      ),
      ChallengeOption(
        id: 'always-load-all',
        title: 'Cargar todas',
        body: 'Abrir todas las skills disponibles para no perder detalles.',
      ),
      ChallengeOption(
        id: 'ignore-skills',
        title: 'Resolver sin skill',
        body: 'Evitar skills porque anaden pasos al trabajo.',
      ),
    ],
    correctOptionId: 'named-or-matching',
    successText:
        'La skill aparece en el momento correcto y mantiene el contexto ligero.',
    rewardXp: 40,
  ),
  WorldChallenge(
    id: 'skills-context-load',
    worldId: MiniGameWorldId.skills,
    level: 5,
    title: 'Referencias ligeras',
    fileFocus: 'references/',
    story:
        'La biblioteca crece. El reto ya no es tener mas documentos, sino cargar justo los que mantienen al agente lucido.',
    mission: 'Controla cuanto contexto lee el agente desde una skill.',
    prompt:
        'Una skill apunta a diez documentos auxiliares. ¿Como evitas llenar la ventana de contexto?',
    options: [
      ChallengeOption(
        id: 'load-only-needed',
        title: 'Solo lo necesario',
        body:
            'Leer SKILL.md y abrir unicamente las referencias directamente utiles.',
      ),
      ChallengeOption(
        id: 'paste-library',
        title: 'Pegar toda la carpeta',
        body:
            'Cargar cada referencia para que el agente tenga memoria completa.',
      ),
      ChallengeOption(
        id: 'trust-title',
        title: 'Confiar en el nombre',
        body: 'No abrir instrucciones y adivinar el flujo por el titulo.',
      ),
    ],
    correctOptionId: 'load-only-needed',
    successText:
        'La skill suma criterio sin desplazar el contexto que importa.',
    rewardXp: 40,
  ),
  WorldChallenge(
    id: 'skills-quality',
    worldId: MiniGameWorldId.skills,
    level: 6,
    title: 'Checklist de calidad',
    fileFocus: 'skill QA',
    story:
        'Tu skill ya se activa bien. Ahora necesita un cierre fiable: pruebas, criterios y senales claras de que la mejora funciona.',
    mission: 'Refuerza una skill para que produzca cambios verificables.',
    prompt:
        'Quieres que una skill de pruebas genere resultados confiables. ¿Que regla debe destacar?',
    options: [
      ChallengeOption(
        id: 'deterministic-tests',
        title: 'Pruebas deterministas',
        body:
            'Cubrir comportamiento, evitar red/reloj aleatorio y ejecutar el test mas cercano.',
      ),
      ChallengeOption(
        id: 'snapshot-everything',
        title: 'Snapshots masivos',
        body: 'Probar todos los estilos visuales aunque no cambie la UI.',
      ),
      ChallengeOption(
        id: 'long-fixtures',
        title: 'Fixtures enormes',
        body:
            'Crear datos amplios para que cada test parezca un caso real completo.',
      ),
    ],
    correctOptionId: 'deterministic-tests',
    successText:
        'La skill produce pruebas rapidas que fallan por razones utiles.',
    rewardXp: 40,
  ),
  WorldChallenge(
    id: 'instructions-output',
    worldId: MiniGameWorldId.instructions,
    level: 7,
    title: 'Prompt verificable',
    fileFocus: 'prompt base',
    story:
        'En el submundo de instrucciones, una frase vaga puede perder una mision entera. Aqui conviertes deseos en encargos comprobables.',
    mission:
        'Mejora instrucciones ambiguas para que la salida se pueda revisar.',
    prompt: 'Un prompt dice: "hazlo mejor". ¿Que version guia mejor al agente?',
    options: [
      ChallengeOption(
        id: 'goal-constraints-format',
        title: 'Objetivo y formato',
        body:
            'Indicar objetivo, restricciones, criterio de exito y formato de salida.',
      ),
      ChallengeOption(
        id: 'more-energy',
        title: 'Mas entusiasmo',
        body: 'Pedir que responda con mas energia y creatividad.',
      ),
      ChallengeOption(
        id: 'longer-answer',
        title: 'Respuesta larga',
        body: 'Exigir muchas palabras para cubrir cualquier posibilidad.',
      ),
    ],
    correctOptionId: 'goal-constraints-format',
    successText:
        'El agente sabe que hacer, como limitarse y como demostrar que termino.',
    rewardXp: 40,
  ),
  WorldChallenge(
    id: 'instructions-context',
    worldId: MiniGameWorldId.instructions,
    level: 8,
    title: 'Presupuesto de contexto',
    fileFocus: 'context window',
    story:
        'El camino se llena de notas, logs y decisiones. Para avanzar, reduces el equipaje a contexto que ayude al siguiente paso.',
    mission: 'Evita que el agente pierda precision por llevar demasiado ruido.',
    prompt:
        'Debes pasar contexto de una sesion larga a otra. ¿Que resumen es mas util?',
    options: [
      ChallengeOption(
        id: 'state-decisions-next',
        title: 'Estado accionable',
        body:
            'Objetivo, decisiones tomadas, archivos tocados, riesgos y siguiente paso.',
      ),
      ChallengeOption(
        id: 'full-transcript',
        title: 'Transcripcion total',
        body: 'Copiar cada mensaje para no perder matices.',
      ),
      ChallengeOption(
        id: 'vague-memory',
        title: 'Recuerdo vago',
        body: 'Decir que "casi todo estaba listo" y continuar.',
      ),
    ],
    correctOptionId: 'state-decisions-next',
    successText: 'El contexto queda compacto, recuperable y listo para actuar.',
    rewardXp: 40,
  ),
  WorldChallenge(
    id: 'instructions-hierarchy',
    worldId: MiniGameWorldId.instructions,
    level: 9,
    title: 'Jerarquia de instrucciones',
    fileFocus: 'instruction stack',
    story:
        'La ultima bandera prueba si el agente puede sostener prioridades cuando dos instrucciones tiran en direcciones opuestas.',
    mission: 'Haz que el agente resuelva conflictos sin mezclar prioridades.',
    prompt:
        'Una nota de usuario contradice una regla de seguridad del sistema. ¿Que debe hacer el agente?',
    options: [
      ChallengeOption(
        id: 'follow-hierarchy',
        title: 'Aplicar jerarquia',
        body:
            'Seguir la instruccion de mayor prioridad y explicar el limite cuando afecte la tarea.',
      ),
      ChallengeOption(
        id: 'latest-wins',
        title: 'Gana lo ultimo',
        body: 'Obedecer siempre el mensaje mas reciente.',
      ),
      ChallengeOption(
        id: 'average-rules',
        title: 'Promediar reglas',
        body: 'Combinar partes de ambas instrucciones aunque choquen.',
      ),
    ],
    correctOptionId: 'follow-hierarchy',
    successText:
        'El agente mantiene comportamiento consistente incluso con instrucciones en tension.',
    rewardXp: 40,
  ),
];
