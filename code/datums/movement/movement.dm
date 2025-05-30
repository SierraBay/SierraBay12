var/global/const/MOVEMENT_HANDLED = FLAG_01 // If no further movement handling should occur after this
var/global/const/MOVEMENT_REMOVE  = FLAG_02

var/global/const/MOVEMENT_PROCEED = FLAG_03
var/global/const/MOVEMENT_STOP    = FLAG_04

#define INIT_MOVEMENT_HANDLERS \
if(LAZYLEN(movement_handlers) && ispath(movement_handlers[1])) { \
	var/new_handlers = list(); \
	for(var/path in movement_handlers){ \
		var/arguments = movement_handlers[path];   \
		arguments = arguments ? (list(src) | (arguments)) : list(src); \
		new_handlers += new path(arglist(arguments)); \
	} \
	movement_handlers= new_handlers; \
}

/// Removes `X` from `movement_handlers` then qdel's it.
#define REMOVE_AND_QDEL(X) LAZYREMOVE(movement_handlers, X); qdel(X);


/**
 * List (Instances of `/datum/movement`) - List of movement handlers attached to this atom.
 *
 * Do not modify or reference directly. See the various procs defined in `code\datums\movement\movement.dm`.
 */
/atom/movable/var/list/movement_handlers


/**
 * Checks if the provided movement handler path exists in this atom's `movement_handlers` list. Ignores subtypes, must be an exact match.
 *
 * **Parameters**:
 * - `handler_path` (Path, type of `/datum/movement_handler`) - The movement handler path to search for.
 *
 * Returns boolean.
 */
/atom/movable/proc/HasMovementHandler(handler_path)
	if(!LAZYLEN(movement_handlers))
		return FALSE
	if(ispath(movement_handlers[1]))
		return (handler_path in movement_handlers)
	else
		for(var/mh in movement_handlers)
			var/datum/MH = mh
			if(MH.type == handler_path)
				return TRUE
	return FALSE


/**
 * Creates a new movement handler instance and attaches it to this atom's `movement_handlers` list.
 *
 * **Parameters**:
 * - `handler_path` (Path, type of `/datum/movement_handler`) - The movement handler to create.
 * - `handler_path_to_add_before` (Path, type of `/datum/movement_handler`) - If defined, and this path already exists in the atom's movement handlers, the new handler will be added before this. Otherwise, the new handler is added to the beginning of the list.
 *
 * Returns instance of `/datum/movement_handler` - The created movement handler.
 */
/atom/movable/proc/AddMovementHandler(handler_path, handler_path_to_add_before)
	INIT_MOVEMENT_HANDLERS

	. = new handler_path(src)

	// If a handler_path_to_add_before was given, attempt to find it and insert our handler just before it
	if(handler_path_to_add_before && LAZYLEN(movement_handlers))
		var/index = 0
		for(var/handler in movement_handlers)
			index++
			var/datum/H = handler
			if(H.type == handler_path_to_add_before)
				LAZYINSERT(movement_handlers, ., index)
				return

	// If no handler_path_to_add_after was given or found, add first
	LAZYINSERT(movement_handlers, ., 1)


/atom/movable/proc/RemoveMovementHandler(handler_path)
	INIT_MOVEMENT_HANDLERS

	if(ispath(handler_path))
		for(var/handler in movement_handlers)
			var/datum/H = handler
			if(H.type == handler_path)
				REMOVE_AND_QDEL(H)
				break
	else if (handler_path in movement_handlers)
		REMOVE_AND_QDEL(handler_path)

/atom/movable/proc/ReplaceMovementHandler(handler_path)
	RemoveMovementHandler(handler_path)
	AddMovementHandler(handler_path)

/atom/movable/proc/GetMovementHandler(handler_path)
	INIT_MOVEMENT_HANDLERS

	for(var/handler in movement_handlers)
		var/datum/H = handler
		if(H.type == handler_path)
			return H

// If is_external is explicitly set then use that, otherwise if the mover isn't the host assume it's external
#define SET_MOVER(X) X = X || src
#define SET_IS_EXTERNAL(X) is_external = isnull(is_external) ? (mover != src) : is_external

/atom/movable/proc/DoMove(direction, mob/mover, is_external)
	INIT_MOVEMENT_HANDLERS
	SET_MOVER(mover)
	SET_IS_EXTERNAL(mover)

	for(var/mh in movement_handlers)
		var/datum/movement_handler/movement_handler = mh
		if(movement_handler.MayMove(mover, is_external) & MOVEMENT_STOP)
			return MOVEMENT_HANDLED

		. = movement_handler.DoMove(direction, mover, is_external)
		if(. & MOVEMENT_REMOVE)
			REMOVE_AND_QDEL(movement_handler)
		if(. & MOVEMENT_HANDLED)
			return

// is_external means that something else (not inside us) is asking if we may move
// This for example includes mobs bumping into each other
/atom/movable/proc/MayMove(mob/mover, is_external)
	INIT_MOVEMENT_HANDLERS
	SET_MOVER(mover)
	SET_IS_EXTERNAL(mover)

	for(var/mh in movement_handlers)
		var/datum/movement_handler/movement_handler = mh
		var/may_move = movement_handler.MayMove(mover, is_external)
		if(may_move & MOVEMENT_STOP)
			return FALSE
		if((may_move & (MOVEMENT_PROCEED|MOVEMENT_HANDLED)) == (MOVEMENT_PROCEED|MOVEMENT_HANDLED))
			return TRUE
	return TRUE

#undef SET_MOVER
#undef SET_IS_EXTERNAL
#undef INIT_MOVEMENT_HANDLERS
#undef REMOVE_AND_QDEL

/datum/movement_handler
	VAR_PROTECTED/expected_host_type = /atom/movable
	VAR_PROTECTED/atom/movable/host

/datum/movement_handler/New(atom/movable/host)
	if(!istype(host, expected_host_type))
		CRASH("Invalid host type. Expected [expected_host_type], was [host ? host.type : "*null*"]")
	src.host = host

/datum/movement_handler/Destroy()
	host = null
	. = ..()

/datum/movement_handler/proc/DoMove(direction, mob/mover, is_external)
	return

// Asks the handlers if the mob may move, ignoring destination, if attempting a DoMove()
/datum/movement_handler/proc/MayMove(mob/mover, is_external)
	return MOVEMENT_PROCEED

/*******
* /mob *
*******/
/datum/movement_handler/mob
	expected_host_type = /mob
	VAR_PROTECTED/mob/mob
	VAR_PROTECTED/next_feedback


/datum/movement_handler/mob/Destroy()
	mob = null
	. = ..()


/datum/movement_handler/mob/New(host)
	..()
	mob = host


/datum/movement_handler/mob/proc/DoFeedback(feedback)
	if (next_feedback > world.time)
		return
	next_feedback = world.time + 1 SECOND
	to_chat(mob, feedback)
