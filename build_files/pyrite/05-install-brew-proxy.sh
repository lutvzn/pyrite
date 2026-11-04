#!/usr/bin/env bash
#
# brew-proxy moves Homebrew to a dedicated linuxbrew user and forwards brew
# commands over D-Bus. Not on Deck images: installs need a polkit prompt, which
# is untested in Game Mode.
#
set -xeuo pipefail

if [[ "${IMAGE_NAME}" == *deck* ]]; then
    echo "Skipping brew-proxy on deck image ${IMAGE_NAME}"
    exit 0
fi

echo "::group::Install brew-proxy"
trap 'echo "::endgroup::"' EXIT

dnf5 -y copr enable secureblue/packages
dnf5 -y config-manager setopt 'copr:copr.fedorainfracloud.org:secureblue:packages.includepkgs=brew-proxy*'
dnf5 -y install brew-proxy brew-proxy-selinux
dnf5 -y copr remove secureblue/packages
semodule -l | grep -qx brew-proxy
cp -a /tmp/system_files/brew-proxy/. /
systemctl enable brew-proxy-setup.service brew-proxy-fix-ownership.service brew-proxy-wheel-access.service
