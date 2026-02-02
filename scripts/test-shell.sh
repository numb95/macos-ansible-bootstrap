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
  zsh -ic '
set -euo pipefail

mkdir -p ~/.ssh

ansible-playbook playbooks/site.yml --tags shell \
  -e @vars/vars-tests.yml \
  -e macos_home=$HOME \
  -e macos_user=$USER \
  -e omz_path=$HOME/.oh-my-zsh \
  -e p10k_config_path=$HOME/.p10k.zsh \
  -e shell_scripts_dir=$HOME/.shell_scripts \
  -e enable_sdkman=true \
  -e enable_goenv=true \
  -e enable_pyenv=true \
  -e enable_tfenv=true \
  -e enable_nvm=true \
  -e enable_rvm=false \
  -e enable_tfswitch=false \
  -e enable_fvm=false

echo "--- DEBUG ---"
echo "HOME=$HOME"
echo "ZSH=$ZSH"
ls -la ~/.shell_scripts || true
ls -la ~/.p10k.zsh || true
sed -n "1,20p" ~/.zshrc || true
echo "--- END DEBUG ---"

export ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
export ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-$HOME/.zsh/cache}"
source ~/.zshrc
if [ -f ~/.p10k.zsh ]; then
  source ~/.p10k.zsh
fi

echo "ZSH=$ZSH"
echo "ZSH_THEME=${ZSH_THEME:-unset}"
echo "P10K=${POWERLEVEL9K_CONFIG_FILE:-unset}"

echo "CHECK: core commands"
command -v thefuck >/dev/null
command -v fzf >/dev/null
command -v ssh-agent >/dev/null

echo "CHECK: theme"
[ "${ZSH_THEME:-}" = "powerlevel10k/powerlevel10k" ]
[ -n "${POWERLEVEL9K_CONFIG_FILE:-}" ]

echo "CHECK: dirs"
[ -d "$HOME/.sdkman" ]
[ -d "$HOME/.goenv" ]
[ -d "$HOME/.pyenv" ]
[ -d "$HOME/.tfenv" ]
[ -d "$HOME/.nvm" ]
[ -s "$HOME/.nvm/nvm.sh" ]

echo "CHECK: binaries"
command -v goenv >/dev/null
command -v pyenv >/dev/null
command -v tfenv >/dev/null

echo "CHECK: versions"
goenv --version >/dev/null
pyenv --version >/dev/null
tfenv --version >/dev/null

echo "CHECK: nvm"
bash -lc "source $HOME/.nvm/nvm.sh && nvm --version" >/dev/null

echo "CHECK: sdk"
bash -lc "source $HOME/.sdkman/bin/sdkman-init.sh && sdk version" >/dev/null

echo "shell role test: OK"
'
