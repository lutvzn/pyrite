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

# Brave picks KWallet on KDE and libsecret elsewhere, which would give it a
# different cookie encryption key per desktop. Every image uses oo7 through
# libsecret instead (see 08-configure-oo7.sh), so the key survives switching
# desktops and rebasing between KDE and GNOME images.
wrapper=/usr/lib/opt/brave.com/brave-origin/brave-origin
# Match literal shell code; $HERE and $@ expand in Brave's wrapper at launch.
# shellcheck disable=SC2016
test "$(grep -cF '"$HERE/brave" "$@" || true' "$wrapper")" -eq 1
# shellcheck disable=SC2016
sed -i 's/^"\$HERE\/brave" "\$@" || true$/"$HERE\/brave" --password-store=gnome-libsecret "$@" || true/' "$wrapper"
# shellcheck disable=SC2016
grep -Fxq '"$HERE/brave" --password-store=gnome-libsecret "$@" || true' "$wrapper"

rm -f /etc/yum.repos.d/brave-browser.repo
