/obj/structure/adherent_bath/Process()
	..()

	if(ishuman(occupant))
		var/mob/living/carbon/human/H = occupant

		if(H.species.name == SPECIES_ADHERENT && prob(1))
			for(var/obj/item/organ/external/E in H.organs)
				if(E.status & ORGAN_BROKEN)
					E.mend_fracture()
					to_chat(H, SPAN_NOTICE("The mineral-rich bath mends internal structure of your [E.name]."))
					break

				if(istype(E, /obj/item/organ/external/head) && E.status & ORGAN_DISFIGURED)
					E.status &= ~ORGAN_DISFIGURED
					to_chat(H, SPAN_NOTICE("The mineral-rich bath mends your [E.name]."))
					break