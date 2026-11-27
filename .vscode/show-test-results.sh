#!/bin/bash
# Prints the unit test verdict from the newest round log, so there is no need to
# go digging through data/logs/ after a "Run Unit Tests" session.
#
# Run automatically as the postDebugTask of the "Run Unit Tests" launch configs,
# and available on its own as the "dm: show unit test results" task.

shopt -s nullglob

latest=""
for dir in data/logs/*/*/*/round-*; do
	[ -d "$dir" ] || continue
	if [ -z "$latest" ] || [ "$dir" -nt "$latest" ]; then
		latest="$dir"
	fi
done

if [ -z "$latest" ]; then
	echo "No round logs found under data/logs/ - did the server actually start?"
	exit 0
fi

log="$latest/game.log"
if [ ! -f "$log" ]; then
	echo "Newest round is $latest, but it has no game.log."
	exit 0
fi

# Drops the "[timestamp] DEBUG: " prefix so the lines stay readable in a panel.
strip_prefix() {
	sed -E 's/^\[[^]]*\] DEBUG: //'
}

echo "=== $log ==="
echo

failures=$(grep -c '!!! FAILURE !!!' "$log")
if [ "$failures" -gt 0 ]; then
	echo "--- $failures failing test(s) ---"
	grep '!!! FAILURE !!!' "$log" | strip_prefix
	echo
fi

runtimes=$(grep -c 'runtime error:' "$log")
if [ "$runtimes" -gt 0 ]; then
	echo "--- $runtimes runtime error(s), first 10 ---"
	grep 'runtime error:' "$log" | head -10 | strip_prefix
	echo
fi

# Matches both "**** All Unit Tests Passed [N] ****" and "**** [N\M] Unit Tests Failed ****".
echo "--- summary ---"
if ! grep -E '\*\*\*\*|Caught [0-9]+ Runtime' "$log" | strip_prefix; then
	echo "No summary line found - the run probably crashed or was stopped early."
fi
