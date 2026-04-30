# Demo base Flutter - Cute Quests AI

Este demo implementa una base visual para **Fase 1 (Fundación)** y **Fase 2 (MVP jugable)** del plan.

## Incluye
- Tema cute/colorido con identidad visual inicial.
- Pantalla Home con:
  - Progreso de jugador (XP/Nivel).
  - Quests de Fase 1 y Fase 2.
  - Logros bloqueados/desbloqueados.
- Juegos iniciales de Fase 1:
  - `Setup de Campeón`, para crear perfil y cerrar onboarding.
  - `Mapa de Minijuegos`, para escoger los 4 minijuegos MVP.
- Estructura modular para crecer hacia minijuegos.

## Instalación en este entorno (Linux)
Desde la raíz del repo:

```bash
bash scripts/install.sh
```

El script:
1. Instala dependencias del sistema (apt/dnf/pacman si detecta).
2. Descarga Flutter estable en `$HOME/flutter` (o `FLUTTER_DIR`).
3. Ejecuta `flutter pub get` dentro de `app/`.

Variables opcionales:
- `FLUTTER_DIR` (ruta de instalación del SDK)
- `FLUTTER_VERSION` (rama/tag de Flutter, por defecto `stable`)

## Próximos pasos sugeridos
1. Añadir estado global (Riverpod/Bloc).
2. Persistencia local de progreso.
3. Implementar minijuegos reales (`Prompt Surgery`, `Context Budget`, `Memory Manager`).
4. Telemetría base (`session_start`, `minigame_completed`, etc.).
