# Como levantar el proyecto

Relacionado: [[MAPA_PROYECTO]] - [[PLAN_MINIJUEGOS_AI]] - [[ARQUITECTURA_PROYECTO]]

## Resumen

La aplicacion esta en `app/` y es un proyecto Flutter. Para levantarla necesitas Flutter instalado y despues ejecutar los comandos desde esa carpeta.

El repositorio incluye un script pensado para entornos Linux o contenedores: `scripts/install.sh`. En Windows, lo mas directo es instalar Flutter manualmente y usar `flutter` desde PowerShell.

## Requisitos

- Flutter SDK compatible con Dart `>=3.3.0 <4.0.0`.
- Git.
- Un destino de ejecucion Flutter:
  - Windows desktop.
  - Android emulator o dispositivo.
  - iOS si se trabaja desde macOS.
  - Chrome/web si Flutter web esta habilitado.

## Levantar en Windows

Desde la raiz del repositorio:

```powershell
cd .\app
flutter pub get
flutter run
```

Para comprobar el entorno:

```powershell
flutter doctor -v
```

Para listar dispositivos disponibles:

```powershell
flutter devices
```

Si hay varios dispositivos, elige uno con:

```powershell
flutter run -d windows
```

## Levantar en Linux o dev container

Desde la raiz del repositorio:

```bash
bash scripts/install.sh
```

El script:
- Instala dependencias de sistema si detecta `apt-get`, `dnf` o `pacman`.
- Descarga Flutter estable en `$HOME/flutter`, salvo que se defina `FLUTTER_DIR`.
- Ejecuta `flutter pub get` dentro de `app/`.

Variables opcionales:

```bash
export FLUTTER_DIR="$HOME/flutter"
export FLUTTER_VERSION="stable"
```

Despues:

```bash
cd app
flutter run
```

## Comandos utiles

Instalar dependencias:

```powershell
cd .\app
flutter pub get
```

Analizar codigo:

```powershell
cd .\app
flutter analyze
```

Ejecutar tests:

```powershell
cd .\app
flutter test
```

Ejecutar la app:

```powershell
cd .\app
flutter run
```

## Archivos importantes

- `app/pubspec.yaml`: dependencias, version y configuracion Flutter.
- `app/lib/main.dart`: punto de entrada de la app.
- `app/lib/core/app_theme.dart`: tema visual.
- `app/lib/features/home/home_page.dart`: pantalla principal.
- `scripts/install.sh`: instalador para Linux/dev container.
- `scripts/Sync-MarkdownToObsidian.ps1`: sincronizacion de notas Markdown hacia el mirror de Obsidian.

## Sincronizacion con Obsidian

Cuando se creen o modifiquen notas `.md`, hay que sincronizarlas con:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Sync-MarkdownToObsidian.ps1
```

Si solo cambio una nota:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Sync-MarkdownToObsidian.ps1 -Path .\COMO_LEVANTAR_PROYECTO.md
```

El mirror configurado es `D:\test\agent-files-game`.

## Estado actual

El proyecto deberia arrancar como una app demo con:
- Banner de progreso.
- XP acumulada.
- Lista de quests de Fase 1 y Fase 2.
- Logros bloqueados y desbloqueados.

Si Flutter no esta instalado o no aparece ningun dispositivo, `flutter doctor -v` es el primer diagnostico.
