/mob/living/exosuit/proc/step_mech(moving_dir)
	SetMoveCooldown(current_speed)
	var/turf/target_loc = get_step(src, dir)
	if(target_loc && L_leg && R_leg && L_leg.can_move_on(get_turf(src), target_loc) && MayEnterTurf(target_loc))
		if(!body.phazon)
			Move(target_loc)
			add_heat(L_leg.heat_generation + R_leg.heat_generation)
			add_speed()
		else
			for(var/thing in pilots) //Для всех пилотов внутри
				var/mob/pilot = thing
				if(pilot && pilot.client)
					for(var/key in pilot.client.keys_held)
						if (key == MOUSE_SHIFT)
							SetMoveCooldown(current_speed)
							forceMove(target_loc)
						else
							Move(target_loc)
