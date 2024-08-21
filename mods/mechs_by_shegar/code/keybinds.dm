//Здесь хранятся самые разнообразные бинды, при нажатии клавиши указанной в hotkey_keys, срабатывает
//этот кейбинд


///ОСНОВА///
#define CATEGORY_MECH "MECH"

/proc/inmech(mob/living/A, mob/living/exosuit/B)
	if(istype(B, /mob/living/exosuit))
		if(B.pilots.Find(A))
			return TRUE
	return FALSE

/datum/keybinding/mech
	category = CATEGORY_MECH

/datum/keybinding/mech/can_use(client/user)
	return inmech(user.mob, user.mob.loc)
///ОСНОВА///



//Кейбинд на переключение стрейфа//
/datum/keybinding/mech/toggle_strafe
	hotkey_keys = list("Space")
	name = "toggle_strafe"
	full_name = "Toggle Strafe status"
	description = "Turn on/off strafe in mechs"


/datum/keybinding/mech/toggle_strafe/down(client/user)
	var/mob/living/exosuit/mech = user.mob.loc
	mech.toggle_strafe(user.mob)
	return TRUE

/mob/living/exosuit/proc/toggle_strafe(mob/living/user)
	if(legs.can_strafe)
		strafe_status = !strafe_status
		if(strafe_status)
			to_chat(user,SPAN_GOOD( "The position of the body in space is successfully locked."))
		else
			to_chat(user,SPAN_GOOD( "Successfully disabled locking  body position in space."))
	else
		to_chat(user,SPAN_DANGER("The design of the legs does not support locking the body position in space."))


//Кейбинд на смену орудия
/mob/living/exosuit/proc/swap_hardpoint(mob/living/user)
	if(next_move >= world.time)
		return
	if((world.time - last_keybind_use) < 0.5 SECONDS)
		return
	last_keybind_use = world.time
	var/swapped = FALSE
	var/obj/screen/movable/exosuit/hardpoint = hardpoint_hud_elements[selected_hardpoint]
	var/obj/screen/movable/exosuit/hardpoint/previous_hardpoint = hardpoint
	if(selected_hardpoint == "right hand")
		swapped = TRUE
		set_hardpoint("left hand")
	else if(selected_hardpoint == "left hand")
		swapped = TRUE
		set_hardpoint("right hand")
	else if(selected_hardpoint == "left shoulder")
		if(!hardpoints.Find("right shoulder"))
			return
		swapped = TRUE
		set_hardpoint("right shoulder")
	else if(selected_hardpoint == "right shoulder")
		if(!hardpoints.Find("left shoulder"))
			return
		swapped = TRUE
		set_hardpoint("left shoulder")
	if(swapped)
		hardpoint = hardpoint_hud_elements[selected_hardpoint]
		previous_hardpoint.icon_state = "hardpoint"
		hardpoint.icon_state = "hardpoint_selected"
		previous_hardpoint.update_icon()
		hardpoint.update_icon()
		playsound(src, 'mods/mechs_by_shegar/sounds/mech_swap_weapon.ogg', 50, 0)


/datum/keybinding/mech/toggle_back_hardpoint
	hotkey_keys = list("None")
	name = "toggle_back"
	full_name = "Toggle Back Hardpoint"
	description = "Toggle equipment on mech back"

/datum/keybinding/mech/toggle_back_hardpoint/down(client/user)
	var/mob/living/exosuit/mech = user.mob.loc
	mech.toggle_back_hardpoint(user.mob)
	return TRUE

/mob/living/exosuit/proc/toggle_back_hardpoint(mob/living/user)
	if(!hardpoints.Find("back"))
		return
	if((world.time - last_keybind_use) < 0.5 SECONDS)
		return
	last_keybind_use = world.time
	var/obj/item/mech_equipment/back_equipment = hardpoints["back"]
	if(back_equipment.attack_self(user))
		playsound(src, 'mods/mechs_by_shegar/sounds/mech_swap_weapon.ogg', 50, 0)

/datum/keybinding/mech/toggle_power
	hotkey_keys = list("None")
	name = "toggle_power"
	full_name = "Toggle Mech Power"
	description = "Toggle mech power"

/datum/keybinding/mech/toggle_power/down(client/user)
	var/mob/living/exosuit/mech = user.mob.loc
	mech.toggle_power(user.mob)
	mech.hud_power_control.update_icon()
	return TRUE
