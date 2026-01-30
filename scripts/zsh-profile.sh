#!/usr/bin/env bash
set -euo pipefail

zsh -ic 'zmodload zsh/zprof; source ~/.zshrc; zprof'
