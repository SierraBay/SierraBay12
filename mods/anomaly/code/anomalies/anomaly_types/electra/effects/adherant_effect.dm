/mob/living/carbon/human/adherent/electra_mob_effect()
	var/obj/item/cell/power_cell
	var/obj/item/organ/internal/cell/cell = locate() in internal_organs
	if(cell && cell.cell)
		power_cell = cell.cell
	if(power_cell)
		power_cell.charge = power_cell.maxcharge
		to_chat(src, SPAN_NOTICE("<b>Your [power_cell] has been charged to capacity.</b>"))
