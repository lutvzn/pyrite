#!/usr/bin/env bash
set -euo pipefail

image=$1
candidate=$2
logs=$3
mkdir -p "$logs"
work=$(mktemp -d)
vm=
boot_user=pyrite-smoke
password=$(openssl rand -hex 24)
ssh_vm() {
    ssh -F /dev/null -o BatchMode=yes -o ConnectTimeout=5 \
        -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile="$work/known_hosts" \
        -i "$work/id" -p 2222 "$boot_user@127.0.0.1" "$@"
}
root_vm() {
    printf '%s\n' "$password" | ssh_vm "sudo -kS -p '' $*"
}
cleanup() {
    local result=$?
    if [[ -n "$vm" ]]; then
        if (( result != 0 )); then
            root_vm journalctl -b --no-pager -n 500 > "$logs/guest-journal.log" 2>&1 || true
        fi
        kill "$vm" 2>/dev/null || true
        wait "$vm" 2>/dev/null || true
    fi
    rm -rf "$work"
}
trap cleanup EXIT

stable=$(skopeo inspect --no-tags --format '{{.Digest}}' "docker://$image:stable")
for digest in "$stable" "$candidate"; do
    [[ "$digest" =~ ^sha256:[0-9a-f]{64}$ ]]
    cosign verify --key cosign.pub --new-bundle-format=false "$image@$digest" > /dev/null
done

ssh-keygen -q -t ed25519 -N '' -f "$work/id"
cat > "$work/config.toml" <<EOF
[[customizations.user]]
name = "$boot_user"
password = "$password"
key = "$(cat "$work/id.pub")"
groups = ["wheel"]

[customizations.services]
enabled = ["sshd.service"]

[[customizations.filesystem]]
mountpoint = "/"
minsize = "40 GiB"
EOF
mkdir "$work/output"
sudo podman pull "$image@$stable"
sudo podman run --rm --privileged \
    --volume "$work/config.toml:/config.toml:ro" \
    --volume "$work/output:/output" \
    --volume /var/lib/containers/storage:/var/lib/containers/storage \
    quay.io/centos-bootc/bootc-image-builder@sha256:dab86ee6b46dcade411b37f4e70b07d93b6a06da0dbfec6fe89247a220e0d9f8 \
    --type qcow2 --rootfs btrfs --chown "$(id -u):$(id -g)" "$image@$stable"

accel=(-accel 'tcg,thread=multi' -cpu max)
if [[ -e /dev/kvm ]]; then
    sudo chmod a+rw /dev/kvm
    accel=(-accel kvm -cpu host)
fi
cp /usr/share/OVMF/OVMF_VARS_4M.fd "$work/ovmf-vars.fd"
qemu-system-x86_64 -machine q35 "${accel[@]}" -smp 4 -m 4096 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd \
    -drive "if=pflash,format=raw,file=$work/ovmf-vars.fd" \
    -drive "if=virtio,format=qcow2,file=$work/output/qcow2/disk.qcow2" \
    -device virtio-vga -display none -monitor none -serial "file:$logs/serial.log" \
    -nic user,model=virtio-net-pci,hostfwd=tcp:127.0.0.1:2222-:22 \
    > "$logs/qemu.log" 2>&1 &
vm=$!

wait_for_boot() {
    local previous=${1:-} boot_id attempt
    for ((attempt = 0; attempt < 90; attempt++)); do
        kill -0 "$vm" || return 1
        if boot_id=$(ssh_vm 'cat /proc/sys/kernel/random/boot_id' 2>/dev/null) &&
            [[ -n "$boot_id" && "$boot_id" != "$previous" ]] &&
            ssh_vm 'systemctl is-active --quiet display-manager.service'; then
            printf '%s\n' "$boot_id"
            return
        fi
        sleep 5
    done
    echo 'Timed out waiting for a new boot and an active display manager' >&2
    return 1
}

assert_deployment() {
    local expected=$1 status
    status=$(ssh_vm 'rpm-ostree status --json')
    jq -er --arg digest "$expected" '
        .deployments[] | select(.booted and .["container-image-reference-digest"] == $digest) | .checksum
    ' <<< "$status"
}

boot_id=$(wait_for_boot)
initial_checksum=$(assert_deployment "$stable")
echo "Booted stable: $stable ($initial_checksum)"
root_vm rpm-ostree rebase "ostree-image-signed:docker://$image@$candidate"
root_vm systemd-run --on-active=2s systemctl reboot
boot_id=$(wait_for_boot "$boot_id")
candidate_checksum=$(assert_deployment "$candidate")
echo "Booted candidate: $candidate ($candidate_checksum)"

ssh_vm bash -s > "$logs/brave-sandbox.html" <<'GUEST'
set -eu
profile=$(mktemp -d)
trap 'rm -rf "$profile"' EXIT
timeout 90 brave-origin-stable --headless --disable-gpu --no-first-run --allow-chrome-scheme-url \
    --user-data-dir="$profile" --dump-dom brave://sandbox
GUEST
grep -F 'You are adequately sandboxed.' "$logs/brave-sandbox.html" > /dev/null

root_vm rpm-ostree rollback
root_vm systemd-run --on-active=2s systemctl reboot
wait_for_boot "$boot_id" > /dev/null
rolled_back_checksum=$(assert_deployment "$stable")
[[ "$rolled_back_checksum" == "$initial_checksum" ]]
echo "Rolled back to $stable ($rolled_back_checksum)"
