FROM nousresearch/hermes-agent:latest

# Tool versions (bump these ARGs to update)
ARG GH_VERSION=2.63.0
ARG BW_VERSION=2025.1.0
ARG HIMALAYA_VERSION=1.2.0
ARG KUBECTL_VERSION=1.32.0

USER root

# jq — tiny JSON processor, install via apt
RUN apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI
RUN curl -fsSL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" \
    | tar xz -C /tmp \
    && mv "/tmp/gh_${GH_VERSION}_linux_amd64/bin/gh" /usr/local/bin/ \
    && rm -rf "/tmp/gh_${GH_VERSION}_linux_amd64"

# Bitwarden CLI
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip \
    && curl -fsSL "https://github.com/bitwarden/clients/releases/download/cli-v${BW_VERSION}/bw-linux-${BW_VERSION}.zip" -o /tmp/bw.zip \
    && unzip -o /tmp/bw.zip -d /tmp/bw \
    && mv /tmp/bw/bw /usr/local/bin/ \
    && rm -rf /tmp/bw /tmp/bw.zip \
    && apt-get purge -y unzip \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Himalaya — extract from .tgz archive
RUN curl -fsSL "https://github.com/pimalaya/himalaya/releases/download/v${HIMALAYA_VERSION}/himalaya.x86_64-linux.tgz" \
    | tar xz -C /tmp \
    && mv /tmp/himalaya /usr/local/bin/ \
    && chmod +x /usr/local/bin/himalaya

# kubectl — static binary from upstream
RUN curl -fsSL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

USER hermes

# ── Hotfix: webhook template resolution ──────────────────────
# Overlay patched webhook.py that adds fallback key resolution
# for GitHub webhook payloads where repository.full_name may be
# nested under pull_request.base.repo or pull_request.head.repo
# instead of at the top level.
# Remove this block once the upstream fix lands.
USER root
COPY webhook.py /opt/hermes/gateway/platforms/webhook.py
USER hermes
