#!/usr/bin/env bash
#
# Use oo7 as the Secret Service on every image, so secrets stay in the same
# keyring (~/.local/share/keyrings/v1) after a rebase between KDE and GNOME.
# Fedora already does this for GNOME. On KDE images, kwalletd6 only passes
# the KWallet API through to oo7: /etc/xdg/kwalletrc turns off ksecretd, and
# pam_kwallet goes, since it only starts ksecretd. The login manager's PAM
# stack unlocks oo7 with pam_oo7 instead.
#
# oo7 starts with any session that reaches graphical-session-pre.target, or
# with Hyprland's config, or on first use through D-Bus. pam_oo7's login
# helper only holds the password for two minutes, so it has to start early.
# pyrite-kwallet-import moves KWallet secrets into oo7 at the first login.
#
set -xeuo pipefail

echo "::group::Configure oo7"
trap 'echo "::endgroup::"' EXIT

fail() {
    echo "ERROR: $*" >&2
    exit 1
}

dnf5 -y install --setopt=install_weak_deps=False \
    oo7-daemon \
    oo7-portal \
    pam_oo7 \
    python3-secretstorage
test -x /usr/libexec/oo7-daemon
test -f /usr/lib64/security/pam_oo7.so
test -f /usr/share/xdg-desktop-portal/portals/oo7-portal.portal
python3 -c 'import secretstorage'
python3 -c 'import ast, sys; ast.parse(open(sys.argv[1]).read())' /usr/libexec/pyrite-kwallet-import
# gnome-keyring would take org.freedesktop.secrets from oo7.
if rpm -q gnome-keyring; then
    fail "gnome-keyring is installed"
fi
f=/usr/share/dbus-1/services/org.freedesktop.secrets.service
if rpm -qf "$f"; then
    fail "$f belongs to a package, so it may not start oo7"
fi
grep -qx 'SystemdService=dbus-org.freedesktop.secrets.service' "$f" || fail "$f doesn't start oo7"

if [[ "${BASE_IMAGE_NAME}" == kinoite ]]; then
    if rpm -q pam-kwallet; then
        dnf5 -y remove pam-kwallet
    fi
    test ! -e /usr/libexec/pam_kwallet_init
    test ! -e /usr/lib64/security/pam_kwallet5.so

    grep -qx 'Enabled=false' /etc/xdg/kwalletrc || fail "/etc/xdg/kwalletrc doesn't turn off ksecretd"
    grep -qx 'apiEnabled=false' /etc/xdg/kwalletrc || fail "/etc/xdg/kwalletrc doesn't turn off ksecretd's Secret Service"

    f=/usr/share/xdg-desktop-portal/kde-portals.conf
    sed -i 's/^org\.freedesktop\.impl\.portal\.Secret=kwallet$/org.freedesktop.impl.portal.Secret=oo7-portal/' "$f"
    grep -qx 'org.freedesktop.impl.portal.Secret=oo7-portal' "$f" || fail "$f wasn't patched"
fi

# Every login manager on these images must unlock oo7 with the login password.
found=false
for f in /usr/lib/pam.d/plasmalogin /usr/lib/pam.d/gdm-password /etc/pam.d/sddm; do
    [[ -e "$f" ]] || continue
    found=true
    grep -Eq '^-?auth[[:blank:]]+optional[[:blank:]]+pam_oo7\.so$' "$f" || fail "$f doesn't pass the password to pam_oo7"
    grep -Eq '^-?session[[:blank:]]+optional[[:blank:]]+pam_oo7\.so auto_start$' "$f" || fail "$f doesn't start pam_oo7"
done
$found || fail "no known login manager PAM config found"

# Re-encrypt the keyring when the password changes with passwd, as GDM's own
# stack does. https://github.com/ublue-os/bazzite/issues/6274
f=/etc/pam.d/passwd
if ! grep -q 'pam_oo7\.so' "$f"; then
    sed -i '/^-password[[:blank:]]\+optional[[:blank:]]\+pam_gnome_keyring\.so use_authtok$/a -password   optional'$'\t''pam_oo7.so use_authtok' "$f"
fi
grep -Eq '^-password[[:blank:]]+optional[[:blank:]]+pam_oo7\.so use_authtok$' "$f" || fail "$f wasn't patched"

systemctl --global add-wants graphical-session-pre.target oo7-daemon.service
systemctl --global enable pyrite-kwallet-import.service
