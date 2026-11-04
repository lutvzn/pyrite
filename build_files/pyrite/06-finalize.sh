#!/usr/bin/env bash
#
# Final Pyrite tweaks that depend on the packages installed above.
#
set -xeuo pipefail

echo "::group::Finalize Pyrite"
trap 'echo "::endgroup::"' EXIT

# Hide the NVIDIA settings autostart entry on nvidia images.
if [[ -f /etc/xdg/autostart/nvidia-settings-load.desktop ]]; then
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /etc/xdg/autostart/nvidia-settings-load.desktop
fi
