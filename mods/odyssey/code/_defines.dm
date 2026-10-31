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

/// After Transfer wins End the shift, wait this long before actually ending the round.
#define ODYSSEY_SHIFT_END_DELAY (5 MINUTES)
/// Countdown from Odyssey Jump initiate to sector transition (BSD).
#define ODYSSEY_BSD_JUMP_DELAY (10 MINUTES)
/// After a continued shift that just arrived via Odyssey Jump: drive thermal lock from previous transition.
#define ODYSSEY_BSD_POST_JUMP_COOLDOWN (90 MINUTES)
/// Last-minute FX window before Odyssey jump climax (bluespace lights, brace cues / local sounds).
#define ODYSSEY_JUMP_FX_BUILDUP (60 SECONDS)

/// status_display mode: Odyssey / sector BSD jump ETA (see status_display_odyssey.dm).
#define STATUS_DISPLAY_BLUESPACE_JUMP 6

#define ODYSSEY_CHOICE_YES "За"
#define ODYSSEY_CHOICE_NO "Против"

/// Command and Communications Program submenu state for the sector map.
#define ODYSSEY_COMM_STATE 6
/// Command submenu: campaign chronicle (public + command entries).
#define ODYSSEY_COMM_CHRONICLE_STATE 7
/// Command submenu: expedition briefing for command staff.
#define ODYSSEY_COMM_BRIEFING_STATE 8

#define ODYSSEY_CHRONICLE_MAX 200
#define ODYSSEY_CHRONICLE_VIS_PUBLIC "public"
#define ODYSSEY_CHRONICLE_VIS_COMMAND "command"
#define ODYSSEY_CHRONICLE_VIS_ADMIN "admin"

#define ODYSSEY_CHRONICLE_KIND_START "campaign_start"
#define ODYSSEY_CHRONICLE_KIND_CONTINUE "campaign_continue"
#define ODYSSEY_CHRONICLE_KIND_COURSE "course_set"
#define ODYSSEY_CHRONICLE_KIND_JUMP "jump"
#define ODYSSEY_CHRONICLE_KIND_SHIFT_END "shift_end"
#define ODYSSEY_CHRONICLE_KIND_SHUTTLE "shuttle_lost"
#define ODYSSEY_CHRONICLE_KIND_SHUTTLE_DAMAGED "shuttle_damaged"
#define ODYSSEY_CHRONICLE_KIND_DEATH "crew_death"
#define ODYSSEY_CHRONICLE_KIND_LOSSES "crew_losses"
#define ODYSSEY_CHRONICLE_KIND_MERC "antag_merc"
#define ODYSSEY_CHRONICLE_KIND_HOSTILE "antag_hostile"
#define ODYSSEY_CHRONICLE_KIND_OUTCOME "outcome"
#define ODYSSEY_CHRONICLE_KIND_ADMIN "admin"
#define ODYSSEY_CHRONICLE_KIND_OBJECTIVE "objective"
#define ODYSSEY_CHRONICLE_KIND_CONTRACT "contract"

#define ODYSSEY_OBJ_STATUS_ACTIVE "active"
#define ODYSSEY_OBJ_STATUS_COMPLETED "completed"
#define ODYSSEY_OBJ_STATUS_FAILED "failed"
#define ODYSSEY_OBJ_STATUS_EXPIRED "expired"

#define ODYSSEY_OBJ_KIND_REACH_FINAL "reach_final"
#define ODYSSEY_OBJ_KIND_RETURN_HOME "return_home"
#define ODYSSEY_OBJ_KIND_SHIP_INTACT "ship_intact"
#define ODYSSEY_OBJ_KIND_HOLD_SECTOR "hold_sector"
#define ODYSSEY_OBJ_KIND_JUMP_ONWARD "jump_onward"
#define ODYSSEY_OBJ_KIND_NO_SHUTTLE_LOSS "no_shuttle_loss"
#define ODYSSEY_OBJ_KIND_LIMIT_CASUALTIES "limit_casualties"
#define ODYSSEY_OBJ_KIND_SURVIVE_HOSTILE "survive_hostile"
#define ODYSSEY_OBJ_KIND_SURVIVE_SHIFT "survive_shift"

#define ODYSSEY_OBJ_VIS_PUBLIC "public"
#define ODYSSEY_OBJ_VIS_COMMAND "command"

#define ODYSSEY_SHIFT_OBJECTIVE_MAX 2
#define ODYSSEY_CASUALTY_SOFT_LIMIT 3
#define ODYSSEY_CASUALTY_HARD_LIMIT 5

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
#define ODYSSEY_CHANGELING_STATUS_ACTIVE "active"
#define ODYSSEY_CHANGELING_STATUS_LOST "lost"

/// Persisted revolutionaries / loyalists (heads and converted members).
#define ODYSSEY_FACTION_RANK_HEAD "head"
#define ODYSSEY_FACTION_RANK_MEMBER "member"
#define ODYSSEY_FACTION_STATUS_ACTIVE "active"
#define ODYSSEY_FACTION_STATUS_DEAD "dead"
#define ODYSSEY_FACTION_STATUS_LOST "lost"

#define ODYSSEY_OUTSIDER_DECISION_SPAWN "spawn"
#define ODYSSEY_OUTSIDER_DECISION_MISS "miss"
#define ODYSSEY_OUTSIDER_DECISION_SKIP_CANDIDATES "skip_candidates"
#define ODYSSEY_OUTSIDER_DECISION_WRONG_SECTOR "wrong_sector"

/// Sierra fleet craft for abandon/damage reports; their areas are always kept in the persist allowlist.
#define ODYSSEY_TRACKED_SHUTTLE_NAMES list("Guppy", "Charon", "Petrov", "Phaethon")

/// Tracked shuttle returned to Sierra with at least this damage score → "damaged" report.
#define ODYSSEY_SHUTTLE_DAMAGE_THRESHOLD 8
/// Approximate repair estimate (thalers) per damage point — display only, not charged.
#define ODYSSEY_SHUTTLE_REPAIR_CREDITS_PER_POINT 40
/// Re-log damage in chronicle if score rose by more than this since the last report.
#define ODYSSEY_SHUTTLE_DAMAGE_REPORT_DELTA 8
#define ODYSSEY_SHUTTLE_STATUS_ABANDONED "abandoned"
#define ODYSSEY_SHUTTLE_STATUS_DAMAGED "damaged"

/// Filing-cabinet paperwork caps (grief / runaway size). Soft: stop adding, log, still save what fits.
#define ODYSSEY_PAPERS_MAX_ITEMS 500
#define ODYSSEY_PAPERS_MAX_PHOTOS 100
#define ODYSSEY_PAPERS_MAX_INFO_BYTES 2000000

/// Roster custody: detained on Sierra brig territory carries into the next shift.
#define ODYSSEY_CUSTODY_BRIG "brig"
#define ODYSSEY_CUSTODY_CRIMINAL_STATUSES list("Incarcerated", "Arrest")
#define ODYSSEY_CUSTODY_AREAS list(\
	/area/security/sierra/prison,\
	/area/security/sierra/brig,\
	/area/security/sierra/hallway/port,\
	/area/security/sierra/hallway/aft,\
	/area/security/sierra/interrogation,\
	/area/security/sierra/interrogation/second,\
	/area/security/prison\
)
#define ODYSSEY_CUSTODY_SPAWN_AREAS list(/area/security/sierra/brig, /area/security/sierra/prison)

/// Science sector briefs (RnD layer for Odyssey). Stored in research.json, not campaign objectives.
#ifndef ODYSSEY_SCI_BRIEF_SPECTRUM
#define ODYSSEY_SCI_BRIEF_SPECTRUM "spectrum"
#define ODYSSEY_SCI_BRIEF_CATALOG "catalog"
#define ODYSSEY_SCI_BRIEF_FLORA "flora"
#define ODYSSEY_SCI_BRIEF_SLIME "slime"
#endif

#define ODYSSEY_SCI_REWARD_SPECTRUM 2000
#define ODYSSEY_SCI_REWARD_CATALOG 2500
#define ODYSSEY_SCI_REWARD_FLORA 2500
#define ODYSSEY_SCI_REWARD_SLIME 3000

#define ODYSSEY_SCI_BRIEFS_MAX 2
#ifndef ODYSSEY_CHRONICLE_KIND_SCIENCE
#define ODYSSEY_CHRONICLE_KIND_SCIENCE "science"
#endif

/// Department sector briefs (Cargo / Medical). Stored alongside science in research.json.
#define ODYSSEY_DEPT_BRIEF_CARGO "cargo_sales"
#define ODYSSEY_DEPT_BRIEF_MEDICAL "medical_exam"
#define ODYSSEY_DEPT_REWARD_MEDICAL 1250
#define ODYSSEY_DEPT_BRIEFS_MAX 2
/// Cargo export quota in thallers (supply sale points × 15 via cargo mod).
#define ODYSSEY_DEPT_CARGO_THALLERS_MIN 750
#define ODYSSEY_DEPT_CARGO_THALLERS_MAX 2700
#define ODYSSEY_DEPT_MEDICAL_COUNT_MIN 2
#define ODYSSEY_DEPT_MEDICAL_COUNT_MAX 4
