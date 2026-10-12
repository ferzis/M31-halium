#!/usr/bin/env bash
set -euo pipefail

config_file="${1:?usage: check-m31-halium-config.sh path/to/.config}"
if [[ ! -r "$config_file" ]]; then
  echo "ERROR: kernel config not readable: $config_file" >&2
  exit 2
fi

required=(
  CONFIG_DEVTMPFS
  CONFIG_FHANDLE
  CONFIG_SYSVIPC
  CONFIG_IPC_NS
  CONFIG_NET_NS
  CONFIG_PID_NS
  CONFIG_USER_NS
  CONFIG_UTS_NS
  CONFIG_VT
  CONFIG_IKCONFIG
  CONFIG_IKCONFIG_PROC
  CONFIG_CGROUPS
  CONFIG_SECCOMP
  CONFIG_SECCOMP_FILTER
  CONFIG_BLK_DEV_LOOP
  CONFIG_INPUT_EVDEV
  CONFIG_ANDROID_BINDER_IPC
  CONFIG_ASHMEM
  CONFIG_FUSE_FS
  CONFIG_OVERLAY_FS
  CONFIG_TMPFS
)

failed=0
for option in "${required[@]}"; do
  if ! grep -qx "${option}=y" "$config_file"; then
    echo "ERROR: required Halium option missing or disabled: $option" >&2
    failed=1
  fi
done

if (( failed )); then
  echo "Halium kernel config validation failed." >&2
  exit 1
fi

echo "Halium kernel config validation passed."
