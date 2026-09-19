#define ODYSSEY_VERSION 2

/// Flat filename prefix under data/ for campaign JSON files.
#define ODYSSEY_DATA_DIR "data/odyssey"

/// Minimum lobby «За» votes required to start or continue Odyssey.
#define ODYSSEY_MIN_YES_VOTES 10
/// Minimum lobby players required to offer continuing an existing Odyssey.
#define ODYSSEY_MIN_CONTINUE_PLAYERS ODYSSEY_MIN_YES_VOTES

#define ODYSSEY_MIN_SHIFTS 3
#define ODYSSEY_MAX_SHIFTS 5

#define ODYSSEY_STATUS_ACTIVE "active"
#define ODYSSEY_STATUS_COMPLETED "completed"
#define ODYSSEY_STATUS_RETURNED "returned"
#define ODYSSEY_STATUS_EVACUATED "evacuated"
#define ODYSSEY_STATUS_SHIP_DESTROYED "ship_destroyed"
#define ODYSSEY_STATUS_CREW_LOST "crew_lost"
#define ODYSSEY_STATUS_ADMIN_ABORTED "admin_aborted"

#define ODYSSEY_SECTOR_START "start"
#define ODYSSEY_SECTOR_RETURN "return"
#define ODYSSEY_SECTOR_COMPLETE "complete"

#define ODYSSEY_DANGER_SAFE "safe"
#define ODYSSEY_DANGER_CIVILIAN "civilian"
#define ODYSSEY_DANGER_DANGEROUS "dangerous"
#define ODYSSEY_DANGER_HOSTILE "hostile"

/// Pregame: start Odyssey vote this many seconds before round start (same window idea as gamemode vote).
#define ODYSSEY_VOTE_TIMELEFT 90

/// After Transfer wins End the shift, wait this long before actually ending the round.
#define ODYSSEY_SHIFT_END_DELAY (5 MINUTES)

#define ODYSSEY_CHOICE_YES "За"
#define ODYSSEY_CHOICE_NO "Против"

/// Command and Communications Program submenu state for the sector map.
#define ODYSSEY_COMM_STATE 6

/// Roundstart new sleeper traitors per Odyssey shift (persisted sleepers reapply separately).
#define ODYSSEY_SLEEPER_ROUNDSTART_COUNT 1
/// Living Sierra crew above this triggers one extra midround sleeper.
#define ODYSSEY_SLEEPER_CREW_MIDROUND_THRESHOLD 20
/// First midround sleeper check after roundstart.
#define ODYSSEY_SLEEPER_MIDROUND_DELAY (12 MINUTES)
/// Retry midround check if crew was still too low.
#define ODYSSEY_SLEEPER_MIDROUND_RETRY (25 MINUTES)

#define ODYSSEY_SLEEPER_STATUS_ACTIVE "active"
#define ODYSSEY_SLEEPER_STATUS_DEAD "dead"

/// Flat per-shift chance to queue mercenaries while merc_used is false.
#define ODYSSEY_MERC_CHANCE 40
/// Do not roll mercenaries unless at least this many eligible candidates exist.
#define ODYSSEY_MERC_MIN_CANDIDATES 3

#define ODYSSEY_MERC_DECISION_SPAWN "spawn"
#define ODYSSEY_MERC_DECISION_MISS "miss"
#define ODYSSEY_MERC_DECISION_SKIP_CANDIDATES "skip_candidates"

/// Hostile (red) sectors: independent flat chances for raiders and ninja.
#define ODYSSEY_RAIDER_CHANCE 55
#define ODYSSEY_RAIDER_MIN_CANDIDATES 3
#define ODYSSEY_NINJA_CHANCE 50
#define ODYSSEY_NINJA_MIN_CANDIDATES 1

#define ODYSSEY_CHANGELING_MIN 1
#define ODYSSEY_CHANGELING_MAX 2

#define ODYSSEY_OUTSIDER_DECISION_SPAWN "spawn"
#define ODYSSEY_OUTSIDER_DECISION_MISS "miss"
#define ODYSSEY_OUTSIDER_DECISION_SKIP_CANDIDATES "skip_candidates"
#define ODYSSEY_OUTSIDER_DECISION_WRONG_SECTOR "wrong_sector"
