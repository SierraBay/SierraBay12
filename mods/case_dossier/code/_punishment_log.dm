LEGACY_RECORD_STRUCTURE(all_punishments, punishment)

#define PUNISHMENT_STATUS_ACTIVE "Active"
#define PUNISHMENT_STATUS_SERVED "Served"
#define PUNISHMENT_STATUS_APPEALED "Appealed"
#define PUNISHMENT_STATUS_VOIDED "Voided"

GLOBAL_LIST_AS(punishment_types, list("Warning", "Fine", "Brig Time", "Demotion", "Other"))
GLOBAL_LIST_AS(punishment_statuses, list(PUNISHMENT_STATUS_ACTIVE, PUNISHMENT_STATUS_SERVED, PUNISHMENT_STATUS_APPEALED, PUNISHMENT_STATUS_VOIDED))

/datum/computer_file/data/punishment
	var/status = PUNISHMENT_STATUS_ACTIVE

/datum/computer_file/data/punishment/proc/is_active_brig_sentence()
	return status == PUNISHMENT_STATUS_ACTIVE && fields["type"] == "Brig Time" && text2num(fields["brig_minutes"])

/// Called by door timers once a linked sentence has actually finished counting down.
/datum/computer_file/data/punishment/proc/mark_served()
	status = PUNISHMENT_STATUS_SERVED
