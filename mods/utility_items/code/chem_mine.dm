/obj/item/mine
	name = "mine"
	var/active = 0

/obj/item/mine/proc/activate(mob/user)
	if(active)
		return

	if(user)
		msg_admin_attack("[user.name] ([user.ckey]) primed \a [src] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	active = 1

/obj/item/mine/proc/detonate()
	var/turf/T = get_turf(src)
	if(T)
		T.hotspot_expose(700,125)

/obj/item/mine/Crossed(AM as mob|obj)
	if(active)
		detonate()

/obj/item/mine/chem_mine
	name = "mine casing"
	icon = 'packs/infinity/icons/obj/mine.dmi'
	icon_state = "mine"
	desc = "A hand made chemical mine."
	w_class = ITEM_SIZE_SMALL
	force = 2.0
	unacidable = TRUE
	var/stage = 0
	var/state = 0
	var/path = 0
	var/obj/item/device/assembly/igniter/detonator = null
	var/list/beakers = list()
	var/list/allowed_containers = list(/obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/glass/bottle)
	var/affected_area = 3

/obj/item/mine/chem_mine/Initialize()
	..()
	create_reagents(1000)

/obj/item/mine/chem_mine/attack_self(mob/user)
	if(!stage || stage==1)
		if(detonator)
			usr.put_in_hands(detonator)
			detonator=null
			stage=0
			icon_state = initial(icon_state)
		else if(length(beakers))
			for(var/obj/B in beakers)
				if(istype(B))
					beakers -= B
					user.put_in_hands(B)
		SetName("unsecured mine with [length(beakers)] containers")
	if (stage > 1)
		add_fingerprint(user)
		to_chat(user, "Planting mine...")

		if(do_after(user, 40))
			activate()
			src.anchored = TRUE
			icon_state = initial(icon_state) +"_act"
			if(!user.unequip_item())
				return
			user.drop_from_inventory(src)
			user.visible_message(SPAN_DANGER("[user.name] finished planting mine."))
			log_game("[key_name(user)] planted [src.name]")

/obj/item/mine/chem_mine/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(istype(W,/obj/item/device/assembly/igniter) && (!stage || stage==1) && path != 2)
		var/obj/item/device/assembly/igniter/det = W
		if(!det.secured)
			to_chat(user, SPAN_WARNING("Igniter must be secured with screwdriver."))
			return
		if(!user.unEquip(det, src))
			return
		path = 1
		log_and_message_admins("has attached \a [W] to \the [src].")
		to_chat(user, SPAN_WARNING("You add [W] to the metal casing."))
		playsound(src.loc, 'sound/items/Screwdriver2.ogg', 25, -3)
		stage = 1
		detonator = det
	else if(isScrewdriver(W) && path != 2)
		if(stage == 1)
			path = 1
			if(length(beakers))
				to_chat(user, SPAN_NOTICE("You lock the assembly."))
				SetName("mine")
			else
				to_chat(user, SPAN_NOTICE("You lock the empty assembly."))
				SetName("mine")
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, -3)
			icon_state = initial(icon_state) +"_not_act"
			stage = 2
		else if(stage == 2)
			if(active && user.skill_fail_prob(SKILL_DEVICES, 100, SKILL_MAX+1, 0.2))
				to_chat(user, SPAN_WARNING("You trigger the assembly!"))
				detonate()
				return
			else
				to_chat(user, SPAN_NOTICE("You unlock the assembly."))
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, -3)
				SetName("unsecured mine with [length(beakers)] containers")
				icon_state = initial(icon_state) +"_not_act"
				stage = 1
				active = 0
				src.anchored = FALSE
				src.alpha = 255
	else if(is_type_in_list(W, allowed_containers) && (!stage || stage==1) && path != 2)
		path = 1
		if(length(beakers) == 2)
			to_chat(user, SPAN_WARNING("The mine can not hold more containers."))
			return
		else
			if(W.reagents.total_volume)
				if(!user.unEquip(W, src))
					return
				to_chat(user, SPAN_NOTICE("You add \the [W] to the assembly."))
				beakers += W
				stage = 1
				SetName("unsecured mine with [length(beakers)] containers[detonator?" and detonator":""]")
			else
				to_chat(user, SPAN_WARNING("\The [W] is empty."))
	else if(istype(W, /obj/item/device/paint_sprayer))
		if(src.anchored)
			playsound(get_turf(src), 'sound/effects/spray3.ogg', 30, 1, -6)
			src.alpha = 50

	return ..()


/obj/item/mine/chem_mine/activate(mob/user as mob)
	if(active) return

	if(detonator)
		active = 1
	if(active)
		if(user)
			log_and_message_admins("has primed \a [src].")

	return

/obj/item/mine/chem_mine/detonate()
	if(!stage || stage<2) return
	var/has_reagents = 0
	for(var/obj/item/reagent_containers/glass/G in beakers)
		if(G.reagents.total_volume) has_reagents = 1
	active = 0
	if(!has_reagents)
		return
	playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)
	for(var/obj/item/reagent_containers/glass/G in beakers)
		G.reagents.trans_to_obj(src, G.reagents.total_volume)
	if(src.reagents.total_volume)
		var/datum/effect/steam_spread/steam = new /datum/effect/steam_spread()
		steam.set_up(10, 0, get_turf(src))
		steam.attach(src)
		steam.start()
		for(var/atom/A in view(affected_area, src.loc))
			if( A == src ) continue
			src.reagents.touch(A)
	set_invisibility(INVISIBILITY_MAXIMUM)
	detonator.activate()
	addtimer(new Callback(GLOBAL_PROC, /.proc/qdel, src), 1 SECONDS)


/obj/item/mine/chem_mine/examine(mob/user)
	. = ..()
	if(detonator)
		to_chat(user, "With attached [detonator.name]")

/datum/stack_recipe/chem_mine
	title = "mine casing"
	result_type = /obj/item/mine/chem_mine
	difficulty = 3

/material/steel/generate_recipes(reinforce_material)
	. = ..()
	. += new/datum/stack_recipe/chem_mine(src)
