#!/usr/bin/env bash
#
# Install Brave Origin as a system package. The RPM installs to /opt, which links
# to /var/opt on this image and is wiped by cleanup, so move it into /usr/lib/opt.
# usr/lib/tmpfiles.d/pyrite-brave.conf links it back at boot.
#
set -xeuo pipefail

echo "::group::Install Brave Origin"
trap 'echo "::endgroup::"' EXIT

dnf5 -y config-manager addrepo --overwrite --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
mkdir -p /var/opt /usr/lib/opt
dnf5 -y install --setopt=install_weak_deps=False brave-origin
mv /var/opt/brave.com /usr/lib/opt/brave.com
test -x /usr/lib/opt/brave.com/brave-origin/brave
test -u /usr/lib/opt/brave.com/brave-origin/chrome-sandbox
test -s /usr/lib/opt/brave.com/brave-origin/LICENSE
rm -f /etc/yum.repos.d/brave-browser.repo
