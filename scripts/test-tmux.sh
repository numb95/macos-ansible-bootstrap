#!/usr/bin/env bash
set -euo pipefail

IMAGE="macos-ansible-tmux-test"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is not installed"
  exit 1
fi

docker build -f docker/Dockerfile.tmux -t "$IMAGE" .

TTY_FLAG=""
if [ -t 1 ]; then
  TTY_FLAG="-it"
fi

echo "Running tmux role test..."
docker run --rm $TTY_FLAG \
  -e HOME=/home/ansible \
  -e USER=ansible \
  -e ANSIBLE_CONFIG=/repo/ansible.cfg \
  -e ANSIBLE_COLLECTIONS_PATH=/repo/collections \
  -v "$(pwd)":/repo \
  "$IMAGE" \
  bash -lc 'set -euo pipefail; tmux new-session -d -s test || true; ansible-playbook playbooks/site.yml --tags tmux -e @vars/vars-tests.yml -e macos_home=$HOME -e macos_user=$USER; echo "--- DEBUG ---"; echo "HOME=$HOME"; tmux -V || true; ls -la ~/.tmux ~/.tmux/plugins || true; sed -n "1,40p" ~/.tmux.conf || true; echo "--- END DEBUG ---"; tmux source-file ~/.tmux.conf; tmux list-keys >/dev/null; tmux run-shell ~/.tmux/plugins/tpm/bin/install_plugins >/dev/null; ~/.tmux/plugins/tmux/scripts/wttr.sh | grep -q "Berlin:"; echo "tmux role test: OK"'
