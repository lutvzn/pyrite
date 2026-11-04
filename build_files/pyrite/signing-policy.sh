#!/usr/bin/env bash
#
# Require images from ghcr.io/lutvzn to be signed with Pyrite's key, which the
# Containerfile copies from cosign.pub to /etc/pki/containers/pyrite.pub.
#
set -euo pipefail

key=/etc/pki/containers/pyrite.pub
policy=/etc/containers/policy.json

test -s "$key"
if ! jq -e '.transports.docker["ghcr.io/ublue-os"]' "$policy" > /dev/null; then
    echo "ERROR: $policy is missing or has no ghcr.io/ublue-os rule" >&2
    ls -l /etc/containers /usr/etc/containers >&2 || true
    exit 1
fi
jq --arg key "$key" \
    '.transports.docker["ghcr.io/lutvzn"] = [{type: "sigstoreSigned", keyPath: $key, signedIdentity: {type: "matchRepository"}}]' \
    "$policy" > "$policy.new"
mv "$policy.new" "$policy"
if [ -e /usr/etc/containers/policy.json ]; then
    cp "$policy" /usr/etc/containers/policy.json
fi

# The COPY and the policy edit happen after build.sh's mtime reset.
/ctx/reset-mtimes.sh
