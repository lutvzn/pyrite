# TODO

## Test on a booted image

- [ ] Brave Origin: run `ls -l /opt/brave.com` and `brave-origin-stable --version`, then open `brave://sandbox`.
- [ ] Brave Origin: test video acceleration on NVIDIA, Wayland, and deck images.
- [ ] `kernel.kptr_restrict=2`: run `scxctl switch -m auto` and check `journalctl -u scx_loader`. If the scheduler fails, change the value to `1`.
- [ ] Blocked kernel modules: confirm nothing needs them, especially `vkms` and `sctp`.

## Brave Origin

- [ ] Check the first build's log for the Brave Origin step: the `/opt` link, the install scripts, and the move to `/usr/lib/opt`.
- [ ] Change the `build.yml` schedule from weekly to daily (`40 4 * * *`) so browser security fixes reach users sooner.
- [ ] Decide whether to remove the setuid bit from `chrome-sandbox` and rely on user namespaces.
- [ ] Add an SELinux policy adapted from Trivalent's. Start with one `brave_t` domain in permissive mode, and only enforce it after testing.
- [ ] Decide whether Brave Origin should replace Firefox as the default browser. Firefox stays the default for now.

## Finish the rename

- [ ] Update the text of the 12 translated READMEs, which still describe Bazzite.
- [ ] Update the `README.md` notice and install commands once Pyrite publishes its own images.
