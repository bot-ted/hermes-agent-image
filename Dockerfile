FROM nousresearch/hermes-agent:latest

# Tool versions (bump these ARGs to update)
ARG GH_VERSION=2.63.0
ARG BW_VERSION=2025.1.0
ARG HIMALAYA_VERSION=1.9.0

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
RUN curl -fsSL "https://github.com/bitwarden/clients/releases/download/cli-v${BW_VERSION}/bw-linux-${BW_VERSION}.zip" -o /tmp/bw.zip \
    && python3 -c "import zipfile; zipfile.ZipFile('/tmp/bw.zip').extractall('/tmp/bw')" \
    && mv /tmp/bw/bw /usr/local/bin/ \
    && rm -rf /tmp/bw /tmp/bw.zip

# Himalaya — static binary
RUN curl -fsSL "https://github.com/pimalaya/himalaya/releases/download/v${HIMALAYA_VERSION}/himalaya-linux-amd64" \
    -o /usr/local/bin/himalaya \
    && chmod +x /usr/local/bin/himalaya

USER hermes
