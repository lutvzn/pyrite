#!/bin/sh

# Replaces the ublue-os/brew version, which evaluates `brew shellenv` in every
# interactive shell. With brew-proxy that would be a D-Bus call per shell.
#
# Brew stays after system binaries in PATH to prevent it overriding things like dbus.
# See: https://github.com/ublue-os/brew/blob/54b30cc07d3211fca65ca5cc724e9812c8c79b77/system_files/usr/lib/systemd/system/brew-upgrade.service#L17-L22
case "$-" in
  *i*)
    if [ -z "${HOMEBREW_PREFIX:-}" ] && [ -d /home/linuxbrew/.linuxbrew ]; then
      export HOMEBREW_PREFIX='/home/linuxbrew/.linuxbrew'
      export HOMEBREW_CELLAR='/home/linuxbrew/.linuxbrew/Cellar'
      export HOMEBREW_REPOSITORY='/home/linuxbrew/.linuxbrew/Homebrew'
      export PATH="${PATH}:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin"
      [ -z "${MANPATH-}" ] || export MANPATH=":${MANPATH#:}"
      export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:${INFOPATH:-}"
    fi
    ;;
esac
