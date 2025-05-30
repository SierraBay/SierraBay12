/obj/item/clothing/gloves/insulated/psi
	name = "psychokinetic gloves"

	var/maintain_cost = 2
	var/mob/living/carbon/human/owner
	color = "#0095ff"
	alpha = 110

/obj/item/clothing/gloves/insulated/psi/New()
	owner = usr
	if(!istype(owner))
		qdel(src)
		return
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/clothing/gloves/insulated/psi/Destroy()
	if(istype(owner) && owner.psi)
		LAZYREMOVE(owner.psi.manifested_items, src)
		UNSETEMPTY(owner.psi.manifested_items)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/clothing/gloves/insulated/psi/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/clothing/gloves/insulated/psi/dropped()
	..()
	qdel(src)

/obj/item/clothing/gloves/insulated/psi/Process()
	if(istype(owner))
		owner.psi.spend_power(maintain_cost)
	if(!owner || owner.do_psionics_check(maintain_cost, owner) || loc != owner || (owner.l_hand != src && owner.r_hand != src && owner.gloves != src))
		if(istype(loc,/mob/living))
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



/obj/item/crowbar/psi
	name = "psychokinetic crowbar"

	var/maintain_cost = 2
	var/mob/living/owner
	color = "#0095ff"
	alpha = 110

/obj/item/crowbar/psi/New()
	owner = usr
	if(!istype(owner))
		qdel(src)
		return
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/crowbar/psi/Destroy()
	if(istype(owner) && owner.psi)
		LAZYREMOVE(owner.psi.manifested_items, src)
		UNSETEMPTY(owner.psi.manifested_items)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/crowbar/psi/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/crowbar/psi/dropped()
	..()
	qdel(src)

/obj/item/crowbar/psi/Process()
	if(istype(owner))
		owner.psi.spend_power(maintain_cost)
	if(!owner || owner.do_psionics_check(maintain_cost, owner) || loc != owner || (owner.l_hand != src && owner.r_hand != src))
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



/obj/item/screwdriver/psi
	name = "psychokinetic screwdriver"
	item_state = "screwdriver_preview"

	var/maintain_cost = 2
	var/mob/living/owner
	color = "#0095ff"
	alpha = 110

/obj/item/screwdriver/psi/New()
	owner = usr
	if(!istype(owner))
		qdel(src)
		return
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/screwdriver/psi/Destroy()
	if(istype(owner) && owner.psi)
		LAZYREMOVE(owner.psi.manifested_items, src)
		UNSETEMPTY(owner.psi.manifested_items)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/screwdriver/psi/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/screwdriver/psi/dropped()
	..()
	qdel(src)

/obj/item/screwdriver/psi/Process()
	if(istype(owner))
		owner.psi.spend_power(maintain_cost)
	if(!owner || owner.do_psionics_check(maintain_cost, owner) || loc != owner || (owner.l_hand != src && owner.r_hand != src))
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



/obj/item/wirecutters/psi
	name = "psychokinetic wirecutters"
	item_state = "cutters_preview"

	var/maintain_cost = 2
	var/mob/living/owner
	color = "#0095ff"
	alpha = 110

/obj/item/wirecutters/psi/New()
	owner = usr
	if(!istype(owner))
		qdel(src)
		return
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/wirecutters/psi/Destroy()
	if(istype(owner) && owner.psi)
		LAZYREMOVE(owner.psi.manifested_items, src)
		UNSETEMPTY(owner.psi.manifested_items)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/wirecutters/psi/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/wirecutters/psi/dropped()
	..()
	qdel(src)

/obj/item/wirecutters/psi/Process()
	if(istype(owner))
		owner.psi.spend_power(maintain_cost)
	if(!owner || owner.do_psionics_check(maintain_cost, owner) || loc != owner || (owner.l_hand != src && owner.r_hand != src))
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



/obj/item/wrench/psi
	name = "psychokinetic wrench"

	var/maintain_cost = 2
	var/mob/living/owner
	color = "#0095ff"
	alpha = 110

/obj/item/wrench/psi/New()
	owner = usr
	if(!istype(owner))
		qdel(src)
		return
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/wrench/psi/Destroy()
	if(istype(owner) && owner.psi)
		LAZYREMOVE(owner.psi.manifested_items, src)
		UNSETEMPTY(owner.psi.manifested_items)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/wrench/psi/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/wrench/psi/dropped()
	..()
	qdel(src)

/obj/item/wrench/psi/Process()
	if(istype(owner))
		owner.psi.spend_power(maintain_cost)
	if(!owner || owner.do_psionics_check(maintain_cost, owner) || loc != owner || (owner.l_hand != src && owner.r_hand != src))
		if(istype(loc,/mob/living))
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



/obj/item/welder_tank/experimental/special
	max_fuel = 100

/obj/item/weldingtool/experimental/psi
	name = "psychokinetic welding"
	tank = /obj/item/welder_tank/experimental/special

	var/maintain_cost = 4
	var/mob/living/owner
	color = "#0095ff"
	alpha = 110

/obj/item/weldingtool/experimental/psi/New()
	owner = usr
	if(!istype(owner))
		qdel(src)
		return
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/weldingtool/experimental/psi/Destroy()
	if(istype(owner) && owner.psi)
		LAZYREMOVE(owner.psi.manifested_items, src)
		UNSETEMPTY(owner.psi.manifested_items)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/weldingtool/experimental/psi/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/weldingtool/experimental/psi/dropped()
	..()
	qdel(src)

/obj/item/weldingtool/experimental/psi/Process()
	if(istype(owner))
		owner.psi.spend_power(maintain_cost)
	if(!owner || owner.do_psionics_check(maintain_cost, owner) || loc != owner || (owner.l_hand != src && owner.r_hand != src))
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



/obj/item/device/multitool/psi
	name = "psychokinetic multitool"
	item_state = "multitool"

	var/maintain_cost = 4
	var/mob/living/owner
	color = "#0095ff"
	alpha = 110

/obj/item/device/multitool/psi/New()
	owner = usr
	if(!istype(owner))
		qdel(src)
		return
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/device/multitool/psi/Destroy()
	if(istype(owner) && owner.psi)
		LAZYREMOVE(owner.psi.manifested_items, src)
		UNSETEMPTY(owner.psi.manifested_items)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/device/multitool/psi/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/device/multitool/psi/dropped()
	..()
	qdel(src)

/obj/item/device/multitool/psi/Process()
	if(istype(owner))
		owner.psi.spend_power(maintain_cost)
	if(!owner || owner.do_psionics_check(maintain_cost, owner) || loc != owner || (owner.l_hand != src && owner.r_hand != src))
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
