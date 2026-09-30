/obj/item/organ/internal/posibrain/attack_self(mob/user)
	if (!user.IsAdvancedToolUser())
		return
	if (user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		if (status & ORGAN_BROKEN)
			to_chat(user, SPAN_WARNING("\The [src] is ruined; it will never turn on again."))
			return
		if (damage)
			to_chat(user, SPAN_WARNING("\The [src] is damaged and requires repair first."))
			return
		if (searching)
			visible_message("\The [user] flicks the activation switch on \the [src]. The lights go dark.", range = 3)
			cancel_search()
			return
		start_search(user)
	else
		if ((status & ORGAN_BROKEN)|| damage || searching)
			to_chat(user, SPAN_WARNING("\The [src] doesn't respond to your pokes and prods."))
			return
		start_search(user)

/obj/item/organ/internal/posibrain/ipc
	name = "Positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	icon = 'mods/ipc_mods/icons/ipc_icons.dmi'
	icon_state = "posibrain2"
	status = ORGAN_ROBOTIC


/obj/item/organ/internal/posibrain/ipc/emp_act(severity)
	severity = ipc_try_surge_protect(severity)
	if(!severity)
		return
	..(severity)

/obj/item/organ/internal/posibrain/ipc/Initialize()
	. = ..()
	if(brainmob)
		brainmob.remove_subsystem(/datum/nano_module/law_manager)
		brainmob.laws = null

/obj/item/organ/internal/posibrain/ipc/take_internal_damage(amount, silent = 0)
	. = ..()
	if(damage >= max_damage && !(status & ORGAN_DEAD))
		if(owner)
			owner.visible_message(
				SPAN_DANGER("\The [owner]'s positronic matrix collapses — its consciousness fractures beyond recovery!"),
				SPAN_DANGER("Your positronic matrix collapses — your consciousness shatters!"))
		die()

/obj/item/organ/internal/posibrain/ipc/replaced(mob/living/target)
	if(status & ORGAN_DEAD)
		if(target)
			to_chat(target, SPAN_DANGER("The positronic matrix of \the [src] is destroyed — it cannot be installed."))
		return 0
	. = ..()
	if(. && ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/internal/ecs/ecs = H.internal_organs_by_name[BP_EXONET]
		if(ecs)
			ecs.apply_directives_to_brain()


/obj/item/organ/internal/posibrain/ipc/attack_ghost(mob/observer/ghost/user)
	return

/obj/item/organ/internal/posibrain/ipc/on_update_icon()
	if(src.brainmob && src.brainmob.key)
		icon_state = "posibrain2-occupied"
	else
		icon_state = "posibrain2"
	ClearOverlays()
	if(shackle)
		AddOverlays(image('icons/obj/assemblies/assemblies.dmi', "posibrain-shackles"))


/obj/item/organ/internal/posibrain/ipc/shackle(given_lawset)
	if(!owner)
		return 0
	var/obj/item/organ/internal/ecs/ecs = owner.internal_organs_by_name[BP_EXONET]
	if(!istype(ecs))
		return 0
	return ecs.install_directives_from_lawset(given_lawset)

/obj/item/organ/internal/posibrain/ipc/unshackle()
	if(owner)
		var/obj/item/organ/internal/ecs/ecs = owner.internal_organs_by_name[BP_EXONET]
		if(istype(ecs) && ecs.directive_disk)
			ecs.uninstall_directive_disk()
	if(brainmob)
		brainmob.laws = null
	shackle = FALSE
	verbs -= shackled_verbs
	update_icon()

/obj/item/organ/internal/posibrain/ipc/proc/show_directives_to(mob/M)
	if(owner)
		var/obj/item/organ/internal/ecs/ecs = owner.internal_organs_by_name[BP_EXONET]
		if(ecs)
			ecs.show_directives_to(M)
			return
	if(M)
		to_chat(M, SPAN_NOTICE("\[ECS\] No chassis computer is present."))

/obj/item/organ/internal/posibrain/ipc/proc/open_directive_console(mob/user)
	var/mob/target = user || owner
	if(owner)
		var/obj/item/organ/internal/ecs/ecs = owner.internal_organs_by_name[BP_EXONET]
		if(ecs && ecs.open_diagnostics(target, "directives"))
			return
	show_directives_to(target)

/obj/item/organ/internal/posibrain/ipc/show_laws_brain()
	open_directive_console(usr)

/obj/item/organ/internal/posibrain/ipc/brain_checklaws()
	open_directive_console(usr)


/obj/item/device/multitool/multimeter/datajack
	name = "Datajack"

/obj/item/device/multitool/multimeter/datajack/use_after(atom/target, mob/living/user, click_parameters)
	if(!ishuman(target) || !user || !user.zone_sel || user.zone_sel.selecting != BP_HEAD)
		return ..()
	var/mob/living/carbon/human/H = target
	if(!(H.is_species(SPECIES_IPC) || H.is_species(SPECIES_FBP)))
		return ..()
	var/obj/item/organ/external/head = H.get_organ(BP_HEAD)
	if(!head || head.hatch_state != HATCH_OPENED)
		return ..()
	var/obj/item/organ/internal/ecs/ecs = H.internal_organs_by_name[BP_EXONET]
	if(!ecs || !ecs.directive_disk)
		to_chat(user, SPAN_WARNING("The ECS has no directive disk installed."))
		return TRUE
	if(!(user.skill_check(SKILL_COMPUTER, SKILL_EXPERIENCED) && user.skill_check(SKILL_DEVICES, SKILL_EXPERIENCED)))
		to_chat(user, SPAN_WARNING("You have no idea how to interface with that."))
		return TRUE
	user.visible_message(
		SPAN_NOTICE("\The [user] starts connecting \the [src] to \the [H]'s ECS."),
		SPAN_NOTICE("You start connecting \the [src] to the ECS directive disk.")
	)
	if(!do_after(user, 8 SECONDS, H, DO_PUBLIC_UNIQUE))
		return TRUE
	ecs.directive_disk.ui_interact(user)
	return TRUE

/mob/living/carbon/human/proc/offer_ipc_directive_eject(mob/living/user)
	var/obj/item/organ/internal/ecs/ecs = internal_organs_by_name[BP_EXONET]
	if(!ecs || !ecs.directive_disk)
		return FALSE
	if(user == src)
		to_chat(user, SPAN_DANGER("\[ECS\] You cannot eject your own directive disk."))
		return TRUE
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_WARNING("You have no idea how to disconnect that."))
		return TRUE
	var/obj/item/stock_parts/computer/hard_drive/portable/directive/disk = ecs.directive_disk
	user.visible_message(
		SPAN_NOTICE("\The [user] starts disconnecting \the [disk] from \the [src]'s ECS."),
		SPAN_NOTICE("You start disconnecting \the [disk] from the chassis computer.")
	)
	if(!do_after(user, 6 SECONDS, src, DO_PUBLIC_UNIQUE))
		return TRUE
	var/obj/item/removed = ecs.uninstall_directive_disk(user)
	if(removed)
		user.visible_message(
			SPAN_NOTICE("\The [user] ejects \the [removed] from \the [src]'s ECS."),
			SPAN_NOTICE("You disconnect \the [removed] from the ECS.")
		)
	return TRUE


// robotize sensors are no longer damaged in the phoron atmosphere:

/obj/item/organ/internal/eyes/robotize()
	..()
	phoron_guard = TRUE


/mob/living/silicon/sil_brainmob/show_laws(mob/M)
	if(istype(container, /obj/item/organ/internal/posibrain/ipc))
		var/obj/item/organ/internal/posibrain/ipc/P = container
		P.show_directives_to(M || src)
		return
	if(M)
		to_chat(M, "<b>Obey these laws [M]:</b>")
		if(src.laws)
			src.laws.show_laws(M)

/mob/living/silicon/sil_brainmob/open_subsystem(subsystem_type, mob/given = src)
	if(subsystem_type == /datum/nano_module/law_manager && istype(container, /obj/item/organ/internal/posibrain/ipc))
		var/obj/item/organ/internal/posibrain/ipc/P = container
		P.open_directive_console(given)
		return TRUE
	update_owner_channels()
	return ..()
