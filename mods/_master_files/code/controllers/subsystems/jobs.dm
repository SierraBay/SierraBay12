/datum/controller/subsystem/jobs/equip_rank(mob/living/carbon/human/H, rank, joined_late = 0)
	. = ..()
	if(!H?.mind || !H.client)
		return
	var/datum/payroll_record/record = SSpayroll.ledger.register(H.mind, H.mind.assigned_job)
	var/obj/item/card/id/card = H.GetIdCard()
	if(record && card)
		card.payroll_id = record.id

