# pug-ng

Sync Arch Linux official repository and AUR package lists to GitHub Gists via an ALPM hook.

`pug-ng` is a replacement for the legacy `pug` hook script.

## Why this exists

The original `pug` implementation dates back to 2017 and has a few operational problems:

- install-time interaction (`gist --login`) mixed into packaging
- token management tied to `/root/.gist` and Ruby `gist` tooling
- temporary file handling in fixed `/tmp/*` paths
- no explicit command UX for setup, status, or migration

`pug-ng` keeps the same outcome (sync native + AUR package lists to two gists) but with explicit commands and safer defaults.

## Features

- Non-interactive ALPM hook: `pug-ng sync --hook --quiet`
- Explicit one-time setup: `pug-ng init`
- Uses GitHub REST API via `curl` + `jq` (no Ruby `gist` gem)
- Config file in `/etc/pug-ng/config`
- Token from file (`/etc/pug-ng/token` by default)
- Legacy import from `/etc/pug`

## Commands

```bash
# one-time setup (as root), creating two private gists
sudo pug-ng init

# optional: create public gists
sudo pug-ng init --public --force

# optional: pass token directly and store it in TOKEN_FILE
sudo pug-ng init --token "<github_token>"

# run sync manually
sudo pug-ng sync

# check IDs and paths
sudo pug-ng show-config

# check full setup health (config/token/gist access/hook)
sudo pug-ng doctor

# import GIST_NAT/GIST_AUR from old /etc/pug
sudo pug-ng import-legacy

# overwrite existing /etc/pug-ng/token from /root/.gist during migration
sudo pug-ng import-legacy --force-token
```

`pug-ng init` detects an existing legacy `pug` installation and, when possible, prompts to migrate from `/etc/pug` and `/root/.gist`.
After migration (or when legacy files are still present), it warns to uninstall old `pug` to avoid duplicate hooks.
If no token exists and `--token` is not provided, `init` prompts for one interactively with a link to GitHub token settings.
During legacy migration, `pug-ng` reads the first non-empty line from `/root/.gist` and stores it in `/etc/pug-ng/token`.
`init` validates tokens against GitHub before creating gists:
- tokens entered via `--token` or interactive prompt are rejected if invalid
- if an existing token file is invalid, `init` warns with the filename and exits
- validation includes both authentication and gist-access permission

## Token handling

Token source:

1. `TOKEN_FILE` from config (`/etc/pug-ng/token` default)

Minimum token permission: `gist`.

`pug-ng` enforces token file permissions at runtime. Accepted modes are `0600` (preferred) or `0400`.
If run as root and mode is too open, it is automatically corrected to `0600`.

## Install

```bash
sudo make -C pug-ng install
```

This installs:

- binary: `/usr/bin/pug-ng`
- hook: `/usr/share/libalpm/hooks/pug-ng.hook`
- config template (if missing): `/etc/pug-ng/config`

## Uninstall

```bash
sudo make -C pug-ng uninstall
```

Config and token files are left in place intentionally.
