# pug-ng

Sync Arch Linux repo and AUR package lists to GitHub Gists via an ALPM hook.

`pug-ng` is a modern reimplementation of the `pug` hook script. It keeps the same basic outcome, but makes setup, diagnostics, and migration explicit instead of burying them inside packaging-time behavior.

## Why Use It

Compared to the original `pug`, `pug-ng` is easier to operate and recover:

- setup is explicit: run `pug-ng init` once, then let the hook do the rest
- sync is non-interactive, so pacman hooks do not depend on login prompts
- GitHub access uses `curl` and `jq`, not the Ruby `gist` toolchain
- token handling is separated from general config
- `doctor`, `status`, and `show-config` make troubleshooting straightforward
- legacy `pug` config and token data can be imported
- hostname-specific gist filenames are reused automatically when matching gists already exist in the authenticated account

## Quick Start

Install the package, then initialize it once as root:

```bash
sudo pug-ng init
```

That will:

- validate the GitHub token
- create or reuse one gist for the official repository package list
- create or reuse one gist for the AUR package list
- write `/etc/pug-ng/config`

By default, `init` prompts for a token if `/etc/pug-ng/token` does not exist. You can also provide one directly:

```bash
sudo pug-ng init --token "<github_token>"
```

To create public gists instead of private ones:

```bash
sudo pug-ng init --public --force
```

Minimum GitHub token permission: `gist`.

## How It Works

- the ALPM hook runs `pug-ng sync --hook --quiet` after package transactions
- the official repository list and AUR list are uploaded to separate gists
- gist filenames include the hostname:
  - `<hostname>.pacman-list.pkg`
  - `<hostname>.aur-list.pkg`
- if `init` finds an existing gist with the expected hostname-specific filename, it reuses that gist instead of creating a new one

## Common Commands

```bash
# run a sync manually
sudo pug-ng sync

# check whether both gists match local package state
sudo pug-ng status

# print config paths and configured gist IDs
sudo pug-ng show-config

# check config readability, token state, gist access, and hook installation
sudo pug-ng doctor
```

`pug-ng status` also prints the gist URLs so you can inspect them directly.

## Migration From Legacy `pug`

If `/etc/pug` and the old token file are present, `pug-ng init` can offer to migrate them interactively.

You can also import the legacy settings directly:

```bash
sudo pug-ng import-legacy
```

To overwrite the current token from the legacy token file during migration:

```bash
sudo pug-ng import-legacy --force-token
```

After migration, uninstall the old `pug` package or hook so both tools do not try to sync at the same time.

## Configuration Notes

- runtime config path: `/etc/pug-ng/config`
- default token path: `/etc/pug-ng/token`
- the config file is non-secret and should be readable
- the token file is secret and should be `0600` or `0400`
- if the token file is unreadable to an unprivileged user, status and doctor will tell you to run the command as root

## Install From Source

```bash
sudo make install
```

This installs:

- `pug-ng` to `/usr/bin/pug-ng`
- the ALPM hook to `/usr/share/libalpm/hooks/pug-ng.hook`
- a config file template to `/etc/pug-ng/config` if that file does not already exist

## Uninstall

```bash
sudo make uninstall
```

The uninstall target removes the binary and hook, but leaves config and token files in place.
