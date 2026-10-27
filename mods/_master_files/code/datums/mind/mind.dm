/datum/mind
	/// Stable employment identity for the current round, independent of the carried ID/PDA.
	var/payroll_id

/datum/mind/Destroy()
	var/datum/payroll_record/record = SSpayroll?.ledger?.find_record(src)
	if(record)
		SSpayroll.ledger.end_employment(record, "Character mind deleted")
	return ..()

/datum/mind/transfer_to(mob/living/new_character)
	var/datum/payroll_record/record = SSpayroll?.ledger?.find_record(src)
	if(record && !ishuman(new_character))
		SSpayroll.ledger.end_employment(record, "Character transferred to a non-crew body")
	return ..()
