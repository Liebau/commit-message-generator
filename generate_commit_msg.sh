#!/usr/bin/env bash
# Datei: generate_commit_msg.sh
# Beschreibung: Manuelle Erzeugung einer Git-Commit-Message via GPT-4.1-mini OpenAI-API


# --- Logging-Verzeichnis vorbereiten ---
LOG_ROOT="logs/openai"
TS="$(date '+%Y-%m-%d_%H-%M-%S')"
RUN_DIR="${LOG_ROOT}/${TS}"
mkdir -p "${RUN_DIR}"

PAYLOAD="${RUN_DIR}/payload.json"
RESPONSE="${RUN_DIR}/response.json"
COMMIT_TXT="${RUN_DIR}/commit_message.txt"

LATEST_LINK="${LOG_ROOT}/latest" # Symlink auf letzten Lauf


# 1) Diff der gestageten Änderungen in Variable speichern
DIFF=$(git diff --cached --unified=0)

if [[ -z "$DIFF" ]]; then
  echo "Keine gestageten Änderungen gefunden."
  exit 0
fi


# 2) System-Prompt als Here-Doc mit deinem Format-Skelett
read -r -d '' SYSTEM_PROMPT <<'EOF'
Du bist ein Git-Experte und Commit-Message-Generator.
Erzeuge auf deutsch **ausschließlich** eine Commit-Message im exakt folgenden ASCII-Format:

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


# 3) Payload mit j
# mit jq alles korrekt escapen und in payload.json schreiben
jq -n \
  --arg model  "gpt-4.1-mini" \
  --arg system "$SYSTEM_PROMPT" \
  --arg user   "Analysiere bitte diesen Git-Diff und gib die Commit-Message **nur** im oben vorgegebenen ASCII-Format zurück.\n\nDiff:\n$DIFF" \
  --argjson max 500 \
  --argjson temp 0.2 \
  '{
     model: $model,
     messages: [
       { role:"system", content: $system },
       { role:"user",   content: $user   }
     ],
     max_tokens: $max,
     temperature: $temp
   }' > "${PAYLOAD}"



# und dann
curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d  @"${PAYLOAD}" \
  > "${RESPONSE}"



echo "→ Volle API-Antwort gespeichert: ${RESPONSE}"

# 5) Commit-Text extrahieren
jq -r '.choices[0].message.content' "${RESPONSE}" > "${COMMIT_TXT}"
echo "→ Commit-Text gespeichert: ${COMMIT_TXT}"

# 6) Symlink auf letzten Lauf aktualisieren

( cd "$LOG_ROOT" && ln -sfn "$TS" latest )
echo "→ Symlink aktualisiert: ${LOG_ROOT}/latest -> $(readlink "${LOG_ROOT}/latest")"
echo "   (resolves to $(readlink -f "${LOG_ROOT}/latest"))"
