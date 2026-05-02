// Attached to surrogate mobs that are being controlled by a living occupant in VR.
// Virtual mobs can return to their occupant at any time, and vanish on death.
// This file also includes VR-related verbs.
// This extension has a lot of custom logic. Gibbing and brainmobs are disabled on virtual mobs, for instance.
/datum/extension/virtual_surrogate
	base_type = /datum/extension/virtual_surrogate
	expected_type = /mob

	var/mob/living/virtual_mob
	var/mob/living/real_mob

/datum/extension/virtual_surrogate/Destroy()
	GLOB.death_event.unregister(virtual_mob, SSvirtual_reality, /datum/controller/subsystem/virtual_reality/proc/remove_virtual_mob)
	GLOB.death_event.unregister(real_mob, SSvirtual_reality, /datum/controller/subsystem/virtual_reality/proc/remove_virtual_mob)
	GLOB.destroyed_event.unregister(virtual_mob, SSvirtual_reality, /datum/controller/subsystem/virtual_reality/proc/remove_virtual_mob)
	GLOB.destroyed_event.unregister(real_mob, SSvirtual_reality, /datum/controller/subsystem/virtual_reality/proc/remove_virtual_mob)
	. = ..()

/datum/extension/virtual_surrogate/proc/set_mob(mob/living/new_mob)
	real_mob = new_mob
	virtual_mob = holder
	new_mob.verbs += /mob/living/proc/exit_vr_mob
	new_mob.verbs += /mob/living/proc/clear_reagents_vr
	new_mob.verbs += /mob/living/proc/rejuvenate_self_vr
	new_mob.verbs += /mob/living/proc/toggle_max_skills_vr
	GLOB.death_event.register(virtual_mob, SSvirtual_reality, /datum/controller/subsystem/virtual_reality/proc/remove_virtual_mob, virtual_mob)
	GLOB.death_event.register(real_mob, SSvirtual_reality, /datum/controller/subsystem/virtual_reality/proc/remove_virtual_mob, real_mob)
	GLOB.destroyed_event.register(virtual_mob, SSvirtual_reality, /datum/controller/subsystem/virtual_reality/proc/remove_virtual_mob, real_mob)
	GLOB.destroyed_event.register(real_mob, SSvirtual_reality, /datum/controller/subsystem/virtual_reality/proc/remove_virtual_mob, real_mob)

/// VR verbs. Being completely virtual, people controlling VR mobs can do a bunch of stuff.
/mob/living/proc/exit_vr_mob()
	set name = "\[Exit VR\]"
	set desc = "Exits your virtual mob, and returns to your normal body."
	set category = "VR"
	set src = usr

	SSvirtual_reality.remove_virtual_mob(src)

/mob/living/proc/clear_reagents_vr()
	set name = "Clear Reagents"
	set desc = "Removes any reagents in your stomach and bloodstream."
	set category = "VR"
	set src = usr

	if (reagents)
		to_chat(usr, SPAN_NOTICE("You clear your virtual body of reagents."))
		reagents.clear_reagents()

/mob/living/proc/rejuvenate_self_vr()
	set name = "Rejuvenate"
	set desc = "Fully undoes any kind of damage on your body, as well as clearing reagents and stuns."
	set category = "VR"
	set src = usr

	rejuvenate()
	if (ishuman(src))
		var/mob/living/carbon/human/H = src
		usr.client.prefs.copy_to(H) // Redo hair, augments, and limbs after rejuvenating
		H.set_nutrition(400)
		H.set_hydration(400)

		var/mob/living/occupant = SSvirtual_reality.virtual_mobs_to_occupants[H]
		if(occupant)
			H.languages = occupant.languages.Copy()
			H.default_language = occupant.default_language

	to_chat(usr, SPAN_NOTICE("You fully rejuvenate your virtual body."))

/datum/skill_buff/virtual_reality
	limit = 1

/mob/living/proc/toggle_max_skills_vr()
	set name = "Toggle Max Skills"
	set desc = "Become a master in all skills. Useful for allowing you to compare your own skills to a fully-learned professional's."
	set category = "VR"
	set src = usr

	var/mob/living/user = usr
	var/list/vr_buffs = user.fetch_buffs_of_type(/datum/skill_buff/virtual_reality)
	if (LAZYLEN(vr_buffs))
		for (var/datum/skill_buff/virtual_reality/VRB in vr_buffs)
			VRB.remove()
		to_chat(user, SPAN_NOTICE("You fall back to your own skills, remembering your own knowledge and training."))
	else
		var/list/buffs = list()
		for (var/singleton/hierarchy/skill/S in GLOB.skills)
			buffs[S.type] = SKILL_MAX
		user.buff_skill(buffs, buff_type = /datum/skill_buff/virtual_reality)
		to_chat(user, SPAN_NOTICE("You connect yourself to a database and augment your skills. Your virtual body is now a master in all skills."))

/mob/living/proc/select_vr_equipment()
	set name = "Select Tournament Equipment"
	set desc = "Pick a provided set of equipment."
	set category = "VR"
	set src = usr

	var/list/available_outfits = list(
		"NT officer" = /singleton/hierarchy/outfit/nanotrasen/officer,
		"NT commander" = /singleton/hierarchy/outfit/nanotrasen/commander,
		"ERT" = /singleton/hierarchy/outfit/vr/ert,
		"ERT - medical" = /singleton/hierarchy/outfit/vr/ert/hardsuit/medical,
		"ERT - engineer" = /singleton/hierarchy/outfit/vr/ert/hardsuit/engineer,
		"ERT - security" = /singleton/hierarchy/outfit/vr/ert/hardsuit/security,
		"ERT - commander" = /singleton/hierarchy/outfit/vr/ert/hardsuit/commander,
		"ERT - janitor" = /singleton/hierarchy/outfit/vr/ert/hardsuit/janitor,
		"SCG Marine" = /singleton/hierarchy/outfit/scg/troops/standart,
		"SCG Marine Engineer" = /singleton/hierarchy/outfit/scg/troops/engineer,
		"SCG Marine Medic" = /singleton/hierarchy/outfit/scg/troops/medic,
		"SCG Marine Sergeant" = /singleton/hierarchy/outfit/scg/troops/sergeant,
		"ICGN Voidsuit" = /singleton/hierarchy/outfit/vr/icgn/voidsuit,
		"ICGN Hardsuit" = /singleton/hierarchy/outfit/vr/icgn/hardsuit,
		"Pirate" = /singleton/hierarchy/outfit/pirate/norm,
		"Pirate captain" = /singleton/hierarchy/outfit/vr/pirate/captain,
		"Terrorist" = /singleton/hierarchy/outfit/vr/mercenary,
		"Terrorist - Armored" = /singleton/hierarchy/outfit/vr/mercenary/armored,
		"Terrorist - Voidsuit" = /singleton/hierarchy/outfit/vr/mercenary/voidsuit,
		"Terrorist - Hardsuit" = /singleton/hierarchy/outfit/vr/mercenary/hardsuit,
		"Stealth Suit" = /singleton/hierarchy/outfit/vr/stealth,
		"Tournamet gear - red" = /singleton/hierarchy/outfit/tournament_gear/red,
		"Tournamet gear - green" = /singleton/hierarchy/outfit/tournament_gear/green,
		"Tournamet gear - chef" = /singleton/hierarchy/outfit/tournament_gear/chef,
		"Tournamet gear - janitor" = /singleton/hierarchy/outfit/tournament_gear/janitor,
	)

	var/outfit_name = input("Select outfit.", "Select equipment.") as null|anything in available_outfits

	var/singleton/hierarchy/outfit/outfit

	if(outfit_name)
		outfit = GET_SINGLETON(available_outfits[outfit_name])

	if(!outfit)
		return
	var/reset_equipment = (outfit.flags&OUTFIT_RESET_EQUIPMENT)
	if(!reset_equipment)
		reset_equipment = alert("Do you wish to delete all current equipment first?", "Delete Equipment?","Yes", "No") == "Yes"
	dressup_human(src, outfit, reset_equipment)

	var/list/held_items = src.GetAllHeld(/obj/item/storage/box)

	for(var/obj/item/storage/box/B in held_items)
		qdel(B)

	var/mob/living/occupant = SSvirtual_reality.virtual_mobs_to_occupants[src]
	var/list/real_access = list()
	if(occupant)
		real_access = occupant.GetIdCard()?.access.Copy()

	for(var/obj/item/card/id/I in src)
		I.access = real_access

/mob/living/proc/spawn_vr_item()
	set name = "Spawn VR item"
	set desc = "Pick an item to spawn."
	set category = "VR"
	set src = usr

	var/item_type

	item_type = input("What to spawn", "Select spawn type") as null|anything in list("Gun", "Ammo", "Melee weapon")

	if(item_type == "Gun")
		var/list/available_gun = typesof(/obj/item/gun)
		var/path_gun = input("Select a gun.", "Select gun.") as null|anything in available_gun
		if(path_gun)
			new path_gun(get_turf(src))
	else if(item_type == "Ammo")
		var/list/available_ammo = list()
		available_ammo += typesof(/obj/item/ammo_magazine)
		available_ammo += typesof(/obj/item/ammobox)
		available_ammo += typesof(/obj/item/ammo_casing)

		var/path_ammo = input("Select ammo for spawn.", "Select ammo.") as null|anything in available_ammo
		if(path_ammo)
			new path_ammo(get_turf(src))
	else if(item_type == "Melee weapon")
		var/list/available_melee = typesof(/obj/item/melee)
		available_melee -= typesof(/obj/item/melee/changeling)
		available_melee += typesof(/obj/item/material/sword)
		available_melee += typesof(/obj/item/material/twohanded)
		var/path_melee = input("Select melee weapon.", "Select melee.") as null|anything in available_melee
		if(path_melee)
			new path_melee(get_turf(src))