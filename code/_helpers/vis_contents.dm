// Vis content procs from Nebula -> Not the actual subsystem, that may follow later

// Horrible colon syntax below is because vis_contents
// exists in /atom.vars, but will not compile. No idea why.
/atom/proc/add_vis_contents(adding)
	src:vis_contents |= adding

/atom/proc/remove_vis_contents(removing)
	src:vis_contents -= removing

/atom/proc/clear_vis_contents()
	src:vis_contents = null

/atom/proc/set_vis_contents(list/adding)
	src:vis_contents = adding

/atom/proc/get_vis_contents_to_add()
	return

/turf/proc/refresh_vis_contents()
	var/new_vis_contents = get_vis_contents_to_add()
	if(length(new_vis_contents))
		set_vis_contents(new_vis_contents)
	else if(length(vis_contents))
		clear_vis_contents()


/image/proc/add_vis_contents(adding)
	vis_contents |= adding

/image/proc/remove_vis_contents(removing)
	vis_contents -= removing

/image/proc/clear_vis_contents()
	vis_contents.Cut()

/image/proc/set_vis_contents(list/adding)
	vis_contents = adding
