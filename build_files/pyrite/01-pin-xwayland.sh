#!/usr/bin/env bash
#
# Keep Terra's Xwayland on the 24.x series on images that install Hyprland.
# Terra's stale 26.0.99.903-1 build doesn't provide
# xorg-x11-server-Xwayland(x86-64), which the Hyprland package requires, but
# it outranks the fixed 24.x builds. Fedora 44's Terra has 24.1.14 and Fedora
# 45's has 24.1.13, so pin the series, not a single version. Drop this once
# Terra removes the 26.0.99.903 builds or bumps the package's Epoch.
#
# bazzite/05-valve-patches.sh swaps in Terra's newest Xwayland and versionlocks
# it, so move the lock here instead of editing that upstream script. Deck
# images skip Hyprland, so they keep upstream's Xwayland.
#
set -xeuo pipefail

if [[ "${IMAGE_NAME}" == *deck* ]]; then
    echo "Skipping Xwayland pin on deck image ${IMAGE_NAME}"
    exit 0
fi

echo "::group::Pin Xwayland to 24.x"
trap 'echo "::endgroup::"' EXIT

dnf5 versionlock delete terra-xorg-x11-server-Xwayland
dnf5 -y install --allowerasing --repo terra-extras 'terra-xorg-x11-server-Xwayland-24.*'
rpm -q --qf '%{VERSION}\n' terra-xorg-x11-server-Xwayland | grep -q '^24\.'
dnf5 versionlock add terra-xorg-x11-server-Xwayland
