# Mini plan - Step 1

Relacionado: [[MAPA_PROYECTO]] · [[PLAN_MINIJUEGOS_AI]] · [[ARQUITECTURA_PROYECTO]] · [[FUNCIONALIDAD_PROYECTO]]

## Step 1: Crear la base del proyecto

- [x] Definir el objetivo minimo jugable.
- [x] Elegir Flutter como tecnologia base.
- [x] Crear estructura inicial de carpetas.
- [x] Crear el primer prototipo funcional.
- [x] Documentar arquitectura, arranque, estilo y funcionalidad.
- [x] Crear skill `obsidian-markdown` para notas claras en Obsidian.
- [x] Verificar que las notas del proyecto se reflejan en Obsidian.

## Lo que ya existe

La base actual ya permite ver la direccion del producto:

- App Flutter en `app/`.
- Pantalla principal con progreso, XP, quests y logros.
- Tema visual cute/colorido.
- Quests demo de Fase 1 y Fase 2.
- Logros demo.
- Documentacion enlazada para Obsidian.

## Lo que falta para cerrar Step 1

Step 1 queda practicamente cerrado. Solo falta una comprobacion tecnica final:

- Ejecutar `flutter pub get`.
- Ejecutar `flutter analyze`.
- Ejecutar `flutter test`.
- Confirmar que `flutter run` abre la demo en un dispositivo disponible.

## Step 2 recomendado: primer minijuego jugable

El siguiente paso ya no es crear base, sino convertir la demo en juego.

Prioridad:

1. Definir contrato comun de minijuego.
2. Persistir XP, quests completadas y logros.
3. Crear navegacion desde Home hacia minijuegos.
4. Implementar `Prompt Surgery v1`.
5. Hacer que completar `Prompt Surgery v1` actualice Home.

Resultado esperado:

- El usuario entra desde Home.
- Juega una ronda corta.
- Recibe score, XP y feedback.
- Vuelve a Home y ve su progreso actualizado.
