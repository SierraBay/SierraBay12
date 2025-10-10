//OVERRIDE

/turf/simulated/update_graphic(list/graphic_add = null, list/graphic_remove = null)
	if(length(graphic_add))
		add_vis_contents(graphic_add)

	if(length(graphic_remove))
		remove_vis_contents(graphic_remove)
