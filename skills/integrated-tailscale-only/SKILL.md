---
name: integrated-tailscale-only
description: Use whenever designing or deploying any service that should be reachable via Tailscale on Dhruv's bear-atria tailnet — Tower (Unraid), Mac Mini, Beast, or any other host. MUST trigger on "deploy [X] to tailscale", "add tailscale to [container]", "expose [service] via tailscale serve", "tailscale-fronted [anything]", "new sidecar", "tailscale funnel", any docker-compose mention combined with tailscale, any container architecture for a service intended to receive tailnet traffic. Skip ONLY if Dhruv explicitly says he is exploring an alternative pattern for a deliberate reason.
---

# Integrated-Tailscale-Only — The Rule

## ONE container per Tailscale identity.

Tailscaled runs INSIDE the same container as the application it fronts. The model to imitate is **immich, Jellyfin, ymnotes, LibreChat** — each is one container in `docker ps` with tailscale baked in.

## Anti-patterns — these are FORBIDDEN

- `network_mode: container:tailscale` or `network_mode: service:tailscale` in any compose file
- A separate `tailscale/tailscale` image as its own service alongside the app's container
- Multiple containers in `docker ps` for what's conceptually ONE tailnet identity

If you find yourself proposing any of the above: STOP. You're making the mistake from 2026-04-26. Re-read this skill.

## The two acceptable patterns

### Pattern 1 — Custom image (any host, including Mac Mini)

Build a Dockerfile that bundles app + tailscale + an entrypoint script. One image, one container per identity.

**Reference implementation:** `~/code/homelab/bhandar/image/` (Caddy-fronted static sites, in production at https://aakashvani.bear-atria.ts.net/).

Canonical Dockerfile shape:

```dockerfile
FROM caddy:2-alpine     # ← change to YOUR app's base for your service

# Tailscale via Alpine apk package — DO NOT use install.sh, it calls
# rc-update (OpenRC) which doesn't exist in containers.
RUN apk add --no-cache iptables ip6tables ca-certificates curl tzdata tailscale && \
    mkdir -p /var/lib/tailscale /var/run/tailscale

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
```

Canonical entrypoint.sh — see `~/code/homelab/bhandar/image/entrypoint.sh` for the full file. Critical behaviors:

- **Required env:** `TS_AUTHKEY`, `TS_HOSTNAME`. Container exits with clear error if missing (uses `${VAR:?msg}` guard).
- **`tailscaled --tun=userspace-networking`** — no kernel TUN, no caps required. Works on Mac Docker Desktop too.
- **Idempotent first-boot vs restart:** the entrypoint only passes `--authkey` if the state file is absent OR `tailscale status` fails. Restarts use persisted state (one-shot keys throw if reused).
- **Default `--accept-dns=true`** — required for the container to resolve other tailnet hosts (e.g., portfolio talking to a DB at `*.bear-atria.ts.net`). Override via `TS_ACCEPT_DNS=false` if needed.
- **Optional Funnel via `TS_FUNNEL=true`** — wrapped in `timeout 10` because Tailscale CLI hangs (does not error) when the ACL doesn't permit Funnel for this node's IP.
- **`exec "$@"` at the end** so the Dockerfile's CMD overrides still work (debugging, custom commands).

### Pattern 2 — Unraid CA Hook (Tower only)

If the app has an Unraid Community Apps template, just toggle the **"Use Tailscale"** field ON. The CA Tailscale Hook injects tailscaled into the container at startup.

**Reference implementation:** LibreChat on Tower (live at https://librechat.bear-atria.ts.net/), and the immich / Jellyfin / ymnotes containers (linuxserver-style baked-in tailscale).

Required template fields:
- Use Tailscale: ON
- Tailscale Hostname: `<your-hostname>`
- Tailscale Tags: `tag:server` (or whatever role fits)
- Extra Parameters: **`--user=0`** if the image's default user is non-root (Open WebUI as `node`, GitLab as `git`, many node-based apps). The CA Hook needs root inside the container to start tailscaled.

## Decision tree

```
Q: Is the host Tower (Unraid)?
  ├─ Yes — Q: Does the app have a CA template?
  │           ├─ Yes  → Pattern 2 (CA Hook). Done.
  │           └─ No   → Pattern 1 (custom image). Build Dockerfile.
  └─ No  → Pattern 1 (custom image). Build Dockerfile.
```

## Self-test before declaring a design complete

You MUST be able to answer YES to all of these (or N/A):

1. Does your design produce ONE container per tailnet identity?
2. Are tailscaled and the app in the SAME container?
3. If non-root image (Open WebUI, GitLab, etc.), did you add `--user=0`?
4. Did you set `--accept-dns=true` if the service needs to resolve other tailnet hosts?
5. If Funnel is in scope, did you use the LOCAL port as the funnel argument (NOT 443)? See pitfall #13.
6. Did you check the 13-pitfall list before finalizing?

If any answer is NO (and the question applies), redesign before proceeding.

## The 13 pitfalls — checklist before deployment

Source: `~/code/homelab/tailscale/tags-and-acls.md` Lessons Learned section + the 2026-04-26 redeploy. Walk through each:

1. **`tailscale up --reset` footgun** — over SSH, always use `tailscale set` not `tailscale up` for incremental changes
2. **Server-to-server ACL gap** — ensure `policy.hujson` has `{src: tag:server, dst: tag:server:*}` rule
3. **Mac standalone Tailscale.app blocks Tailscale SSH** — use regular SSH over tailnet instead
4. **macOS sshd non-interactive PATH excludes /opt/homebrew/bin** — fix in `~/.zshenv`
5. **macOS Keychain ACL denies SSH-spawned processes** — fix via Keychain Access app
6. **DOMAIN_CLIENT/SERVER must match actual tailscale hostname** — audit env vars after rename
7. **Bridge network DNS doesn't resolve container names** — use tailscale hostnames OR put app in tailscale namespace (Pattern 1)
8. **Unraid CA template `[IP]:[PORT:N]` placeholders don't always substitute** — replace literally if needed
9. **`/mnt/user/appdata/<app>/` may be owned by root** — `chown -R 99:100`
10. **`ALLOW_REGISTRATION` defaults to false in newer apps** — audit explicitly
11. **Privacy leaks in published content** — audit BEFORE first publish, not after
12. **Funnel only allows ports 443/8443/10000** — `tailscale serve` to one of these first
13. **`tailscale funnel <arg>` argument is the LOCAL SERVICE TO EXPOSE, NOT the public port.** Passing `443` makes Tailscale try to expose port 443 of the container itself (where nothing listens) → 502s. Correct: `tailscale funnel --bg <local-port>` where `<local-port>` is your app's listening port (e.g., `8080` for Caddy default, `3080` for LibreChat). Public-side port is always 443 unless `--https=N` overrides. Real example: `tailscale funnel --bg 8080` exposes `127.0.0.1:8080` via public HTTPS:443.

## Additional sub-rules (caught during 2026-04-26 redeploy)

- **Don't use Tailscale's `install.sh`** in containers — it calls `rc-update` (OpenRC init) which doesn't exist. Use `apk add tailscale` (Alpine community repo, available since 3.18) instead.
- **Tailscale DNS suffix is sticky to NodeKey, not to `--hostname`**. Once a node registers as `foo-1` (because `foo` was taken), `tailscale up --hostname=foo` won't change the DNS to `foo`. Fix: either rename the node in admin (https://login.tailscale.com/admin/machines → machine → Edit machine name), OR delete the conflicting old node first AND wipe local state to force fresh registration.
- **`tailscale serve` config is also sticky** — after a hostname change, the serve config still points to the OLD hostname. Run `tailscale serve reset && tailscale serve --bg --https=443 http://127.0.0.1:<APP_PORT>` to refresh. The cert auto-fetches for the new name.
- **`tailscale serve set <file>` may not work in older Tailscale versions.** If you need declarative serve config, use the JSON shape via `--set-path` or pipe to stdin per the version's CLI help. For simple "443 → local port", the CLI form is fine and more portable.

## References

- Spec: `~/code/homelab/tailscale/docs/specs/2026-04-26-integrated-tailscale-only-design.md`
- Plan: `~/code/homelab/tailscale/docs/plans/2026-04-26-integrated-tailscale-only-plan.md`
- Decision log: `~/code/homelab/tailscale/tags-and-acls.md`
- Mac SSH runbook: `~/code/homelab/tailscale/mac-ssh-runbook.md`
- Working examples:
  - **Pattern 1** — `~/code/homelab/bhandar/image/` and `~/code/homelab/bhandar/docker-compose.yml` (live at https://aakashvani.bear-atria.ts.net/ + https://aakashvani-private.bear-atria.ts.net/)
  - **Pattern 2** — LibreChat on Tower (Unraid CA template `my-LibreChat.xml` with Use Tailscale: ON + `--user=0`), live at https://librechat.bear-atria.ts.net/

## Why this skill exists

On 2026-04-26, several Tailscale-fronted services were deployed using a "sidecar pattern" (separate `tailscale/tailscale` container with `network_mode: service:tailscale`). This appeared to work but produced 4-container bhandar deploys, 2-container Open WebUI deploys, "in use by another container" errors when trying to delete via Unraid WebUI, and outbound-DNS failures from inside the app containers (default bridge can't see tailnet hostnames).

Dhruv was rightfully angry — the immich/Jellyfin pattern is one container per service. This skill prevents future sessions from re-making the same mistake.

The cost of the mistake was several hours of misdesign + an angry user + a public-URL outage during the unwinding. The cost of triggering this skill before designing is ~30 seconds of reading. The asymmetry is deliberate.
