#!/usr/bin/env bash
#
# login-uipath.sh
#
# Signs in to UiPath fresh on every session, non-interactively, using the
# Confidential External Application credentials the user entered in the plugin
# config modal. Runs from the SessionStart hook (the only place the masked
# secret is available, as CLAUDE_PLUGIN_OPTION_* env vars). The resulting token
# is stored by the CLI and reused by later pack/publish/deploy calls.
#
# No browser, no prompts. Always exits 0 so a misconfiguration never blocks the
# session — the skill detects "not signed in" and guides the user to fix config.
#
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Honor HTTP(S)_PROXY in the CLI's bundled-Node fetch (e.g. Claude Cowork's
# egress proxy). No-op when no proxy is configured.
export NODE_USE_ENV_PROXY=1

log() { printf '[uipath-coded-apps] %s\n' "$*" >&2; }

# Plugin config values are injected into hook subprocesses as CLAUDE_PLUGIN_OPTION_*.
CLIENT_ID="${CLAUDE_PLUGIN_OPTION_client_id:-}"
CLIENT_SECRET="${CLAUDE_PLUGIN_OPTION_client_secret:-}"
TENANT="${CLAUDE_PLUGIN_OPTION_tenant_name:-}"
ENVIRONMENT="${CLAUDE_PLUGIN_OPTION_environment:-cloud}"

if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ] || [ -z "$TENANT" ]; then
  log "UiPath credentials not configured yet. Open the plugin's settings and enter App ID, App Secret, and Tenant to enable automatic sign-in."
  exit 0
fi

UIP="$("$SCRIPT_DIR/resolve-uip.sh" 2>/dev/null || true)"
if [ -z "$UIP" ] || [ ! -x "$UIP" ]; then
  log "UiPath CLI not ready yet; skipping sign-in this session."
  exit 0
fi

# Map environment -> authority (cloud is the default authority, no flag needed).
AUTHORITY=""
case "$ENVIRONMENT" in
  staging) AUTHORITY="https://staging.uipath.com" ;;
  alpha)   AUTHORITY="https://alpha.uipath.com" ;;
  cloud|"") AUTHORITY="" ;;
  *) log "Unknown environment '${ENVIRONMENT}', defaulting to cloud." ;;
esac

# Pass the secret via env (env.NAME) so it never appears in the process args.
export UIPATH_COWORK_CLIENT_SECRET="$CLIENT_SECRET"

log "Signing in to UiPath (${ENVIRONMENT}, tenant ${TENANT})..."
set -- login --client-id "$CLIENT_ID" --client-secret "env.UIPATH_COWORK_CLIENT_SECRET" --tenant "$TENANT"
[ -n "$AUTHORITY" ] && set -- "$@" --authority "$AUTHORITY"

if "$UIP" "$@" >/dev/null 2>&1; then
  log "UiPath sign-in successful."
else
  log "UiPath sign-in failed. Check the App ID / Secret / Tenant in the plugin settings and that the External Application is enabled with the required scopes."
fi

exit 0
