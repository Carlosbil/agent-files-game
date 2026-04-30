# Arquitectura del proyecto

Relacionado: [[MAPA_PROYECTO]] - [[PLAN_MINIJUEGOS_AI]] - [[STEP_1_MINI_PLAN]]

## Resumen

El proyecto actual es un prototipo Flutter llamado `cute_quests_ai`. La raiz del repositorio contiene la documentacion y scripts de apoyo, mientras que la aplicacion vive dentro de `app/`.

La arquitectura implementada ahora es cliente-only: no hay backend, base de datos, autenticacion ni capa IA conectada todavia. El codigo muestra una base visual y de navegacion para el futuro sistema de minijuegos, progreso, quests y logros.

## Estructura actual

```text
.
|-- AGENTS.md
|-- MAPA_PROYECTO.md
|-- PLAN_MINIJUEGOS_AI.md
|-- STEP_1_MINI_PLAN.md
|-- scripts/
|   |-- Sync-MarkdownToObsidian.ps1
|   `-- install.sh
`-- app/
    |-- README.md
    |-- pubspec.yaml
    `-- lib/
        |-- main.dart
        |-- core/
        |   `-- app_theme.dart
        `-- features/
            |-- achievements/
            |   `-- achievement.dart
            |-- home/
            |   `-- home_page.dart
            `-- quests/
                `-- quest.dart
```

## Capas de la app Flutter

### Entrada de aplicacion

`app/lib/main.dart` define `CuteQuestsApp`, configura `MaterialApp`, aplica el tema global y monta `HomePage` como pantalla inicial.

Responsabilidades actuales:
- Inicializar la app.
- Definir el titulo `Cute Quests AI`.
- Ocultar el banner de debug.
- Aplicar `AppTheme.light`.

### Core

`app/lib/core/app_theme.dart` centraliza la identidad visual inicial.

Responsabilidades actuales:
- Definir colores base.
- Configurar `ColorScheme`.
- Configurar tema de `AppBar`.
- Configurar tema de tarjetas.

### Features

La carpeta `app/lib/features/` separa dominios funcionales.

`home/`
- Contiene la pantalla principal.
- Combina quests de varias fases.
- Calcula XP acumulada.
- Renderiza progreso, lista de quests y logros.

`quests/`
- Define el modelo `Quest`.
- Contiene datos demo de Fase 1 y Fase 2.

`achievements/`
- Define el modelo `Achievement`.
- Contiene logros demo bloqueados y desbloqueados.

## Flujo de datos actual

Los datos son estaticos y viven en memoria:

1. `HomePage` importa `phaseOneQuests`, `phaseTwoQuests` y `demoAchievements`.
2. Junta las quests en una lista local.
3. Calcula `totalXp` sumando solo las quests completadas.
4. Renderiza la UI con widgets privados: `_ProgressBanner` y `_QuestTile`.

No existe persistencia local. Al abrir la app, el progreso siempre sale de los datos declarados en codigo.

## Arquitectura prevista

El plan del proyecto plantea evolucionar hacia cuatro bloques:

1. Cliente Flutter con motor de minijuegos, niveles, logros, feedback y metricas.
2. Backend API para perfiles, autenticacion, telemetria y evaluacion.
3. Capa IA con adaptadores por proveedor/modelo, calculo de tokens/coste y guardrails.
4. Contenido versionado para misiones y escenarios en JSON/YAML.

## Decisiones actuales

- Flutter es la tecnologia base recomendada y ya adoptada.
- La estructura modular por `features` permite crecer sin concentrar toda la app en `main.dart`.
- Los modelos son simples, inmutables y sin dependencias externas.
- El prototipo prioriza claridad visual y demostracion de flujo antes que persistencia o logica real de minijuegos.

## Proximos puntos arquitectonicos

- Introducir estado global cuando las quests dejen de ser datos estaticos.
- Agregar persistencia local de progreso.
- Separar datos demo de datos reales versionados.
- Definir contratos para minijuegos.
- Preparar una capa de servicios para telemetria y evaluacion.
- Mantener la capa IA desacoplada para evitar dependencia de un proveedor concreto.
