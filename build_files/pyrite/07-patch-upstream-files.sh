#!/usr/bin/env bash
#
# Patch files that Bazzite ships, at build time instead of in the source tree,
# so merges from Bazzite don't conflict on them. Every patch is followed by a
# check, so the build fails if Bazzite changes the text a patch relies on.
#
set -xeuo pipefail

echo "::group::Patch upstream files"
trap 'echo "::endgroup::"' EXIT

fail() {
    echo "ERROR: $*" >&2
    exit 1
}

# Point the rollback helper at Pyrite's images. IMAGE_INFO is a path, not a
# registry, so it keeps ublue-os. Pyrite doesn't build the dx variants.
f=/usr/bin/bazzite-rollback-helper
sed -i \
    -e '/^  "bazzite-dx/d' \
    -e 's/^  "bazzite\(.*\)"$/  "pyrite\1"/' \
    -e '/^IMAGE_INFO=/!s/ublue-os/lutvzn/g' \
    -e 's/skopeo_tags "lutvzn" "bazzite"/skopeo_tags "lutvzn" "pyrite"/' \
    -e 's/rebase bazzite-gnome:/rebase pyrite-gnome:/' \
    "$f"
if grep -v '^IMAGE_INFO=' "$f" | grep -q 'ublue-os'; then
    fail "$f still refers to ublue-os"
fi
if grep -q '"bazzite' "$f"; then
    fail "$f still lists a bazzite image"
fi
test "$(grep -c '^  "pyrite' "$f")" -eq 9 || fail "$f doesn't list the 9 Pyrite variants"
test "$(grep -c 'skopeo_tags "lutvzn" "pyrite"' "$f")" -eq 2 || fail "$f doesn't list Pyrite's tags"
bash -n "$f"

# Warn about unverified Pyrite images rather than unverified Bazzite ones.
f=/etc/profile.d/verify_motd.sh
sed -i 's|^\( *OFFICIAL_TAG=\)"ghcr.io/ublue-os/"$|\1"ghcr.io/lutvzn/"|' "$f"
grep -q '^ *OFFICIAL_TAG="ghcr.io/lutvzn/"$' "$f" || fail "$f wasn't patched"
bash -n "$f"

f=/usr/share/ublue-os/just/92-bazzite-verify.just
sed -i 's|\*"ghcr.io/ublue-os/"\*|*"ghcr.io/lutvzn/"*|' "$f"
grep -qF '*"ghcr.io/lutvzn/"*' "$f" || fail "$f wasn't patched"
if grep -q 'ghcr.io/ublue-os/' "$f"; then
    fail "$f still checks for ghcr.io/ublue-os/"
fi

# Homebrew refuses to load casks from taps that aren't trusted. Bazzite's ujust
# recipes and yafti already run `brew trust` first, but Bazaar's hook doesn't.
# Skip this once Bazzite fixes the hook itself.
f=/usr/share/ublue-os/bazaar/hooks.py
if ! grep -q 'brew trust ublue-os/tap' "$f"; then
    sed -i "s|brew_eval(f'brew tap ublue-os/tap && |brew_eval(f'brew trust ublue-os/tap \\&\\& brew tap ublue-os/tap \\&\\& |" "$f"
    grep -qF "brew_eval(f'brew trust ublue-os/tap && brew tap ublue-os/tap && brew install --cask {cask}')" "$f" ||
        fail "$f wasn't patched"
fi
python3 -c 'import ast, sys; ast.parse(open(sys.argv[1]).read())' "$f"
