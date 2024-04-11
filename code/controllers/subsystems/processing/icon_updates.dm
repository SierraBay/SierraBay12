SUBSYSTEM_DEF(icon_update)
	name = "Icon Updates"
	wait = 1	// ticks
	flags = SS_TICKER
	priority = FIRE_PRIORITY_ICON_UPDATE
	init_order = SS_INIT_ICON_UPDATE
	VAR_PRIVATE/static/list/queue = list()


/datum/controller/subsystem/icon_update/Recover()
	LIST_RESIZE(queue, 0)
	queue = list()


/datum/controller/subsystem/icon_update/UpdateStat(time)
	if (PreventUpdateStat(time))
		return ..()
	..("queue: [length(queue)]")


/datum/controller/subsystem/icon_update/Initialize(start_uptime)
	flush_queue()

/datum/controller/subsystem/icon_update/fire(resumed)
	var/queue_position = 1
	while(length(queue) >= queue_position)
		process_atom_icon_update(queue[queue_position])
		queue_position++
		if(MC_TICK_CHECK)
			break

	queue.Cut(1, queue_position)

/datum/controller/subsystem/icon_update/proc/flush_queue()
	var/queue_position = 1
	while(length(queue) >= queue_position)
		process_atom_icon_update(queue[queue_position])
		queue_position++
		CHECK_TICK

	LIST_RESIZE(queue, 0)

/datum/controller/subsystem/icon_update/proc/process_atom_icon_update(atom/atom_to_update)
	if(QDELETED(atom_to_update))
		return

	var/list/params = queue[atom_to_update]
	if (islist(params))
		atom_to_update.update_icon(arglist(params))
	else
		atom_to_update.update_icon()

/datum/controller/subsystem/icon_update/proc/enque_atom_icon_update(atom/atom_to_update, arguments)
	SSicon_update.queue[atom_to_update] = arguments

/**
 * Adds the atom to the icon_update subsystem to be queued for icon updates. Use this if you're going to be pushing a
 * lot of icon updates at once.
 */
/atom/proc/queue_icon_update(...)
	SSicon_update.enque_atom_icon_update(src, length(args) ? args : TRUE)

/hook/game_ready/proc/flush_icon_update_queue()
	SSicon_update.flush_queue()
	return TRUE
