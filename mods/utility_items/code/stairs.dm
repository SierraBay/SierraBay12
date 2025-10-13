/obj/structure/stairs
	var/steel_added = FALSE
	var/welded = FALSE
	var/destroyed = FALSE


/obj/structure/stairs/Destroy()
	SHOULD_CALL_PARENT(FALSE)
	for(var/turf/turf in locs)
		var/turf/simulated/open/above = GetAbove(turf)
		if(!above)
			warning("Stair created without level above: ([loc.x], [loc.y], [loc.z])")
			return INITIALIZE_HINT_QDEL
		if(!istype(above))
			above.ChangeTurf(/turf/simulated/open)
	destroyed = TRUE
	steel_added = FALSE
	welded = FALSE
	icon = 'mods/utility_items/icons/stairs.dmi'
	update_icon()
	return


/obj/structure/stairs/ex_act(severity)
	if(destroyed)
		return
	switch(severity)
		if(EX_ACT_DEVASTATING)
			Destroy()
		if(EX_ACT_HEAVY)
			if(prob(25))
				Destroy()
		if(EX_ACT_LIGHT)
			return

/obj/structure/stairs/use_tool(obj/item/tool, mob/living/user, list/click_params)
	. = ..()
	if(!destroyed)
		return
	if(!steel_added)
		if(istype(tool, /obj/item/stack/material/steel))
			var/obj/item/stack/material/steelsheet = tool
			if(steelsheet.amount > 10)
				if(do_after(user, (rand(5,7)) SECONDS, src, DO_REPAIR_CONSTRUCT))
					user.visible_message(
						SPAN_NOTICE("\The [user] adds \a [steelsheet] to \the [src]."),
					SPAN_NOTICE("You add \a [steelsheet] to \the [src].")
				)
					steel_added = TRUE
					steelsheet.use(10)
					playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
	if(!welded)
		if(isWelder(tool))
			var/obj/item/weldingtool/welder = tool
			if(steel_added && !welded)
				if(!welder.can_use(1, user))
					return TRUE
				playsound(src, 'sound/items/Welder.ogg', 50, 1)
				user.visible_message(SPAN_WARNING("\The [user] begins welding \the [src]"),
					SPAN_NOTICE("You begin welding \the [src]"))
				if(do_after(user, (rand(3,5)) SECONDS, src, DO_REPAIR_CONSTRUCT))
					welded = TRUE
					destroyed = FALSE
					icon = 'icons/obj/structures/stairs.dmi'
					update_icon()


/obj/structure/stairs/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	if(destroyed)
		return TRUE
	if(get_dir(loc, target) == dir && upperStep(mover.loc))
		return FALSE
	return ..()
