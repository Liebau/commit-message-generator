# Commit-Message Automation

This repository contains scripts for automatically generating Git commit messages using **OpenAI** and **Mixtral** (Ollama).  
The generated messages are stored in a structured format and made quickly accessible via symlinks.

## Scripts

### 1. `generate_commit_msg.sh`

Generates a commit message using **OpenAI** (`gpt-4.1-mini`) based on the currently **staged Git diff**.

- Output:
  - `logs/openai/<YYYY-MM-DD_HH-MM-SS>/` containing:
    - `payload.json` – API payload
    - `response.json` – full API response
    - `commit_message.txt` – generated commit message
  - Symlink `logs/openai/latest` → latest run
  - Symlink `latest-Commit-MSG-openai.txt` → most recent OpenAI commit message

- Usage:
  ```bash
  ./generate_commit_msg.sh
  git commit -F latest-Commit-MSG-openai.txt
  ```

---

### 2. `mixtral-commit.sh`

Generates a commit message using **Mixtral** (locally via Ollama) based on the currently **staged Git diff**.

- Output:
  - `logs/mixtral/<YYYY-MM-DD_HH-MM-SS>/full_prompt.txt` – prompt used
  - `commit_message.txt` – generated commit message
  - Symlink `logs/mixtral/latest` → latest run
  - Symlink `latest-Commit-MSG-mixtral.txt` → most recent Mixtral commit message

- Usage:
  ```bash
  ./mixtral-commit.sh
  git commit -F latest-Commit-MSG-mixtral.txt
  ```

---

### 3. `cleanup_logs.sh`

Deletes log directories older than a specified number of days (default: 30).

- Usage:
  ```bash
  ./cleanup_logs.sh         # Keep 30 days
  ./cleanup_logs.sh 7       # Keep 7 days
  ./cleanup_logs.sh --help  # Show help
  ```

---

## Log Structure

```text
logs/
  openai/
    YYYY-MM-DD_HH-MM-SS/
      payload.json
      response.json
      commit_message.txt
    latest -> <last run>
  mixtral/
    YYYY-MM-DD_HH-MM-SS/
      full_prompt.txt
      commit_message.txt
    latest -> <last run>
```

---

## Requirements

- `git`

**For OpenAI:**
- Valid API key in `$OPENAI_API_KEY`
- `jq`
- `curl`

**For Mixtral:**
- [Ollama](https://ollama.ai) installed
- Model `mixtral:8x7b` available locally

> **Note:**  
> The symlinks `latest-Commit-MSG-openai.txt` and `latest-Commit-MSG-mixtral.txt`  
> are updated on every run and should be listed in `.gitignore`.

---

## Further Information

Full explanation and background available in the related blog post:  
🔗 [https://gwr-mbh.de/ki-commit-messages-git-diff/](https://gwr-mbh.de/ki-commit-messages-git-diff/)
