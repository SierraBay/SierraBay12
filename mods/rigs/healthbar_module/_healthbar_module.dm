
/obj/item/rig

	initial_modules = list(/obj/item/rig_module/healthbar)


/obj/item/rig_module/healthbar
	name = "healthbar"
	desc = "A hardsuit-mounted health scanner."
	icon_state = "healthbar"
	interface_name = "healthbar"
	interface_desc = "Shows an informative health readout on the user's spine."
	use_power_cost = 0
	origin_tech = list(TECH_MAGNET = 3, TECH_BIO = 3, TECH_ENGINEERING = 5)
	suit_overlay_inactive = "healthbar_100"
	suit_overlay_active = "healthbar_100"
	suit_overlay_used = "healthbar_100"
	suit_overlay = "healthbar_100"
	var/mob/living/carbon/human/user


/obj/item/rig_module/healthbar/proc/register_user(mob/newuser)
	user = newuser
	GLOB.updatehealth_event.register(user, src, /obj/item/rig_module/healthbar/proc/update)
	GLOB.death_event.register(user, src, /obj/item/rig_module/healthbar/proc/death)


/obj/item/rig_module/healthbar/proc/unregister_user()
	GLOB.updatehealth_event.unregister(user, src, /obj/item/rig_module/healthbar/proc/update)
	GLOB.death_event.unregister(user, src, /obj/item/rig_module/healthbar/proc/death)
	user = null

/obj/item/rig_module/healthbar/rig_equipped(mob/user, slot)
	register_user(user)

/obj/item/rig_module/healthbar/rig_unequipped(mob/user, slot)
	unregister_user()

/obj/item/rig_module/healthbar/proc/death()
	playsound(src, 'sound/effects/flatline.ogg', 15, 0, 4)
	update()

/obj/item/rig_module/healthbar/proc/update()
	if (QDELETED(user) || QDELETED(holder) || holder.loc != user)
		//Something broked
		unregister_user()
		return

	var/percentage = user.healthpercent()

	//Just in case
	percentage = clamp(percentage, 0, 100)

	if (user.stat == DEAD)
		percentage = 0

	//95% health is good enough, lets not make people obsess about getting it to blue
	if (percentage > 95)
		percentage = 100
	else
		percentage = round(percentage, 10)

	suit_overlay = "healthbar_[percentage]"
	suit_overlay_inactive = "healthbar_[percentage]"
	suit_overlay_active = "healthbar_[percentage]"
	suit_overlay_used = "healthbar_[percentage]"
	holder.update_wear_icon()


/obj/item/rig/combat/equipped/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/military/equipped/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/ert/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/ert/engineer/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/ert/medical/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/ert/security/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/merc/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/industrial/equipped/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/eva/equipped/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/ce/equipped/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/hazmat/equipped/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/medical/equipped/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/hazard/equipped/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/command/equipped/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/command/captain/equipped/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/command/cmo/equipped/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/command/hos/equipped/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/command/hop/equipped/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/command/science/equipped/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()

/obj/item/rig/exploration/equipped/Initialize()
	LAZYADD(initial_modules, /obj/item/rig_module/healthbar)
	. = ..()
