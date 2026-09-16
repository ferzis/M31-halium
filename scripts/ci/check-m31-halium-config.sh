#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0
# Verify that the M31 defconfig retains the kernel interfaces needed by Halium.
set -euo pipefail

config=${1:?usage: $0 <kernel-config>}
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

require_config() {
  local option=$1
  if ! grep -qx "${option}" "${config}"; then
    echo "Missing required Halium/M31 option: ${option}" >&2
    exit 1
  fi
}

# Android compatibility required by libhybris and Android vendor services.
require_config 'CONFIG_ANDROID=y'
require_config 'CONFIG_ANDROID_BINDER_IPC=y'
require_config 'CONFIG_ANDROID_BINDERFS=y'
require_config 'CONFIG_ANDROID_BINDER_DEVICES="binder,hwbinder,vndbinder"'
require_config 'CONFIG_ASHMEM=y'
require_config 'CONFIG_ION=y'
require_config 'CONFIG_ION_EXYNOS=y'

# Droidian's Halium initramfs and userspace requirements.
require_config 'CONFIG_BLK_DEV_INITRD=y'
require_config 'CONFIG_RD_LZ4=y'
require_config 'CONFIG_DEVTMPFS=y'
require_config 'CONFIG_TMPFS=y'
require_config 'CONFIG_EXT4_FS=y'
require_config 'CONFIG_F2FS_FS=y'
require_config 'CONFIG_OVERLAY_FS=y'
require_config 'CONFIG_CGROUPS=y'
require_config 'CONFIG_NAMESPACES=y'
require_config 'CONFIG_SECCOMP=y'
require_config 'CONFIG_SECCOMP_FILTER=y'
require_config 'CONFIG_USB_CONFIGFS=y'
require_config 'CONFIG_USB_CONFIGFS_F_FS=y'
require_config 'CONFIG_USB_CONFIGFS_F_MTP=y'
require_config 'CONFIG_USB_CONFIGFS_RNDIS=y'

# Samsung M31 storage, display, touch, audio, power and sensor drivers.
require_config 'CONFIG_SCSI_UFSHCD=y'
require_config 'CONFIG_SCSI_UFS_EXYNOS=y'
require_config 'CONFIG_EXYNOS_DECON_LCD_EA8076_M31=y'
require_config 'CONFIG_TOUCHSCREEN_MELFAS_MSS100=y'
require_config 'CONFIG_SND_SOC_SAMSUNG_EXYNOS9610=y'
require_config 'CONFIG_BATTERY_SAMSUNG=y'
require_config 'CONFIG_CHARGER_S2MU106=y'
require_config 'CONFIG_SENSORS_SSP_M31=y'
require_config 'CONFIG_SENSORS_A96T3X6_M31=y'

# Every M31 regional/revision overlay must be part of the DTBO build.
for overlay in \
  exynos9611-m31_eur_open_00 \
  exynos9611-m31_eur_open_01 \
  exynos9611-m31_swa_open_00 \
  exynos9611-m31_swa_open_01; do
  dts="${root}/arch/arm64/boot/dts/samsung/${overlay}.dts"
  test -s "${dts}"
  grep -q 'samsung, M31' "${dts}"
  grep -q 'dtbo-hw_rev' "${dts}"
  grep -q "samsung/${overlay}.dtbo" "${root}/arch/arm64/boot/dts/Makefile"
done

echo 'M31 Halium/Droidian configuration check passed.'
