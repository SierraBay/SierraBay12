/mob/observer
	var/atom/following

/mob/observer/Destroy()
	. = ..()
	stop_following()

/mob/observer/proc/stop_following()
	if(!following)
		return
	unregister_signal(following, SIGNAL_MOVED)
	unregister_signal(following, SIGNAL_DIR_SET)
	unregister_signal(following, SIGNAL_QDELETING)
	following = null

/mob/observer/proc/start_following(atom/a)
	stop_following()
	following = a

	register_signal(a, SIGNAL_MOVED, .proc/keep_following)
	register_signal(a, SIGNAL_DIR_SET, /atom/proc/recursive_dir_set)
	register_signal(a, SIGNAL_QDELETING, .proc/stop_following)

	keep_following(new_loc = get_turf(following))

/mob/observer/proc/keep_following(atom/movable/moving_instance, atom/old_loc, atom/new_loc)
	forceMove(get_turf(new_loc))
