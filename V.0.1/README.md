# OpenClaw on Docker Compose

A Compose setup for running [OpenClaw](https://docs.openclaw.ai) (gateway + Control UI + TUI) with:

- a thin wrapper image that applies a **one-time bootstrap** (gateway config, allowed browser origins) and then hands off to the official image's own entrypoint
- a **named volume** for all state (config, auth, sessions, agent workspaces), so there are no file-permission problems
- all secrets kept in a local `.env` file that is **never committed**

## Project layout

```
.
├── .env                    # template: copy to .env and 
├── docker-compose.yaml     # gateway service + optional 
└── openclaw-custom/
    ├── Dockerfile          # wraps the official image
    └── entrypoint.sh       # first-run bootstrap, then starts OpenClaw
```

## Requirements

- Docker with the Compose plugin (`docker compose version`)
- At least one model provider API key (Gemini, OpenAI, Anthropic or xAI)

## Quick start

### 1. Create your `.env`

Then edit `.env`. Use **real values or leave a line empty**; do not leave placeholder text, because anything after `=` is passed to the container as-is.

| Variable | Description |
|---|---|
| `BUILD_VERSION` | Used in the project and volume names. Lowercase letters, digits and dashes only, **no dots** (e.g. `v0-1`). Changing it creates a new, empty state volume. |
| `OPENCLAW_GATEWAY_TOKEN` | Login token for the Control UI. Must be a real random value (see below). |
| `OPENCLAW_IMAGE` | Base image. `latest-browser` includes Chromium; `latest` does not. |
| `OPENCLAW_GATEWAY_PORT` | Host port for the Control UI (default `18789`). |
| `OPENCLAW_TZ` | IANA timezone, e.g. `UTC` or `Africa/Lusaka`. |
| `OPENCLAW_DEFAULT_MODEL` | Default model in `provider/model-id` form, e.g. `google/gemini-3.6-flash`. Applied on first run only. |
| `GEMINI_API_KEY` | Get one at <https://aistudio.google.com/apikey> |
| `OPENAI_API_KEY` | Get one at <https://platform.openai.com/api-keys> |
| `ANTHROPIC_API_KEY` | Get one at <https://platform.claude.com/settings/keys> |
| `XAI_API_KEY` | Get one at <https://console.x.ai> |

Leave the keys for providers you don't use empty.

Generate a gateway token:

```bash
openssl rand -hex 32
```

Example `.env` (fake values):

```env
BUILD_VERSION=v0-1
OPENCLAW_GATEWAY_TOKEN=paste-the-generated-token-here
OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:latest-browser
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_TZ=UTC
OPENCLAW_DEFAULT_MODEL=google/gemini-3.6-flash
GEMINI_API_KEY=
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
XAI_API_KEY=
```

### 2. Build and start

```bash
docker compose up -d --build
docker compose logs -f openclaw-gateway
```

On first start you'll see the `[bootstrap]` lines, then OpenClaw's doctor step, then the gateway starting. Look for `[gateway] ready`. A warning that the "pull access denied for openclaw-custom" can be ignored if it appears; the image is built locally.

### 3. Open the Control UI

Open `http://localhost:18789` (or your `OPENCLAW_GATEWAY_PORT`) and enter your `OPENCLAW_GATEWAY_TOKEN`.

The port is published on `127.0.0.1` only. To reach it from another machine, use an SSH tunnel:

```bash
ssh -L 18789:127.0.0.1:18789 user@your-server
```

## Using the TUI

Open the terminal UI inside the running container:

```bash
docker exec -it openclaw-gateway openclaw tui
```

Type a message and press Enter. Exit with `Ctrl+C`.

If the TUI replies with `No API key found for provider ...`, see [Add or change an API key](#add-or-change-an-api-key).

## Check and change models

```bash
# Show configured providers and the active model
docker exec openclaw-gateway openclaw models status

# List models OpenClaw knows about
docker exec openclaw-gateway openclaw models list

# Change the default model
docker exec openclaw-gateway openclaw models set google/gemini-3.6-flash
```

`OPENCLAW_DEFAULT_MODEL` in `.env` is only applied on the **first** start. After that, use `models set`.

If a newly released model isn't listed, restart the gateway so it picks up the refreshed model catalog:

```bash
docker compose restart openclaw-gateway
```

## Add or change an API key

Keys in `.env` are passed to the container as environment variables. After editing `.env`, recreate the container:

```bash
docker compose up -d
```

Or store a key inside OpenClaw's own auth store (kept in the state volume):

```bash
docker exec -it openclaw-gateway openclaw models auth paste-api-key --provider google
```

## Useful commands

```bash
docker compose ps                                   # status
docker compose logs -f openclaw-gateway             # follow logs
docker compose restart openclaw-gateway             # restart
docker compose down                                 # stop (state volume is kept)
docker exec -it openclaw-gateway sh                 # shell inside the container
docker exec openclaw-gateway openclaw agents list   # list agents and workspaces
```

Optional CLI helper service (shares the gateway's network):

```bash
docker compose run --rm openclaw-cli models status
```

## Where things are stored

All state lives in the named volume `openclaw-volume-<BUILD_VERSION>`, mounted at `/home/node/.openclaw`:

| Path in container | Contents |
|---|---|
| `/home/node/.openclaw/openclaw.json` | Main config (including agent identities) |
| `/home/node/.openclaw/workspace/` | Main agent workspace (`SOUL.md`, `IDENTITY.md`, ...) |
| `/home/node/.openclaw/.bootstrap-done` | Marker so the bootstrap runs only once |

Read an agent's soul file:

```bash
docker exec openclaw-gateway cat /home/node/.openclaw/workspace/SOUL.md
```

Back up the volume:

```bash
docker run --rm \
  -v openclaw-volume-v0-1:/data \
  -v "$(pwd)":/backup \
  busybox tar czf /backup/openclaw-state.tgz -C /data .
```

(Replace `v0-1` with your `BUILD_VERSION`.)

## Re-running the first-run bootstrap

The bootstrap sets `gateway.mode`, `gateway.bind` and the allowed browser origins, then disables memory search. It runs once. To run it again (for example after changing `OPENCLAW_GATEWAY_PORT`):

```bash
docker exec openclaw-gateway rm /home/node/.openclaw/.bootstrap-done
docker compose restart openclaw-gateway
```

## Updating

```bash
docker compose build --pull --no-cache
docker compose up -d
```

If an OpenClaw update changes the image's entrypoint or command, update `ORIG_ENTRYPOINT` and `CMD` in `openclaw-custom/Dockerfile`. Check the current values with:

```bash
docker inspect ghcr.io/openclaw/openclaw:latest-browser \
  --format '{{json .Config.Entrypoint}} {{json .Config.Cmd}}'
```

## Troubleshooting

| Problem | Fix |
|---|---|
| `"/entrypoint.sh": not found` during build | The file must be named exactly `entrypoint.sh` (lowercase). Linux filenames are case-sensitive. |
| Container starts then exits right away | `ORIG_ENTRYPOINT` or `CMD` is missing or wrong in the Dockerfile. Check the logs. |
| `Browser origin not allowed` in the Control UI | The URL in your address bar isn't in `gateway.controlUi.allowedOrigins`. Use the port from `OPENCLAW_GATEWAY_PORT`, or re-run the bootstrap (see above). |
| `No API key found for provider "google"` | The key isn't reaching the container. Check `.env`, run `docker compose up -d`, or use `models auth paste-api-key`. |
| `invalid project name` | `BUILD_VERSION` contains uppercase letters or dots. Use something like `v0-1`. |
| Agent is slow or erroring with 429 messages | Likely free-tier rate limits. Check the logs, try another model, or enable billing for the provider. |

## Security notes

- **Never commit `.env`.** It is listed in `.gitignore`. Only `.env.example` (with empty values) belongs in the repo.
- If a key is ever pushed or pasted somewhere public, **rotate it** at the provider and delete the old one.
- The gateway port is bound to `127.0.0.1` only. Do not change it to `0.0.0.0` without reading OpenClaw's security docs.
- Keep `.env` private: `chmod 600 .env`.
- Free-tier Gemini usage may be used by Google to improve its products; don't send sensitive data through it.

## License

Add your license here.