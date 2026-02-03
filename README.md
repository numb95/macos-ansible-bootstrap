# macos-ansible-bootstrap

Small, practical Ansible setup to rebuild a macOS workstation: Homebrew packages/casks, Dock layout, and a few essentials. The goal is repeatability without over-engineering.

Heavily influenced by [geerlingguy/mac-dev-playbook](https://github.com/geerlingguy/mac-dev-playbook/).

## License

MIT License. See `LICENSE`.

## Quick start

```sh
ansible-playbook playbooks/site.yml
```

## Install Ansible

### virtualenv (per-project)

```sh
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install ansible
```

## Dependencies

```sh
make deps
```

This installs collections into `./collections` to match `ansible.cfg`.

## Make targets

Run the playbook via Make:

```sh
make run
```

Role-specific runs:

```sh
make run-homebrew
make run-dock
make run-shell
make run-tmux
make run-update
```

## Inventory

- Default inventory: `inventories/local/hosts.ini`
- Vars: `vars/vars.yml` (default)
- Test vars: `vars/vars-tests.yml`

## Homebrew configuration

Define packages and casks in `vars/vars.yml`:

```
homebrew_packages
homebrew_casks
```

These lists drive the `homebrew` role installs.

## Playbook

- `playbooks/site.yml`: full run
- Tags: `common`, `homebrew`, `dock`, `shell`, `tmux`, `update`, `dotfiles`

Examples:

```sh
# Homebrew only
ansible-playbook playbooks/site.yml --tags homebrew

# Dock only
ansible-playbook playbooks/site.yml --tags dock

# Shell only (oh-my-zsh + powerlevel10k)
ansible-playbook playbooks/site.yml --tags shell

# Tmux only (TPM + config)
ansible-playbook playbooks/site.yml --tags tmux

# Update only (brew, env managers, oh-my-zsh, tmux plugins)
ansible-playbook playbooks/site.yml --tags update

# Backup runs automatically before `shell`
```

## Shell role details

Backups:
- `~/.zshrc`
- `~/.p10k.zsh` and `~/.p10k.zsh.zwc`
- `~/.shell_scripts`

What it installs/configures:
- oh-my-zsh and powerlevel10k
- custom oh-my-zsh plugins from `zsh_custom_plugins`
- `~/.zshrc` template and Powerlevel10k config
- shell script fragments under `~/.shell_scripts`
- env managers (per `enable_*` flags)

## Tmux role details

Backups:
- `~/.tmux.conf`
- `~/.tmux`
- `~/.tmuxp`

What it installs/configures:
- `~/.tmux.conf` from template
- TPM in `~/.tmux/plugins/tpm`
- Dracula custom weather script at `~/.tmux/plugins/tmux/scripts/wttr.sh`
- plugin install/update via TPM (runs inside tmux)

## Homebrew role details

What it installs/configures:
- Homebrew itself (if missing)
- Packages from `homebrew_packages`
- Casks from `homebrew_casks`

## Common role details

What it installs/configures:
- Placeholder role for shared prerequisites (currently only logs a message)

## Dock role details

What it installs/configures:
- Dock autohide, size, magnification, position, and recents
- Hot corners and Dock persistent apps (from `vars/vars.yml`)

## Dotfiles role details

What it installs/configures:
- Placeholder role (no real dotfile actions yet)

## Update role details

Updates:
- Homebrew: `brew update`, `brew upgrade`, `brew upgrade --cask` (cask failures are non-fatal)
- oh-my-zsh, powerlevel10k, and custom plugins via git update
- env managers:
  - git-based: pyenv, goenv, tfenv, nvm
  - SDKMAN: `sdk selfupdate` + `sdk update`
  - rvm: `rvm get stable`
- tmux plugins: TPM `update_plugins all`

## Env managers

Enable/disable each manager in `vars/vars.yml`:

```
enable_sdkman
enable_goenv
enable_pyenv
enable_tfenv
enable_nvm
enable_rvm
enable_tfswitch
enable_fvm
```

Paths are also configurable in `vars/vars.yml`:

```
goenv_root
pyenv_root
tfenv_root
nvm_dir
rvm_path
sdkman_dir
```

Shell init is only injected when the corresponding `enable_*` flag is true.

## Tests

```sh
make test
```

This runs the playbook in check mode using `vars/vars-tests.yml`.

## Zsh Startup Profiling

```sh
scripts/zsh-profile.sh
```

This runs Zsh with `zprof` enabled and prints a startup timing report.

### Shell test (Linux container)

```sh
scripts/test-shell.sh
```

This builds a small Ubuntu image and runs the `shell` role to confirm oh-my-zsh
and powerlevel10k install and your config loads without errors, plus env manager
checks (sdkman, goenv, pyenv, tfenv, nvm).

### Tmux test (Linux container)

```sh
scripts/test-tmux.sh
```

This builds a small Ubuntu image and runs the `tmux` role to confirm the config
loads, TPM runs, and the custom weather script works.

## CI details

- Jobs use path-based filtering on PRs and non-main branch pushes.
- A full run is forced on `main` branch updates.
- Shell and tmux tests run in Linux containers.

## CI

GitHub Actions runs:
- ansible-lint on Ubuntu
- syntax-check on Ubuntu
- check-mode runs on macOS (Homebrew + Dock)
- container tests for `shell` and `tmux`
- path-based filtering on PRs and branch pushes; full run on `main`
