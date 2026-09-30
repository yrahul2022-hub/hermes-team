# Hermes Agent Team (local, single user)

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

- Dashboard: http://localhost:9119 (user/password in `.env`)
- API: http://localhost:8642  |  SearXNG: http://localhost:8080
- LLM: Ollama on Windows, model `qwen3.5-64k` (qwen3.5:4b, 64K context), models stored in `models/`
- Agents (Hermes profiles): esteban (coordinator), ai-engineer, genai-engineer, data-engineer, data-scientist, researcher
- Coordination: Hermes kanban board + Esteban's `shared/TEAM_NOTES.md`
- Handoffs are wired with task parent/child links (see `team.ps1 ask`) because the 4B model is unreliable at creating follow-up tasks itself.

Commands: `.\team.ps1 up | down | board | ask "goal"`

Better quality: set a cloud provider in `data\config.yaml` (`hermes model` inside the container); nothing else changes.
