#!/usr/bin/env bash
set -euo pipefail

RUST_G_TARGET="${RUST_G_TARGET:-i686-unknown-linux-gnu}"
RUST_G_LIB="${HOME}/.byond/bin/librust_g.so"
RUST_G_STAMP="${HOME}/.byond/bin/librust_g.cache-key"
RUST_G_CACHE_KEY="${RUST_G_REPO:-}|${RUST_G_BRANCH:-}|${RUST_G_COMMIT:-}|${RUST_G_VERSION:-}|${RUST_G_TARGET}"
RUST_G_REQUIRED_SYMBOLS="${RUST_G_REQUIRED_SYMBOLS:-power_shadow_solve power_shadow_solve_many power_shadow_stateful_apply power_shadow_stateful_reset}"

mkdir -p ~/.byond/bin

cached_rust_g_matches_request() {
	[ -f "${RUST_G_LIB}" ] || return 1
	[ -f "${RUST_G_STAMP}" ] || return 1
	local cached_key
	cached_key="$(<"${RUST_G_STAMP}")"
	[ "${cached_key}" = "${RUST_G_CACHE_KEY}" ]
}

cached_rust_g_has_required_symbols() {
	[ -f "${RUST_G_LIB}" ] || return 1
	[ -n "${RUST_G_REQUIRED_SYMBOLS}" ] || return 0
	if ! command -v nm >/dev/null 2>&1; then
		echo "warning: nm is unavailable, skipping rust_g symbol validation."
		return 0
	fi

	local exported_symbols
	exported_symbols="$(nm -D "${RUST_G_LIB}" 2>/dev/null || true)"
	local symbol
	for symbol in ${RUST_G_REQUIRED_SYMBOLS}; do
		if ! grep -q "[[:space:]]${symbol}\$" <<<"${exported_symbols}"; then
			echo "Cached librust_g.so is missing required symbol: ${symbol}"
			return 1
		fi
	done
}

write_rust_g_stamp() {
	printf '%s\n' "${RUST_G_CACHE_KEY}" > "${RUST_G_STAMP}"
}

if cached_rust_g_matches_request && cached_rust_g_has_required_symbols; then
	echo "Using cached ~/.byond/bin/librust_g.so."
elif [ -n "${RUST_G_BRANCH:-}" ]; then
	if [ -f "${RUST_G_LIB}" ]; then
		echo "Cached ~/.byond/bin/librust_g.so is stale or incompatible. Rebuilding."
		rm -f "${RUST_G_LIB}" "${RUST_G_STAMP}"
	fi
	echo "Building rust_g from ${RUST_G_REPO} branch ${RUST_G_BRANCH} for target ${RUST_G_TARGET}..."
	tmpdir="$(mktemp -d)"
	if [ -n "${RUST_G_COMMIT:-}" ]; then
		git clone "https://github.com/${RUST_G_REPO}.git" "${tmpdir}/rust-g"
	else
		git clone --depth 1 --branch "${RUST_G_BRANCH}" "https://github.com/${RUST_G_REPO}.git" "${tmpdir}/rust-g"
	fi
	pushd "${tmpdir}/rust-g" >/dev/null
	if [ -n "${RUST_G_COMMIT:-}" ]; then
		git checkout "${RUST_G_COMMIT}"
	fi
	if command -v rustup >/dev/null 2>&1; then
		rustup target add "${RUST_G_TARGET}"
	fi
	cargo build --release --target "${RUST_G_TARGET}"
	cp "target/${RUST_G_TARGET}/release/librust_g.so" "${RUST_G_LIB}"
	popd >/dev/null
	rm -rf "${tmpdir}"
	write_rust_g_stamp
else
	if [ -f "${RUST_G_LIB}" ]; then
		echo "Cached ~/.byond/bin/librust_g.so is stale or incompatible. Refreshing."
		rm -f "${RUST_G_LIB}" "${RUST_G_STAMP}"
	fi
	echo "~/.byond/bin/librust_g.so doesn't exist! Downloading..."
	wget -O "${RUST_G_LIB}" "https://github.com/${RUST_G_REPO}/releases/download/${RUST_G_VERSION}/librust_g.so"
	write_rust_g_stamp
fi

chmod +x "${RUST_G_LIB}"

echo "LDD ~/.byond/bin/librust_g.so:"
ldd "${RUST_G_LIB}"
