/mob/living/exosuit/proc/step_mech(moving_dir)
	SetMoveCooldown(current_speed/3)
	var/turf/target_loc = get_step(src, dir)
	if(target_loc && L_leg && R_leg && L_leg.can_move_on(get_turf(src), target_loc) && MayEnterTurf(target_loc))
		if(!body.phazon)
			Move(target_loc)
			add_heat(L_leg.heat_generation)
			add_heat(R_leg.heat_generation)
			add_speed()
		else
			for(var/thing in pilots) //Для всех пилотов внутри
				var/mob/pilot = thing
				if(pilot && pilot.client)
					for(var/key in pilot.client.keys_held)
						if (key == "Shift")
							var/move_speed = (L_leg.move_delay + R_leg.move_delay)/2
							move_speed = move_speed * 2.5
							SetMoveCooldown(current_speed/3)
							forceMove(target_loc)
						else
							Move(target_loc)
