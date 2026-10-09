
create .env file with these congifs
BUILD_VERSION=v0-1
OPENCLAW_DEFAULT_MODEL=ai_model_name
OPENCLAW_GATEWAY_TOKEN=your_generated_openclaw_token[echo "gtw-$(head -c 96 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 64 | fold -w 8 | paste -sd-)"]
OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:latest-browser
# OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:latest
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_TZ=your_time_zone
ANTHROPIC_API_KEY=anthropic_ai_key[get from https://aistudio.google.com/apikey]
OPENAI_API_KEY=openai_ai_key[get from https://platform.openai.com/api-keys]
GEMINI_API_KEY=gemini_ai_key[get from https://platform.claude.com/settings/keys]
XAI_API_KEY=xai_ai_key[get from https://console.x.ai]

to run openclaw via tui

run docker exec -it openclaw-gateway openclaw tui