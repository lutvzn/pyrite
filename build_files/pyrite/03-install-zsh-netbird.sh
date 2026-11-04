#!/usr/bin/env bash
#
# Install zsh and NetBird. NetBird's install script generates and starts a service,
# which can't work in an image build, so skip its scripts and ship
# usr/lib/systemd/system/netbird.service instead. It is off by default.
#
set -xeuo pipefail

echo "::group::Install zsh and NetBird"
trap 'echo "::endgroup::"' EXIT

dnf5 -y install zsh gtk4 webkitgtk6.0 xdg-utils ca-certificates
dnf5 -y config-manager addrepo --overwrite --id=netbird \
    --set=name=NetBird \
    --set=baseurl=https://pkgs.netbird.io/yum/ \
    --set=gpgcheck=1 \
    --set=repo_gpgcheck=1 \
    --set=gpgkey=https://pkgs.netbird.io/yum/repodata/repomd.xml.key
dnf5 -y install --setopt=tsflags=noscripts --setopt=install_weak_deps=False netbird netbird-ui
chmod 0600 /etc/sysconfig/netbird
test -x /usr/bin/netbird
test -x /usr/bin/netbird-ui
test -s /usr/share/licenses/netbird/LICENSE
rm -f /etc/yum.repos.d/netbird.repo
