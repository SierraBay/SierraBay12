/mob/living
	/// If TRUE, the mob faces the atom under the player's mouse and does not turn while walking.
	var/combat_mode = FALSE
	/// Last map atom the mouse hovered while combat mode was on.
	var/atom/combat_look_target
	/// Last mouse position on the map, used when the tile under the cursor is not sent to the client.
	var/combat_look_screen_loc

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
		combat_look_screen_loc = null
		facing_dir = null
		face_dir_click = null
		combat_update_neck_grabs(TRUE)
		to_chat(src, SPAN_NOTICE("Боевой режим выключен."))

/mob/living/proc/on_combat_mode_moved(atom/old_loc)
	SIGNAL_HANDLER
	combat_face_mouse(combat_look_target)

/mob/living/proc/combat_face_mouse(atom/A, params)
	if(!combat_mode)
		return
	if(!canface() || lying)
		return
	if(buckled)
		if(facing_dir || face_dir_click)
			facing_dir = null
			face_dir_click = null
		return

	// Unseen tiles are not sent to the client. The catcher on that screen tile still is.
	if(istype(A, /obj/screen/click_catcher))
		var/obj/screen/click_catcher/catcher = A
		if(catcher.catcher_x && catcher.catcher_y)
			combat_look_screen_loc = "[catcher.catcher_x],[catcher.catcher_y]"
	else if(params)
		var/list/modifiers = params2list(params)
		if(modifiers[MOUSE_SCREEN_LOC])
			combat_look_screen_loc = modifiers[MOUSE_SCREEN_LOC]
	if(A && !istype(A, /obj/screen))
		if(!A.x || !A.y || A.z != z)
			A = get_turf(A)
		if(A && A.x && A.y)
			combat_look_target = A

	var/atom/target
	if(combat_look_screen_loc && client)
		var/turf/origin = get_turf(src)
		var/turf/eye_turf = get_turf(client.eye)
		if(eye_turf && eye_turf.z == z)
			origin = eye_turf
		target = screen_params_turf(combat_look_screen_loc, origin, client)
	else
		target = combat_look_target
	if(!target || !target.x || !target.y || !x || !y)
		return

	var/direction = get_dir(src, target)
	if(!direction)
		return

	facing_dir = direction
	face_dir_click = direction
	if(dir != direction)
		set_dir(direction)
	combat_update_neck_grabs()

// Each unseen tile is its own catcher, so entering it updates facing.
/obj/screen/click_catcher/MouseMove(location, control, params)
	..()

/client/MouseMove(object, location, control, params)
	var/mob/living/L = mob
	if(istype(L) && L.combat_mode)
		L.combat_face_mouse(object, params)

/datum/click_handler/OnMouseEntered(atom/object, location, control, params)
	hovered_atom = object
	object.MouseEntered(location, control, params)
	var/mob/living/L = user
	if(istype(L) && L.combat_mode)
		L.combat_face_mouse(object, params)
