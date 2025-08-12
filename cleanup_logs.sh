#!/usr/bin/env bash
# Datei: cleanup_logs.sh
# Beschreibung: Löscht Log-Verzeichnisse älter als X Tage aus logs/openai und logs/mixtral

set -euo pipefail

# --- Konfiguration ---
REPO_ROOT="$(git rev-parse --show-toplevel)"
LOG_DIRS=(
    "${REPO_ROOT}/logs/openai"
    "${REPO_ROOT}/logs/mixtral"
)

# --- Hilfe-Funktion ---
show_help() {
    cat <<EOF
Verwendung: $(basename "$0") [TAGE]

Löscht Unterverzeichnisse in den folgenden Log-Ordnern, die älter als die angegebene Anzahl von Tagen sind:
  - logs/openai
  - logs/mixtral

Argumente:
  TAGE     Anzahl der Tage, die behalten werden sollen (Standard: 30)
  -h, --help   Zeigt diese Hilfe an

Beispiele:
  $(basename "$0")        # Behalte die letzten 30 Tage, lösche ältere
  $(basename "$0") 7      # Behalte die letzten 7 Tage
EOF
}

# --- Argument-Parsing ---
KEEP_DAYS=30
if [[ $# -gt 0 ]]; then
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        ''|*[!0-9]*)
            echo " Fehler: Ungültige Anzahl von Tagen: $1" >&2
            echo "Verwende -h für Hilfe." >&2
            exit 1
            ;;
        *)
            KEEP_DAYS="$1"
            ;;
    esac
fi

echo "🧹 Log-Cleanup gestartet – behalte die letzten ${KEEP_DAYS} Tage"
echo "------------------------------------------------------------"

for dir in "${LOG_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        echo " Verarbeite: $dir"
        find "$dir" -mindepth 1 -maxdepth 1 -type d -mtime "+${KEEP_DAYS}" -exec rm -rf {} +
    else
        echo " Verzeichnis nicht gefunden: $dir"
    fi
done

echo "✅ Cleanup abgeschlossen."
