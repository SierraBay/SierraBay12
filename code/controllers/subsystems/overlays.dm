/// SSoverlays. Target the normal overlay cache.
var/global/const/ATOM_ICON_CACHE_NORMAL = FLAG(0)

/// SSoverlays. Target the protected overlay cache.
var/global/const/ATOM_ICON_CACHE_PROTECTED = FLAG(1)

/// SSoverlays. Target both normal and protected overlay caches.
var/global/const/ATOM_ICON_CACHE_ALL = (ATOM_ICON_CACHE_NORMAL | ATOM_ICON_CACHE_PROTECTED)


SUBSYSTEM_DEF(overlays)
	name = "Overlays"
	flags = SS_TICKER
	wait = 1
	priority = FIRE_PRIORITY_OVERLAYS
	init_order = SS_INIT_OVERLAYS
	/// The queue of atoms that need under/overlay updates.
	VAR_PRIVATE/static/list/atom/queue = list()
	/// A list([icon] = list([state] = [appearance], ...), ...) cache of appearances.
	VAR_PRIVATE/static/list/state_cache = list()
	/// A list([icon] = [appearance], ...) cache of appearances.
	VAR_PRIVATE/static/list/icon_cache = list()
	/// The number of appearances currently cached.
	VAR_PRIVATE/static/cache_size = 0


/datum/controller/subsystem/overlays/Recover()
	LIST_RESIZE(queue, 0)
	LIST_RESIZE(state_cache, 0)
	LIST_RESIZE(icon_cache, 0)
	cache_size = 0
	for(var/atom/atom as anything in world)
		if(atom.atom_flags & ATOM_AWAITING_OVERLAY_UPDATE)
			SSoverlays.queue += atom

		CHECK_TICK


/datum/controller/subsystem/overlays/Initialize(start_uptime)
	flush_queue()


/datum/controller/subsystem/overlays/UpdateStat(time)
	if (PreventUpdateStat(time))
		return ..()
	..({"Queued Atoms: [length(queue)], Cache Size: [cache_size]"})


/datum/controller/subsystem/overlays/fire(resumed)
	var/queue_position = 1
	while(length(queue) >= queue_position)
		var/atom/atom_to_update = queue[queue_position]
		if(!QDELETED(atom_to_update) && atom_to_update.atom_flags & ATOM_AWAITING_OVERLAY_UPDATE)
			atom_to_update.UpdateOverlays()

		queue_position++
		if(MC_TICK_CHECK)
			break

	queue.Cut(1, queue_position)

/datum/controller/subsystem/overlays/proc/flush_queue()
	var/queue_position = 1
	while(length(queue) >= queue_position)
		process_atom_overlays_update(queue[queue_position])
		queue_position++
		CHECK_TICK

	LIST_RESIZE(queue, 0)

/datum/controller/subsystem/overlays/proc/process_atom_overlays_update(atom/atom_to_update)
	if(!QDELETED(atom_to_update) && atom_to_update.atom_flags & ATOM_AWAITING_OVERLAY_UPDATE)
		atom_to_update.UpdateOverlays()


/datum/controller/subsystem/overlays/proc/GetStateAppearance(icon, state)
	var/list/state_to_appearance = state_cache[icon]
	if(!state_to_appearance)
		state_to_appearance = list()
		state_cache[icon] = state_to_appearance

	var/state_appearance = state_to_appearance[state]
	if(!state_appearance)
		var/image/state_image = image(icon, null, state)
		state_appearance = state_image.appearance
		state_to_appearance[state] = state_appearance
		cache_size++

	return state_appearance


/datum/controller/subsystem/overlays/proc/GetIconAppearance(icon)
	var/icon_appearance = icon_cache[icon]
	if (!icon_appearance)
		var/image/icon_image = image(icon)
		icon_appearance = icon_image.appearance
		icon_cache[icon] = icon_appearance
		cache_size++

	return icon_appearance


/datum/controller/subsystem/overlays/proc/getAppearanceList(atom/subject, list/sources)
	if (!sources)
		return list()

	if (!islist(sources))
		sources = list(sources)

	var/list/result = list()
	for (var/atom/source as anything in sources)
		if(!source)
			continue

		if(istext(source))
			result += GetStateAppearance(subject.icon, source)

		else if(isicon(source))
			result += GetIconAppearance(source)

		else
			if(isatom(source) && source.atom_flags & ATOM_AWAITING_OVERLAY_UPDATE)
				source.UpdateOverlays()

			if(!ispath(source))
				result += source.appearance
			else
				var/image/image = source
				result += image.appearance

	return result

/datum/controller/subsystem/overlays/proc/enque_atom_overlay_update(atom/atom_to_update)
	if(!atom_to_update)
		return

	if(atom_to_update.atom_flags & ATOM_AWAITING_OVERLAY_UPDATE)
		return

	atom_to_update.atom_flags |= ATOM_AWAITING_OVERLAY_UPDATE
	SSoverlays.queue += atom_to_update


/// Immediately runs an overlay update.
/atom/proc/ImmediateOverlayUpdate()
	SHOULD_NOT_OVERRIDE(TRUE)
	UpdateOverlays()


/**
* Shared behavior for CutOverlays & CutUnderlays. Do not use directly.
* null: nothing changed, do nothing
* FALSE: update should be queued
* TRUE: update should be queued, cache should be nulled
*/
/atom/proc/CutCacheBehavior(sources, cache)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/initial_length = length(cache)
	if (!initial_length)
		return
	cache -= sources
	var/after_length = length(cache)
	if (!after_length)
		return TRUE
	if (initial_length > after_length)
		return FALSE


/// Enqueues the atom for an overlay update if not already queued
/atom/proc/QueueOverlayUpdate()
	SHOULD_NOT_OVERRIDE(TRUE)
	SSoverlays.enque_atom_overlay_update(src)

/// Builds the atom's overlay state from caches
/atom/proc/UpdateOverlays()
	SHOULD_NOT_OVERRIDE(TRUE)
	atom_flags &= ~ATOM_AWAITING_OVERLAY_UPDATE
	if (QDELING(src))
		LIST_RESIZE(overlays, 0)
		return

	if (length(atom_protected_overlay_cache))
		if (length(atom_overlay_cache))
			overlays = atom_protected_overlay_cache + atom_overlay_cache
		else
			overlays = atom_protected_overlay_cache
	else if (length(atom_overlay_cache))
		overlays = atom_overlay_cache
	else
		LIST_RESIZE(overlays, 0)


/// Clears the atom's overlay cache(s) and queues an update if needed. Use CLEAR_TARGET_* flags.
/atom/proc/ClearOverlays(cache_target = ATOM_ICON_CACHE_NORMAL)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (cache_target & ATOM_ICON_CACHE_PROTECTED)
		if (!atom_protected_overlay_cache)
			return
		LAZYCLEARLIST(atom_protected_overlay_cache)
		QueueOverlayUpdate()
	if (cache_target & ATOM_ICON_CACHE_NORMAL)
		if (!atom_overlay_cache)
			return
		LAZYCLEARLIST(atom_overlay_cache)
		QueueOverlayUpdate()


/**
 * Adds specific overlay(s) to the atom.
 * It is designed so any of the types allowed to be added to /atom/overlays can be added here too. More details below.
 *
 * @param sources The overlay(s) to add. These may be
 *	- A string: In which case it is treated as an icon_state of the atom's icon.
 *	- An icon: It is treated as an icon.
 *	- An atom: Its own overlays are compiled and then it's appearance is added. (Meaning its current apperance is frozen).
 *	- An image: Image's apperance is added (i.e. subsequently editing the image will not edit the overlay)
 *	- A type path: Added to overlays as is.  Does whatever it is BYOND does when you add paths to overlays.
 *	- Or a list containing any of the above.
 * @param cache_target If ATOM_ICON_CACHE_PROTECTED, add to the protected cache instead of normal.
 */
/atom/proc/AddOverlays(sources, cache_target = ATOM_ICON_CACHE_NORMAL)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (!sources)
		return
	sources = SSoverlays.getAppearanceList(src, sources)
	if (!length(sources))
		return
	if (cache_target & ATOM_ICON_CACHE_PROTECTED)
		if (atom_protected_overlay_cache)
			atom_protected_overlay_cache += sources
		else
			atom_protected_overlay_cache = sources
	else if (atom_overlay_cache)
		atom_overlay_cache += sources
	else
		atom_overlay_cache = sources
	QueueOverlayUpdate()


/**
 * Removes specific overlay(s) from the atom's normal or protected overlay cache and queue an update.
 *
 * @param overlays The overlays to removed. See AddOverlays for legal source types.
 * @param cache_target A mask of ICON_CACHE_TARGET_*.
 */
/atom/proc/CutOverlays(sources, cache_target = ATOM_ICON_CACHE_NORMAL)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (!sources)
		return

	sources = SSoverlays.getAppearanceList(src, sources)
	if (!length(sources))
		return

	var/update
	if (cache_target & ATOM_ICON_CACHE_PROTECTED)
		var/outcome = CutCacheBehavior(sources, atom_protected_overlay_cache)
		if (!isnull(outcome))
			update = TRUE
			if (outcome == TRUE)
				atom_protected_overlay_cache = null

	if (cache_target & ATOM_ICON_CACHE_NORMAL)
		var/outcome = CutCacheBehavior(sources, atom_overlay_cache)
		if (!isnull(outcome))
			update = TRUE
			if (outcome == TRUE)
				atom_overlay_cache = null

	if (update)
		QueueOverlayUpdate()


/// AddOverlays with ClearOverlays first. See AddOverlays for behavior.
/atom/proc/SetOverlays(sources, cache_target = ATOM_ICON_CACHE_NORMAL)
	SHOULD_NOT_OVERRIDE(TRUE)
	ClearOverlays(cache_target)
	AddOverlays(sources, cache_target)


/**
 * Copy the overlays from another atom.
 *
 * @param other The atom to copy overlays from.
 * @param clear If TRUE, clear before adding other's overlays.
 * @param cache_target A mask of ICON_CACHE_TARGET_* indicating what to copy.
 */
/atom/proc/CopyOverlays(atom/other, clear, cache_target = ATOM_ICON_CACHE_NORMAL)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (clear)
		ClearOverlays(cache_target)
	if (!istype(other))
		return
	if (cache_target & ATOM_ICON_CACHE_PROTECTED)
		AddOverlays(other.atom_protected_overlay_cache, ATOM_ICON_CACHE_PROTECTED)
	if (cache_target & ATOM_ICON_CACHE_NORMAL)
		AddOverlays(other.atom_overlay_cache, ATOM_ICON_CACHE_NORMAL)


// Skin-deep API parity for images.
// Reference <https://www.byond.com/docs/ref/#/atom/var/overlays> for permitted types.

/// Adds sources to the image's overlays.
/image/proc/AddOverlays(sources)
	SHOULD_NOT_OVERRIDE(TRUE)
	overlays += sources


/// Removes sources from the image's overlays.
/image/proc/CutOverlays(sources)
	SHOULD_NOT_OVERRIDE(TRUE)
	overlays -= sources


/// Removes all of the image's overlays.
/image/proc/ClearOverlays()
	SHOULD_NOT_OVERRIDE(TRUE)
	LIST_RESIZE(overlays, 0)


/// Copies the overlays from the atom other, clearing first if set, and using the caches indicated.
/image/proc/CopyOverlays(atom/other, clear, cache_target = ATOM_ICON_CACHE_ALL)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (clear)
		LIST_RESIZE(overlays, 0)
	if (!istype(other))
		return
	if (cache_target & ATOM_ICON_CACHE_PROTECTED)
		overlays |= other.atom_protected_overlay_cache
	if (cache_target & ATOM_ICON_CACHE_NORMAL)
		overlays |= other.atom_overlay_cache
