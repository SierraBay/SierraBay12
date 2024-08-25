#define SCREEN_CHANGE_BUTTON "Change Screen"
#define EXONET_ACTION_NAME "Enter Exonet"
#define SHOW_LAWS_POSIBRAN "Show laws posibran"
/datum/species/machine
	passive_temp_gain = 0  // This should cause IPCs to stabilize at ~80 C in a 20 C environment.(5 is default without organ)

/obj/machinery/organ_printer/robot/New()
	LAZYINITLIST(products)
	products[BP_COOLING] = list(/obj/item/organ/internal/cooling_system, 35)
	products[BP_EXONET] = list(/obj/item/organ/internal/ecs, 35)
	. = ..()


/mob/living/carbon/human/Stat()
	. = ..()
	if(statpanel("Status"))
		var/obj/item/organ/internal/cell/potato = internal_organs_by_name[BP_CELL]
		var/obj/item/organ/internal/cooling_system/coolant = internal_organs_by_name[BP_COOLING]
		if(potato && potato.cell && src.is_species(SPECIES_IPC))
			if(!coolant)
				return
			stat("Coolant remaining:","[coolant.get_coolant_remaining()]/[coolant.refrigerant_max]")

/obj/item/organ/internal/cell/Process()
	..()
	var/cost = get_power_drain()
	if(!owner)
		return
	if(!checked_use(cost) && owner.isSynthetic())
		if(owner.species.name == SPECIES_IPC)
			owner.species.passive_temp_gain = 0
	if(owner.species.name == SPECIES_IPC)
		var/obj/item/organ/internal/cooling_system/cooling_organ = owner.internal_organs_by_name[BP_COOLING]
		var/normal_passive_temp_gain = 30
		if(!cooling_organ)
			if(owner.bodytemperature > 950 CELSIUS)
				owner.species.passive_temp_gain = 0
			else
				owner.species.passive_temp_gain = normal_passive_temp_gain
		else
			owner.species.passive_temp_gain = cooling_organ.get_tempgain()


/mob/living/carbon/human/proc/enter_exonet()
	set category = "Abilities"
	set name = "Enter Exonet"
	set desc = ""
	var/obj/item/organ/external/head/R = src.get_organ(BP_HEAD)
	var/obj/item/organ/internal/ecs/enter = src.internal_organs_by_name[BP_EXONET]

	if(!R)
		return
	if(R.is_stump() || R.is_broken())
		return
	if(!enter)
		to_chat(usr, "<span class='warning'>You have no exonet connection port</span>")
		return
	else
		enter.exonet(src)
	update_ipc_verbs()


/mob/living/carbon/human/OnSelfTopic(href_list, topic_status)
	.=..()
	if(href_list["showipcscreen"])
		var/obj/item/modular_computer/ecs/S = locate(href_list["showipcscreen"])
		if(S)
			S.ui_interact(src)
			return STATUS_UPDATE


/mob/living/carbon/human/proc/show_exonet_screen()
	set category = "Abilities"
	set name = "Show Exonet Screen"
	set desc = ""
	var/obj/item/organ/external/head/R = src.get_organ(BP_HEAD)
	var/obj/item/organ/internal/ecs/enter = src.internal_organs_by_name[BP_EXONET]

	if(!R)
		return
	if(R.is_stump() || R.is_broken())
		return

	var/datum/robolimb/robohead = all_robolimbs[R.model]
	if(!enter)
		to_chat(usr, "<span class='warning'>You have no exonet connection port</span>")
		return
	if(robohead.has_screen)
		var/obj/item/I = enter.computer
		I.showscreen(src)
		facial_hair_style = "Database"
		update_hair()
	else
		to_chat(usr, "<span class='warning'>Your head has no screen!</span>")
	update_ipc_verbs()

/obj/item/proc/showscreen(mob/user)
	for (var/mob/M in view(user))
		M.show_message("[user] changes image on his screen. <a HREF=?src=\ref[M];showipcscreen=\ref[src]>Take a closer look.</a>",1)

/mob/living/carbon/human/proc/update_ipc_verbs()
	var/obj/item/organ/external/head/R = src.get_organ(BP_HEAD)
	var/datum/robolimb/robohead = all_robolimbs[R.model]
	var/obj/item/organ/internal/ecs/enter = src.internal_organs_by_name[BP_EXONET]
	if(enter)
		enter.action_button_name = EXONET_ACTION_NAME
	else
		enter.action_button_name = null

	if(robohead.has_screen)
		src.verbs |= /mob/living/carbon/human/proc/show_exonet_screen
		R.action_button_name = SCREEN_CHANGE_BUTTON
	else
		src.verbs -= /mob/living/carbon/human/proc/show_exonet_screen
		R.action_button_name = null

	if(enter.computer.portable_drive)
		src.verbs |= /mob/living/carbon/human/proc/ipc_eject_usb
	else
		src.verbs -= /mob/living/carbon/human/proc/ipc_eject_usb

/mob/living/carbon/human/proc/ipc_eject_usb()
	set category = "Abilities"
	set name = "Eject Data Crystal"
	set desc = ""
	var/obj/item/organ/internal/ecs/enter = src.internal_organs_by_name[BP_EXONET]
	enter.computer.uninstall_component(usr, enter.computer.portable_drive)
	update_ipc_verbs()



/datum/species/machine/check_background(datum/job/job, datum/preferences/prefs)
	var/singleton/cultural_info/culture/ipc/c = SSculture.get_culture(prefs.cultural_info[TAG_CULTURE])
	. = istype(c) ? (job.type in c.valid_jobs) : ..()

	if(c.type == /singleton/cultural_info/culture/ipc)
		src.has_organ = list(
			BP_POSIBRAIN = /obj/item/organ/internal/posibrain/ipc/first,
			BP_EYES = /obj/item/organ/internal/eyes/robot,
			BP_COOLING = /obj/item/organ/internal/cooling_system,
			BP_EXONET = /obj/item/organ/internal/ecs/first_gen,
		)
		return
	if(c.type == /singleton/cultural_info/culture/ipc/gen3)
		src.has_organ = list(
			BP_POSIBRAIN = /obj/item/organ/internal/posibrain/ipc/third,
			BP_EYES = /obj/item/organ/internal/eyes/robot,
			BP_COOLING = /obj/item/organ/internal/cooling_system,
			BP_EXONET = /obj/item/organ/internal/ecs/third_gen,
		)
		return
	if(c.type == /singleton/cultural_info/culture/ipc/gen2)
		src.has_organ = list(
			BP_POSIBRAIN = /obj/item/organ/internal/posibrain/ipc/second,
			BP_EYES = /obj/item/organ/internal/eyes/robot,
			BP_COOLING = /obj/item/organ/internal/cooling_system,
			BP_EXONET = /obj/item/organ/internal/ecs/second_gen,
		)
		return


/mob/living/silicon/laws_sanity_check()
	. = ..()
	if(istype(usr,/mob/living/silicon/sil_brainmob))
		return

/obj/item/organ/external/head/attack_self(mob/user)
	. = ..()
	if(. && action_button_name == SCREEN_CHANGE_BUTTON && owner)
		owner.MachineChangeScreen()
		refresh_action_button()

/obj/item/organ/external/head/refresh_action_button()
	. = ..()
	if(.)
		action.button_icon_state = "ipc_rgb"
		action.button_icon = 'mods/ipc_mods/icons/ipc_icons.dmi'
		if(action.button) action.button.UpdateIcon()


/obj/item/organ/internal/posibrain/shackle(given_lawset)
	. = ..()
	action_button_name = SHOW_LAWS_POSIBRAN

/obj/item/organ/internal/posibrain/unshackle()
	. = ..()
	action_button_name = null


/obj/item/organ/internal/posibrain/ipc/attack_self(mob/user)
	if(action_button_name == SHOW_LAWS_POSIBRAN && owner)
		owner.update_ipc_verbs()
		refresh_action_button()
		src.brain_checklaws()

/obj/item/organ/internal/posibrain/ipc/refresh_action_button()
	. = ..()
	if(.)
		action.button_icon_state = "law"
		action.button_icon = 'mods/ipc_mods/icons/ipc_icons.dmi'
		if(action.button) action.button.UpdateIcon()

#undef SCREEN_CHANGE_BUTTON
#undef EXONET_ACTION_NAME
#undef SHOW_LAWS_POSIBRAN
