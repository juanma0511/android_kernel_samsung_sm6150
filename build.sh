#!/usr/bin/env bash
set -e

KERNEL_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$KERNEL_DIR/out"
JOBS="$(nproc --all)"

# Use bundled make 4.3 — system make 4.4 is incompatible with this kernel's build system
MAKE="$KERNEL_DIR/tools/make"
if [ ! -x "$MAKE" ]; then
    MAKE="$(command -v make)"
fi

MAKE_FLAGS=(
    ARCH=arm64
    CROSS_COMPILE=aarch64-linux-gnu-
    HOSTCC=gcc
    HOSTCXX=g++
    DTC_EXT="$KERNEL_DIR/tools/dtc"
    CONFIG_BUILD_ARM64_DT_OVERLAY=y
    O="$OUT"
)

DEFCONFIG="${1:-a70q_defconfig}"

mkdir -p "$OUT"

echo "==> Configuring: $DEFCONFIG"
"$MAKE" -C "$KERNEL_DIR" "${MAKE_FLAGS[@]}" "$DEFCONFIG"

echo "==> Building with $JOBS threads ($(aarch64-linux-gnu-gcc --version | head -1))"
"$MAKE" -C "$KERNEL_DIR" "${MAKE_FLAGS[@]}" -j"$JOBS"

echo "==> Done: $OUT/arch/arm64/boot/Image"
cp "$OUT/arch/arm64/boot/Image" "$KERNEL_DIR/arch/arm64/boot/Image"
