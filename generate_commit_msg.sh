#!/usr/bin/env bash
# Datei: generate_commit_msg.sh
# Beschreibung: Manuelle Erzeugung einer Git-Commit-Message via GPT-4.1-mini OpenAI-API

# 1) Diff der gestageten Änderungen in Variable speichern
DIFF=$(git diff --cached --unified=0)

if [[ -z "$DIFF" ]]; then
  echo "Keine gestageten Änderungen gefunden."
  exit 0
fi


# 2) System-Prompt als Here-Doc mit deinem Format-Skelett
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
   }' > payload.json



# und dann
curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d @payload.json \
  > response.json



echo "→ Volle API-Antwort in response.json gespeichert."

# 4) Nur den generierten Commit-Text extrahieren und in Datei schreiben
jq -r '.choices[0].message.content' response.json > commit_message.txt

echo "→ Commit-Text in commit_message.txt gespeichert."
