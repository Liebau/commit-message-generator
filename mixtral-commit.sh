#!/usr/bin/env bash
#set -euo pipefail


# --- Verzeichnisse & Zeitstempel ---
REPO_ROOT="$(git rev-parse --show-toplevel)"
LOG_ROOT="${REPO_ROOT}/logs/mixtral"
TS="$(date '+%Y-%m-%d_%H-%M-%S')"
RUN_DIR="${LOG_ROOT}/${TS}"
mkdir -p "${RUN_DIR}"

OUTFILE="${RUN_DIR}/commit_message.txt"
LATEST_LINK="${LOG_ROOT}/latest"


# 1) Git-Diff einlesen (nur gestagte Änderungen oder gesamten Diff, je nach Bedarf)
DIFF=$(git diff --cached --unified=0)



if [[ -z "$DIFF" ]]; then
  echo "Keine gestageten Änderungen gefunden."
  exit 0
fi



# 2) System-Prompt mit deinem ASCII-Gerüst
read -r -d '' SYSTEM_PROMPT <<'EOF'
Du bist ein Git-Experte und Commit-Message-Generator. Antworte auf **Deutsch** und
erzeuge **ausschließlich** eine Commit-Message im exakt folgenden ASCII-Format:

===========================================================
Commit: <Kurztitel des Commits – funktional und prägnant>
===========================================================

CONTEXT:
---------
- <Kompakte Aufzählung der übergeordneten Änderungen, Absicht, Motivation>
- <Was wurde verbessert, abstrahiert, entfernt oder robuster gemacht?>

------------------------------------------------------------
FILE: <Pfad/zur/Datei.cpp>
METHOD/CLASS: <Name> (optional)
------------------------------------------------------------
- [Add] ...     
- [Mod] ...     
- [Del] ...     
- [Refactor] ...
- [Clean] ...
EOF



# 3) User-Prompt mit dem Diff
#USER_PROMPT="Analysiere bitte diesen Git-Diff und gib die Commit-Message **nur** im oben vorgegebenen ASCII-Format auf deutsch zurück. Diff: \n\n $DIFF" 

USER_PROMPT=$'Analysiere bitte diesen Git-Diff und gib **ausschließlich** die Commit-Message im oben vorgegebenen ASCII-Format auf deutsch zurück. \
Gib den Diff-Text oder andere zusätzliche Informationen nicht aus.\n\nDiff:\n'"$DIFF"



# 4) Voller Prompt (System + User) zusammenführen
FULL_PROMPT="${SYSTEM_PROMPT}   
git diff:  ${USER_PROMPT}"

echo -e "$FULL_PROMPT" > "${RUN_DIR}/full_prompt.txt"



# 6) Mixtral aufrufen und Ausgabe in OUTFILE schreiben
#    Prompt über stdin geben, da --prompt-Flag bei 'run' nicht unterstützt wird
echo -e "$FULL_PROMPT" | ollama run mixtral:8x7b > "$OUTFILE"

echo "Commit-Message wurde in $OUTFILE geschrieben. Bitte prüfen und dann manuell committen."

# 7) Symlinks aktualisieren
( cd "$LOG_ROOT" && ln -sfn "$TS" latest )
ln -sfn "./logs/mixtral/latest/commit_message.txt" "${REPO_ROOT}/latest-Commit-MSG-mixtral.txt"



# 8) Ausgabeinfo
echo "→ Commit-Message gespeichert: ${OUTFILE}"
echo "→ Schnellzugriff im Repo: latest-Commit-MSG-mixtral.txt"


