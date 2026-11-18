#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=.github/scripts/brave-rpm.sh
source .github/scripts/brave-rpm.sh

published_evr() {
    local image=$1 tag=$2 digest artifact ref layer
    digest=$(skopeo inspect --no-tags --format '{{.Digest}}' "docker://$image:$tag")
    ref="$image@$digest"
    cosign verify --key cosign.pub --new-bundle-format=false "$ref" > /dev/null
    artifact=$(oras discover --format json "$ref" | jq -er \
        '[.referrers[] | select(.artifactType == "application/vnd.spdx+json")][0].digest')
    cosign verify --key cosign.pub --new-bundle-format=false "$image@$artifact" > /dev/null
    layer=$(oras manifest fetch "$image@$artifact" | jq -er --arg digest "$digest" \
        'select(.subject.digest == $digest and (.layers | length == 1)) | .layers[0].digest')
    oras blob fetch --output - "$image@$layer" | jq -er \
        '[.artifacts[] | select(.type == "rpm" and .name == "brave-origin") | .version] | unique | select(length == 1) | .[0]'
}

matrix=$(./build.py matrix)
arch=$(jq -er '[.include[].arch] | unique | select(length == 1) | .[0]' <<< "$matrix")
# OCI uses amd64; RPM uses x86_64.
[[ "$arch" == amd64 || "$arch" == x86_64 ]]
fedora=$(jq -er '[.include[].fedora_version] | max' <<< "$matrix")
# Same repository as build_files/pyrite/02-install-brave-origin.sh.
latest=$(podman run --rm "registry.fedoraproject.org/fedora:$fedora" bash -euc '
    dnf5 -qy config-manager addrepo --overwrite --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo >&2
    dnf5 -q --repo=brave-browser repoquery --arch=x86_64 --latest-limit=1 --queryformat="%{evr}" brave-origin
')
# Validate even when every published image is already current.
comparison=$(brave_compare "$latest" "$latest")
[[ "$comparison" == 0 ]]

images=()
while IFS= read -r variant; do
    image="ghcr.io/${GITHUB_REPOSITORY_OWNER,,}/$variant"
    stable=$(published_evr "$image" stable)
    comparison=$(brave_compare "$latest" "$stable")
    echo "$variant: repository $latest, stable $stable"
    [[ "$comparison" == 1 ]] || continue

    tags=$(skopeo list-tags "docker://$image")
    if jq -e '.Tags | index("brave-candidate") != null' <<< "$tags" > /dev/null; then
        candidate=$(published_evr "$image" brave-candidate)
        comparison=$(brave_compare "$latest" "$candidate")
        echo "$variant: candidate $candidate"
        [[ "$comparison" == 1 ]] || continue
    fi
    images+=("$variant")
done < <(jq -r '.include[].image' <<< "$matrix")

printf 'images=%s\nevr=%s\n' "${images[*]}" "$latest" >> "$GITHUB_OUTPUT"
