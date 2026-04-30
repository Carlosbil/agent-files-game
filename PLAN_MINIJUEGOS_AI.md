# Plan completo (corto, medio y largo plazo)
## App instalable de minijuegos para aprender Agentes, Skills, Hooks, instrucciones, memoria/contexto y coste de tokens

Relacionado: [[MAPA_PROYECTO]] · [[STEP_1_MINI_PLAN]] · [[ARQUITECTURA_PROYECTO]] · [[FUNCIONALIDAD_PROYECTO]] · [[COMO_LEVANTAR_PROYECTO]] · [[ESTILO_PROYECTO]] · [[AGENTS]]

> Objetivo: crear una app **instalable en Windows** y, si es viable, **multiplataforma (iOS/Android)** orientada a enseñar uso práctico de flujos tipo Copilot/Claude (agentes, skills, hooks, instrucciones), incluyendo buenas prácticas de contexto/memoria y eficiencia de tokens.

---

## Estado actual del proyecto

El proyecto ya tiene una base funcional, no parte de cero.

Ya construido:
- App Flutter en `app/` con nombre `cute_quests_ai`.
- Pantalla principal `HomePage` con progreso, XP, quests y logros.
- Tema visual inicial en `app/lib/core/app_theme.dart`.
- Estructura modular por features: `home`, `quests` y `achievements`.
- Datos demo de Fase 1 y Fase 2 en codigo.
- Documentacion operativa: arquitectura, como levantar el proyecto, estilo y funcionalidad.
- Sincronizacion de notas Markdown a Obsidian.
- Skill repo-local `obsidian-markdown` para crear y editar notas claras para Obsidian.

Todavia no construido:
- Minijuegos jugables reales.
- Estado interactivo para completar quests desde la app.
- Persistencia local de XP, logros y progreso.
- Motor comun de minijuegos y scoring.
- Telemetria real.
- Integracion con IA o backend.
- Build instalable Windows validada.

Implicacion para el plan: el siguiente paso no es crear la base, sino cerrar la fundacion y construir el primer minijuego jugable extremo a extremo.

---

## 1) Visión de producto

### Propuesta de valor
- Aprendizaje activo mediante minijuegos cortos (2–8 minutos).
- Simulación segura de escenarios reales de prompting y agentes.
- Métricas pedagógicas claras: precisión, coste de tokens, calidad del contexto, latencia y robustez.
- Progresión por niveles: principiante → intermedio → avanzado → “equipo/proyecto real”.

### Público objetivo
- Usuarios individuales que quieren mejorar uso de asistentes de IA.
- Equipos técnicos/no técnicos que necesitan buenas prácticas de contexto y costes.
- Formación corporativa (LMS, certificación interna, analítica de progreso).

### Resultado esperado del usuario
Al terminar, el usuario debe poder:
1. Diseñar instrucciones efectivas y delimitadas.
2. Gestionar memoria/contexto sin “contaminar” sesiones.
3. Optimizar coste de tokens manteniendo calidad.
4. Orquestar flujos básicos con agentes/skills/hooks.
5. Detectar riesgos (fugas de contexto, prompts ambiguos, sobrecoste).

---

## 2) Estrategia tecnológica recomendada

## Opción A (recomendada): **Flutter**
- **Ventajas**:
  - Un solo código para Windows, iOS y Android.
  - Excelente rendimiento en móvil y escritorio.
  - Entrega instalable nativa en Windows (MSIX/EXE) y paquetes móviles.
- **Contras**:
  - Curva inicial si el equipo viene de JS.

## Opción B: **React Native + Electron/Tauri**
- **Ventajas**:
  - Si el equipo domina JS/TS, mayor velocidad inicial.
- **Contras**:
  - Desktop y mobile con capas distintas; más fricción en mantenimiento.

## Opción C: **Unity**
- **Ventajas**:
  - Excelente para gamificación avanzada.
- **Contras**:
  - Sobredimensionado si el foco es aprendizaje textual y flujos IA.

### Recomendación final
- **MVP actual**: Flutter client-first, usando datos locales mientras se valida la experiencia jugable.
- **Backend**: posponer hasta que haya scoring, telemetria o sincronizacion que lo justifiquen.
- **Evolución**: mantener arquitectura desacoplada para cambiar proveedor LLM sin reescribir el juego.

---

## 3) Arquitectura funcional (alto nivel)

1. **Cliente (App)**
   - Motor de minijuegos.
   - Sistema de niveles, logros y feedback.
   - Editor guiado de prompts/instrucciones.
   - Panel de métricas por partida (tokens, coste, tiempo, calidad).

2. **Backend (API)**
   - Autenticación y perfiles.
   - Telemetría de aprendizaje.
   - Orquestación de partidas/simulaciones.
   - Motor de evaluación (rúbricas + heurísticas + tests automáticos).

3. **Capa IA (abstracción de proveedores)**
   - Adaptadores por proveedor/modelo (evita lock-in).
   - Cálculo unificado de tokens/coste.
   - Guardrails: filtros y validaciones de seguridad.

4. **Contenido (CMS ligero o repositorio versionado)**
   - Definición de misiones/minijuegos en JSON/YAML.
   - Versionado de escenarios (A/B testing).

---

## 4) Diseño pedagógico de minijuegos

## Tipos de minijuegos (ejemplos)
1. **Prompt Surgery**
   - Corregir prompts ambiguos.
   - KPI: mejora de precisión sin aumentar >X% tokens.

2. **Context Budget**
   - Elegir qué contexto incluir/excluir con límite de tokens.
   - KPI: ratio señal/ruido y coste por respuesta útil.

3. **Memory Manager**
   - Decidir qué va a memoria persistente vs temporal.
   - KPI: retención útil vs contaminación de memoria.

4. **Agent Pipeline Builder**
   - Conectar agente principal + skills + hooks por fases.
   - KPI: tasa de éxito del flujo y resiliencia ante fallos.

5. **Token Tycoon**
   - Simulación económica: presupuesto mensual y decisiones de modelo.
   - KPI: calidad media / coste total.

6. **Red Team / Safety**
   - Detectar filtraciones de secretos y prompt injection.
   - KPI: incidentes prevenidos.

## Progresión de dificultad
- Nivel 1: fundamentos (instrucciones claras y formato).
- Nivel 2: contexto y memoria.
- Nivel 3: agentes y herramientas.
- Nivel 4: costes y rendimiento.
- Nivel 5: seguridad + producción.

---

## 5) Roadmap por fases (corto, medio, largo plazo)

## Corto plazo (0–3 meses) — **MVP funcional**
### Objetivos
- Convertir la demo Flutter actual en un primer vertical slice jugable.
- Validar problema/solución y retención inicial con usuarios reales.
- Publicar primera versión instalable en Windows.

### Entregables
- Cierre de fundacion:
  - Estado interactivo de progreso.
  - Persistencia local de XP, logros y quests.
  - Contrato comun para minijuegos.
  - Navegacion desde Home hacia minijuegos.
- Primer minijuego extremo a extremo:
  - `Prompt Surgery v1` como candidato principal.
  - Pantalla de instrucciones.
  - Input del usuario.
  - Evaluacion inicial con reglas locales.
  - Score, XP y feedback pedagogico.
- Despues del primer vertical slice, ampliar a 4 minijuegos base:
  - Prompt Surgery
  - Context Budget
  - Memory Manager
  - Token Tycoon (versión simple)
- Sistema de usuario local basico.
- Métricas mínimas: tokens, coste estimado, tiempo, score.
- Empaquetado Windows (instalador).

### KPI de fase
- Activación (usuario completa tutorial): >50%.
- D7 retention: >20%.
- Tiempo medio sesión: >12 min.
- Coste IA por usuario activo: dentro de objetivo definido.

---

## Medio plazo (3–9 meses) — **Escalado y multiplataforma**
### Objetivos
- Lanzar en Android e iOS.
- Mejorar profundidad pedagógica y analítica.

### Entregables
- Port móvil completa + adaptaciones UX táctil.
- 6–10 minijuegos totales (incluyendo Agent Pipeline y Safety).
- Sistema de “campañas” por rol (dev, PM, soporte, educación).
- Backend de telemetría avanzada y dashboard de aprendizaje.
- A/B testing de contenidos y dificultad adaptativa.
- Integración opcional con LMS (SCORM/xAPI, si aplica negocio B2B).

### KPI de fase
- MAU en crecimiento sostenido.
- Retención D30 >10–15%.
- Mejora demostrable de score de usuarios recurrentes.
- Reducción de coste por sesión mediante optimizaciones.

---

## Largo plazo (9–24 meses) — **Plataforma y ecosistema**
### Objetivos
- Convertir app en plataforma formativa de referencia.
- Abrir marketplace/comunidad de escenarios.

### Entregables
- Editor de minijuegos para creadores (UGC moderado).
- Certificaciones por competencias (paths de aprendizaje).
- Modo equipo/empresa con analítica por cohortes.
- Simulaciones avanzadas multiagente con evaluación automática.
- Localización a múltiples idiomas.
- Marketplace de packs temáticos (educación, ventas, legal, coding).

### KPI de fase
- NPS > 40.
- Ingresos recurrentes (si modelo SaaS).
- Ratio de finalización de rutas >35%.
- Conversión B2B y expansión por cuentas.

---

## 6) Plan de implementación técnica (detallado)

## Fase 0 — Descubrimiento (2–4 semanas)
- Estado: parcialmente cubierta por el plan, la demo Flutter y la documentacion actual.
- Pendiente:
  - Investigacion usuarios (entrevistas + encuesta).
  - Definir 8–12 jobs-to-be-done.
  - Priorizar contenidos de mayor impacto (matriz valor/esfuerzo).
  - Especificar en papel los 4 minijuegos MVP.
  - Usar la demo actual como prototipo navegable inicial.

## Fase 1 — Fundación (4–6 semanas)
- Estado: iniciada.
- Ya existe app Flutter, estructura modular, tema visual, Home demo y documentacion base.
- Cerrar fundacion con:
  - Estado local para progreso.
  - Persistencia local.
  - Navegacion preparada para minijuegos.
  - Contrato de minijuego: entrada, reglas, scoring, feedback y recompensa.
  - Quality gates minimos: `flutter analyze` y `flutter test`.
- Módulos core:
  - Perfil de progreso local
  - Catálogo de minijuegos
  - Motor de puntuación local
  - Registro local de partidas
- Módulos aplazados:
  - Auth
  - Backend
  - Capa IA real
- Instrumentación analítica desde día 1, empezando local y preparada para backend.

## Fase 2 — MVP jugable (6–8 semanas)
- Implementar primero `Prompt Surgery v1` de extremo a extremo.
- Validar que completar un minijuego actualiza XP, logros y estado de quest.
- Despues implementar:
  - `Context Budget v1`
  - `Memory Manager v1`
  - `Token Tycoon v1`
- Sistema de feedback inmediato y explicación pedagógica.
- Pruebas de usabilidad con 5–10 usuarios al cerrar el primer minijuego.
- Pruebas de usabilidad con 20–30 usuarios al cerrar los 4 minijuegos.
- Iteración rápida quincenal.

## Fase 3 — Multiplataforma y monetización (8–12 semanas)
- Build y publicación Android/iOS.
- Cuenta cloud + sincronización de progreso.
- Modelo de negocio inicial (freemium / suscripción / licencias).

---

## 6.1) Proximo vertical slice recomendado

El primer vertical slice deberia ser `Prompt Surgery v1`, porque conecta directamente con el objetivo pedagogico y no necesita backend para una primera version.

Alcance minimo:
- Lista de 3 prompts problematicos.
- Objetivo claro para cada prompt.
- Campo para que el usuario proponga una version mejorada.
- Reglas locales de evaluacion:
  - Claridad de objetivo.
  - Restricciones explicitas.
  - Formato de salida pedido.
  - Evitar contexto innecesario.
- Score final.
- XP ganada.
- Feedback corto y accionable.
- Actualizacion de progreso en Home.

Queda fuera de la primera version:
- Evaluacion con IA.
- Ranking online.
- Login.
- Sincronizacion cloud.
- Tienda o monetizacion.

---

## 7) Diseño de datos y métricas

## Eventos clave
- `session_start`, `session_end`
- `minigame_started`, `minigame_completed`
- `prompt_submitted`, `prompt_refined`
- `tokens_input`, `tokens_output`, `cost_estimated`
- `context_overflow_detected`
- `memory_item_saved`, `memory_item_evicted`

## Métricas de aprendizaje
- Accuracy por competencia.
- Tiempo a primera solución correcta.
- Iteraciones hasta solución aceptable.
- Calidad/coste (score ponderado).

## Métricas de negocio
- CAC, LTV (si hay adquisición pagada).
- Conversión free → pro.
- Churn mensual.

---

## 8) Seguridad, privacidad y cumplimiento

- Minimizar datos personales (privacy by design).
- Cifrado en tránsito y reposo.
- Políticas claras de retención de prompts y logs.
- Anonimización para analítica de aprendizaje.
- Controles parentales si apuntas a menores.
- Revisión legal para tiendas (Apple/Google/Microsoft).

---

## 9) Equipo recomendado

## Etapa MVP
- 1 Product Manager / Learning Designer.
- 1 dev cliente Flutter.
- 1 dev backend solo cuando entren login, sincronizacion cloud o telemetria real.
- 1 diseñador UX/UI (part-time).
- 1 QA (part-time/automatización).

## Escalado
- +1 dev mobile/cliente.
- +1 data/analytics engineer.
- +1 content designer (gamificación).

---

## 10) Riesgos y mitigaciones

1. **Riesgo:** coste de API de IA elevado.
   - Mitigación: caché, truncado inteligente, modelos por tier, simulaciones offline parciales.

2. **Riesgo:** dependencia de un proveedor.
   - Mitigación: capa de abstracción + contratos de entrada/salida.

3. **Riesgo:** baja retención.
   - Mitigación: sesiones cortas, feedback claro, recompensas, rutas personalizadas.

4. **Riesgo:** complejidad de publicación móvil.
   - Mitigación: pipeline de release temprano, beta cerrada por plataforma.

---

## 11) Modelo de negocio (opciones)

- **Freemium**: 4 minijuegos gratis, rutas avanzadas premium.
- **Suscripción individual**: mensual/anual.
- **B2B**: licencia por asiento + panel administrador.
- **Marketplace**: venta de packs de escenarios de terceros (revenue share).

---

## 12) Backlog inicial priorizado (primeros 90 días)

1. Convertir Home demo en Home interactiva.
2. Persistir progreso local: XP, quests completadas y logros.
3. Definir contrato comun de minijuego.
4. Implementar `Prompt Surgery v1` de extremo a extremo.
5. Conectar recompensa de `Prompt Surgery v1` con Home.
6. Agregar `flutter analyze` y `flutter test` como verificacion minima.
7. Implementar `Context Budget v1`.
8. Implementar `Memory Manager v1`.
9. Implementar `Token Tycoon v1` simple.
10. Crear build instalable Windows.
11. Agregar telemetria local o mockeada.
12. Test con cohorte piloto pequena (5–10 usuarios) antes de ampliar a 20–50.

---

## 13) Plan de entregas (hitos)

- **Hito 0 (hecho):** base Flutter + Home demo + documentacion + sincronizacion Obsidian.
- **Hito 1 (siguiente):** Home interactiva + persistencia local + contrato de minijuegos.
- **Hito 2 (Semana 2–4):** `Prompt Surgery v1` jugable extremo a extremo.
- **Hito 3 (Semana 6–8):** 4 minijuegos + analítica local/mockeada + beta Windows.
- **Hito 4 (Semana 14–18):** iteración por feedback + preparación Android.
- **Hito 5 (Semana 20+):** salida Android/iOS + growth loops.

---

## 14) Recomendación práctica para empezar mañana

1. Cerrar `STEP_1_MINI_PLAN`: confirmar que la base Flutter arranca y que Obsidian recibe las notas.
2. Definir el contrato comun de minijuego en codigo.
3. Convertir las quests demo en estado interactivo.
4. Construir `Prompt Surgery v1` como vertical slice completo.
5. Medir uso real y ajustar antes de escalar contenido.

---

## 15) Formato de instalación y distribución

- **Windows**: instalador firmado (MSIX o EXE).
- **Android**: Play Internal Testing → Closed Testing → Producción.
- **iOS**: TestFlight → App Store.
- Actualizaciones in-app y versionado semántico.

---

## 16) Definición de éxito (12 meses)

- Producto estable en Windows, Android e iOS.
- Biblioteca de 12+ minijuegos.
- Retención D30 sostenible.
- Unidad económica controlada (coste/token por usuario objetivo).
- Evidencia de mejora de competencias en usuarios activos.

