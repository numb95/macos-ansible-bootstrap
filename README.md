# macos-ansible-bootstrap

Small, practical Ansible setup to rebuild a macOS workstation: Homebrew packages/casks, Dock layout, and a few essentials. The goal is repeatability without over-engineering.

Heavily influenced by [geerlingguy/mac-dev-playbook](https://github.com/geerlingguy/mac-dev-playbook/).

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
- Tags: `common`, `homebrew`, `dock`, `dotfiles`

Examples:

```sh
# Homebrew only
ansible-playbook playbooks/site.yml --tags homebrew

# Dock only
ansible-playbook playbooks/site.yml --tags dock
```

## Tests

```sh
make test
```

This runs the playbook in check mode using `vars/vars-tests.yml`.

## CI

GitHub Actions runs:
- ansible-lint on Ubuntu
- syntax-check on Ubuntu
- check-mode runs on macOS (Homebrew + Dock)
