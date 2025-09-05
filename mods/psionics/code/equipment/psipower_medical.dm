/obj/item/clothing/gloves/latex/psi
	name = "psychokinetic gloves"

	var/maintain_cost = 2
	var/mob/living/owner
	color = "#0095ff"
	alpha = 110

/obj/item/clothing/gloves/latex/psi/New()
	owner = usr
	if(!istype(owner))
		qdel(src)
		return
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/clothing/gloves/latex/psi/Destroy()
	if(istype(owner) && owner.psi)
		LAZYREMOVE(owner.psi.manifested_items, src)
		UNSETEMPTY(owner.psi.manifested_items)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/clothing/gloves/latex/psi/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/clothing/gloves/latex/psi/dropped()
	..()
	qdel(src)

/obj/item/clothing/gloves/latex/psi/Process()
	if(istype(owner))
		owner.psi.spend_power(maintain_cost)
	var/mob/living/carbon/human/H = owner
	if(!H || H.do_psionics_check(maintain_cost, H) || loc != H || (H.l_hand != src && H.r_hand != src && H.gloves != src))
		if(isliving(loc))
			var/mob/living/carbon/human/host = loc
			if(istype(host))
				for(var/obj/item/organ/external/organ in host.organs)
					for(var/obj/item/O in organ.implants)
						if(O == src)
							organ.implants -= src
			host.pinned -= src
			host.embedded -= src
			host.drop_from_inventory(src)
		else
			STOP_PROCESSING(SSprocessing, src)

//RETRACTOR

/obj/item/retractor/psi
	name = "psychokinetic retractor"
	item_state = "retractor"

	var/mob/living/owner
	color = "#0095ff"
	alpha = 110

/obj/item/retractor/psi/New()
	owner = usr
	if(!istype(owner))
		qdel(src)
		return
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/retractor/psi/Destroy()
	if(istype(owner) && owner.psi)
		LAZYREMOVE(owner.psi.manifested_items, src)
		UNSETEMPTY(owner.psi.manifested_items)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/retractor/psi/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/retractor/psi/attack_self(mob/user)
	sound_to(owner, 'sound/effects/psi/power_fail.ogg')
	user.drop_from_inventory(src)

/obj/item/retractor/psi/dropped()
	..()
	qdel(src)

//HEMOSTAT

/obj/item/hemostat/psi
	name = "psychokinetic hemostat"
	item_state = "hemostat"

	var/mob/living/owner
	color = "#0095ff"
	alpha = 110

/obj/item/hemostat/psi/New()
	owner = usr
	if(!istype(owner))
		qdel(src)
		return
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/hemostat/psi/Destroy()
	if(istype(owner) && owner.psi)
		LAZYREMOVE(owner.psi.manifested_items, src)
		UNSETEMPTY(owner.psi.manifested_items)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/hemostat/psi/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/hemostat/psi/attack_self(mob/user)
	sound_to(owner, 'sound/effects/psi/power_fail.ogg')
	user.drop_from_inventory(src)

/obj/item/hemostat/psi/dropped()
	..()
	qdel(src)

//DRILL

/obj/item/surgicaldrill/psi
	name = "psychokinetic drill"
	item_state = "drill"

	var/mob/living/owner
	color = "#0095ff"
	alpha = 110

/obj/item/surgicaldrill/psi/New()
	owner = usr
	if(!istype(owner))
		qdel(src)
		return
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/surgicaldrill/psi/Destroy()
	if(istype(owner) && owner.psi)
		LAZYREMOVE(owner.psi.manifested_items, src)
		UNSETEMPTY(owner.psi.manifested_items)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/surgicaldrill/psi/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/surgicaldrill/psi/attack_self(mob/user)
	sound_to(owner, 'sound/effects/psi/power_fail.ogg')
	user.drop_from_inventory(src)

/obj/item/surgicaldrill/psi/dropped()
	..()
	qdel(src)

//SCALPEL

/obj/item/scalpel/psi
	name = "psychokinetic scalpel"
	item_state = "scalpel"

	var/mob/living/owner
	color = "#0095ff"
	alpha = 110

/obj/item/scalpel/psi/New()
	owner = usr
	if(!istype(owner))
		qdel(src)
		return
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/scalpel/psi/Destroy()
	if(istype(owner) && owner.psi)
		LAZYREMOVE(owner.psi.manifested_items, src)
		UNSETEMPTY(owner.psi.manifested_items)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/scalpel/psi/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/scalpel/psi/attack_self(mob/user)
	sound_to(owner, 'sound/effects/psi/power_fail.ogg')
	user.drop_from_inventory(src)

/obj/item/scalpel/psi/dropped()
	..()
	qdel(src)

//SAW

/obj/item/circular_saw/psi
	name = "psychokinetic saw"
	item_state = "saw3"

	var/mob/living/owner
	color = "#0095ff"
	alpha = 110

/obj/item/circular_saw/psi/New()
	owner = usr
	if(!istype(owner))
		qdel(src)
		return
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/circular_saw/psi/Destroy()
	if(istype(owner) && owner.psi)
		LAZYREMOVE(owner.psi.manifested_items, src)
		UNSETEMPTY(owner.psi.manifested_items)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/circular_saw/psi/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/circular_saw/psi/attack_self(mob/user)
	sound_to(owner, 'sound/effects/psi/power_fail.ogg')
	user.drop_from_inventory(src)

/obj/item/circular_saw/psi/dropped()
	..()
	qdel(src)

//BONE SETTER

/obj/item/bonesetter/psi
	name = "psychokinetic bone setter"
	item_state = "bone setter"

	var/mob/living/owner
	color = "#0095ff"
	alpha = 110

/obj/item/bonesetter/psi/New()
	owner = usr
	if(!istype(owner))
		qdel(src)
		return
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/bonesetter/psi/Destroy()
	if(istype(owner) && owner.psi)
		LAZYREMOVE(owner.psi.manifested_items, src)
		UNSETEMPTY(owner.psi.manifested_items)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/bonesetter/psi/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/bonesetter/psi/attack_self(mob/user)
	sound_to(owner, 'sound/effects/psi/power_fail.ogg')
	user.drop_from_inventory(src)

/obj/item/bonesetter/psi/dropped()
	..()
	qdel(src)
