// Internal one-slot hardsuit adapter for IPC/FBP chassis.
// Modules draw from the chassis cell and use existing rig actions/overlays.

/mob/living/carbon/human
	var/obj/item/rig/ipc_chassis/ipc_module_bay

/obj/effect/ipc_rig_overlay
	name = ""
	icon = 'icons/mob/onmob/onmob_rig_modules.dmi'
	mouse_opacity = 0
	anchored = TRUE
	unacidable = TRUE
	simulated = FALSE
	layer = FLOAT_LAYER
	appearance_flags = DEFAULT_APPEARANCE_FLAGS | RESET_COLOR | KEEP_APART
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE | VIS_INHERIT_ID

/obj/item/rig/ipc_chassis
	name = "chassis module bay"
	desc = "An internal hardpoint that mounts a single hardsuit module to a positronic chassis."
	icon_state = "module"
	slot_flags = 0
	w_class = ITEM_SIZE_HUGE
	canremove = FALSE
	airtight = FALSE
	security_check_enabled = FALSE
	online_slowdown = 0
	offline_slowdown = 0
	chest_type = null
	helm_type = null
	boot_type = null
	glove_type = null
	cell_type = null
	air_type = null
	banned_modules = list(
		/obj/item/rig_module/vision,
		/obj/item/rig_module/chem_dispenser,
		/obj/item/rig_module/cooling_unit,
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/self_destruct,
		/obj/item/rig_module/selfrepair
	)
	var/obj/effect/ipc_rig_overlay/visual

/obj/item/rig/ipc_chassis/Destroy()
	cell = null
	air_supply = null
	remove_module_actions()
	if(wearer)
		if(visual)
			wearer.vis_contents -= visual
		if(wearer.ipc_module_bay == src)
			wearer.ipc_module_bay = null
	wearer = null
	QDEL_NULL(visual)
	. = ..()

/obj/item/rig/ipc_chassis/dropped(mob/user)
	. = ..()
	if(wearer)
		forceMove(wearer)

/obj/item/rig/ipc_chassis/proc/bind_to(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(H.ipc_module_bay && H.ipc_module_bay != src)
		qdel(src)
		return
	wearer = H
	H.ipc_module_bay = src
	forceMove(H)
	sync_power()
	update_offline()
	give_module_actions()
	refresh_visual()

/obj/item/rig/ipc_chassis/proc/sync_power()
	cell = null
	if(!wearer)
		return
	var/obj/item/organ/internal/cell/power = wearer.internal_organs_by_name[BP_CELL]
	if(power && power.cell)
		cell = power.cell

/obj/item/rig/ipc_chassis/Process()
	if(!wearer)
		return
	if(loc != wearer)
		forceMove(wearer)
	sync_power()
	var/changed = update_offline()
	if(changed && offline)
		for(var/obj/item/rig_module/module in installed_modules)
			module.deactivate()
	if(offline || !cell)
		return
	if(length(installed_modules))
		var/has_actions = FALSE
		for(var/datum/action/A in wearer.actions)
			if(istype(A.target, /obj/item/rig_module))
				var/obj/item/rig_module/owned = A.target
				if(owned.holder == src)
					has_actions = TRUE
					break
		if(!has_actions)
			give_module_actions()
	for(var/obj/item/rig_module/module in installed_modules)
		var/cost = module.Process()
		if(cost && !cell.checked_use(cost * CELLRATE))
			module.deactivate()

/obj/item/rig/ipc_chassis/update_offline()
	var/go_offline = (!istype(wearer) || loc != wearer || !cell || cell.charge <= 0)
	if(offline != go_offline)
		offline = go_offline
		return 1
	return 0

/obj/item/rig/ipc_chassis/check_power_cost(mob/living/user, cost, use_unconcious, obj/item/rig_module/mod, user_is_ai)
	sync_power()
	if(!istype(user) || user != wearer)
		return 0
	if(!use_unconcious && user.stat)
		to_chat(user, SPAN_WARNING("You are in no fit state to do that."))
		return 0
	if(!cell)
		to_chat(user, SPAN_WARNING("Chassis power cell is missing."))
		return 0
	if(cost && !cell.check_charge(cost * CELLRATE))
		to_chat(user, SPAN_WARNING("Not enough stored power."))
		return 0
	if(mod && mod.disruptive)
		for(var/obj/item/rig_module/module in (installed_modules - mod))
			if(module.active && module.disruptable)
				module.deactivate()
	cell.use(cost * CELLRATE)
	return 1

/obj/item/rig/ipc_chassis/check_suit_access(mob/living/carbon/human/user)
	return user == wearer

/obj/item/rig/ipc_chassis/set_slowdown_and_vision(active)
	return

/obj/item/rig/ipc_chassis/suit_is_deployed()
	return istype(wearer) && loc == wearer

/obj/item/rig/ipc_chassis/on_update_icon(update_mob_icon)
	refresh_visual()

/obj/item/rig/ipc_chassis/get_mob_overlay(mob/user_mob, slot)
	return null

/obj/item/rig/ipc_chassis/proc/refresh_visual()
	if(!visual)
		visual = new(src)
	if(!wearer)
		return
	var/state
	if(length(installed_modules))
		var/obj/item/rig_module/module = installed_modules[1]
		state = module.suit_overlay
	if(!state)
		wearer.vis_contents -= visual
		visual.icon_state = ""
		return
	visual.icon = equipment_overlay_icon
	visual.icon_state = state
	if(!(visual in wearer.vis_contents))
		wearer.vis_contents += visual

/obj/item/rig/ipc_chassis/proc/give_module_actions()
	remove_module_actions()
	if(!wearer)
		return
	for(var/obj/item/rig_module/module in installed_modules)
		if(module.selectable)
			var/datum/action/module_select/select = new(module)
			select.Grant(wearer)
		if(module.toggleable || module.show_toggle_button)
			var/datum/action/module_toggle/toggle = new(module)
			toggle.Grant(wearer)
		else if(module.usable && !module.selectable)
			var/datum/action/module_engage/use = new(module)
			use.Grant(wearer)
	wearer.update_action_buttons()

/obj/item/rig/ipc_chassis/proc/remove_module_actions()
	if(!wearer)
		return
	for(var/datum/action/A in wearer.actions.Copy())
		var/obj/item/rig_module/module = A.target
		if(!istype(module))
			continue
		if(module.holder == src || (module in installed_modules))
			A.Remove(wearer)
	wearer.update_action_buttons()

/obj/item/rig/ipc_chassis/proc/can_accept_module(obj/item/rig_module/module, mob/user)
	if(!istype(module))
		return FALSE
	if(length(installed_modules))
		if(user)
			to_chat(user, SPAN_WARNING("\The [wearer]'s chassis hardpoint is already occupied."))
		return FALSE
	return module.can_install(src, user)

/obj/item/rig/ipc_chassis/proc/install_module(obj/item/rig_module/module, mob/user)
	if(!can_accept_module(module, user))
		return FALSE
	if(user && !user.unEquip(module, src))
		FEEDBACK_UNEQUIP_FAILURE(user, module)
		return FALSE
	if(!user)
		module.forceMove(src)
	installed_modules |= module
	module.installed(src)
	give_module_actions()
	update_icon()
	return TRUE

/obj/item/rig/ipc_chassis/proc/uninstall_module(mob/user)
	if(!length(installed_modules))
		return null
	var/obj/item/rig_module/removed = installed_modules[1]
	if(removed.permanent)
		if(user)
			to_chat(user, SPAN_WARNING("\The [removed] is permanently integrated."))
		return null
	remove_module_actions()
	removed.removed()
	installed_modules -= removed
	selected_module = null
	if(user)
		user.put_in_hands(removed)
	else
		removed.dropInto(get_turf(src))
	give_module_actions()
	update_icon()
	return removed

/datum/action/module_engage
	name = "Use module"
	var/obj/item/rig_module/module

/datum/action/module_engage/New(Target)
	..()
	if(istype(Target, /obj/item/rig_module))
		module = Target
		name = module.engage_string || module.interface_name

/datum/action/module_engage/Trigger()
	if(!Checks())
		return
	if(istype(target, /obj/item/rig_module))
		module = target
		if(module.holder)
			module.engage()

/mob/living/carbon/human/get_rig()
	if(istype(back, /obj/item/rig) && !istype(back, /obj/item/rig/ipc_chassis))
		return back
	if(wearing_rig && !istype(wearing_rig, /obj/item/rig/ipc_chassis))
		return wearing_rig
	return ipc_module_bay

/mob/living/carbon/human/proc/ensure_ipc_module_bay()
	if(!(is_species(SPECIES_IPC) || is_species(SPECIES_FBP)))
		if(ipc_module_bay)
			QDEL_NULL(ipc_module_bay)
		return null
	if(!ipc_module_bay)
		var/obj/item/rig/ipc_chassis/bay = new(src)
		bay.bind_to(src)
	else if(ipc_module_bay.wearer != src)
		ipc_module_bay.bind_to(src)
	return ipc_module_bay

/mob/living/carbon/human/proc/can_access_ipc_module_bay(mob/living/user)
	var/obj/item/organ/external/chest = get_organ(BP_CHEST)
	if(!chest || !BP_IS_ROBOTIC(chest))
		to_chat(user, SPAN_WARNING("There is no robotic chassis hardpoint here."))
		return FALSE
	if(chest.hatch_state != HATCH_OPENED)
		to_chat(user, SPAN_WARNING("The chassis maintenance hatch must be open."))
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/install_ipc_rig_module(obj/item/rig_module/module, mob/living/user)
	if(!istype(module) || !istype(user))
		return FALSE
	if(!can_access_ipc_module_bay(user))
		return TRUE
	if(!user.skill_check(SKILL_DEVICES, SKILL_BASIC))
		to_chat(user, SPAN_WARNING("You have no idea how to seat that into a chassis hardpoint."))
		return TRUE
	var/obj/item/rig/ipc_chassis/bay = ensure_ipc_module_bay()
	if(!bay || !bay.can_accept_module(module, user))
		return TRUE
	user.visible_message(
		SPAN_NOTICE("\The [user] starts mounting \the [module] into \the [src]'s chassis hardpoint."),
		SPAN_NOTICE("You start mounting \the [module] into the chassis hardpoint.")
	)
	if(!do_after(user, 8 SECONDS, src, DO_PUBLIC_UNIQUE) || !(module in user))
		return TRUE
	if(!can_access_ipc_module_bay(user) || !bay.install_module(module, user))
		return TRUE
	user.visible_message(
		SPAN_NOTICE("\The [user] seats \the [module] into \the [src]'s chassis."),
		SPAN_NOTICE("You lock \the [module] into the chassis hardpoint.")
	)
	return TRUE

/mob/living/carbon/human/proc/offer_ipc_rig_module_disconnect(mob/living/user)
	if(!ipc_module_bay || !length(ipc_module_bay.installed_modules))
		return FALSE
	var/obj/item/rig_module/module = ipc_module_bay.installed_modules[1]
	var/list/choices = list()
	choices[module] = make_item_radial_menu_button(module, "Disconnect ")
	var/choice = show_radial_menu(user, src, choices, radius = 42, require_near = TRUE, use_labels = TRUE, tooltips = TRUE, check_locs = list(user.get_active_hand()))
	if(choice != module)
		return TRUE
	return remove_ipc_rig_module(user)

/mob/living/carbon/human/proc/remove_ipc_rig_module(mob/living/user, skip_delay = FALSE)
	if(!ipc_module_bay || !length(ipc_module_bay.installed_modules))
		return FALSE
	if(!can_access_ipc_module_bay(user))
		return TRUE
	if(!user.skill_check(SKILL_DEVICES, SKILL_BASIC))
		to_chat(user, SPAN_WARNING("You have no idea how to disconnect that hardpoint."))
		return TRUE
	var/obj/item/rig_module/module = ipc_module_bay.installed_modules[1]
	if(!skip_delay)
		user.visible_message(
			SPAN_NOTICE("\The [user] starts detaching \the [module] from \the [src]'s chassis."),
			SPAN_NOTICE("You start detaching \the [module] from the chassis hardpoint.")
		)
		if(!do_after(user, 6 SECONDS, src, DO_PUBLIC_UNIQUE))
			return TRUE
	module = ipc_module_bay.uninstall_module(user)
	if(module)
		user.visible_message(
			SPAN_NOTICE("\The [user] removes \the [module] from \the [src]."),
			SPAN_NOTICE("You disconnect \the [module] from the chassis hardpoint.")
		)
	return TRUE

/obj/item/rig_module/use_before(atom/target, mob/living/user, click_parameters)
	if(ishuman(target) && user && user.zone_sel && user.zone_sel.selecting == BP_CHEST)
		var/mob/living/carbon/human/H = target
		if(H.is_species(SPECIES_IPC) || H.is_species(SPECIES_FBP))
			return H.install_ipc_rig_module(src, user)
	return ..()

/obj/item/device/multitool/use_after(atom/target, mob/living/user, click_parameters)
	if(istype(src, /obj/item/device/multitool/multimeter/datajack))
		return ..()
	if(!ishuman(target) || !user || !user.zone_sel)
		return ..()
	var/mob/living/carbon/human/H = target
	if(!(H.is_species(SPECIES_IPC) || H.is_species(SPECIES_FBP)))
		return ..()
	if(user.zone_sel.selecting == BP_HEAD)
		var/obj/item/organ/external/head = H.get_organ(BP_HEAD)
		var/obj/item/organ/internal/ecs/ecs = H.internal_organs_by_name[BP_EXONET]
		if(head && head.hatch_state == HATCH_OPENED && ecs && ecs.directive_disk)
			return H.offer_ipc_directive_eject(user)
		return ..()
	if(user.zone_sel.selecting != BP_CHEST)
		return ..()
	if(!H.ipc_module_bay || !length(H.ipc_module_bay.installed_modules))
		return ..()
	var/obj/item/organ/external/chest = H.get_organ(BP_CHEST)
	if(!chest || chest.hatch_state != HATCH_OPENED)
		return ..()
	return H.offer_ipc_rig_module_disconnect(user)

/singleton/surgery_step/robotics/unmount_ipc_rig_module
	name = "Disconnect chassis module"
	allowed_tools = list(
		/obj/item/device/multitool = 100
	)
	min_duration = 50
	max_duration = 70

/singleton/surgery_step/robotics/unmount_ipc_rig_module/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	if(!.)
		return FALSE
	if(target_zone != BP_CHEST)
		return FALSE
	if(!(target.is_species(SPECIES_IPC) || target.is_species(SPECIES_FBP)))
		return FALSE
	var/obj/item/organ/external/chest = target.get_organ(BP_CHEST)
	if(!chest || chest.hatch_state != HATCH_OPENED)
		return FALSE
	return target.ipc_module_bay && length(target.ipc_module_bay.installed_modules)

/singleton/surgery_step/robotics/unmount_ipc_rig_module/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!target.ipc_module_bay || !length(target.ipc_module_bay.installed_modules))
		to_chat(user, SPAN_WARNING("There is no chassis module to disconnect."))
		return FALSE
	return TRUE

/singleton/surgery_step/robotics/unmount_ipc_rig_module/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/rig_module/module = target.ipc_module_bay?.installed_modules[1]
	user.visible_message(
		"[user] starts disconnecting \the [module] from \the [target]'s chassis with \the [tool].",
		"You start disconnecting \the [module] from the chassis hardpoint with \the [tool]."
	)
	playsound(target.loc, 'sound/items/Deconstruct.ogg', 15, 1)
	..()

/singleton/surgery_step/robotics/unmount_ipc_rig_module/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	target.remove_ipc_rig_module(user, TRUE)

/singleton/surgery_step/robotics/unmount_ipc_rig_module/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		SPAN_WARNING("\The [user]'s hand slips, failing to disconnect the chassis module."),
		SPAN_WARNING("Your hand slips, failing to disconnect the chassis module.")
	)

/singleton/species/machine/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	if(H)
		H.ensure_ipc_module_bay()

/singleton/species/machine/get_additional_examine_text(mob/living/carbon/human/H)
	. = ..()
	if(H && H.ipc_module_bay && length(H.ipc_module_bay.installed_modules))
		var/obj/item/rig_module/module = H.ipc_module_bay.installed_modules[1]
		. += "<br>It has \a [module] mounted in a chassis hardpoint."
