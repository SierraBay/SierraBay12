/proc/electra_adherant_effect(mob/living/carbon/human/adherent/victim)
	var/obj/item/cell/power_cell
	var/obj/item/organ/internal/cell/cell = locate() in victim.internal_organs
	if(cell && cell.cell)
		power_cell = cell.cell
	if(power_cell)
		power_cell.charge = power_cell.maxcharge
		to_chat(victim, SPAN_NOTICE("<b>Your [power_cell] has been charged to capacity.</b>"))
