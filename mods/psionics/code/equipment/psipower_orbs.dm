///ELECTRIC ORB///

//ATOM related things, that cannot be putted in orb itself
/obj/machinery/vending/use_tool(obj/item/W as obj, mob/living/user as mob)

	if(istype(W, /obj/item/psychic_power/psielectro))
		if(istype(user) && user.psi && !user.psi.suppressed && user.psi.get_rank(PSI_METAKINESIS) >= PSI_RANK_APPRENTICE)
			var/option = input(user, "Do something!", "What do you want to do?") in list("Hack", "Electrify")
			if (!option)
				return
			if(option == "Hack")
				if(do_after(user, 30))
					to_chat(user, SPAN_WARNING("Вы аккуратно меняете настройки автомата..."))
					if(!emagged)
						emag_act()
			if(option == "Electrify")
				if(do_after(user, 50))
					to_chat(user, SPAN_WARNING("Вы прикладываете руку к автомату, наполняя его избыточной энергией..."))
					new /obj/temporary(get_turf(src),3, 'icons/effects/effects.dmi', "electricity_constant")
					src.seconds_electrified = 50

	..()

/obj/machinery/smartfridge/use_tool(obj/item/O as obj, mob/living/user as mob)

	if(istype(O, /obj/item/psychic_power/psielectro))
		if(istype(user) && user.psi && !user.psi.suppressed && user.psi.get_rank(PSI_METAKINESIS) >= PSI_RANK_APPRENTICE)
			if(do_after(user, 30))
				to_chat(user, SPAN_WARNING("Вы аккуратно меняете настройки автомата..."))
				if(!emagged)
					emag_act()
					new /obj/temporary(get_turf(src),3, 'icons/effects/effects.dmi', "electricity_constant")
				. = TRUE

	..()

/obj/machinery/atm/use_tool(obj/item/I as obj, mob/living/user as mob)

	if(istype(I, /obj/item/psychic_power/psielectro))
		if(istype(user) && user.psi && !user.psi.suppressed && user.psi.get_rank(PSI_METAKINESIS) >= PSI_RANK_OPERANT)
			if(do_after(user, 30))
				to_chat(user, SPAN_WARNING("Вы прислоняете руку к терминалу, запуская в него мощный поток тока!"))
				if(!emagged)
					emag_act()
					new /obj/temporary(get_turf(src),3, 'icons/effects/effects.dmi', "electricity_constant")
				. = TRUE

	..()

/mob/living/carbon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0, def_zone = null)
//По всем законам логики оно не должно работать, но если ставить тут == вместо != - оно волшебным образом ломается
	var/obj/item/psychic_power/psielectro/carried_orb
	if(carried_orb != src.get_active_hand())
		if(src.psi && src.psi.get_rank(PSI_METAKINESIS) >= PSI_RANK_MASTER)
			if(prob(80))
				src.visible_message(SPAN_WARNING("[src] absorbed all pure energy, sent into them!"))
				src.psi.stamina = min(src.psi.max_stamina, src.psi.stamina + rand(15,20))
				carried_orb.charge += 1

				var/datum/effect/spark_spread/l = new /datum/effect/spark_spread
				l.set_up(5, 1, loc)
				l.start()
				return 0

	..()

/obj/machinery/psi_monitor/use_tool(obj/item/O as obj, mob/living/user as mob)

	if(istype(O, /obj/item/psychic_power/psielectro))
		if(istype(user) && user.psi && !user.psi.suppressed && user.psi.get_rank(PSI_METAKINESIS) >= PSI_RANK_OPERANT)
			if(do_after(user, 30))
				to_chat(user, SPAN_WARNING("Вы прислоняете руку к монитору, пропуская мощный поток тока, ломающий все электронные замки!"))
				if(!emagged)
					emag_act()
					new /obj/temporary(get_turf(src),3, 'icons/effects/effects.dmi', "electricity_constant")
				. = TRUE
	return ..()

//ATOM related stuff ending here

//ELECTRIC ORB itself
/obj/item/psychic_power/psielectro
	name = "orb of energy"
	force = 5
	edge = TRUE
	maintain_cost = 8

	item_icons = list(
		slot_l_hand_str = 'mods/psionics/icons/psi_fd/lefthand.dmi',
		slot_r_hand_str = 'mods/psionics/icons/psi_fd/righthand.dmi',
		)

	icon_state = "electro"
	item_state = "electro"
	attack_cooldown = 5
	var/charge = 0
	var/cooldown = 0

/obj/item/psychic_power/psielectro/attack_self(mob/living/user as mob)
	var/el_rank = user.psi.get_rank(PSI_METAKINESIS)
	if(el_rank >= PSI_RANK_MASTER)
		user.put_in_hands(new /obj/item/psychic_power/electric_whip(user))
		qdel(src)

/obj/item/psychic_power/psielectro/Process()
	if(cooldown > 0)
		cooldown--

	. = ..()

/obj/item/psychic_power/psielectro/New(mob/living/user)
	user = usr
	var/el_rank = user.psi.get_rank(PSI_METAKINESIS)
	maintain_cost -= el_rank

	..()

/obj/item/psychic_power/psielectro/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	var/el_rank = user.psi.get_rank(PSI_METAKINESIS)

	if(target.psi && !target.psi.suppressed)
		var/el_rank_target = target.psi.get_rank(PSI_METAKINESIS)
		if(el_rank_target >= el_rank && prob(50))
			user.visible_message(SPAN_DANGER("[target] пропускает ток через себя, возвращая его [user] в виде молнии!"))
			user.electrocute_act(rand(el_rank_target * 2, el_rank_target * 5), target, 1, target.zone_sel.selecting)
			new /obj/temporary(get_turf(user),3, 'icons/effects/effects.dmi', "electricity_constant")
			..()
	target.electrocute_act(rand(el_rank * 2, el_rank * 5), user, 1, user.zone_sel.selecting)
	new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "electricity_constant")
	..()

/obj/item/psychic_power/psielectro/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob, proximity)

//TURFS AND ANYTHING ELSE

	if(proximity)
		var/datum/effect/spark_spread/sparks = new ()
		sparks.set_up(3, 0, get_turf(A))
		sparks.start()

	if(!proximity)
		return

	var/el_rank = user.psi.get_rank(PSI_METAKINESIS)

//MOBS

	if(istype(A, /mob/living))
		var/mob/living/target = A

		if(cooldown > 0)
			to_chat(user, SPAN_WARNING("Ты не можешь использовать данную способность настолько часто!"))
			return
		if(target == user)
			to_chat(user, SPAN_WARNING("Вы не можете зарядить самого себя!"))
			return
		if(user.psi && !user.psi.suppressed && user.psi.get_rank(PSI_METAKINESIS) <= PSI_RANK_OPERANT)
			user.visible_message(SPAN_DANGER("[user] направляет свору еле-заметных молний в тело [target]!"))
		if(user.psi && !user.psi.suppressed && user.psi.get_rank(PSI_METAKINESIS) >= PSI_RANK_MASTER)
			user.visible_message(SPAN_DANGER("[user] поражает [target] мощным электрическим шквалом!"))
		if(target.psi && !target.psi.suppressed)
			var/el_rank_target = target.psi.get_rank(PSI_METAKINESIS)
			if(el_rank_target >= el_rank && prob(50))
				user.visible_message(SPAN_DANGER("[target] пропускает ток через себя, возвращая его [user] в виде молнии!"))
				user.electrocute_act(rand(el_rank_target * 2,el_rank_target * 5), target, 1, target.zone_sel.selecting)
				cooldown += 1
				new /obj/temporary(get_turf(user),3, 'icons/effects/effects.dmi', "electricity_constant")
				return TRUE
		target.electrocute_act(rand(el_rank + charge * 2,el_rank + charge * 5), user, 1, user.zone_sel.selecting)
		cooldown += 1
		if(charge >= 1)
			charge -= 1
		new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "electricity_constant")
		return TRUE

//LIGHT

	if(istype(A, /obj/machinery/light))

		if(A.do_psionics_check(maintain_cost, user))
			to_chat(user, SPAN_WARNING("Your power skates across \the [A.name], but cannot get a grip..."))
			return FALSE

		var/obj/machinery/light/lighting = A
		if(lighting.on)
			if(user.psi && !user.psi.suppressed && user.psi.get_rank(PSI_METAKINESIS) >= PSI_RANK_OPERANT)
				if(do_after(user, 30))
					if(proximity)
						user.visible_message(SPAN_DANGER("[user] прислоняет руку к источнику света, и уже через пару секунд он угасает!"))
						to_chat(user, SPAN_WARNING("Вы прислоняете руку к рабочей лампе, высасывая из неё всё содержимое!"))
					else
						user.visible_message(SPAN_DANGER("[user] протягивает руку к [lighting], и затем, резким взмахом вырывает всю энергию, которая в нём хранилась!"))
						to_chat(user, SPAN_WARNING("Вы с скрипом разбиваете источник света, вытягивая всё электричество, которое в нём было."))
					lighting.broken(TRUE)
					user.psi.stamina = min(user.psi.max_stamina, user.psi.stamina + rand(5,10))
					charge += 1
		else
			return

//CELLS

	var/obj/item/cell/charging_cell = A.get_cell()
	if(istype(charging_cell))

		if(A.do_psionics_check(maintain_cost, user))
			to_chat(user, SPAN_WARNING("Your power skates across \the [A.name], but cannot get a grip..."))
			return FALSE

		if(proximity)
			user.visible_message(SPAN_WARNING("[user] прикладывает руку к [charging_cell], наполняя её энергией!"))
		else
			user.visible_message(SPAN_WARNING("[user] направляет руку к [charging_cell], посылая в неё поток молний!"))
		charging_cell.give(rand(el_rank * 3,el_rank * 6))
		new /obj/temporary(get_turf(A),3, 'icons/effects/effects.dmi', "electricity_constant")
		return TRUE
	..()

/obj/item/psychic_power/psielectro/use_before(atom/target, mob/living/user)
	if(!target)
		return

	//AIRLOCKS
	if(istype(target,/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/D = target
		var/option = input(user, "Выбирай!", "Что ты планируешь сделать?") in list("Открыть/Закрыть", "Заболтировать/Разболтировать", "Электризовать")
		if (!option || !user.psi || user.psi.suppressed)
			return

		if(target.do_psionics_check(maintain_cost, user))
			to_chat(user, SPAN_WARNING("Your power skates across \the [target.name], but cannot get a grip..."))
			return FALSE

		if(option == "Открыть/Закрыть")
			to_chat(SPAN_NOTICE("Шлюз становится продолжением тебя, ты посылаешь сигналы, в попытке открыть шлюз"))
			if(do_after(user, 5 SECONDS, D, DO_DEFAULT | DO_BOTH_UNIQUE_ACT))
				if(user.psi.get_rank(PSI_METAKINESIS) <= PSI_RANK_OPERANT)
					if(prob(30))
						to_chat(SPAN_WARNING("Механизм [D.name] сопротивляется"))
						return
				if(D && AIRLOCK_OPEN)
					D.open()
					user.visible_message(SPAN_NOTICE("[user] щёлкает пальцами и [D.name] открывается."))
					new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "electricity_constant")
					playsound(D.loc, "sparks", 50, 1)
				if(D && AIRLOCK_CLOSED)
					D.close()
					user.visible_message(SPAN_NOTICE("[user] щёлкает пальцами и [D.name] закрывается."))
					new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "electricity_constant")
					playsound(D.loc, "sparks", 50, 1)

		if(option == "Электризовать")
			to_chat(SPAN_NOTICE("Ты перенаправляешь свою энергию в оболочку шлюза"))
			if(do_after(user, 3 SECOND, D, DO_DEFAULT | DO_BOTH_UNIQUE_ACT))
				if(charge > 0)
					charge -= 1
					D.electrify(30 SECONDS, 0)
					user.visible_message(SPAN_WARNING("[user] посылает в [D.name] [SPAN_DANGER("продолжительный")] поток электричества."))
				else
					D.electrify(10 SECONDS, 0)
					user.visible_message(SPAN_WARNING("[user] посылает в [D.name] поток электричества."))
				new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "electricity_constant")
				playsound(D.loc, "sparks", 50, 1)

		if(option == "Заболтировать/Разболтировать")
			if(user.psi && !user.psi.suppressed && user.psi.get_rank(PSI_METAKINESIS) >= PSI_RANK_MASTER || !user.skill_check(SKILL_ELECTRICAL, SKILL_EXPERIENCED))
				to_chat(SPAN_NOTICE("Ты тянешь болты как собственные сухожилия, стараясь изменить их положение"))
				if(do_after(user, 5 SECONDS, D, DO_DEFAULT | DO_BOTH_UNIQUE_ACT))
					D.toggle_lock()
					user.visible_message(SPAN_NOTICE("[user] прислоняет обе руки к [D.name], приводя болты в движение."))
					new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "electricity_constant")
					playsound(D.loc, "sparks", 50, 1)
			else
				user.visible_message(SPAN_NOTICE("[user] прислоняет обе руки к [D.name], тебе нехватило [SPAN_INFO("знаний")] в этом."))
				to_chat(SPAN_WARNING("Вы прислоняете свои руки к [D.name], пытаясь пропустить поток через его внутренние механизмы, но ничего не получается!"))
				return


///FIRE ORB///

//ATOM related things, that cannot be putted in orb itself

/obj/item/psychic_power/psifire/IsFlameSource()
	return TRUE

/obj/item/psychic_power/psifire/IsWelder()
	return TRUE

/mob/living/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
//По всем законам логики оно не должно работать, но если ставить тут == вместо != - оно волшебным образом ломается
	var/obj/item/psychic_power/psifire/carried_orb
	if(carried_orb != src.get_active_hand())
		if(src.psi && src.psi.get_rank(PSI_METAKINESIS) >= PSI_RANK_OPERANT)
			return
	..()

//ATOM related stuff ending here

//FIRE ORB itself
/obj/item/psychic_power/psifire
	name = "orb of flame"
	force = 5
	edge = TRUE
	maintain_cost = 8

	item_icons = list(
		slot_l_hand_str = 'mods/psionics/icons/psi_fd/lefthand.dmi',
		slot_r_hand_str = 'mods/psionics/icons/psi_fd/righthand.dmi',
		)

	icon_state = "pyro"
	item_state = "pyro"
	attack_cooldown = 5

	var/combat_mode = TRUE
	var/turf/previousturf = null

	var/attack_type = "FIRE WALL"

	var/range = 2
	var/flame_power = 25
	var/flame_color = COLOR_RED

/obj/item/psychic_power/psifire/New(mob/living/user)
	user = usr
	var/fire_rank = user.psi.get_rank(PSI_METAKINESIS)

	maintain_cost -= fire_rank
	flame_power += fire_rank
	range += fire_rank

	if(user.psi && !user.psi.suppressed && user.psi.get_rank(PSI_METAKINESIS) >= PSI_RANK_MASTER)
		flame_color = "#33ccc9"
		flame_power += 5

	..()


/obj/item/psychic_power/psifire/Process()
	if(istype(owner))
		if(!owner.on_fire)
			owner.psi.spend_power(maintain_cost)
	if(!owner || owner.do_psionics_check(maintain_cost, owner) || !owner.IsHolding(src))
		if(istype(loc,/mob/living))
			var/mob/living/carbon/human/host = loc
			if(istype(host))
				for(var/obj/item/organ/external/organ in host.organs)
					for(var/obj/item/O in organ.implants)
						if(O == src)
							organ.implants -= src
			host.pinned -= src
			host.embedded -= src
			host.drop_from_inventory(src)
		else
			qdel(src)

/obj/item/psychic_power/psifire/attack_self(mob/living/user as mob)
	var/pyro_rank = user.psi.get_rank(PSI_METAKINESIS)
	if(combat_mode)
		var/list/options = list(
			"FIRE WALL" = image('mods/psionics/icons/psi.dmi', "FIRE PUNCH"),
			"FIRE JUMP" = image('mods/psionics/icons/psi.dmi', "FIRE JUMP")
		)
		var/chosen_option = show_radial_menu(user, user, options, radius = 25, require_near = TRUE)
		if (!chosen_option)
			return 0
		if(user.psi.suppressed)
			return 0
		if(!combat_mode)
			return 0
		switch(chosen_option)
			if("FIRE WALL")
				attack_type = "FIRE WALL"
				to_chat(user, SPAN_WARNING("Теперь вы будете стрелять огнём из рук!"))
				return 1
			if("FIRE JUMP")
				if(pyro_rank < PSI_RANK_OPERANT)
					to_chat(user, SPAN_WARNING("Вы ещё недостаточно обучены для подобного приёма!"))
					return 0
				attack_type = "FIRE JUMP"
				to_chat(user, SPAN_WARNING("Теперь вы будете использовать огонь в качестве средства передвижения!"))
				return 1

/obj/item/psychic_power/psifire/AltClick(mob/living/carbon/user)
	var/list/options = list(
		"HELP" = image('mods/psionics/icons/psi.dmi', "HELP"),
		"HARM" = image('mods/psionics/icons/psi.dmi', "HARM")
	)

	var/chosen_option = show_radial_menu(user, user, options, radius = 25, require_near = TRUE)
	if (!chosen_option)
		return 0
	if(user.psi.suppressed)
		return 0
	switch(chosen_option)
		if("HARM")
			combat_mode = TRUE
			to_chat(user, SPAN_WARNING("Вы приготовились к бою. Теперь, ваше касание будет поджигать людей."))
		if("HELP")
			combat_mode = FALSE
			to_chat(user, SPAN_WARNING("Вы вновь можете безопасно прикасаться к вещам вокруг."))

/obj/item/psychic_power/psifire/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	if(combat_mode)
		user.visible_message(SPAN_DANGER("[user] прислоняет руку к [target], зажигая его как спичку!"))
		target.fire_act(exposed_temperature = 300, exposed_volume = 250)
	..()

/obj/item/psychic_power/psifire/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob, proximity)
//TURFS

	if(istype(A, /turf) && !proximity && combat_mode)
		if(attack_type == "FIRE WALL")
			var/turf/target_turf = get_turf(A)
			if(target_turf)
				var/turflist = getline(user, target_turf)
				flame_turf(turflist)
				user.visible_message(SPAN_DANGER("[user] взмахивает рукой, создавая стену из огня!"))
		if(attack_type == "FIRE JUMP")
			if(get_dist(user, A) > range)
				return 0
			var/turf/target_turf = get_step(get_turf(A), pick(GLOB.alldirs))
			var/list/line_list = getline(user, target_turf)
			for(var/i = 1 to length(line_list))
				var/turf/T = line_list[i]
				var/obj/temp_visual/decoy/D = new /obj/temp_visual/decoy(T, user.dir, user)
				D.alpha = min(150 + i*15, 255)
				animate(D, alpha = 0, time = 2 + i*2)
			user.throw_at(target_turf, range, 1, user, FALSE)
			user.visible_message(SPAN_DANGER("[user] делает рывок, используя свои ноги как двигатели!"))
			flame_turf(line_list)
	else if(!proximity)
		return

//EATING FIRE

	if(istype(A, /obj/turf_fire))
		var/obj/turf_fire/fire = A
		if(fire.fire_power >= 20)
			if(user.psi && !user.psi.suppressed && user.psi.get_rank(PSI_METAKINESIS) >= PSI_RANK_OPERANT)
				if(do_after(user, 30))
					user.visible_message(SPAN_DANGER("[user] протягивает руку к [fire], постепенно поглащая его!"))
					to_chat(user, SPAN_WARNING("Вы подводите руку к [fire], вытягивая всю энергии, что в нём скопилась. Огонь приятно обвивает вашу руку."))
					qdel(fire)
					user.psi.stamina = min(user.psi.max_stamina, user.psi.stamina + rand(5,10))
		else
			return

//OTHER STUFF

	var/obj/OBJ = A
	if(istype(OBJ))
		user.visible_message(SPAN_WARNING("[user] прислоняет руку к [OBJ]. Можно заметить, как от места соприкосновения идёт пар."))
		OBJ.HandleObjectHeating(src, user, 700)

//MOBS

	if(istype(A, /mob/living) && combat_mode)
		var/mob/living/target = A

		user.visible_message(SPAN_DANGER("[user] прислоняет руку к [target], зажигая его как спичку!"))
		target.fire_act(exposed_temperature = 300, exposed_volume = 250)
	else if(istype(A, /mob/living))
		var/mob/living/target = A
		if(istype(target.wear_mask, /obj/item/clothing/mask/smokable/cigarette) && user.zone_sel.selecting == BP_MOUTH)
			var/obj/item/clothing/mask/smokable/cigarette/cig = target.wear_mask
			if(target == user)
				cig.use_tool(src, user)
			else
				cig.light("<span class='notice'>[user] щёлкает пальцами как зажигалкой, подпаливая [cig.name] во рту [target].</span>")

/obj/item/psychic_power/psifire/proc/flame_turf(list/turflist)
	var/length = LAZYLEN(turflist)
	if(length < 1)
		return
	LIST_RESIZE(turflist, min(length, range))

	playsound(src, pick('sound/weapons/guns/flamethrower1.ogg','sound/weapons/guns/flamethrower2.ogg','sound/weapons/guns/flamethrower3.ogg' ), 50, TRUE, -3)

	for(var/turf/T in turflist)
		if(T.density || istype(T, /turf/space))
			break
		if(!previousturf && length(turflist)>1)
			previousturf = get_turf(src)
			continue	//so we don't burn the tile we be standin on
		if(previousturf && (!T.CanPass(null, previousturf, 0,0) || !previousturf.CanPass(null, T, 0,0)))
			break
		previousturf = T

		//Consume part of our fuel to create a fire spot
		var/obj/turf_fire/TF = T.IgniteTurf(flame_power, flame_color)
		if(istype(TF))
			TF.interact_with_atmos = FALSE
		T.hotspot_expose((flame_power * 3) + 300, 50)
		sleep(1)
	previousturf = null

/obj/item/psychic_power/psifire/proc/remove_fuel()
	return

///ICE ORB///

//ATOM related things, that cannot be putted in orb itself
/obj/item/projectile/bullet/pellet/ice
	damage = 20
	pellets = 4
	range_step = 1
	spread_step = 50
	armor_penetration = 20
	icon = 'mods/psionics/icons/psi_fd/projectiles.dmi'
	icon_state = "ice_spikes"
	color = "#9ee0dd"

/obj/structure/girder/ice_wall
	anchored = TRUE
	density = TRUE
	layer = ABOVE_HUMAN_LAYER
	plane = GAME_PLANE_FOV_HIDDEN
	health_max = 200
	icon = 'mods/psionics/icons/psi_fd/freeze.dmi'
	icon_state = "ice_cube"
	mouse_opacity = 2
	cover = 100
	var/timer = 30

/obj/structure/girder/ice_wall/New()
	. = ..()
	run_timer()

/obj/structure/girder/ice_wall/use_tool(obj/item/W, mob/user)
	if (user.a_intent == I_HURT)
		..()
		return

	if(W.IsFlameSource() || istype(W, /obj/item/psychic_power/psiblade/master/grand/paramount))
		if(istype(W, /obj/item/gun/energy/plasmacutter))
			var/obj/item/gun/energy/plasmacutter/cutter = W
			if(!cutter.slice(user))
				return
		playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
		to_chat(user, "<span class='notice'>Now slicing apart the wall...</span>")
		if(do_after(user,reinf_material ? 40: 20,src))
			to_chat(user, "<span class='notice'>You slice apart the wall!</span>")
			if(reinf_material)
				reinf_material.place_dismantled_product(get_turf(src))
			dismantle()
		return

/obj/structure/girder/ice_wall/dismantle()
	qdel(src)

/obj/structure/girder/ice_wall/proc/run_timer()
	set waitfor = 0
	var/T = timer
	while(T > 0)
		sleep(1 SECOND)
		T--
	src.visible_message(SPAN_WARNING("[src] тает!"))
	animate(src, alpha = 0, time = 10 SECONDS)
	QDEL_IN(src, 9 SECONDS)

//ATOM related stuff ending here

//ICE ORB itself
/obj/item/psychic_power/psiice
	name = "orb of ice"
	force = 5
	edge = TRUE
	maintain_cost = 8

	item_icons = list(
		slot_l_hand_str = 'mods/psionics/icons/psi_fd/lefthand.dmi',
		slot_r_hand_str = 'mods/psionics/icons/psi_fd/righthand.dmi',
		)

	icon_state = "cryo"
	item_state = "cryo"
	attack_cooldown = 5
	var/combat_mode = TRUE
	var/structure_attack = "ICE WALL"
	var/range = 2
	var/cooldown = 0
	var/turf/previousturf = null
	var/inner_radius = -1 //for all your ring spell needs
	var/outer_radius = 2

/obj/item/psychic_power/psiice/New(mob/living/user)
	user = usr
	var/cryo_rank = user.psi.get_rank(PSI_METAKINESIS)

	maintain_cost -= cryo_rank
	range += cryo_rank

	..()

/obj/item/psychic_power/psiice/Process()
	if(cooldown > 0)
		cooldown--

	. = ..()

/obj/item/psychic_power/psiice/attack_self(mob/living/user as mob)
	var/cryo_rank = user.psi.get_rank(PSI_METAKINESIS)
	if(combat_mode)
		var/list/options = list(
			"ICE WALL" = mutable_appearance('mods/psionics/icons/psi.dmi', "WALL"),
			"ICE SPIKES" = mutable_appearance('mods/psionics/icons/psi.dmi', "SPIKES"),
			"ICE FISTS" = mutable_appearance('mods/psionics/icons/psi.dmi', "FISTS"),
			"ICE SWORD" = mutable_appearance('mods/psionics/icons/psi.dmi', "SWORD")
		)
		var/chosen_option = show_radial_menu(user, user, options, radius = 25, require_near = TRUE)
		if (!chosen_option)
			return 0
		if(user.psi.suppressed)
			return 0
		if(!combat_mode)
			return 0
		switch(chosen_option)
			if("ICE WALL")
				structure_attack = "ICE WALL"
				to_chat(user, SPAN_WARNING("Теперь вы будете возводить ледяные стены при использовании дальней атаки!"))
				return 1
			if("ICE SPIKES")
				if(cryo_rank < PSI_RANK_OPERANT)
					to_chat(user, SPAN_WARNING("Вы ещё недостаточно обучены для подобного приёма!"))
					return 0
				structure_attack = "ICE SPIKES"
				to_chat(user, SPAN_WARNING("Теперь вы будете метать ледяные иглы при использовании дальней атаки!"))
				return 1
			if("ICE FISTS")
				user.put_in_hands(new /obj/item/cryokinesis/fists(user))
				qdel(src)
				return 1
			if("ICE SWORD")
				user.put_in_hands(new /obj/item/cryokinesis/rapier(user))
				qdel(src)
				return 1

/obj/item/psychic_power/psiice/AltClick(mob/living/user as mob)
	var/list/options = list(
		"HELP" = image('mods/psionics/icons/psi.dmi', "HELP"),
		"HARM" = image('mods/psionics/icons/psi.dmi', "HARM")
	)

	var/chosen_option = show_radial_menu(user, user, options, radius = 25, require_near = TRUE)
	if (!chosen_option)
		return 0
	if(user.psi.suppressed)
		return 0
	switch(chosen_option)
		if("HARM")
			combat_mode = TRUE
			to_chat(user, SPAN_WARNING("Вы приготовились к бою. Теперь, ваше касание будет замораживать людей, вы сможете создавать ледяные стены и прочие приспособления."))
		if("HELP")
			combat_mode = FALSE
			to_chat(user, SPAN_WARNING("Вы вновь можете безопасно прикасаться к вещам вокруг."))

/obj/item/psychic_power/psiice/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	var/cryo_rank = user.psi.get_rank(PSI_METAKINESIS)

	if(target.do_psionics_check(maintain_cost, user))
		to_chat(user, SPAN_WARNING("Your power skates across \the [target.name], but cannot get a grip..."))
		return FALSE
	cooldown += 2

	if(target == user && cryo_rank >= PSI_RANK_MASTER)
		var/list/targets = list()
		for(var/turf/point in oview_or_orange(outer_radius, user, "range"))
			if(!(point in oview_or_orange(inner_radius, user, "range")))
				if(point.density)
					continue
				if(istype(point, /turf/space))
					continue
				targets += point

		if(!LAZYLEN(targets))
			return FALSE

		var/turf/user_turf = get_turf(user)
		for(var/turf/T in targets)
			var/obj/structure/girder/ice_wall/IW = new(T)
			if(istype(IW))
				IW.pixel_x = (user_turf.x - T.x) * world.icon_size
				IW.pixel_y = (user_turf.y - T.y) * world.icon_size
				animate(IW, pixel_x = 0, pixel_y = 0, time = 3, easing = EASE_OUT)

		..()
	..()

/obj/item/psychic_power/psiice/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob, proximity)
	var/cryo_rank = user.psi.get_rank(PSI_METAKINESIS)

	if(cooldown > 0)
		to_chat(user, SPAN_WARNING("Ты не можешь использовать данную способность настолько часто!"))
		return

	if(!proximity && cryo_rank >= PSI_RANK_OPERANT && structure_attack == "ICE SPIKES")
		var/obj/item/projectile/pew
		var/pew_sound
		cooldown += 2
		user.visible_message(SPAN_DANGER("[user] запускает вперёд град ледяных пик!"))
		pew = new /obj/item/projectile/bullet/pellet/ice(get_turf(user))
		pew.name = "stack of ice spikes"
		pew_sound = 'sound/weapons/guns/ricochet4.ogg'
		if(istype(pew))
			playsound(pew.loc, pew_sound, 25, 1)
			pew.original = A
			pew.current = A
			pew.starting = get_turf(user)
			pew.shot_from = user
			pew.launch(A, user.zone_sel.selecting, (A.x-user.x), (A.y-user.y))

//TURFS

	if(istype(A, /turf))
		var/turf/target = A
		if(combat_mode)
			if(!proximity && cryo_rank >= PSI_RANK_MASTER && structure_attack == "ICE WALL")
				if(do_after(user, 10))
					cooldown += 2
					user.visible_message(SPAN_DANGER("[user] возводит стену из льда!"))
					var/turf/target_turf = get_turf(target)
					if(target_turf)
						var/turflist = getline(user, target_turf)
						ice_turf(turflist)
			if(!proximity)
				return
			if(do_after(user, 10))
				cooldown += 2
				user.visible_message(SPAN_DANGER("[user] возводит стену из льда!"))
				new /obj/temporary(target,3, 'icons/effects/effects.dmi', "blueshatter")
				sleep(1)
				new /obj/structure/girder/ice_wall(get_turf(target))
				return TRUE
		else
			if(!proximity)
				return
			if(istype(A, /turf/simulated))
				var/turf/simulated/sim = target
				cooldown += 2
				user.visible_message(SPAN_DANGER("[user] покрывает [sim] ледяной коркой!"))
				sim.wet_floor(5 * cryo_rank)
				new /obj/temporary(sim,3, 'icons/effects/effects.dmi', "blueshatter")
				return TRUE

	if(!proximity)
		return

//MOBS

	if(istype(A, /mob/living) && combat_mode == TRUE)
		if(A.do_psionics_check(maintain_cost, user))
			to_chat(user, SPAN_WARNING("Your power skates across \the [A.name], but cannot get a grip..."))
			return FALSE
		cooldown += 2
		var/mob/living/target = A

		if(target == user && cryo_rank >= PSI_RANK_MASTER)
			var/list/targets = list()

			for(var/turf/point in oview_or_orange(outer_radius, user, "range"))
				if(!(point in oview_or_orange(inner_radius, user, "range")))
					if(point.density)
						continue
					if(istype(point, /turf/space))
						continue
					targets += point

			if(!LAZYLEN(targets))
				return FALSE

			var/turf/user_turf = get_turf(user)
			for(var/turf/T in targets)
				var/obj/structure/girder/ice_wall/IW = new(T)
				if(istype(IW))
					IW.pixel_x = (user_turf.x - T.x) * world.icon_size
					IW.pixel_y = (user_turf.y - T.y) * world.icon_size
					animate(IW, pixel_x = 0, pixel_y = 0, time = 3, easing = EASE_OUT)

			return TRUE

		if(cryo_rank >= PSI_RANK_MASTER)
			new /obj/structure/girder/ice_wall(get_turf(target))
			new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "extinguish")
			target.Stun(3*cryo_rank)
			user.visible_message(SPAN_DANGER("[user] прикасается к телу [target] побледневшей рукой, обращая его в лёд!"))
			target.bodytemperature = 500 / cryo_rank
			return TRUE

		else
			new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "extinguish")
			user.visible_message(SPAN_DANGER("[user] прикасается к телу [target] побледневшей рукой, заставляя его покрыться коркой льда!"))
			target.bodytemperature = 400 / cryo_rank
			return TRUE

//ITEMS

	if(istype(A,/obj/item))
		var/obj/item/S = A
		S.temperature = T0C - 20

/obj/item/psychic_power/psiice/proc/ice_turf(list/turflist)
	var/length = LAZYLEN(turflist)
	if(length < 1)
		return
	LIST_RESIZE(turflist, min(length, range))

	playsound(src, pick('sound/weapons/guns/flamethrower1.ogg','sound/weapons/guns/flamethrower2.ogg','sound/weapons/guns/flamethrower3.ogg' ), 50, TRUE, -3)

	for(var/turf/T in turflist)
		if(T.density || istype(T, /turf/space))
			break
		if(!previousturf && length(turflist)>1)
			previousturf = get_turf(src)
			continue	//so we don't burn the tile we be standin on
		if(previousturf && (!T.CanPass(null, previousturf, 0,0) || !previousturf.CanPass(null, T, 0,0)))
			break
		previousturf = T

		//Consume part of our fuel to create a fire spot
		new /obj/structure/girder/ice_wall(get_turf(T))
		sleep(1)
	previousturf = null
