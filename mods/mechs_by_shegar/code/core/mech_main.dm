

// Big stompy robots.
/mob/living/exosuit
	name = "mech"
	desc = "A powerful machine piloted from a cockpit"
	density =  TRUE
	opacity =  TRUE
	anchored = TRUE
	default_pixel_x = -8
	default_pixel_y = 0
	status_flags = PASSEMOTES
	a_intent =     I_HURT
	mob_size =     MOB_LARGE
	mob_push_flags = ALLMOBS
	mob_flags = MOB_FLAG_UNPINNABLE

	meat_type = null
	meat_amount = 0
	skin_material = null
	skin_amount = 0
	bone_material = null
	bone_amount = 0

	blood_color = "#1f181f"

	can_be_buckled = FALSE

	ignore_hazard_flags = HAZARD_FLAG_SHARD

	var/emp_damage = 0

	var/obj/item/device/radio/exosuit/radio

	var/wreckage_path = /obj/structure/mech_wreckage

	// Access updating/container.
	var/obj/item/card/id/access_card
	var/list/saved_access = list()
	var/sync_access = 1

	// Mob currently piloting the exosuit.
	var/list/pilots
	var/list/pilot_overlays

	// Visible external components. Not strictly accurately named for non-humanoid machines (submarines) but w/e
	var/obj/item/mech_component/manipulators/L_arm
	var/obj/item/mech_component/manipulators/R_arm
	var/obj/item/mech_component/propulsion/L_leg
	var/obj/item/mech_component/propulsion/R_leg
	var/obj/item/mech_component/sensors/head
	var/obj/item/mech_component/chassis/body

	// Invisible components.
	var/datum/effect/spark_spread/sparks

	// Equipment tracking vars.
	var/obj/item/mech_equipment/selected_system
	var/selected_hardpoint
	var/list/hardpoints = list()
	var/maintenance_protocols

	// Material
	var/material/material

	// Cockpit access vars.
	var/hatch_closed = FALSE
	var/hatch_locked = FALSE

	//Air!
	var/use_air      = FALSE

	// Interface stuff.
	var/list/hud_elements = list()
	var/list/hardpoint_hud_elements = list()
	var/obj/screen/movable/exosuit/guide/hud_guide
	var/obj/screen/movable/exosuit/mech_integrity/hud_health
	var/obj/screen/movable/exosuit/power/hud_power
	var/obj/screen/exosuit/menu_button/power/hud_power_control
	var/obj/screen/exosuit/menu_button/camera/hud_camera

	// Sounds for mech_movement.dm and mech_interaction.dm are stored on legs.dm and arms.dm, respectively
	var/obj/item/device/gps/mech_gps/GPS
	var/obj/item/device/scanner/health/medscan
	// Passenger places
	///Костыль, предотвращает двойной таран
	var/Bumps = 0
	///Хранит в себе время последнего столкновения
	var/last_collision
	///Список с изображениями всех частей меха. Применяется в ремонте.
	var/list/parts_list
	var/list/parts_list_images
	///Содержит в себе данные привязанной id карты. По умолчанию - пусто
	var/list/id_holder
	///Мех никогда не должен свапаться
	mob_never_swap = TRUE

/mob/living/exosuit/get_blood_name()
	return "oil"

/mob/living/exosuit/MayZoom()
	if(head?.vision_flags)
		return FALSE
	return TRUE

/mob/living/exosuit/is_flooded(lying_mob, absolute)
	. = (body && body.pilot_coverage >= 100 && hatch_closed) ? FALSE : ..()

/mob/living/exosuit/isSynthetic()
	return TRUE

/mob/living/exosuit/IsAdvancedToolUser()
	return TRUE

/mob/living/exosuit/examine(mob/user)
	. = ..()
	if(LAZYLEN(pilots) && (!hatch_closed || body.pilot_coverage < 100 || body.transparent_cabin))
		to_chat(user, "It is being piloted by [english_list(pilots, nothing_text = "nobody")].")
	if(body && LAZYLEN(body.pilot_positions))
		to_chat(user, "It can seat [length(body.pilot_positions)] pilot\s total.")
	if(length(hardpoints))
		to_chat(user, "It has the following hardpoints:")
		for(var/hardpoint in hardpoints)
			var/obj/item/I = hardpoints[hardpoint]
			to_chat(user, "- [hardpoint]: [istype(I) ? "[I]" : "nothing"].")
	else
		to_chat(user, "It has no visible hardpoints.")

	for(var/obj/item/mech_component/thing in list(head, body,L_arm, R_arm, L_leg, R_leg ))
		if(!thing)
			continue

		var/damage_string = thing.get_damage_string()
		to_chat(user, "Its [thing.name] [thing.gender == PLURAL ? "are" : "is"] [damage_string].")

	to_chat(user, "It menaces with reinforcements of [material].")

/mob/living/exosuit/return_air()
	return (body && body.pilot_coverage >= 100 && hatch_closed && body.cockpit) ? body.cockpit : loc.return_air()

/mob/living/exosuit/set_dir()
	. = ..()
	if(.)
		update_pilots()
		if(passengers_ammount > 0)
			update_passengers()
		var/need_to_update = FALSE
		for(var/hardpoint in hardpoints)
			if(hardpoint == "left hand" || hardpoint == "right hand" || hardpoint == "left shoulder" || hardpoint == "right shoulder")
				need_to_update = TRUE
		if(need_to_update == TRUE)
			update_icon()

/mob/living/exosuit/can_swap_with(mob/living/tmob)
	return 0
