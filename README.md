# Project-OpenClaw

Docker Compose setups for running [OpenClaw](https://docs.openclaw.ai), a self-hosted AI agent gateway with a Control UI and terminal UI (TUI).


## Versions

| Folder | Description |
|---|---|
| [`V.0.1`](./V.0.1) | Gateway + first-run bootstrap, optional CLI helper |

## Quick start

```bash
git clone https://github.com/danchipili/Project-OpenClaw.git
cd Project-OpenClaw/V.0.1

docker compose up -d --build
```

Open `http://localhost:18789` and log in with your `OPENCLAW_GATEWAY_TOKEN`, or use the TUI:

```bash
docker exec -it openclaw-gateway openclaw tui
```

See the README inside each version folder for the full setup, model commands, and troubleshooting.

## Security

- If a key is ever exposed, rotate it at the provider.

## Author

Built by **Danson Chipili** on 9 October 2026, with plenty of Docker logs, a few "origin not allowed" errors, and one blocked push that saved the API keys. 🦞

