# hermes-agent-image

Derived [Hermes Agent](https://github.com/NousResearch/hermes-agent) Docker image with pre-installed CLI tools.

## Included Tools

| Tool | Version | Purpose |
|------|---------|---------|
| `gh` | 2.63.0 | GitHub CLI — PRs, issues, repos, auth |
| `bw` | 2025.1.0 | Bitwarden CLI — secret/credential management |
| `himalaya` | 1.2.0 | Email CLI — send, read, search |
| `jq` | (apt) | JSON processor for shell pipelines |

All versions are pinned via `ARG` directives in the Dockerfile for reproducible builds.

## Usage

```yaml
# In your Kubernetes pod spec:
containers:
  - name: hermes
    image: ghcr.io/bot-ted/hermes-agent-image:latest
```

Or pin to a specific build:

```yaml
    image: ghcr.io/bot-ted/hermes-agent-image:sha-abc1234
```

## How It Works

- Base: `nousresearch/hermes-agent:latest` (Debian Trixie)
- Tools installed as root into `/usr/local/bin/` (already on `PATH`)
- Container runs as `hermes` user (inherited from base image)
- All Hermes Agent entrypoints and `/opt/data` semantics unchanged

## CI

Builds on:
- Push to `main` (Dockerfile changes)
- Nightly at 8 PM EST (`0 1 * * *` UTC) — picks up new upstream base image

Pipeline: **Build → smoke test (all 4 tools must report versions) → push `:latest` + `:sha-<commit>`**

## Updating Tool Versions

Edit the `ARG` lines in the Dockerfile and push to `main`. CI rebuilds automatically.

```dockerfile
ARG GH_VERSION=2.63.0     # bump me
ARG BW_VERSION=2025.1.0   # bump me
ARG HIMALAYA_VERSION=1.9.0 # bump me
```

## License

MIT — same as the base image. The Dockerfile and CI config in this repo are MIT-licensed.
