#!/usr/bin/env bash
#
# Orchestration script for Pyrite's additions on top of Bazzite.
#
# Runs from build_files/build.sh after the core, deck and nvidia builds, so
# upstream's scripts stay untouched and merges from Bazzite rarely conflict.
# The signing policy for cosign.pub is set in the Containerfile, since
# cosign.pub sits outside build_files.
#
set -xeuo pipefail

echo "--- Starting Pyrite build ---"

/ctx/pyrite/01-pin-xwayland.sh
/ctx/pyrite/02-install-brave-origin.sh
/ctx/pyrite/03-install-zsh-netbird.sh
/ctx/pyrite/04-install-hyprland.sh
/ctx/pyrite/05-install-brew-proxy.sh
/ctx/pyrite/06-finalize.sh
/ctx/pyrite/07-patch-upstream-files.sh
