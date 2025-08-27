/obj/item/paimod/hack_speed
	name = "unknown encryption PAImod"
	desc = "This is the root encryption PAImod. You should not have this."
	icon_state = "enc_root"

	special_limit_tag = "hacking"

	var/speed_hack = 1

/obj/item/paimod/hack_speed/on_recalculate(mob/living/silicon/pai/P)
	. = ..()
	P.hack_speed += speed_hack


/obj/item/paimod/hack_speed/standard
	name = "standard encryption PAImod"
	desc = "This is the standard 'DAIS-PAIDES' encryption PAImod. It's used to increase speed of hacking by PAI by making decrypting protocols much easier. Doubles its speed of hacking."
	speed_hack = 2

/obj/item/paimod/hack_speed/advanced
	name = "advanced encryption PAImod"
	desc = "This is an advanced 'DAIS-PAIAES' encryption PAImod. It's used to increase speed of hacking by PAI by making decrypting protocols WAY TOO much easier. Quadruples its speed of hacking."
	icon_state = "enc_adv"
	speed_hack = 4

//механ взлома
/mob/living/silicon/pai/hackloop()
	var/turf/T = get_turf_or_move(src.loc)
	if(!is_hack_covered)
		for(var/mob/living/silicon/ai/AI in GLOB.player_list)
			if(T.loc)
				to_chat(AI, "<font color = red><b>Network Alert: Brute-force encryption crack in progress in [T.loc].</b></font>")
			else
				to_chat(AI, "<font color = red><b>Network Alert: Brute-force encryption crack in progress. Unable to pinpoint location.</b></font>")
	var/obj/machinery/door/D = cable.machine
	if(!istype(D))
		hack_aborted = 1
		hackprogress = 0
		cable.machine = null
		hackdoor = null
		return
	while(hackprogress < 1000)
		if(cable && cable.machine == D && cable.machine == hackdoor && get_dist(src, hackdoor) <= 1)
			hackprogress = min(hackprogress+rand(1, 20)*hack_speed, 1000)
		else
			hack_aborted = 1
			hackprogress = 0
			hackdoor = null
			return
		if(hackprogress >= 1000)
			hackprogress = 0
			D.open()
			cable.machine = null
			return
		sleep(10)
