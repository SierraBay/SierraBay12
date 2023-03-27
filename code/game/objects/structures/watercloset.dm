//todo: toothbrushes, and some sort of "toilet-filthinator" for the hos
/obj/structure/hygiene
	var/next_gurgle = 0
	var/clogged = 0 // -1 = never clog
	var/can_drain = 0
	var/drainage = 0.5
	var/last_gurgle = 0

/obj/structure/hygiene/New()
	..()
	SSfluids.hygiene_props += src
	START_PROCESSING(SSobj, src)

/obj/structure/hygiene/Destroy()
	SSfluids.hygiene_props -= src
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/hygiene/proc/clog(severity)
	if(clogged) //We can only clog if our state is zero, aka completely unclogged and cloggable
		return FALSE
	clogged = severity
	return TRUE

/obj/structure/hygiene/proc/unclog()
	clogged = 0

/obj/structure/hygiene/attackby(obj/item/thing, mob/user)
	if(clogged > 0 && isplunger(thing))
		user.visible_message(SPAN_NOTICE("\The [user] strives valiantly to unclog \the [src] with \the [thing]!"))
		spawn
			playsound(loc, 'sound/effects/plunger.ogg', 75, 1)
			sleep(5)
			playsound(loc, 'sound/effects/plunger.ogg', 75, 1)
			sleep(5)
			playsound(loc, 'sound/effects/plunger.ogg', 75, 1)
			sleep(5)
			playsound(loc, 'sound/effects/plunger.ogg', 75, 1)
			sleep(5)
			playsound(loc, 'sound/effects/plunger.ogg', 75, 1)
		if(do_after(user, 4.5 SECONDS, src, DO_PUBLIC_UNIQUE) && clogged > 0)
			visible_message(SPAN_NOTICE("With a loud gurgle, \the [src] begins flowing more freely."))
			playsound(loc, pick(SSfluids.gurgles), 100, 1)
			clogged--
			if(clogged <= 0)
				unclog()
		return
	. = ..()

/obj/structure/hygiene/examine(mob/user)
	. = ..()
	if(clogged > 0)
		to_chat(user, SPAN_WARNING("It seems to be badly clogged."))

/obj/structure/hygiene/Process()
	if(clogged <= 0)
		drain()
	var/flood_amt
	switch(clogged)
		if(1)
			flood_amt = FLUID_SHALLOW
		if(2)
			flood_amt = FLUID_OVER_MOB_HEAD
		if(3)
			flood_amt = FLUID_DEEP
	if(flood_amt)
		var/turf/T = loc
		if(istype(T))
			var/obj/effect/fluid/F = locate() in T
			if(!F) F = new(loc)
			T.show_bubbles()
			if(world.time > next_gurgle)
				visible_message("\The [src] gurgles and overflows!")
				next_gurgle = world.time + 80
				playsound(T, pick(SSfluids.gurgles), 50, 1)
			SET_FLUID_DEPTH(F, min(F.fluid_amount + (rand(30,50)*clogged), flood_amt))

/obj/structure/hygiene/proc/drain()
	if(!can_drain) return
	var/turf/T = get_turf(src)
	if(!istype(T)) return
	var/fluid_here = T.get_fluid_depth()
	if(fluid_here <= 0)
		return

	T.remove_fluid(Ceil(fluid_here*drainage))
	T.show_bubbles()
	if(world.time > last_gurgle + 80)
		last_gurgle = world.time
		playsound(T, pick(SSfluids.gurgles), 50, 1)

/obj/structure/hygiene/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	density = FALSE
	anchored = TRUE
	var/open = 0			//if the lid is up
	var/cistern = 0			//if the cistern bit is open
	var/w_items = 0			//the combined w_class of all the items in the cistern
	var/mob/living/swirlie = null	//the mob being given a swirlie

/obj/structure/hygiene/toilet/Initialize()
	. = ..()
	open = round(rand(0, 1))
	update_icon()

/obj/structure/hygiene/toilet/attack_hand(mob/living/user)
	if(swirlie)
		usr.visible_message(SPAN_DANGER("[user] slams the toilet seat onto [swirlie.name]'s head!"), SPAN_NOTICE("You slam the toilet seat onto [swirlie.name]'s head!"), "You hear reverberating porcelain.")
		swirlie.adjustBruteLoss(8)
		return

	if(cistern && !open)
		if(!length(contents))
			to_chat(user, SPAN_NOTICE("The cistern is empty."))
			return
		else
			var/obj/item/I = pick(contents)
			if(ishuman(user))
				user.put_in_hands(I)
			else
				I.dropInto(loc)
			to_chat(user, SPAN_NOTICE("You find \an [I] in the cistern."))
			w_items -= I.w_class
			return

	open = !open
	update_icon()

/obj/structure/hygiene/toilet/on_update_icon()
	icon_state = "toilet[open][cistern]"

/obj/structure/hygiene/toilet/attackby(obj/item/I as obj, mob/living/user)
	if(isCrowbar(I))
		to_chat(user, SPAN_NOTICE("You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]."))
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(do_after(user, 3 SECONDS, src, DO_REPAIR_CONSTRUCT))
			user.visible_message(
				SPAN_NOTICE("[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!"),
				SPAN_NOTICE("You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!"),
				"You hear grinding porcelain."
			)
			cistern = !cistern
			update_icon()
			return

	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I

		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting
			if(!GM.loc == get_turf(src))
				to_chat(user, SPAN_WARNING("\The [GM] needs to be on the toilet."))
				return
			if(open && !swirlie)
				user.visible_message(SPAN_DANGER("\The [user] starts jamming \the [GM]'s face into \the [src]!"))
				swirlie = GM
				if(do_after(user, 3 SECONDS, src, DO_PUBLIC_UNIQUE))
					user.visible_message(SPAN_DANGER("\The [user] gives [GM.name] a swirlie!"))
					GM.adjustOxyLoss(5)
				swirlie = null
			else
				user.visible_message(SPAN_DANGER("\The [user] slams [GM.name] into the [src]!"), SPAN_NOTICE("You slam [GM.name] into the [src]!"))
				GM.adjustBruteLoss(8)

	if(cistern && !istype(user,/mob/living/silicon/robot)) //STOP PUTTING YOUR MODULES IN THE TOILET.
		if(I.w_class > ITEM_SIZE_NORMAL)
			to_chat(user, SPAN_WARNING("\The [I] does not fit."))
			return
		if(w_items + I.w_class > 5)
			to_chat(user, SPAN_WARNING("The cistern is full."))
			return
		if(!user.unEquip(I, src))
			return
		w_items += I.w_class
		to_chat(user, SPAN_NOTICE("You carefully place \the [I] into the cistern."))
		return

	. = ..()

/obj/structure/hygiene/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = FALSE
	anchored = TRUE

/obj/structure/hygiene/urinal/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting
			if(!GM.loc == get_turf(src))
				to_chat(user, SPAN_WARNING("[GM.name] needs to be on the urinal."))
				return
			user.visible_message(SPAN_DANGER("[user] slams [GM.name] into the [src]!"))
			GM.adjustBruteLoss(8)
	. = ..()

/obj/item/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"

/obj/structure/hygiene/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = TRUE
	var/busy = 0 	//Something's being washed at the moment

/obj/structure/hygiene/sink/MouseDrop_T(obj/item/thing, mob/user)
	..()
	if(!istype(thing) || !thing.is_open_container())
		return ..()
	if(!usr.Adjacent(src))
		return ..()
	if(!thing.reagents || thing.reagents.total_volume == 0)
		to_chat(usr, SPAN_WARNING("\The [thing] is empty."))
		return
	// Clear the vessel.
	visible_message(SPAN_NOTICE("\The [usr] tips the contents of \the [thing] into \the [src]."))
	thing.reagents.clear_reagents()
	thing.update_icon()

/obj/structure/hygiene/sink/attack_hand(mob/user)
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.organs_by_name[BP_R_HAND]
		if (user.hand)
			temp = H.organs_by_name[BP_L_HAND]
		if(temp && !temp.is_usable())
			to_chat(user,SPAN_NOTICE("You try to move your [temp.name], but cannot!"))
			return

	if(isrobot(user) || isAI(user))
		return

	if(!Adjacent(user))
		return

	if(busy)
		to_chat(user, SPAN_WARNING("Someone's already washing here."))
		return

	to_chat(usr, SPAN_NOTICE("You start washing your hands."))
	playsound(loc, 'sound/effects/sink_long.ogg', 75, 1)

	busy = 1
	if(!do_after(user, 4 SECONDS, src, DO_PUBLIC_UNIQUE))
		busy = 0
		return TRUE
	busy = 0

	user.clean_blood()
	user.visible_message( \
		SPAN_NOTICE("[user] washes their hands using \the [src]."), \
		SPAN_NOTICE("You wash your hands using \the [src]."))


/obj/structure/hygiene/sink/attackby(obj/item/O as obj, mob/living/user)

	if(isplunger(O) && clogged > 0)
		return ..()

	if(busy)
		to_chat(user, SPAN_WARNING("Someone's already washing here."))
		return

	var/obj/item/reagent_containers/RG = O
	if (istype(RG) && RG.is_open_container() && RG.reagents)
		RG.reagents.add_reagent(/datum/reagent/water, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		user.visible_message(SPAN_NOTICE("[user] fills \the [RG] using \the [src]."),SPAN_NOTICE("You fill \the [RG] using \the [src]."))
		playsound(loc, 'sound/effects/sink.ogg', 75, 1)
		return 1

	else if (istype(O, /obj/item/melee/baton))
		var/obj/item/melee/baton/B = O
		if(B.bcell)
			if(B.bcell.charge > 0 && B.status == 1)
				flick("baton_active", src)
				user.Stun(10)
				user.stuttering = 10
				user.Weaken(10)
				if(isrobot(user))
					var/mob/living/silicon/robot/R = user
					R.cell.charge -= 20
				else
					B.deductcharge(B.hitcost)
				user.visible_message( \
					SPAN_DANGER("[user] was stunned by \his wet [O]!"), \
					SPAN_CLASS("userdanger", "[user] was stunned by \his wet [O]!"))
				return 1
	else if(istype(O, /obj/item/mop))
		O.reagents.add_reagent(/datum/reagent/water, 5)
		to_chat(user, SPAN_NOTICE("You wet \the [O] in \the [src]."))
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
		return

	var/turf/location = user.loc
	if(!isturf(location)) return

	var/obj/item/I = O
	if(!I || !istype(I,/obj/item)) return

	to_chat(usr, SPAN_NOTICE("You start washing \the [I]."))
	playsound(loc, 'sound/effects/sink_long.ogg', 75, 1)

	busy = 1
	if(!do_after(user, 4 SECONDS, src, DO_PUBLIC_UNIQUE))
		busy = 0
		return TRUE
	busy = 0

	if(istype(O, /obj/item/extinguisher)) return TRUE // We're washing, not filling.

	O.clean_blood()
	user.visible_message( \
		SPAN_NOTICE("[user] washes \a [I] using \the [src]."), \
		SPAN_NOTICE("You wash \a [I] using \the [src]."))


/obj/structure/hygiene/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"

/obj/structure/hygiene/sink/puddle	//splishy splashy ^_^
	name = "puddle"
	icon_state = "puddle"
	clogged = -1 // how do you clog a puddle

/obj/structure/hygiene/sink/puddle/attack_hand(mob/M)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"

/obj/structure/hygiene/sink/puddle/attackby(obj/item/O as obj, mob/user)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"

//toilet paper interaction for clogging toilets and other facilities

/obj/structure/hygiene/attackby(obj/item/I, mob/user)
	if (!istype(I, /obj/item/taperoll/bog))
		..()
		return
	if (clogged == -1)
		to_chat(user, SPAN_WARNING("Try as you might, you can not clog \the [src] with \the [I]."))
		return
	if (clogged)
		to_chat(user, SPAN_WARNING("\The [src] is already clogged."))
		return
	if (!do_after(user, 3 SECONDS, src, DO_PUBLIC_UNIQUE))
		return
	if (clogged || QDELETED(I) || !user.unEquip(I))
		return
	to_chat(user, SPAN_NOTICE("You unceremoniously jam \the [src] with \the [I]. What a rebel."))
	clog(1)
	qdel(I)

/obj/item/taperoll/bog
	name = "toilet paper roll"
	icon = 'icons/obj/watercloset.dmi'
	desc = "A unbranded roll of standard issue two ply toilet paper. Refined from carefully rendered down sea shells due to SolGov's 'Abuse Of The Trees Act'."
	tape_type = /obj/item/tape/bog
	icon_state = "bogroll"
	item_state = "mummy_poor"
	slot_flags = SLOT_HEAD | SLOT_OCLOTHING
	var/sheets = 30

/obj/item/tape/bog
	name = "toilet paper"
	desc = "A length of toilet paper. Seems like custodia is marking their territory again."
	icon_base = "stripetape"
	color = COLOR_WHITE
	detail_overlay = "stripes"
	detail_color = COLOR_WHITE

/obj/item/taperoll/bog/verb/tear_sheet()
	set category = "Object"
	set name = "Tear Sheet"
	set desc = "Tear a sheet of toilet paper."
	if (usr.incapacitated())
		return
	if(sheets > 0)
		visible_message("\The [usr] tears a sheet from \the [src].", "You tear a sheet from \the [src].")
		var/obj/item/paper/crumpled/bog/C =  new(loc)
		usr.put_in_hands(C)
		sheets--
	if (sheets < 1)
		to_chat(usr, "\The [src] is depleted.")
		qdel(src)

/obj/item/paper/crumpled/bog
	name = "sheet of toilet paper"
	desc = "A single sheet of toilet paper. Two ply."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "bogroll_sheet"

/obj/structure/hygiene/faucet
	name = "faucet"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "faucet"
	desc = "An outlet for liquids. Water you waiting for?"
	anchored = TRUE
	drainage = 0
	clogged = -1
	var/fill_level = 500
	var/open = FALSE

/obj/structure/hygiene/faucet/attackby(obj/item/thing, mob/user)
	if (isWrench(thing))
		new /obj/item/faucet (loc)
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		user.visible_message(
			SPAN_WARNING("\The [user] unwrenches \the [src]."),
			SPAN_WARNING("You unwrench \the [src].")
		)
		qdel(src)
		return TRUE
	return ..()

/obj/structure/hygiene/faucet/attack_hand(mob/user)
	. = ..()
	open = !open
	if(open)
		playsound(loc, 'sound/effects/closet_open.ogg', 20, 1)
	else
		playsound(loc, 'sound/effects/closet_close.ogg', 20, 1)

	user.visible_message(
		SPAN_NOTICE("\The [user] has [open ? "opened" : "closed"] \the [src]."),
		SPAN_NOTICE("You [open ? "open" : "close"] \the [src].")
	)
	update_icon()

/obj/structure/hygiene/faucet/on_update_icon()
	. = ..()
	icon_state = icon_state = "[initial(icon_state)][open ? "-on" : ""]"

/obj/item/faucet
	name = "faucet"
	desc = "An outlet for liquids. Water you waiting for?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "faucet-item"
	obj_flags = OBJ_FLAG_ROTATABLE
	var/constructed_type = /obj/structure/hygiene/faucet

/obj/item/faucet/attackby(obj/item/thing, mob/user)
	if(isWrench(thing))
		var/turf/simulated/floor/F = loc
		if (istype(F) && istype(F.flooring, /singleton/flooring/pool))
			var/obj/O = new constructed_type (loc)
			O.dir = dir
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			user.visible_message(
				SPAN_WARNING("\The [user] wrenches \the [src] down."),
				SPAN_WARNING("You wrench \the [src] down.")
			)
			qdel(src)
		else
			to_chat(user, SPAN_WARNING("\The [src] can only be secured to pool tiles!"))
		return TRUE
	return ..()

/obj/structure/hygiene/faucet/proc/water_flow()
	if(!isturf(src.loc))
		return

	// Check for depth first, and pass if the water's too high. I know players will find a way to just submerge entire ship if I do not.
	var/turf/T = get_turf(src)

	if(!T || T.get_fluid_depth() > fill_level)
		return

	if(world.time > next_gurgle)
		next_gurgle = world.time + 80
		playsound(T, pick(SSfluids.gurgles), 50, 1)

	T.add_fluid(min(75, fill_level - T.get_fluid_depth()), /datum/reagent/water)

/obj/structure/hygiene/faucet/Process()
	..()
	if(open)
		water_flow()

/obj/structure/hygiene/faucet/examine(mob/user)
	. = ..()
	to_chat(user, "It is turned [open ? "on" : "off"]")
