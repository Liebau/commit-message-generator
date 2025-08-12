#!/usr/bin/env bash
#set -euo pipefail

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
USER_PROMPT="Analysiere bitte diesen Git-Diff und gib die Commit-Message **nur** im oben vorgegebenen ASCII-Format auf deutsch zurück. Diff: \n\n $DIFF" 




# 4) Voller Prompt (System + User) zusammenführen
FULL_PROMPT="${SYSTEM_PROMPT}   
git diff:  ${USER_PROMPT}"

echo "$FULL_PROMPT" > mixtral_full_prompt.txt 



# 5) Ausgabedatei festlegen
OUTFILE="mixtral_commit_message.txt"

# 6) Mixtral aufrufen und Ausgabe in OUTFILE schreiben
#    Prompt über stdin geben, da --prompt-Flag bei 'run' nicht unterstützt wird
echo -e "$FULL_PROMPT" | ollama run mixtral:8x7b > "$OUTFILE"

echo "Commit-Message wurde in $OUTFILE geschrieben. Bitte prüfen und dann manuell committen."


