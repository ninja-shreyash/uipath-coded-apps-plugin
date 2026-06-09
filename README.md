# UiPath Coded Apps

Create, preview, publish, and deploy a **UiPath Coded App** end-to-end — from an
idea to a live app URL — without typing a single command. Built for business
users.

Just invoke the plugin and say what you want to build. It guides you through a
quick UiPath sign-in, generates the app, shows you a live preview, and (once you
approve) publishes and deploys it — then hands back the app URL.

## What it does

1. **Sets up automatically.** A private, pinned UiPath CLI is installed the
   first time a session starts after you enable the plugin — before you do
   anything. No first-use wait, no install command.
2. **Signs you in automatically.** Using the UiPath app credentials you enter
   once in the plugin settings, it signs in fresh at the start of every session —
   no browser, no prompts. The same sign-in is reused for publishing and
   deploying.
3. **Builds your app.** Scaffolds a Coded App starter (form, dashboard, or
   inline-automation) and tailors it to your request.
4. **Previews it.** Runs the app locally and gives you a URL to eyeball before
   anything is published.
5. **Publishes & deploys.** On your OK, it builds, packs, publishes, and deploys
   to UiPath, then returns the **live app URL**.

## Components

| Component | Purpose |
|-----------|---------|
| Skill `uipath-coded-apps` | Orchestrates create → preview → deploy |
| `userConfig` modal | Collects UiPath App ID / Secret / Tenant / Environment at enable time |
| `SessionStart` hook | Installs the pinned UiPath CLI once, then signs in fresh each session |
| Scripts | Bootstrap, sign-in, session check, local preview, pack/publish/deploy |

## Requirements

- **Node.js 20+** on the machine (the only software prerequisite). The plugin
  installs everything else itself.
- A **Confidential External Application** in UiPath (Admin → External
  Applications → Add → Confidential application) with the **application scopes**
  needed to publish/deploy Coded Apps. Note its **App ID** and **App Secret**.

## Configure (one-time)

When you enable the plugin, a settings form asks for:

| Field | Where to get it |
|-------|-----------------|
| **App ID (Client ID)** | The External Application's App ID |
| **App Secret (Client Secret)** | The External Application's App Secret (stored securely, never shown in chat) |
| **Tenant** | Your UiPath tenant name (e.g. `DefaultTenant`) |
| **Environment** | `cloud`, `staging`, or `alpha` |

The plugin uses these to sign in non-interactively (client credentials) — no
browser, no per-session prompts. You can change them anytime from the plugin's
settings.

## Install

This repo is a Claude plugin marketplace. Add it, then install the plugin.

**Claude Code (CLI):**

```
/plugin marketplace add ninja-shreyash/uipath-coded-apps-plugin
/plugin install uipath-coded-apps@uipath-coded-apps
```

**Claude desktop app:** open the plugin manager, add the marketplace
`ninja-shreyash/uipath-coded-apps-plugin`, then install **uipath-coded-apps**
from the Discover list.

After installing, start a new session so the one-time CLI setup runs.

## How to use

Enable the plugin, then say something like:

- "Create a UiPath app to submit expense requests."
- "Build a dashboard coded app for my queue items and deploy it."
- "Make an app on UiPath and give me the link."

The plugin takes it from there. The only thing you do during a build is confirm
the preview looks good — sign-in is automatic from your saved settings.

## Notes

- The bundled UiPath CLI is pinned to a known-good version (`@uipath/cli@1.1.1`)
  and lives privately under `~/.uipath-coded-apps/runtime/` — it does not touch
  any system-wide `uip` install.
- The CLI is always installed from the public npm registry, so a scoped
  `.npmrc` (e.g. one pointing `@uipath` at a private registry) won't break setup.
- Works inside sandboxed environments (e.g. Claude Cowork) that route egress
  through an HTTP proxy: the plugin runs the UiPath CLI with
  `NODE_USE_ENV_PROXY=1` so its built-in `fetch` honors `HTTP(S)_PROXY`. This is
  a no-op when no proxy is configured.
