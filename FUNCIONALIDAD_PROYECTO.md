# Funcionalidad del proyecto

Relacionado: [[MAPA_PROYECTO]] - [[PLAN_MINIJUEGOS_AI]] - [[ARQUITECTURA_PROYECTO]]

## Objetivo del producto

El producto busca ser una app instalable de minijuegos para aprender a usar flujos de IA: agentes, skills, hooks, instrucciones, memoria, contexto y coste de tokens.

El enfoque es aprender haciendo, con sesiones cortas, feedback inmediato y metricas que ayuden al usuario a mejorar su criterio.

## Funcionalidad implementada ahora

La app actual es una demo base Flutter con una pantalla principal.

Incluye:
- Titulo de app `Cute Quests AI`.
- Banner de progreso con nivel, XP acumulada, barra de progreso y siguiente premio.
- Lista de quests agrupadas por fases mediante datos demo.
- Estado de quest completada o pendiente.
- Recompensa de XP por quest.
- Lista de logros bloqueados y desbloqueados.

## Quests demo actuales

Fase 1:
- `Setup de Heroina`: crea perfil y termina onboarding interactivo.
- `Mapa de Minijuegos`: revisa catalogo inicial y marca 4 minijuegos MVP.

Fase 2:
- `Prompt Surgery v1`: resolver prompts ambiguos sin pasarse de presupuesto.
- `Context Budget v1`: elegir contexto util con limite de tokens.
- `Memory Manager v1`: guardar solo memoria util y evitar contaminacion.

## Logros demo actuales

- `Inicio Estelar`: desbloqueado.
- `Cirujana de Prompts`: bloqueado.
- `Guardiana de Tokens`: bloqueado.

## Logica actual

La logica implementada es simple:

1. Se cargan quests estaticas desde `quest.dart`.
2. Se juntan quests de Fase 1 y Fase 2.
3. Se suman los XP de quests completadas.
4. Se renderiza el progreso y las listas en `HomePage`.

No hay interaccion real de completar quests en runtime. El estado `completed` esta fijado en codigo.

## Funcionalidad planificada para el MVP

Segun el plan del proyecto, el MVP deberia incluir:
- Onboarding/tutorial.
- Al menos 4 minijuegos iniciales.
- Sistema de feedback inmediato.
- Explicacion pedagogica de resultados.
- Progreso de jugador.
- Logros y recompensas.
- Metricas basicas por partida.

Minijuegos candidatos:
- `Prompt Surgery`
- `Context Budget`
- `Memory Manager`
- `Agent Pipeline Builder`
- `Token Tycoon`
- `Red Team / Safety`

## Metricas esperadas

Eventos clave previstos:
- `session_start`
- `session_end`
- `minigame_started`
- `minigame_completed`
- `prompt_submitted`
- `prompt_refined`
- `tokens_input`
- `tokens_output`
- `cost_estimated`
- `context_overflow_detected`
- `memory_item_saved`
- `memory_item_evicted`

Metricas de aprendizaje:
- Precision por competencia.
- Tiempo hasta primera solucion correcta.
- Iteraciones hasta solucion aceptable.
- Relacion calidad/coste.

## Pendientes funcionales

- Convertir quests demo en progreso interactivo.
- Definir un contrato comun para minijuegos.
- Persistir XP, logros y estado de quests.
- Implementar minijuegos reales.
- Agregar evaluacion de respuestas.
- Agregar telemetria.
- Preparar integracion futura con una capa IA desacoplada.
- Crear builds instalables, empezando por Windows.
