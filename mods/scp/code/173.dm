/mob/living/simple_animal/hostile/statue
	name = "Statue"
	desc = "A statue, constructed from concrete and rebar with traces of Krylon brand spray paint."
	icon = 'mods/scp/icons/statue.dmi'
	icon_state = "173"
	universal_understand = 1
	mob_size = MOB_LARGE
	status_flags = GODMODE
	can_bleed = FALSE
	see_in_dark = 8
	ai_holder = null
	var/last_charge = 0
	var/next_shit = 0
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent
	var/snap_sound = list('mods/scp/sounds/firstpersonsnap.ogg','mods/scp/sounds/firstpersonsnap2.ogg','mods/scp/sounds/firstpersonsnap3.ogg')
	var/scare_sound = list('mods/scp/sounds/scare1.ogg','mods/scp/sounds/scare2.ogg','mods/scp/sounds/scare3.ogg','mods/scp/sounds/scare4.ogg')

/mob/living/simple_animal/hostile/statue/proc/IsBeingWatched(list/checking)
	if(!checking)
		checking = view(7, src)

	for(var/mob/living/L in checking)
		if(L.stat != CONSCIOUS)
			continue

		if(istype(L, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = L
			if(is_blind(H) || H.eye_blind > 0)
				continue
			if(H.in_fov_strict(src) && isInSightLighting(H, src))
				return TRUE

		else if(istype(L, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = L
			if(!R.is_component_functioning("camera"))
				continue
			if(isInSightLighting(R, src))
				return TRUE

		else if(istype(L, /mob/living/exosuit))
			var/mob/living/exosuit/E = L
			if(E.in_fov_strict(src) && isInSightLighting(E, src))
				return TRUE
	return FALSE

/mob/living/simple_animal/hostile/statue/handle_atmos()
	return

/mob/living/simple_animal/hostile/statue/Move()
	return

/mob/living/simple_animal/hostile/statue/Life()
	if (isobj(loc))
		return

	var/list/our_view = view(7, src)

	if(IsBeingWatched(our_view))
		return

	if(buckled)
		buckled.unbuckle_mob(src)

	if(world.time >= next_shit)
		next_shit = world.time+rand(5 MINUTES, 10 MINUTES)
		var/obj/effect/feces = pick(/obj/gibspawner/generic, /obj/gibspawner/human)
		new feces(loc)
		last_charge = world.time
		return

	if(world.time >= last_charge+50)
		var/mob/living/target
		var/list/mob/living/possible_targets = list()
		for(var/mob/living/L in our_view)
			if(L.stat != CONSCIOUS)
				continue
			if(!istype(L, /mob/living/carbon/human) && !istype(L, /mob/living/exosuit))
				continue
			if(!AStar(loc, L.loc, /turf/proc/AdjacentTurfs, /turf/proc/Distance, max_nodes=25, max_node_depth=7))
				continue // We can't reach this person anyways
			possible_targets += L
		if(length(possible_targets))
			target = pick(possible_targets)

		if (target)	// NECK SNAP TIME
			var/turf/spot
			var/turf/behind_target = get_step(target.loc, turn(target.dir, 180))
			if(isturf(behind_target) && get_dist(behind_target, loc) <= 7 && not_turf_contains_dense_objects(behind_target))
				spot = behind_target
			else
				var/list/directions = shuffle(GLOB.cardinal.Copy())
				for(var/D in directions)
					var/turf/T = get_step(target, D)
					if(turf_contains_dense_objects(T))
						continue
					if(isturf(T) && get_dist(T, loc) <= 7)
						spot = T
						break
			if(!spot)
				return
			forceMove(spot)
			dir = get_dir(src, target)
			if(!IsBeingWatched(our_view))
				visible_message("<span class='danger'>[src] snaps [target]'s neck!</span>")
				playsound(get_turf(src), pick(snap_sound), 50, 1)
				if(ismech(target))
					target.apply_damage(150, DAMAGE_BRUTE)
				else
					target.apply_damage(75, DAMAGE_BRUTE, (ishuman(target) && target.is_species(SPECIES_IPC)) ? BP_CHEST : BP_HEAD)
				if(prob(25))
					playsound(get_turf(src), pick(scare_sound), 25, 1)
			else
				playsound(get_turf(src), pick(scare_sound), 25, 1)
			last_charge = world.time
			return

		if(!target && prob(33)) // crush time
			var/obj/object = find_and_destroy_object()
			if(object)
				visible_message("<span class='danger'>[src] breaks \the [object]!</span>")
				dir = get_dir(src, object)
				last_charge = world.time
				return

		if(!target && prob(10)) // sneaky-peaky, let's travel into vents
			for(entry_vent in view(1, src))
				if(entry_vent.welded)
					continue
				last_charge = world.time + 50
				dir = get_dir(src, entry_vent)
				visible_message("<span class='danger'>\The [src] starts trying to slide itself into the vent!</span>")
				sleep(50) //Let's stop SCP-173 for five seconds to do his parking job
				if(entry_vent.network && length(entry_vent.network.normal_members))
					var/list/vents = list()
					for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in entry_vent.network.normal_members)
						vents.Add(temp_vent)
					if(!length(vents))
						entry_vent = null
						return
					if(IsBeingWatched(our_view)) //Someone started looking at us
						return
					var/obj/machinery/atmospherics/unary/vent_pump/exit_vent = pick(vents)
					visible_message("<span class='danger'>\The [src] suddenly disappears into the vent!</span>")
					forceMove(entry_vent)
					sleep(rand(10,100))
					if(!exit_vent || exit_vent.welded)
						forceMove(get_turf(entry_vent))
						entry_vent = null
						dir = pick(GLOB.cardinal)
						try_to_scare(100, 0, our_view)
						visible_message("<span class='danger'>\The [src] suddenly appears from the vent!</span>")
						last_charge = world.time + 50
						return

					forceMove(get_turf(exit_vent))
					entry_vent = null
					dir = pick(GLOB.cardinal)
					try_to_scare(100, 0, our_view)
					visible_message("<span class='danger'>\The [src] suddenly appears from the vent!</span>")
					last_charge = world.time + 50
					return
				else
					entry_vent = null

		if(!target)
			var/list/turfs = list()
			var/list/possible_turfs = list()
			for(var/turf/T in our_view)
				if(is_space_turf(T) || turf_contains_dense_objects(T))
					continue
				possible_turfs += T

			if(length(possible_turfs))
				var/attempts = 15 // Limit AStar attempts for performance
				while(attempts > 0 && length(possible_turfs))
					attempts--
					var/turf/T = pick(possible_turfs)
					possible_turfs -= T
					if(AStar(loc, T, /turf/proc/AdjacentTurfs, /turf/proc/Distance, max_nodes=25, max_node_depth=7))
						turfs += T
						if(length(turfs) >= 5) break // We found some good spots, that's enough

			if(!length(turfs) || IsBeingWatched(our_view)) // no turfs to jump :(
				return
			var/turf/chosen_turf = pick(turfs)
			dir = get_dir(src, chosen_turf)
			forceMove(chosen_turf)
			last_charge = world.time
			for(var/obj/machinery/door/airlock/AL in view(src,1))
				if(AL && AL.density && prob(50))	// little chance to bump into the door near us.
					dir = get_dir(src, AL)
					AL.bumpopen(src)
					break
			try_to_scare(25, 1, our_view)

/mob/living/simple_animal/hostile/statue/proc/find_and_destroy_object()
	var/list/close_view = shuffle(view(src, 1))

	for(var/obj/machinery/light/L in close_view)
		if(L.on)
			L.broken()
			return L

	for(var/obj/machinery/floodlight/FL in close_view)
		if(FL.use_power)
			qdel(FL)
			return FL

	for(var/obj/item/device/flashlight/F in close_view)
		if(F.on)
			qdel(F)
			return F

	for(var/obj/structure/window/W in close_view)
		var/safe = 1
		for(var/dir in GLOB.cardinal)
			var/turf/T = get_turf(get_step(W.loc, dir))
			if(IsTurfAtmosUnsafe(T))
				safe = 0
				break
		if(safe && W.init_material != /obj/item/stack/material/glass/boron_reinforced)
			W.shatter(0)
			return W
	for(var/obj/structure/grille/G in close_view)
		var/safe = 1
		for(var/dir in GLOB.cardinal)
			var/turf/T = get_turf(get_step(G.loc, dir))
			if(IsTurfAtmosUnsafe(T))
				safe = 0
				break
		if(safe)
			new /obj/item/stack/material/rods(G.loc)
			G.Destroy()
			return G
	for(var/obj/structure/wall_frame/WF in close_view)
		var/safe = 1
		for(var/dir in GLOB.cardinal)
			var/turf/T = get_turf(get_step(WF.loc, dir))
			if(IsTurfAtmosUnsafe(T))
				safe = 0
				break
		if(safe)
			WF.dismantle()
			return WF
	for(var/obj/machinery/door/window/WD in close_view)
		WD.shatter(0)
		return WD
	for(var/obj/structure/closet/CL in close_view)
		CL.ex_act(1)
		return CL
	for(var/obj/structure/table/T in close_view)
		T.Destroy()
		return T

/mob/living/simple_animal/hostile/statue/proc/try_to_scare(chance = 25, should_see = 1, list/checking = null)
	var/scared
	var/list/checking_list = checking || view(7, src)
	for(var/mob/living/carbon/human/spooked in checking_list)
		if(spooked.stat != CONSCIOUS)
			continue
		if(!(spooked.in_fov_strict(src) && isInSightLighting(spooked, src)) && should_see)
			continue
		if(!prob(chance))
			continue
		shake_camera(spooked, rand(5,20))
		scared = 1
	if(scared)
		playsound(get_turf(src), pick(scare_sound), 50, 1)

/mob/living/simple_animal/hostile/statue/ex_act()
	return


// CAGE //

/obj/structure/statue_cage
	icon = 'mods/scp/icons/statue_cage.dmi'
	icon_state = "2"
	layer = MOB_LAYER + 0.05
	name = "cage"
	desc = "An elongated cage with an unusual lever below."
	density = TRUE
	var/contained

/obj/structure/statue_cage/MouseDrop_T(atom/movable/dropping, mob/user)
	if (istype(dropping, /mob/living/simple_animal/hostile/statue))
		visible_message(SPAN_WARNING("[user] starts to put [dropping] into the cage."))
		var/oloc = loc
		if (do_after(user, 5 SECONDS, dropping) && loc == oloc) // shitty but there's no good alternative
			dropping.forceMove(src)
			underlays = list(dropping)
			visible_message(SPAN_NOTICE("[user] puts [dropping] in the cage."))
			contained = dropping
			update_icon()
	else if (isliving(dropping))
		to_chat(user, SPAN_WARNING("\The [dropping] won't fit in the cage."))

/obj/structure/statue_cage/attack_hand(mob/living/carbon/human/H)
	if(contained)
		var/mob/living/simple_animal/hostile/statue/S = contained
		visible_message(SPAN_WARNING("[H] releases [S] from the cage."))
		S.forceMove(get_turf(get_step(src.loc, dir)))
		for(var/dir in shuffle(GLOB.cardinal))
			var/turf/T = get_turf(get_step(loc, dir))
			if(turf_contains_dense_objects(T))
				continue
			S.forceMove(get_turf(get_step(src.loc, dir)))
			break

		contained = null
		underlays.Cut()
		update_icon()
	else
		visible_message(SPAN_NOTICE("The cage is empty; there's nothing to take out."))

/obj/structure/statue_cage/examine(mob/user)
	. = ..()
	if(contained)
		to_chat(user, SPAN_NOTICE("A strange statue is contained there."))
	else
		to_chat(user, SPAN_NOTICE("It's empty."))

/obj/structure/statue_cage/on_update_icon()
	icon_state = contained ? "1" : "2"

/obj/structure/statue_cage/pre_contain
	icon_state = "1"

/obj/structure/statue_cage/pre_contain/Initialize()
	. = ..()

	var/mob/living/simple_animal/hostile/statue/S = new(src)
	contained = S
	underlays += S
	update_icon()

/mob/proc/in_fov_strict(atom/observed_atom)
	if(is_blind() || (sight & BLIND))
		return FALSE

	var/turf/my_turf = get_turf(src)
	if(!my_turf || !observed_atom)
		return FALSE

	// Lighting check
	var/turf/T = get_turf(observed_atom)
	if(T && T.get_lumcount() <= 0.1 && !(sight & SEE_TURFS))
		return FALSE

	var/rel_x = observed_atom.x - my_turf.x
	var/rel_y = observed_atom.y - my_turf.y

	if(rel_x == 0 && rel_y == 0) // We are on the same turf
		return TRUE

	var/client/C = client
	if(!C && istype(src, /mob/living/exosuit))
		var/mob/living/exosuit/E = src
		for(var/mob/living/P in E.pilots)
			if(P.client)
				C = P.client
				break

	if(C?.fovangle)
		// Get the vector length
		var/vector_len = sqrt(rel_x**2 + rel_y**2)

		// Getting a direction vector based on mob's dir
		var/dir_x = 0
		var/dir_y = 0

		if(dir & NORTH) dir_y = 1
		if(dir & SOUTH) dir_y = -1
		if(dir & EAST)  dir_x = 1
		if(dir & WEST)  dir_x = -1

		// Normalize dir vector to match the length of relative vector for arccos calculation
		var/dir_len = sqrt(dir_x**2 + dir_y**2)
		if(dir_len)
			dir_x = (dir_x / dir_len) * vector_len
			dir_y = (dir_y / dir_len) * vector_len

		// Calculate angle using dot product: arccos((A*B) / (|A|*|B|))
		var/dot_product = (dir_x * rel_x + dir_y * rel_y)
		var/magnitudes = (sqrt(dir_x**2 + dir_y**2) * sqrt(rel_x**2 + rel_y**2))

		if(magnitudes == 0) return TRUE // Should be handled by rel_x/y == 0 but just in case

		var/angle = arccos(dot_product / magnitudes)

		// Calculate vision angle and compare
		var/vision_angle = (360 - C.fovangle) / 2
		return (angle < vision_angle)

	return TRUE

/proc/isInSightLighting(atom/A, atom/B)
	var/turf/Aturf = get_turf(A)
	var/turf/Bturf = get_turf(B)

	if(!Aturf || !Bturf)
		return FALSE

	// Check for physical obstructions first
	if(!inLineOfSight(Aturf.x, Aturf.y, Bturf.x, Bturf.y, Aturf.z))
		return FALSE

	// Lighting check
	// If the target tile is lit, it's visible.
	if(Bturf.get_lumcount() > 0.1)
		return TRUE

	// If the observer is a mob, check if they have night vision or special sight.
	if(ismob(A))
		var/mob/M = A
		// Normal humans have see_in_dark = 2. Night vision is > 2 or SEE_TURFS flag.
		if(M.sight & SEE_TURFS)
			return TRUE

	// If neither, then it's too dark for A to see B.
	return FALSE
