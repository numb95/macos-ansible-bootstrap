#!/usr/bin/env bash
set -euo pipefail

IMAGE="macos-ansible-shell-test"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is not installed"
  exit 1
fi

docker build -f docker/Dockerfile.shell -t "$IMAGE" .

TTY_FLAG=""
if [ -t 1 ]; then
  TTY_FLAG="-it"
fi

echo "Running shell role test..."
docker run --rm $TTY_FLAG \
  -e HOME=/home/ansible \
  -e USER=ansible \
  -e ZSH=/home/ansible/.oh-my-zsh \
  -e ANSIBLE_CONFIG=/repo/ansible.cfg \
  -e ANSIBLE_COLLECTIONS_PATH=/repo/collections \
  -v "$(pwd)":/repo \
  "$IMAGE" \
  zsh -ic 'mkdir -p ~/.ssh && ansible-playbook playbooks/site.yml --tags shell -e @vars/vars-tests.yml -e macos_home=$HOME -e macos_user=$USER -e omz_path=$HOME/.oh-my-zsh -e p10k_config_path=$HOME/.p10k.zsh -e shell_scripts_dir=$HOME/.shell_scripts && echo "--- DEBUG ---" && echo "HOME=$HOME" && echo "ZSH=$ZSH" && ls -la ~/.shell_scripts || true && ls -la ~/.p10k.zsh || true && sed -n "1,20p" ~/.zshrc || true && echo "--- END DEBUG ---" && source ~/.zshrc && [ -f ~/.p10k.zsh ] && source ~/.p10k.zsh && echo "ZSH=$ZSH" && echo "ZSH_THEME=${ZSH_THEME:-unset}" && echo "P10K=${POWERLEVEL9K_CONFIG_FILE:-unset}" && command -v thefuck >/dev/null && command -v fzf >/dev/null && command -v ssh-agent >/dev/null && [ "${ZSH_THEME:-}" = "powerlevel10k/powerlevel10k" ] && [ -n "${POWERLEVEL9K_CONFIG_FILE:-}" ]; echo "shell role test: OK"'
