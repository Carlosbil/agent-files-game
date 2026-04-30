# Estilo del proyecto

Relacionado: [[MAPA_PROYECTO]] - [[PLAN_MINIJUEGOS_AI]] - [[ARQUITECTURA_PROYECTO]]

## Identidad visual

El estilo actual apunta a una experiencia cute, clara y gamificada. La pantalla inicial usa colores vivos, progreso visible, tarjetas simples y recompensas tipo XP/logros.

La app se llama `Cute Quests AI`, asi que el tono visual debe sentirse:
- Accesible.
- Optimista.
- Ligero.
- Orientado a aprendizaje.
- Con sensacion de juego sin perder legibilidad.

## Paleta actual

La paleta esta definida en `app/lib/core/app_theme.dart`.

Colores principales:

```text
Pink:   #FF6FB5
Purple: #7C4DFF
Mint:   #7AE7C7
Fondo:  #FFF8FD
```

Uso actual:
- Rosa como color semilla y primario.
- Menta como secundario.
- Morado para textos destacados y `AppBar`.
- Fondo muy claro para mantener una UI suave.
- Gradiente rosa/morado en el banner de progreso.

## Componentes visuales actuales

### AppBar

- Centrada.
- Fondo transparente.
- Texto morado.
- Titulo actual: `Cute Quests AI`.

### Banner de progreso

- Contenedor con gradiente.
- Bordes redondeados.
- Muestra nivel, XP, barra de progreso y siguiente premio.
- Es el bloque principal de feedback motivacional.

### Quest cards

- Tarjetas blancas sin elevacion.
- Bordes redondeados.
- Icono de estado en `CircleAvatar`.
- Texto principal para titulo.
- Subtitulo con fase y descripcion.
- XP como recompensa a la derecha.

### Logros

- Chips compactos.
- Muestran icono, nombre y estado bloqueado/desbloqueado.

## Tono de interfaz

El texto debe ser breve, concreto y motivador. Conviene evitar explicaciones largas dentro de la pantalla principal.

Patron recomendado:
- Accion o estado primero.
- Recompensa clara.
- Feedback inmediato.
- Lenguaje humano, no administrativo.

Ejemplos alineados:
- `Setup de Campeón`
- `Mapa de Minijuegos`
- `Prompt Surgery v1`
- `Context Budget v1`
- `Memory Manager v1`

## Reglas de UI para evolucionar

- Mantener contraste suficiente en texto sobre gradientes.
- Evitar saturar la pantalla con demasiados colores a la vez.
- Usar tarjetas para elementos repetidos, no para envolver secciones enteras.
- Mantener quests escaneables: titulo, fase, descripcion corta y XP.
- Priorizar feedback visible sobre explicaciones teoricas largas.
- Separar estilos globales en `AppTheme` antes de duplicar colores por pantalla.

## Estilo de codigo

El proyecto usa Dart/Flutter con `flutter_lints`.

Convenciones visibles:
- Widgets `StatelessWidget` para pantallas sin estado mutable.
- Modelos inmutables con constructores `const`.
- Datos demo como listas `final`.
- Widgets internos privados con prefijo `_` cuando solo pertenecen a una pantalla.
- Separacion por feature en `app/lib/features/`.

## Criterio para nuevos minijuegos

Cada minijuego deberia mantener la misma claridad:
- Objetivo visible.
- Presupuesto o restriccion visible si aplica.
- Accion principal facil de entender.
- Resultado con puntuacion, XP y explicacion pedagogica.
- Metricas conectadas al aprendizaje: precision, coste, tokens, calidad del contexto y tiempo.
