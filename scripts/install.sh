#!/usr/bin/env bash
set -euo pipefail

# Instalador para entorno Linux (CI/dev container)
# - Instala dependencias del sistema
# - Descarga Flutter SDK estable
# - Ejecuta flutter pub get para el proyecto demo

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/app"
FLUTTER_DIR="${FLUTTER_DIR:-$HOME/flutter}"
FLUTTER_VERSION="${FLUTTER_VERSION:-stable}"

log() {
  echo "[install] $*"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Error: falta el comando '$1'." >&2
    exit 1
  }
}

install_system_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    log "Instalando paquetes del sistema con apt-get..."
    sudo apt-get update
    sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa ca-certificates
  elif command -v dnf >/dev/null 2>&1; then
    log "Instalando paquetes del sistema con dnf..."
    sudo dnf install -y curl git unzip xz zip mesa-libGLU ca-certificates
  elif command -v pacman >/dev/null 2>&1; then
    log "Instalando paquetes del sistema con pacman..."
    sudo pacman -Sy --noconfirm curl git unzip xz zip glu ca-certificates
  else
    log "No se detectó gestor compatible automáticamente. Instala manualmente: curl git unzip xz zip libGLU."
  fi
}

install_flutter() {
  if [[ -x "$FLUTTER_DIR/bin/flutter" ]]; then
    log "Flutter ya existe en $FLUTTER_DIR"
  else
    log "Clonando Flutter ($FLUTTER_VERSION) en $FLUTTER_DIR..."
    git clone https://github.com/flutter/flutter.git -b "$FLUTTER_VERSION" "$FLUTTER_DIR"
  fi

  export PATH="$FLUTTER_DIR/bin:$PATH"

  log "Precache de Flutter..."
  flutter precache

  log "Aceptando licencias de Android (si aplica)..."
  flutter doctor --android-licenses || true

  log "Diagnóstico Flutter..."
  flutter doctor -v
}

install_project_deps() {
  require_cmd git
  require_cmd curl

  if [[ ! -f "$APP_DIR/pubspec.yaml" ]]; then
    echo "Error: no se encontró $APP_DIR/pubspec.yaml" >&2
    exit 1
  fi

  export PATH="$FLUTTER_DIR/bin:$PATH"
  log "Instalando dependencias Dart/Flutter del proyecto..."
  (cd "$APP_DIR" && flutter pub get)

  log "Listo. Para usar Flutter en esta terminal:"
  echo "export PATH=\"$FLUTTER_DIR/bin:\$PATH\""
  echo "cd $APP_DIR && flutter run"
}

main() {
  install_system_packages
  install_flutter
  install_project_deps
}

main "$@"
