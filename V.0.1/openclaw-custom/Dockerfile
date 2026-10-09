# Thin wrapper around the official image: applies first-run config, then
# hands off to the image's original entrypoint.
ARG OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:latest
FROM ${OPENCLAW_IMAGE}

USER root
COPY --chmod=755 entrypoint.sh /usr/local/bin/oc-entrypoint.sh
USER node

# From: docker inspect ghcr.io/openclaw/openclaw:latest-browser
#   Entrypoint: ["tini","-s","--","node","/app/docker-entrypoint.mjs"]
#   Cmd:        ["node","openclaw.mjs","gateway"]
ENV ORIG_ENTRYPOINT="tini -s -- node /app/docker-entrypoint.mjs"
ENTRYPOINT ["/usr/local/bin/oc-entrypoint.sh"]
CMD ["node", "openclaw.mjs", "gateway"]