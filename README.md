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
- Tags: `homebrew`, `dock`, `shell`, `tmux`, `iterm`, `zettlr`, `update`

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

# iTerm2 only (backup/restore)
ansible-playbook playbooks/site.yml --tags iterm -e backup=true
ansible-playbook playbooks/site.yml --tags iterm -e restore=true

# Zettlr only (backup/restore)
ansible-playbook playbooks/site.yml --tags zettlr -e backup=true
ansible-playbook playbooks/site.yml --tags zettlr -e restore=true

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

Powerlevel10k color reference (256-color palette):
```sh
for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
```

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

## iTerm2 role details

Config paths:
- `~/Library/Application Support/iTerm2`
- `~/Library/Preferences/com.googlecode.iterm2.plist`

Backup behavior:
- Dated backup at `~/backup/iterm/<timestamp>/`
- Role template backup at `roles/iterm/files/iTerm2/` and `roles/iterm/files/com.googlecode.iterm2.plist`

Restore behavior:
- Restores config directory and plist from role files into the paths above

## Zettlr role details

Config directory:
- `~/Library/Application Support/Zettlr`

Backups (only these items):
- `stats.json`
- `config.json`
- `custom.css`
- `tags.json`
- `targets.json`
- `user.dic`
- `defaults/`
- `snippets/`
- `lua-filter/`

Backup behavior:
- Dated backup at `~/backup/zettlr/<timestamp>/`
- Role template backup at `roles/zettlr/files/Zettlr/`

Restore behavior:
- Restores from `roles/zettlr/files/Zettlr/` into `~/Library/Application Support/Zettlr`

## Tooling role details

What it installs/configures (when `enable_tooling: true`):
- Runtime dependencies via Homebrew: `node`, `python`, `go`, `ruby`
- npm global packages from `npm_global_packages`
- pip user packages from `pip_packages`
- Go tools from `go_packages`
- Ruby gems from `gem_packages`

## Homebrew role details

What it installs/configures:
- Homebrew itself (if missing)
- Packages from `homebrew_packages`
- Casks from `homebrew_casks`

## Dock role details

What it installs/configures:
- Dock autohide, size, magnification, position, and recents
- Hot corners and Dock persistent apps (from `vars/vars.yml`)

## Update role details

Updates:
- Homebrew: `brew update`, `brew upgrade`, `brew upgrade --cask` (cask failures are non-fatal)
- oh-my-zsh, powerlevel10k, and custom plugins via git update
- env managers:
  - git-based: pyenv, goenv, tfenv, nvm
  - SDKMAN: `sdk selfupdate` + `sdk update`
  - rvm: `rvm get stable`
- tmux plugins: TPM `update_plugins all`
- tooling packages: npm globals, pip user packages, Go tools, and Ruby gems

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

## Secret Scanning

Local (pre-commit):
1. Install pre-commit (example: `pip install pre-commit`)
2. Install hooks: `pre-commit install`
3. Run manually: `pre-commit run --all-files`

CI:
- GitHub Actions workflow `Secret Scan` runs gitleaks on pushes and pull requests.

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
