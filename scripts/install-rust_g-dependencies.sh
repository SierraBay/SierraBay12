#!/usr/bin/env bash
set -euo pipefail

sudo dpkg --add-architecture i386
sudo apt update || true
sudo apt install -y libgcc-s1:i386 gcc-multilib g++-multilib libc6-dev-i386 pkg-config git curl

if ! command -v rustup >/dev/null 2>&1; then
	curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal
fi

if [ -n "${GITHUB_PATH:-}" ]; then
	echo "${HOME}/.cargo/bin" >> "${GITHUB_PATH}"
fi
