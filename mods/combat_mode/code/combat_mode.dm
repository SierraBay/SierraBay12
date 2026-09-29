/mob/living
	/// If TRUE, the mob faces the atom under the player's mouse and does not turn while walking.
	var/combat_mode = FALSE
	/// Last map atom, or click catcher, the mouse hovered while combat mode was on.
	var/atom/combat_look_target

/mob/living/verb/toggle_combat_mode()
	set name = "Toggle Combat Mode"
	set category = "IC"
	set src = usr

	set_combat_mode(!combat_mode)

/mob/living/proc/set_combat_mode(enabled)
	enabled = !!enabled
	if(combat_mode == enabled)
		return

	combat_mode = enabled
	if(combat_mode)
		RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_combat_mode_moved))
		if(canface() && !lying && !buckled)
			facing_dir = dir
			face_dir_click = dir
		combat_update_neck_grabs()
		var/datum/click_handler/handler = GetClickHandler()
		if(handler?.hovered_atom)
			combat_face_mouse(handler.hovered_atom)
		to_chat(src, SPAN_NOTICE("Боевой режим включён. Вы смотрите туда, куда направлена мышь."))
	else
		UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
		combat_look_target = null
		facing_dir = null
		face_dir_click = null
		combat_update_neck_grabs(TRUE)
		to_chat(src, SPAN_NOTICE("Боевой режим выключен."))

/mob/living/proc/on_combat_mode_moved(atom/old_loc)
	SIGNAL_HANDLER
	combat_face_mouse(combat_look_target)

/mob/living/proc/combat_face_mouse(atom/A)
	if(!combat_mode)
		return
	if(!canface() || lying)
		return
	if(buckled)
		if(facing_dir || face_dir_click)
			facing_dir = null
			face_dir_click = null
		return

	// Tiles the mob cannot see are not sent to the client. The mouse hits a click catcher there instead.
	if(istype(A, /obj/screen/click_catcher))
		combat_look_target = A
	else if(istype(A, /obj/screen))
		A = null
	else if(A && (!A.x || !A.y || A.z != z))
		A = get_turf(A)

	if(A && A.x && A.y && !istype(A, /obj/screen/click_catcher))
		combat_look_target = A
	if(QDELETED(combat_look_target))
		combat_look_target = null
		return

	var/atom/target
	if(istype(combat_look_target, /obj/screen/click_catcher))
		target = combat_turf_under_catcher(combat_look_target)
	else
		target = combat_look_target
	if(!target || !target.x || !target.y || !x || !y)
		return

	var/dx = target.x - x
	var/dy = target.y - y
	if(!dx && !dy)
		return

	var/direction
	if(abs(dx) < abs(dy))
		direction = dy > 0 ? NORTH : SOUTH
	else
		direction = dx > 0 ? EAST : WEST

	facing_dir = direction
	face_dir_click = direction
	if(dir != direction)
		set_dir(direction)
	combat_update_neck_grabs()

/mob/living/proc/combat_turf_under_catcher(obj/screen/click_catcher/catcher)
	if(!client || !catcher)
		return null
	var/turf/origin = get_turf(src)
	var/turf/eye_turf = get_turf(client.eye)
	if(eye_turf && eye_turf.z == z)
		origin = eye_turf
	return screen_loc2turf(catcher.screen_loc, origin, client)

// Core catchers cover 15x15. Widen the grid to the 19-wide client view.
/hook/startup/proc/combat_extend_click_catchers()
	for(var/i in 0 to 14)
		for(var/j in 15 to 18)
			var/obj/screen/click_catcher/catcher = new
			catcher.screen_loc = "NORTH-[i],EAST-[j]"
			GLOB.click_catchers += catcher
	return TRUE

/datum/click_handler/OnMouseEntered(atom/object, location, control, params)
	hovered_atom = object
	object.MouseEntered(location, control, params)
	var/mob/living/L = user
	if(istype(L) && L.combat_mode)
		L.combat_face_mouse(object)
