#!/usr/bin/env bash
set -euo pipefail

mkdir -p ~/.byond/bin

if [ -f ~/.byond/bin/librust_g.so ]; then
	echo "Using cached ~/.byond/bin/librust_g.so."
elif [ -n "${RUST_G_BRANCH:-}" ]; then
	echo "Building rust_g from ${RUST_G_REPO} branch ${RUST_G_BRANCH}..."
	tmpdir="$(mktemp -d)"
	git clone --depth 1 --branch "${RUST_G_BRANCH}" "https://github.com/${RUST_G_REPO}.git" "${tmpdir}/rust-g"
	pushd "${tmpdir}/rust-g" >/dev/null
	cargo build --release
	cp target/release/librust_g.so ~/.byond/bin/librust_g.so
	popd >/dev/null
	rm -rf "${tmpdir}"
else
	echo "~/.byond/bin/librust_g.so doesn't exist! Downloading..."
	wget -O ~/.byond/bin/librust_g.so "https://github.com/${RUST_G_REPO}/releases/download/${RUST_G_VERSION}/librust_g.so"
fi

chmod +x ~/.byond/bin/librust_g.so

echo "LDD ~/.byond/bin/librust_g.so:"
ldd ~/.byond/bin/librust_g.so
