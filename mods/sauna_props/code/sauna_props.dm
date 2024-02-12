/obj/item/mop/broom
	name = "broom"
	desc = "This one is made of fake leafsand branches."
	icon = 'mods/sauna_props/icons/sauna_props.dmi'
	icon_state = "sauna_broom"
	hitsound = 'mods/sauna_props/sound/broomwhip.ogg'
	hitsound = 'mods/sauna_props/sound/broomwhip.ogg'
	attack_verb = list("whipped")
	throwforce = 0.001
	force = 0.001
	mopspeed = 110

/obj/item/mop/broom/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return

	if(is_type_in_list(A,moppable_types))
		var/turf/T = get_turf(A)
		if(!T)
			return

		user.visible_message("<span class='warning'>\The [user] begins to clean \the [T].</span>")

		if(do_after(user, mopspeed, T, do_flags = DO_DEFAULT | DO_PUBLIC_PROGRESS))
			if(T)
				T.clean(src, user)
			to_chat(user, "<span class='notice'>You have finished mopping!</span>")

/obj/structure/bed/sofa/sauna_bench
	name = "sauna bench"
	desc = "A wooden sauna bench."
	icon = 'mods/sauna_props/icons/sauna_props.dmi'
	icon_state = "bench"
	base_icon = "bench"
	buckle_dir = SOUTH
	buckle_stance = BUCKLE_FORCE_PRONE

	var/material/bench_material = MATERIAL_WOOD

/obj/structure/bed/sofa/sauna_bench/New(var/newloc)
	base_icon = icon_state
	..(newloc,bench_material)

/obj/structure/bed/sofa/sauna_bench/middle
	icon_state = "bench_middle"
	base_icon = "bench_middle"

/obj/structure/bed/sofa/sauna_bench/middle/north
	icon_state = "bench_middlenorth"
	base_icon = "bench_middlenorth"

/obj/structure/bed/sofa/sauna_bench/north
	icon_state = "bench_north"
	base_icon = "bench_north"

/obj/structure/bed/sofa/sauna_bench/south
	icon_state = "bench_south"
	base_icon = "bench_south"
