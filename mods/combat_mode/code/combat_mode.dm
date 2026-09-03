/mob/living
	/// If TRUE, the mob faces the atom under the player's mouse and does not turn while walking.
	var/combat_mode = FALSE
	/// Last map atom the mouse hovered while combat mode was on.
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
		if(canface() && !lying)
			facing_dir = dir
			face_dir_click = dir
		combat_update_neck_grabs()
		to_chat(src, SPAN_NOTICE("Боевой режим включён. Вы смотрите туда, куда направлена мышь."))
	else
		UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
		combat_look_target = null
		facing_dir = null
		face_dir_click = null
		combat_update_neck_grabs(TRUE)
		to_chat(src, SPAN_NOTICE("Боевой режим выключен."))
	if(combat_mode_icon)
		combat_mode_icon.update_combat_icon(combat_mode)

/mob/living/proc/on_combat_mode_moved(atom/old_loc)
	SIGNAL_HANDLER
	combat_face_mouse(combat_look_target)

/mob/living/proc/combat_face_mouse(atom/A)
	if(!combat_mode)
		return
	if(!canface() || lying)
		return

	if(istype(A, /obj/screen))
		A = null
	else if(A && (!A.x || !A.y || A.z != z))
		A = get_turf(A)

	if(A && A.x && A.y)
		combat_look_target = A
	if(QDELETED(combat_look_target))
		combat_look_target = null
		return

	var/atom/target = combat_look_target
	if(!target.x || !target.y || !x || !y)
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

/datum/click_handler/OnMouseEntered(atom/object, location, control, params)
	hovered_atom = object
	object.MouseEntered(location, control, params)
	var/mob/living/L = user
	if(istype(L) && L.combat_mode)
		L.combat_face_mouse(object)
