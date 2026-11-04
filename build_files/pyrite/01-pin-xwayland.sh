#!/usr/bin/env bash
#
# Keep Terra's Xwayland on the 24.x series. Its 26.x prerelease no longer
# provides xorg-x11-server-Xwayland(x86-64), which the Hyprland package requires.
# Fedora 44's Terra had 24.1.14 and Fedora 45's has 24.1.13, so pin the series,
# not a single version.
#
# bazzite/05-valve-patches.sh swaps in Terra's newest Xwayland and versionlocks
# it, so move the lock here instead of editing that upstream script.
#
set -xeuo pipefail

echo "::group::Pin Xwayland to 24.x"
trap 'echo "::endgroup::"' EXIT

dnf5 versionlock delete terra-xorg-x11-server-Xwayland
dnf5 -y install --allowerasing --repo terra-extras 'terra-xorg-x11-server-Xwayland-24.*'
rpm -q --qf '%{VERSION}\n' terra-xorg-x11-server-Xwayland | grep -q '^24\.'
dnf5 versionlock add terra-xorg-x11-server-Xwayland
