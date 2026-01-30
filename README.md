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

## Inventory

- Default inventory: `inventories/local/hosts.ini`
- Vars: `vars/vars.yml` (default)
- Test vars: `vars/vars-tests.yml`

## Playbook

- `playbooks/site.yml`: full run
- Tags: `common`, `homebrew`, `dock`, `shell`, `dotfiles`

Examples:

```sh
# Homebrew only
ansible-playbook playbooks/site.yml --tags homebrew

# Dock only
ansible-playbook playbooks/site.yml --tags dock

# Shell only (oh-my-zsh + powerlevel10k)
ansible-playbook playbooks/site.yml --tags shell

# Backup runs automatically before `shell`
```

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
and powerlevel10k install and your config loads without errors.

## CI

GitHub Actions runs:
- ansible-lint on Ubuntu
- syntax-check on Ubuntu
- check-mode runs on macOS (Homebrew + Dock)
