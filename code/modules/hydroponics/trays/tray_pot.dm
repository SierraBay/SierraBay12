// A clay pot. Carried as an item, set down to grow, and used to lift a plant off a tray.
/obj/item/plant_pot
	name = "plant pot"
	desc = "A clay pot. Use it on a hydroponics tray to transplant the plant, then set it down wherever you like."
	icon = 'icons/obj/flora/plant_pot.dmi'
	icon_state = "pot"
	item_state = "pot"
	w_class = ITEM_SIZE_NORMAL
	force = 3

	var/datum/seed/seed
	var/age = 0
	var/health = 0
	var/dead = 0
	var/harvest = 0
	var/sampled = 0
	var/lastproduce = 0
	var/waterlevel = 100
	var/nutrilevel = 10
	var/pestlevel = 0
	var/weedlevel = 0
	var/toxins = 0
	var/yield_mod = 0
	var/mutation_level = 0

/obj/item/plant_pot/Initialize()
	. = ..()
	update_icon()

/obj/item/plant_pot/examine(mob/user)
	. = ..()
	if(seed)
		to_chat(user, SPAN_NOTICE("\A [seed.display_name] is planted in it."))
	else
		to_chat(user, SPAN_NOTICE("It is empty."))

/obj/item/plant_pot/on_update_icon()
	ClearOverlays()
	w_class = ITEM_SIZE_NORMAL
	if(!seed)
		SetName(initial(name))
		return
	SetName("potted [seed.display_name]")
	if(seed.get_trait(TRAIT_LARGE))
		w_class = ITEM_SIZE_LARGE
	if(!seed.growth_stages)
		seed.update_growth_stages()
	if(!seed.growth_stages)
		return
	var/stage = 1
	if(seed.get_trait(TRAIT_MATURATION) > 0)
		stage = clamp(round(age / seed.get_trait(TRAIT_MATURATION) * seed.growth_stages), 1, seed.growth_stages)
	AddOverlays(seed.get_icon(stage))

/obj/item/plant_pot/attack_self(mob/user)
	place_at(get_turf(user), user)

/obj/item/plant_pot/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !isturf(target))
		return
	place_at(target, user)

/obj/item/plant_pot/proc/place_at(turf/destination, mob/user)
	if(!istype(destination) || destination.density)
		to_chat(user, SPAN_WARNING("You can't set a pot down there."))
		return FALSE
	if(user && !user.Adjacent(destination))
		return FALSE
	if(user && !user.unEquip(src, destination))
		return FALSE

	var/obj/machinery/portable_atmospherics/hydroponics/plantpot/pot = new(destination)
	pot.load_from_item(src)
	user.visible_message(SPAN_NOTICE("\The [user] sets \the [pot] down."), SPAN_NOTICE("You set \the [pot] down."))
	qdel(src)
	return TRUE

/obj/item/plant_pot/proc/transplant_from(obj/machinery/portable_atmospherics/hydroponics/tray, mob/user)
	if(seed)
		to_chat(user, SPAN_WARNING("\The [src] already has a plant in it."))
		return TRUE
	if(istype(tray, /obj/machinery/portable_atmospherics/hydroponics/soil/invisible))
		to_chat(user, SPAN_WARNING("This plant is rooted in place."))
		return TRUE
	if(!tray.seed)
		to_chat(user, SPAN_WARNING("There is nothing growing in \the [tray]."))
		return TRUE
	if(tray.dead)
		to_chat(user, SPAN_WARNING("The plant is dead."))
		return TRUE

	copy_growth(tray)
	tray.seed = null
	tray.dead = 0
	tray.harvest = 0
	tray.age = 0
	tray.health = 0
	tray.sampled = 0
	tray.lastproduce = 0
	tray.yield_mod = 0
	tray.mutation_level = 0
	tray.update_icon()
	update_icon()
	user.visible_message(SPAN_NOTICE("\The [user] transplants \the [seed.display_name] into \the [src]."), SPAN_NOTICE("You transplant \the [seed.display_name] into \the [src]."))
	return TRUE

/obj/item/plant_pot/proc/copy_growth(obj/machinery/portable_atmospherics/hydroponics/tray)
	seed = tray.seed
	age = tray.age
	health = tray.health
	dead = tray.dead
	harvest = tray.harvest
	sampled = tray.sampled
	lastproduce = tray.lastproduce
	waterlevel = tray.waterlevel
	nutrilevel = tray.nutrilevel
	pestlevel = tray.pestlevel
	weedlevel = tray.weedlevel
	toxins = tray.toxins
	yield_mod = tray.yield_mod
	mutation_level = tray.mutation_level

/obj/machinery/portable_atmospherics/hydroponics/plantpot
	name = "plant pot"
	desc = "A clay pot. The plant inside keeps growing, and the whole pot can be picked up."
	icon = 'icons/obj/flora/plant_pot.dmi'
	icon_state = "pot"
	density = FALSE
	anchored = TRUE
	mechanical = 0
	use_power = POWER_USE_OFF
	stat_immune = MACHINE_STAT_NOINPUT | MACHINE_STAT_NOSCREEN | MACHINE_STAT_NOPOWER
	tray_light = 0

/obj/machinery/portable_atmospherics/hydroponics/plantpot/New()
	..()
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/close_lid_verb
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/setlight

/obj/machinery/portable_atmospherics/hydroponics/plantpot/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/portable_atmospherics/hydroponics/plantpot/on_update_icon()
	..()
	if(seed)
		SetName("potted [seed.display_name]")
	else
		SetName(initial(name))

/obj/machinery/portable_atmospherics/hydroponics/plantpot/physical_attack_hand(mob/user)
	if(user.a_intent == I_HURT)
		return FALSE
	if(user.a_intent != I_GRAB && (harvest || dead))
		return ..()
	return scoop_into(user)

/obj/machinery/portable_atmospherics/hydroponics/plantpot/MouseDrop(atom/over)
	if(over == usr && Adjacent(usr) && ishuman(usr))
		scoop_into(usr)
		return
	return ..()

/obj/machinery/portable_atmospherics/hydroponics/plantpot/proc/load_from_item(obj/item/plant_pot/item)
	seed = item.seed
	age = item.age
	health = item.health
	dead = item.dead
	harvest = item.harvest
	sampled = item.sampled
	lastproduce = item.lastproduce
	waterlevel = item.waterlevel
	nutrilevel = item.nutrilevel
	pestlevel = item.pestlevel
	weedlevel = item.weedlevel
	toxins = item.toxins
	yield_mod = item.yield_mod
	mutation_level = item.mutation_level
	lastcycle = world.time
	if(seed)
		check_health()
	update_icon()

/obj/machinery/portable_atmospherics/hydroponics/plantpot/proc/scoop_into(mob/user)
	if(!user || user.incapacitated() || !user.Adjacent(src))
		return FALSE
	var/obj/item/plant_pot/item = new(get_turf(src))
	item.copy_growth(src)
	item.update_icon()
	var/pot_name = name
	qdel(src)
	user.put_in_hands(item)
	user.visible_message(SPAN_NOTICE("\The [user] picks up \the [pot_name]."), SPAN_NOTICE("You pick up \the [pot_name]."))
	return TRUE
