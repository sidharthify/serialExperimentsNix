#!/usr/bin/env bash
set -e

# definitions
NIX_DIR="/etc/nixos"
CMD_REBUILD_NIX=(sudo nixos-rebuild switch)
GIT=(sudo git)

# colors
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

# push
push() {
  "${GIT[@]}" add .
  "${GIT[@]}" commit -m "serialExperimentsNix: $(date '+%Y-%m-%d %H:%M:%S')"
  "${GIT[@]}" push origin main
}

# enter nix dir
cd "${NIX_DIR}" || exit 1

# run nixos-rebuild, bail if it fails
if ! "${CMD_REBUILD_NIX[@]}"; then
  echo -e "${BLUE}Syncnix:${NC} ${RED}ERROR:${NC} Failed to rebuild"
  exit 1
else
  echo -e "${BLUE}Syncnix: ${NC}NixOS rebuilt!"
fi

# commit & push if there are changes
if [[ -n $("${GIT[@]}" status --porcelain) ]]; then
  push
  echo -e "${BLUE}Git: ${NC}Commit pushed!"
else
  echo -e "${BLUE}Git:${NC} ${RED}ERROR:${NC} No changes to commit"
fi
