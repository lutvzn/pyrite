# TODO

## Test on a booted image

- [ ] Brave Origin: run `ls -l /opt/brave.com` and `brave-origin-stable --version`, then open `brave://sandbox`.
- [ ] Brave Origin: test video acceleration on NVIDIA, Wayland, and deck images.
- [ ] `kernel.kptr_restrict=2`: run `scxctl switch -m auto` and check `journalctl -u scx_loader`. If the scheduler fails, change the value to `1`.
- [ ] Blocked kernel modules: confirm nothing needs them, especially `sctp`.

- [ ] Hyprland: log in on a GNOME image, then check screen sharing and file pickers. Also check that KDE and GNOME's own sessions still use their usual portals.
- [ ] Hyprland passwords: log out and back in on KDE and GNOME images. Check that `busctl --user status org.freedesktop.secrets` finds the service without a password prompt, that a saved password survives a new login, and that a Flatpak app can save one too. Also check the uwsm session.
- [ ] Noctalia: log in to Hyprland and check that the bar starts, and that notifications, the lock screen and the battery and power widgets work. Try Super+R and the volume, mic, brightness and media keys, including on the lock screen. Also check that it doesn't start in KDE or GNOME sessions.

- [ ] brew-proxy updates: run `ujust update` and check that `uupd` still updates brew now that `linuxbrew` owns it. Then run `sudo systemctl start brew-upgrade.service` and check its status. Also check why `brew-update.timer` and `brew-upgrade.timer` are disabled.
- [ ] brew-proxy casks: after rebuilding with the `hooks.py` trust fix, install VS Code from Bazaar without running `brew trust` by hand. Check that it appears in the launcher, logging out and back in if needed.
- [ ] brew-proxy recipes: test `brew bundle` through `ujust bazzite-cli enable`, `bbrew-helper`, and yafti's brew installs.
- [ ] brew-proxy Sunshine: test `ujust setup-sunshine enable-brew`, since `brew services` now belongs to `linuxbrew` instead of the desktop user.
- [ ] brew-proxy analytics: decide whether to set `HOMEBREW_NO_ANALYTICS=1` in the image.
- [ ] brew-proxy on Deck: test a brew install with its password prompt in Game Mode before adding brew-proxy to Deck images.

## Brave Origin

- [ ] Check the first build's log for the Brave Origin step: the `/opt` link, the install scripts, and the move to `/usr/lib/opt`.
- [ ] Change the `build.yml` schedule from weekly to daily (`40 4 * * *`) so browser security fixes reach users sooner.
- [ ] Decide whether to remove the setuid bit from `chrome-sandbox` and rely on user namespaces.
- [ ] Add an SELinux policy adapted from Trivalent's. Start with one `brave_t` domain in permissive mode, and only enforce it after testing.
- [ ] Decide whether Brave Origin should replace Firefox as the default browser. Firefox stays the default for now.

## Finish the rename

- [ ] The README now lives in `.github/README.md`, so the root `README*.md` files stay identical to Bazzite's. Update its Desktop, Deck and GNOME rebase commands, which still install Bazzite, if Pyrite builds those variants.
