//Чёто там меняет с грабами при таскании по лестнице
//Лесенки
/obj/structure/stairs/Bumped(atom/movable/A)
	var/turf/above = GetAbove(A)
	if (above)
		var/turf/target = get_step(above, dir)
		var/turf/source = get_turf(A)
		if(above.CanZPass(source, UP) && target.Enter(A, src))
			if (bluespace_affected)
				var/list/obj/structure/other_stairs= list()
				for (var/obj/structure/stairs/stair)
					if (src != stair && (stair.z in GetConnectedZlevels(above.z)))
						other_stairs += stair
				var/obj/structure/stairs/other_stair = pick(other_stairs)
				if (prob(displacement_chance))
					target = get_turf(other_stair)
					if (prob(20))
						to_chat(A, SPAN_WARNING("You feel turned around..."))
			A.forceMove(target)
			if(isliving(A))
				var/mob/living/L = A
				if(L.pulling)
					L.pulling.forceMove(target)
				for(var/obj/item/grab/founded_grab in L)
					founded_grab.affecting.forceMove(target)
			if(ishuman(A))
				var/mob/living/carbon/human/H = A
				if(H.has_footsteps())
					playsound(source, 'sound/effects/stairs_step.ogg', 50)
					playsound(target, 'sound/effects/stairs_step.ogg', 50)
		else
			to_chat(A, SPAN_WARNING("Something blocks the path."))
	else
		to_chat(A, SPAN_NOTICE("There is nothing of interest in this direction."))
