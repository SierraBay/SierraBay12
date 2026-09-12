#ifndef FARFLEET_SIERRA_EXTRAS


/obj/structure/closet/walllocker/secure_closet


/obj/structure/bed/chair/shuttle/red/New(newloc, newmaterial = DEFAULT_FURNITURE_MATERIAL)
	..(newloc, MATERIAL_STEEL, MATERIAL_CARPET)


#define LIGHT_DEFAULT_LED_NEON	"#ffffff"

/obj/item/light/led_neon
	name = "neon tube"
	desc = "A LED neon tape."
	matter = list(MATERIAL_GLASS = 100, MATERIAL_ALUMINIUM = 20)
	icon = 'packs/infinity/icons/obj/machinery/neon.dmi'
	icon_state = "big_tape"
	base_state = "big_tape"
	item_state = null
	b_range = 4
	b_colour = LIGHT_DEFAULT_LED_NEON
	random_tone = FALSE

/obj/item/light/led_neon/use_tool(obj/item/tool, mob/user, list/click_params)
	if(user)
		if(isMultitool(tool))
			var/c = input("You are changing diode frequency.", "Input", b_colour) as color|null
			if(c)
				set_color(c)
			return TRUE
	return ..()

/obj/item/light/led_neon/large
	base_state = "big_tape"
	icon_state = "big_tape_preset"
	b_range = 7

/obj/item/light/led_neon/small
	base_state = "small_tape"
	icon_state = "small_tape_preset"

/obj/item/light/led_neon/small/use_tool(obj/item/tool, mob/user, list/click_params)
	if(istype(tool, type))
		var/turf/T = get_turf(user)
		if(isturf(T))
			user.drop_from_inventory(src, T)
			user.drop_from_inventory(tool, T)
			qdel(tool)
			qdel(src)
			user.put_in_any_hand_if_possible(new /obj/item/light/led_neon/large(T))
			return TRUE
	return ..()

/obj/machinery/light/led
	name = "neon tube"
	desc = "A tape of LEDs. Not actually neon, but THIS is FUTURE."
	light_type = /obj/item/light/led_neon/large
	icon = 'packs/infinity/icons/obj/machinery/neon.dmi'
	icon_state = "tube_maped"
	layer = BELOW_DOOR_LAYER

/obj/machinery/light/led/small
	name = "small neon tube"
	base_state = "tube_border"
	icon_state = "tube_border_maped"
	light_type = /obj/item/light/led_neon/small

/obj/machinery/light/led/on_update_icon()
	. = ..()
	pixel_x = 0
	pixel_y = 0

// Decals (maps/sierra/sierra_decals.dm)
/obj/floor_decal/corner/grey/bordercorner2
	icon_state = "bordercolorcorner2"

/obj/floor_decal/industrial/danger
	name = "danger stripes"
	icon_state = "danger"

/obj/floor_decal/industrial/outline/green
	name = "green outline"
	color = COLOR_GREEN_GRAY

/obj/floor_decal/corner/darkblue
	name = "dark blue corner"
	color = COLOR_COMMAND_BLUE

/obj/floor_decal/corner/darkblue/diagonal
	icon_state = "corner_white_diagonal"

/obj/floor_decal/corner/darkblue/three_quarters
	icon_state = "corner_white_three_quarters"

/obj/floor_decal/corner/darkblue/full
	icon_state = "corner_white_full"

/obj/floor_decal/corner/darkblue/border
	icon_state = "bordercolor"

/obj/floor_decal/corner/darkblue/half
	icon_state = "bordercolorhalf"

/obj/floor_decal/corner/darkblue/mono
	icon_state = "bordercolormonofull"

/obj/floor_decal/corner/darkblue/bordercorner
	icon_state = "bordercolorcorner"

/obj/floor_decal/corner/darkblue/bordercorner2
	icon_state = "bordercolorcorner2"

/obj/floor_decal/corner/darkblue/borderfull
	icon_state = "bordercolorfull"

/obj/floor_decal/corner/darkblue/bordercee
	icon_state = "bordercolorcee"

/obj/structure/sign/poster/no_alcohol
	icon_state = "no_alcohol"
	poster_type = /singleton/poster/no_alcohol

// Items (maps/sierra/items/*)
/obj/item/stamp/ward
	name = "warden's rubber stamp"
	icon_state = "stamp-brig"

/obj/item/storage/firstaid/brute
	name = "brute first-aid kit"
	desc = "Use it when your hands will be broken... Or worse."
	item_state = "firstaid-advanced"
	startswith = list(
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical/advanced/bruise_pack = 4,
		/obj/item/stack/medical/splint = 2
		)

/obj/item/reagent_containers/hypospray/autoinjector/dexalin
	name = "autoinjector (dexalin plus)"
	starts_with = list(/datum/reagent/dexalin = 5)

/obj/item/reagent_containers/hypospray/autoinjector/kelotane
	name = "autoinjector (antiburn)"
	starts_with = list(/datum/reagent/kelotane = 5)

/obj/item/storage/firstaid/security
	name = "Tactical first-aid kit"
	desc = "It's a small emergency medical kit. Dark and lightweight."
	use_sound = 'sound/effects/storage/pillbottle.ogg'
	icon = 'maps/sierra/icons/obj/medical.dmi'
	icon_state = "fak-sec"
	matter = list(MATERIAL_PLASTIC = 600)
	storage_slots = 7
	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_SMALL
	startswith = list(
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline,
		/obj/item/reagent_containers/hypospray/autoinjector/antirad,
		/obj/item/reagent_containers/hypospray/autoinjector/detox,
		/obj/item/reagent_containers/hypospray/autoinjector/dexalin,
		/obj/item/reagent_containers/hypospray/autoinjector/kelotane,
		/obj/item/reagent_containers/hypospray/autoinjector/pain,
		/obj/item/stack/medical/bruise_pack
	)
	contents_allowed = list(
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical/bruise_pack
	)

/obj/paint/dark_gunmetal
	color = COLOR_DARK_GUNMETAL

// Machinery (maps/sierra/machinery/*)
/obj/machinery/air_sensor/nacelle/fourth
	id_tag = "ReacEng4"

/obj/machinery/door/airlock/medical/mortus
	door_color = COLOR_DARK_GUNMETAL
	stripe_color = COLOR_SKY_BLUE

/obj/random/blood_packs
	name = "random blood"
	desc = "This is random ammout of blood packs for medical bay."
	icon = 'icons/obj/tools/bloodpack.dmi'
	icon_state = "empty"
	spawn_nothing_percentage = 0

/obj/random/blood_packs/spawn_choices()
	return list(/obj/item/reagent_containers/ivbag/blood/human/oneg = 5,
	/obj/item/reagent_containers/ivbag/blood/human/abpos = 3,
	/obj/item/reagent_containers/ivbag/blood/human/bneg = 2)

// packs/infinity: window door recolor
/obj/machinery/door/window/phoronreinforced
	color = GLASS_COLOR_BORON
	health_max = 300

// packs/infinity: wall-mounted table family
/obj/structure/table/wallf
	icon = 'packs/infinity/icons/obj/tables.dmi'
	icon_state = "wallf_regular"
	color = COLOR_OFF_WHITE
	material = MATERIAL_PLASTIC
	reinforced = DEFAULT_WALL_MATERIAL
	flipped = -1

/obj/structure/table/wallf/can_connect()
	return FALSE

/obj/structure/table/wallf/New()
	..()
	verbs -= /obj/structure/table/verb/do_flip
	verbs -= /obj/structure/table/proc/do_put

/obj/structure/table/wallf/on_update_icon()
	if(material)
		if(material.icon_colour)
			src.color = material.icon_colour

/obj/structure/table/wallf/steel
	color = COLOR_GRAY40
	material = DEFAULT_WALL_MATERIAL
	reinforced = DEFAULT_WALL_MATERIAL

// packs/infinity: tactical plate carrier attachments
/obj/item/clothing/accessory/arm_guards/tactical
	desc = "A pair of black arm pads reinforced with additional ablative coating. Attaches to a plate carrier."
	armor = list(melee = 50, bullet = 50, laser = 60, energy = 35, bomb = 30, bio = 0, rad = 0)

/obj/item/clothing/accessory/leg_guards/tactical
	desc = "A pair of armored leg pads reinforced with additional ablative coating. Attaches to a plate carrier."
	armor = list(melee = 50, bullet = 50, laser = 60, energy = 35, bomb = 30, bio = 0, rad = 0)

// packs/infinity: deployable barrier (verbatim from packs/infinity/structures/barrier.dm)
/obj/structure/barrier
	name = "defensive barrier"
	desc = "A portable barrier - usually, you can see it on defensive positions or in storages in important areas. \
	You can deploy it with a screwdriver for maximum protection, or keep it in mobile position. \
	Also, demontage can be done with a crowbar. In case of structural damage, can be repaired with welding tool."
	icon = 'packs/infinity/icons/obj/barrier.dmi'
	icon_state = "barrier_rised"
	density = TRUE
	throwpass = 1
	anchored = TRUE
	atom_flags = ATOM_FLAG_CLIMBABLE | ATOM_FLAG_CHECKS_BORDER
	var/health = 200
	var/maxhealth = 200
	var/deployed = 0
	var/basic_chance = 50

/obj/structure/barrier/Initialize()
	. = ..()
	update_layers()
	update_icon()

/obj/structure/barrier/examine(mob/user)
	..()
	if(health>=200)
		to_chat(user, SPAN_NOTICE("It looks undamaged."))
	if(health>=140 && health<200)
		USE_FEEDBACK_FAILURE("It has small dents.")
	if(health>=80 && health<140)
		USE_FEEDBACK_FAILURE("It has medium dents.")
	if(health<80)
		to_chat(user, "<span class='danger'>It will break apart soon!</span>")

/obj/structure/barrier/Destroy()
	if(health <= 0)
		visible_message("<span class='danger'>[src] was destroyed!</span>")
		playsound(src, 'sound/effects/clang.ogg', 100, 1)
		new /obj/item/stack/material/steel(src.loc)
		new /obj/item/stack/material/steel(src.loc)
	return ..()

/obj/structure/barrier/proc/update_layers()
	if(dir != SOUTH)
		layer = initial(layer) + 0.1
	else if(dir == SOUTH && density)
		layer = ABOVE_HUMAN_LAYER
	else
		layer = initial(layer) + 0.1

/obj/structure/barrier/on_update_icon()
	if(density && !deployed)
		icon_state = "barrier_rised"
	if(!density && !deployed)
		icon_state = "barrier_downed"
	if(deployed)
		icon_state = "barrier_deployed"

/obj/structure/barrier/set_dir()
	..()
	update_layers()

/obj/structure/barrier/CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
	if(!density || air_group || !height)
		return TRUE

	if(istype(mover, /obj/item/projectile))
		var/obj/item/projectile/proj = mover

		if(Adjacent(proj?.firer))
			return TRUE

		if(mover.dir != reverse_direction(dir))
			return TRUE

		if(get_dist(proj.starting, loc) <= 1)//allows to fire from 1 tile away of barrier
			return TRUE

		return check_cover(mover, target)

	if(get_dir(get_turf(src), target) == dir && density)//turned in front of barrier
		return FALSE
	return TRUE

/obj/structure/barrier/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(O?.checkpass(PASS_FLAG_TABLE))
		return 1
	if (get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/structure/barrier/attack_hand(mob/living/carbon/human/user as mob)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if(user.species.can_shred(user) && user.a_intent == I_HURT)
		take_damage(20)
		return
	if(deployed)
		to_chat(user, SPAN_NOTICE("[src] is already deployed. You can't move it."))
	else
		if(do_after(user, 5, src))
			playsound(src, 'sound/effects/extout.ogg', 100, 1)
			density = !density
			to_chat(user, SPAN_NOTICE("You're getting [density ? "up" : "down"] [src]."))
			update_layers()
			update_icon()

/obj/structure/barrier/use_tool(obj/item/tool, mob/user, list/click_params)

	if(isWelder(tool))
		var/obj/item/weldingtool/WT = tool
		if(health == maxhealth)
			to_chat(user, SPAN_NOTICE("\The [src] is fully repaired."))
			return TRUE
		if(!WT.isOn())
			to_chat(user, SPAN_NOTICE("[tool] should be turned on firstly."))
			return TRUE
		if(WT.remove_fuel(0,user))
			visible_message(SPAN_WARNING("[user] is repairing \the [src]..."))
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			if(do_after(user, max(5, health / 5), src) && WT?.isOn())
				to_chat(user, SPAN_NOTICE("You finish repairing the damage to [src]."))
				playsound(src, 'sound/items/Welder2.ogg', 100, 1)
				health = maxhealth
		else
			to_chat(user, SPAN_NOTICE("You need more welding fuel to complete this task."))
		update_icon()
		return TRUE

	if(isScrewdriver(tool))
		if(density)
			visible_message("<span class='danger'>[user] begins to [deployed ? "un" : ""]deploy \the [src]...</span>")
			playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
			if(do_after(user, 30, src))
				visible_message(SPAN_NOTICE("[user] has [deployed ? "un" : ""]deployed \the [src]."))
				deployed = !deployed
				if(deployed)
					basic_chance = 70
				else
					basic_chance = 50
		update_icon()
		return TRUE

	if(isCrowbar(tool))
		if(!deployed && !density)
			visible_message("<span class='danger'>[user] is begins disassembling \the [src]...</span>")
			playsound(src, 'sound/items/Crowbar.ogg', 100, 1)
			if(do_after(user, 60, src))
				var/obj/item/barrier/B = new /obj/item/barrier(get_turf(user))
				visible_message(SPAN_NOTICE("[user] dismantled \the [src]."))
				playsound(src, 'sound/items/Deconstruct.ogg', 100, 1)
				B.health = health
				B.add_fingerprint(user)
				qdel(src)
		else
			to_chat(user, SPAN_NOTICE("You should unsecure \the [src] firstly. Use a screwdriver."))
		update_icon()
		return TRUE
	else
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		take_damage(tool.force)
		return ..()

/obj/structure/barrier/bullet_act(obj/item/projectile/P)
	..()
	take_damage(P.get_structure_damage())

/obj/structure/barrier/attack_generic(mob/user, damage, attack_verb)
	take_damage(damage)
	attack_animation(user)
	if(damage >=1)
		user.visible_message("<span class='danger'>[user] [attack_verb] \the [src]!</span>")
	else
		user.visible_message("<span class='danger'>[user] [attack_verb] \the [src] harmlessly!</span>")
	return 1

/obj/structure/barrier/proc/take_damage(damage)
	health -= damage * 0.5
	if(health <= 0)
		qdel(src)
	else
		playsound(src.loc, 'sound/effects/bang.ogg', 75, 1)

/obj/structure/barrier/proc/check_cover(obj/item/projectile/P, turf/from)
	var/turf/cover = get_turf(src)
	var/chance = basic_chance

	if(!cover)
		return 1

	var/mob/living/carbon/human/M = locate(src.loc)
	if(M)
		chance += 30

		if(M.lying)
			chance += 20

	if(get_dir(loc, from) == dir)
		chance += 10

	if(prob(chance))
		visible_message(SPAN_WARNING("[P] hits \the [src]!"))
		bullet_act(P)
		return 0

	return 1

/obj/structure/barrier/MouseDrop_T(mob/user as mob)
	if(src.loc != user.loc)
		to_chat(user, "You start climbing onto [src]...")
		step(src, get_dir(src, src.dir))

/obj/structure/barrier/ex_act(severity)
	switch(severity)
		if(1.0)
			new /obj/item/stack/material/steel(src.loc)
			new /obj/item/stack/material/steel(src.loc)
			if(prob(50))
				new /obj/item/stack/material/steel(src.loc)
			qdel(src)
			return
		if(2.0)
			new /obj/item/stack/material/steel(src.loc)
			if(prob(50))
				new /obj/item/stack/material/steel(src.loc)
			qdel(src)
			return
		else
	return

/obj/item/barrier
	name = "portable barrier"
	desc = "A portable barrier. Usually, you can see it on defensive positions or in storages at important areas. \
	You can deploy it with a screwdriver for maximum protection, or keep it in mobile position. \
	Also, demontage can be done with a crowbar.In case of structural damage, can be repaired with welding tool."
	icon = 'packs/infinity/icons/obj/items.dmi'
	icon_state = "barrier_hand"
	w_class = 4
	var/health = 200

/obj/item/barrier/proc/turf_check(mob/user as mob)
	for(var/obj/structure/barrier/D in user.loc.contents)
		if((D.dir == user.dir))
			USE_FEEDBACK_FAILURE("There is no more space.")
			return 1
	return 0

/obj/item/barrier/attack_self(mob/user as mob)
	if(!isturf(user.loc))
		USE_FEEDBACK_FAILURE("You can't place it here.")
		return
	if(turf_check(user))
		return

	if(do_after(user, 1 SECOND, src))
		playsound(src, 'sound/effects/extout.ogg', 100, 1)
		var/obj/structure/barrier/B = new(user.loc)
		B.set_dir(user.dir)
		B.health = health
		user.drop_item()
		qdel(src)

/obj/item/barrier/use_tool(obj/item/tool, mob/user, list/click_params)
	if(health != 200 && isWelder(tool))
		var/obj/item/weldingtool/WT = tool
		if(!WT.isOn())
			to_chat(user, SPAN_NOTICE("The [tool] should be turned on firstly."))
			return TRUE
		if(WT.remove_fuel(0,user))
			to_chat(user, SPAN_NOTICE("You start repairing the damage to [src]."))
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			if(do_after(user, max(5, health / 5), src) && WT?.isOn())
				to_chat(user, SPAN_NOTICE("You finish repairing the damage to [src]."))
				playsound(src, 'sound/items/Welder2.ogg', 100, 1)
				health = 200
			return TRUE
		else
			to_chat(user, SPAN_NOTICE("You need more welding fuel to complete this task."))
			return TRUE
	return ..()

// packs/infinity: mobile ladder (verbatim from packs/infinity/structures/ladder_mobile.dm)
/obj/item/ladder_mobile
	name = "mobile ladder"
	desc = "A lightweight deployable ladder, which you can use to move up or down. Or alternatively, you can bash some faces in."
	icon_state = "mobile_ladder"
	item_state = "mobile_ladder"
	icon = 'packs/infinity/icons/obj/mobile_ladder.dmi'
	throw_range = 3
	force = 10
	w_class = ITEM_SIZE_LARGE
	slot_flags = SLOT_BACK
	item_icons = list(
		slot_l_hand_str = 'packs/infinity/icons/mob/onmob/lefthand.dmi',
		slot_r_hand_str = 'packs/infinity/icons/mob/onmob/righthand.dmi',
		slot_back_str = 'packs/infinity/icons/mob/onmob/onmob_back.dmi'
		)

/obj/item/ladder_mobile/proc/place_ladder(atom/A, mob/user)
	if(istype(A, /turf/simulated/open))         //Place into open space
		var/turf/below_loc = GetBelow(A)
		if(!below_loc || (istype(/turf/space, below_loc)))
			to_chat(user, SPAN_NOTICE("Why would you do that?! There is only infinite space there..."))
			return
		user.visible_message(
			SPAN_WARNING("[user] begins to lower \the [src] into \the [A]."),
			SPAN_WARNING("You begin to lower \the [src] into \the [A].")
		)
		if(!handle_action(A, user))
			return
		// Create the lower ladder first. ladder/Initialize() will make the upper
		// ladder create the appropriate links. So the lower ladder must exist first.
		var/obj/structure/ladder/mobile/downer = new(below_loc)
		downer.allowed_directions = UP

		new /obj/structure/ladder/mobile(A)

		user.drop_item()
		qdel(src)

	else if (istype(A, /turf/simulated/floor))        //Place onto Floor
		var/turf/upper_loc = GetAbove(A)
		if(!upper_loc || !istype(upper_loc,/turf/simulated/open))
			to_chat(user, SPAN_NOTICE("There is something above. You can't deploy!"))
			return
		user.visible_message(
			SPAN_WARNING("[user] begins deploying \the [src] on \the [A]."),
			SPAN_WARNING("You begin to deploy \the [src] on \the [A].")
		)
		if(!handle_action(A, user))
			return
		// Ditto here. Create the lower ladder first.
		var/obj/structure/ladder/mobile/downer = new(A)
		downer.allowed_directions = UP

		new /obj/structure/ladder/mobile(upper_loc)

		user.drop_item()
		qdel(src)

/obj/item/ladder_mobile/use_after(atom/A, mob/user)
	place_ladder(A, user)
	return TRUE

/obj/item/ladder_mobile/proc/handle_action(atom/A, mob/user)
	if(!do_after(user, 30, src))
		to_chat(user, "Can't place ladder! You were interrupted!")
		return FALSE
	if(!A || QDELETED(src) || QDELETED(user))
		// Shit was deleted during delay, call is no longer valid.
		return FALSE
	return TRUE

/obj/structure/ladder/mobile
	icon = 'packs/infinity/icons/obj/mobile_ladder.dmi'

/obj/structure/ladder/mobile/New()
	..()
	update_icon()

/obj/structure/ladder/mobile/on_update_icon()
	icon_state = "mobile_ladder[!!(allowed_directions & UP)][!!(allowed_directions & DOWN)]"

/obj/structure/ladder/mobile/verb/fold()
	set name = "Fold Ladder"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated() || !usr.IsAdvancedToolUser() || !ishuman(usr))
		FEEDBACK_FAILURE(usr, "You can't do that right now!")
		return

	var/mob/living/carbon/human/H = usr

	H.visible_message(
		SPAN_NOTICE("[H] starts folding up [src]."),
		SPAN_NOTICE("You start folding up [src].")
	)

	if(!do_after(H, 30, src))
		FEEDBACK_FAILURE(H, "You are interrupted!")
		return

	if(QDELETED(src))
		return

	var/obj/item/ladder_mobile/R = new(get_turf(H))
	transfer_fingerprints_to(R)

	H.visible_message(
		SPAN_NOTICE("[H] folds [src] up into [R]!"),
		SPAN_NOTICE("You fold [src] up into [R]!")
	)

	if(target_down)
		QDEL_NULL(target_down)
		qdel(src)
	else
		QDEL_NULL(target_up)
		qdel(src)

#endif
