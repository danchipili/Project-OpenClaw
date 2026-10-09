# Project-OpenClaw

Docker Compose setups for running [OpenClaw](https://docs.openclaw.ai), a self-hosted AI agent gateway with a Control UI and terminal UI (TUI).

Each version lives in its own folder with its own `README.md`, `docker-compose.yaml`, and `.env.example`.

## Versions

| Folder | Description |
|---|---|
| [`V.0.1`](./V.0.1) | Gateway + first-run bootstrap, named volume for state, optional CLI helper |

## Quick start

```bash
git clone https://github.com/danchipili/Project-OpenClaw.git
cd Project-OpenClaw/V.0.1

cp .env.example .env        # then fill in your values (never commit .env)
docker compose up -d --build
```

Open `http://localhost:18789` and log in with your `OPENCLAW_GATEWAY_TOKEN`, or use the TUI:

```bash
docker exec -it openclaw-gateway openclaw tui
```

See the README inside each version folder for the full setup, model commands, and troubleshooting.

## Security

- `.env` files hold API keys and are listed in `.gitignore`. Only `.env.example` belongs in the repo.
- If a key is ever exposed, rotate it at the provider.

## Author

Created by **Danson Chipili**, 09/10/2026.
