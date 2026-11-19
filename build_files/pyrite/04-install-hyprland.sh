#!/usr/bin/env bash
#
# Install Hyprland on desktop images only. Its recommended kitty is left out on
# purpose in favor of foot. Hyprland isn't in Fedora, so it comes from a COPR that
# is removed again so it can't replace Fedora packages later. Its priority beats
# Fedora's older hypr* libraries. The system-wide config only applies until the
# user adds ~/.config/hypr/hyprland.lua, which Hyprland looks for first. It adds
# Super+B to open the default browser, which the stock config has no bind for, and
# starts the Noctalia shell, which comes from Fedora and only runs under Hyprland.
# Noctalia also takes over the launcher and the volume, brightness and media keys.
# It also starts oo7 and the KWallet import, which sessions that uwsm doesn't
# manage would otherwise only start on first use, after pam_oo7 has dropped the
# login password. /etc/xdg-desktop-portal/hyprland-portals.conf uses oo7's Secret
# portal on every image.
#
# Needs 01-pin-xwayland.sh to have run first.
#
set -xeuo pipefail

if [[ "${IMAGE_NAME}" == *deck* ]]; then
    echo "Skipping Hyprland on deck image ${IMAGE_NAME}"
    exit 0
fi

echo "::group::Install Hyprland"
trap 'echo "::endgroup::"' EXIT

dnf5 -y copr enable lionheartp/Hyprland
dnf5 -y config-manager setopt copr:copr.fedorainfracloud.org:lionheartp:Hyprland.priority=98
dnf5 -y install --setopt=install_weak_deps=False \
    xdg-desktop-portal-gtk \
    hyprland \
    hyprland-uwsm \
    hyprland-guiutils \
    xdg-desktop-portal-hyprland \
    noctalia
test -x /usr/bin/Hyprland
test -x /usr/bin/noctalia

mkdir -p /etc/xdg/hypr
# The $(...) in the Super+B bind is for Hyprland's shell, not this one.
# shellcheck disable=SC2016
sed -e 's/^local terminal .*/local terminal    = "footclient"/' \
    -e 's/^local menu .*/local menu        = "noctalia msg panel-toggle launcher"/' \
    -e '/^hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))$/a hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("gtk-launch \\"$(xdg-settings get default-web-browser)\\""))' \
    -e '/^-- end)$/a hl.on("hyprland.start", function() hl.exec_cmd("systemctl --user start oo7-daemon.service pyrite-kwallet-import.service") hl.exec_cmd("noctalia") end)' \
    -e '/^hl.bind("XF86AudioRaiseVolume"/s/exec_cmd("[^"]*")/exec_cmd("noctalia msg volume-up")/' \
    -e '/^hl.bind("XF86AudioLowerVolume"/s/exec_cmd("[^"]*")/exec_cmd("noctalia msg volume-down")/' \
    -e '/^hl.bind("XF86AudioMute"/s/exec_cmd("[^"]*")/exec_cmd("noctalia msg volume-mute")/' \
    -e '/^hl.bind("XF86AudioMicMute"/s/exec_cmd("[^"]*")/exec_cmd("noctalia msg mic-mute")/' \
    -e '/^hl.bind("XF86MonBrightnessUp"/s/exec_cmd("[^"]*")/exec_cmd("noctalia msg brightness-up")/' \
    -e '/^hl.bind("XF86MonBrightnessDown"/s/exec_cmd("[^"]*")/exec_cmd("noctalia msg brightness-down")/' \
    -e '/^hl.bind("XF86AudioNext"/s/exec_cmd("[^"]*")/exec_cmd("noctalia msg media next")/' \
    -e '/^hl.bind("XF86AudioPrev"/s/exec_cmd("[^"]*")/exec_cmd("noctalia msg media previous")/' \
    -e '/^hl.bind("XF86Audio\(Pause\|Play\)"/s/exec_cmd("[^"]*")/exec_cmd("noctalia msg media toggle")/' \
    -e '/^-- Requires playerctl$/d' \
    /usr/share/hypr/hyprland.lua > /etc/xdg/hypr/hyprland.lua
grep -q '^local terminal    = "footclient"$' /etc/xdg/hypr/hyprland.lua
grep -q 'mainMod .. " + B"' /etc/xdg/hypr/hyprland.lua
test "$(grep -c '^hl.on("hyprland.start"' /etc/xdg/hypr/hyprland.lua)" -eq 1
grep -qF 'hl.exec_cmd("systemctl --user start oo7-daemon.service pyrite-kwallet-import.service")' /etc/xdg/hypr/hyprland.lua
test "$(grep -c 'noctalia msg' /etc/xdg/hypr/hyprland.lua)" -eq 11
if grep -qE 'wpctl|brightnessctl|playerctl|hyprlauncher' /etc/xdg/hypr/hyprland.lua; then
    echo "ERROR: /etc/xdg/hypr/hyprland.lua still calls a tool Noctalia replaces" >&2
    exit 1
fi
echo footclient.desktop > /etc/xdg/hyprland-xdg-terminals.list

dnf5 -y copr remove lionheartp/Hyprland
