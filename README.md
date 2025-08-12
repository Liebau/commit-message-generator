# Commit-Message Automation

Dieses Repository enthält Skripte zur automatisierten Erstellung von Git-Commit-Messages
mithilfe von **OpenAI** und **Mixtral** (Ollama).  
Die generierten Nachrichten werden strukturiert gespeichert und über Symlinks schnell zugänglich gemacht.

## Skripte

### 1. `generate_commit_msg.sh`
Erzeugt eine Commit-Message mit **OpenAI** (`gpt-4.1-mini`) basierend auf dem aktuell **gestageten Git-Diff**.

- Ausgabe:
  - `logs/openai/<YYYY-MM-DD_HH-MM-SS>/` mit:
    - `payload.json` – API-Payload
    - `response.json` – volle API-Antwort
    - `commit_message.txt` – generierte Commit-Message
  - Symlink `logs/openai/latest` → letzter Run
  - Symlink `latest-Commit-MSG-openai.txt` → letzte OpenAI-Commit-Message

- Nutzung:
  ```bash
  ./generate_commit_msg.sh
  git commit -F latest-Commit-MSG-openai.txt
  ```

### 2. `mixtral-commit.sh`
Erzeugt eine Commit-Message mit **Mixtral** (lokal über Ollama) basierend auf dem aktuell **gestageten Git-Diff**.

- Ausgabe:
  - `logs/mixtral/<YYYY-MM-DD_HH-MM-SS>/full_prompt.txt` – verwendeter Prompt
  - `commit_message.txt` – generierte Commit-Message
  - Symlink `logs/mixtral/latest` → letzter Run
  - Symlink `latest-Commit-MSG-mixtral.txt` → letzte Mixtral-Commit-Message

- Nutzung:
  ```bash
  ./mixtral-commit.sh
  git commit -F latest-Commit-MSG-mixtral.txt
  ```

### 3. `cleanup_logs.sh`
Entfernt Log-Verzeichnisse älter als eine bestimmte Anzahl Tage (Standard: 30).

- Nutzung:
  ```bash
  ./cleanup_logs.sh         # Behalte 30 Tage
  ./cleanup_logs.sh 7       # Behalte 7 Tage
  ./cleanup_logs.sh --help  # Hilfe anzeigen
  ```

## Log-Struktur
```
logs/
  openai/
    YYYY-MM-DD_HH-MM-SS/
      payload.json
      response.json
      commit_message.txt
    latest -> <letzter Run>
  mixtral/
    YYYY-MM-DD_HH-MM-SS/
      full_prompt.txt
      commit_message.txt
    latest -> <letzter Run>
```

## Voraussetzungen
- `git`
- Für OpenAI:
  - gültiger API-Key in `$OPENAI_API_KEY`
  - `jq`
  - `curl`
- Für Mixtral:
  - [Ollama](https://ollama.ai) installiert
  - Modell `mixtral:8x7b` lokal verfügbar

---

> **Hinweis:**  
> Die Symlinks `latest-Commit-MSG-openai.txt` und `latest-Commit-MSG-mixtral.txt`
> werden bei jedem Run automatisch aktualisiert und sollten in `.gitignore` stehen.
