#!/usr/bin/env bash
set -euo pipefail

tag=$1
[[ "$tag" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_.-]{0,127}$ ]] || { echo 'Invalid source tag' >&2; exit 1; }
matrix=$(./build.py matrix | jq -er '.include[] | [.image, .fedora_version] | @tsv')
images=() digests=() versions=()

# Resolve and verify every source before changing any tags.
while IFS=$'\t' read -r variant version; do
    image="ghcr.io/${REPO_OWNER,,}/$variant"
    digest=$(skopeo inspect --no-tags --format '{{.Digest}}' "docker://$image:$tag")
    [[ "$digest" =~ ^sha256:[0-9a-f]{64}$ ]]
    cosign verify --key cosign.pub --new-bundle-format=false "$image@$digest" > /dev/null
    images+=("$image")
    digests+=("$digest")
    versions+=("$version")
done <<< "$matrix"

for i in "${!images[@]}"; do
    for alias in latest stable "${versions[i]}"; do
        skopeo copy --preserve-digests "docker://${images[i]}@${digests[i]}" "docker://${images[i]}:$alias"
    done
done
