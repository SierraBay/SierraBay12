//These effects are currently applied to titanium walls that have no stripes, resulting in broken icons for Charon, Guppy and etc.
/obj/paint_stripe/LateInitialize(mapload)
	var/turf/simulated/wall/W = get_turf(src)
	if(istype(W) && W.material.wall_flags & MATERIAL_PAINTABLE_STRIPE) // changed line
		W.stripe_color = color
		W.update_icon()
	var/obj/structure/wall_frame/WF = locate() in loc
	if(WF)
		WF.stripe_color = color
		WF.update_icon()
	qdel(src)