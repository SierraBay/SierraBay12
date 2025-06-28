/singleton/psionic_faculty/psychokinesis
	id = PSI_PSYCHOKINESIS
	name = "Psychokinesis"
	associated_intent = I_GRAB
	armour_types = list("melee", "bullet")

/singleton/psionic_power/psychokinesis
	faculty = PSI_PSYCHOKINESIS
	use_sound = null
	abstract_type = /singleton/psionic_power/psychokinesis

/singleton/psionic_power/psychokinesis/telekinesis
	name =            "Telekinesis"
	cost =            10
	cooldown =        15
	use_ranged =      TRUE
	use_manifest =    FALSE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Нажмите по отдалённом объекту или существу на жёлтом интенте с выбранным телом, чтобы захватить его телекинезом."
	admin_log = FALSE
	use_sound = 'sound/effects/psi/power_used.ogg'
	var/global/list/valid_machine_types = list(
		/obj/machinery
	)

/singleton/psionic_power/psychokinesis/telekinesis/invoke(mob/living/user, mob/living/target)
	if((user.zone_sel.selecting in list(BP_L_ARM, BP_R_ARM, BP_L_HAND, BP_R_HAND, BP_HEAD)))
		return FALSE
	if((user.zone_sel.selecting in list(BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT)))
		return FALSE
	if(user.a_intent != I_GRAB)
		return FALSE
	. = ..()
	if(.)

		var/distance = get_dist(user, target)
		if(distance > user.psi.get_rank(PSI_PSYCHOKINESIS) * 3)
			to_chat(user, SPAN_WARNING("Ваших сил недостаточно, чтобы достать до этого объекта."))
			return FALSE

		if(istype(target, /obj/structure))
			user.visible_message(SPAN_DANGER("[user] вытягивает руку вперёд, чуть сжимая пальцы."))
			var/obj/O = target
			O.attack_hand(user)
			return TRUE
		else if(istype(target, /obj/machinery))
			for(var/mtype in valid_machine_types)
				if(istype(target, mtype))
					var/obj/machinery/machine = target
					return machine.do_simple_ranged_interaction(user)
		else if(istype(target, /mob) || istype(target, /obj))
			var/obj/item/psychic_power/telekinesis/tk = new(user)
			if(tk.set_focus(target))
				tk.sparkle()
				user.visible_message(SPAN_DANGER("[user] вытягивает руку вперёд, чуть сжимая пальцы."))
				return tk

	return FALSE

/singleton/psionic_power/psychokinesis/gravigeddon
	name =           "Repulse"
	cost =           30
	cooldown =       150
	use_ranged =     TRUE
	use_melee =      TRUE
	min_rank =       PSI_RANK_OPERANT
	use_description = "Выберите руки или кисти на жёлтом интенте, а затем нажмите куда угодно, чтобы разбросать людей от себя мощной волной."

/singleton/psionic_power/psychokinesis/gravigeddon/invoke(mob/living/user, mob/living/target)
	if(!(user.zone_sel.selecting in list(BP_L_ARM, BP_R_ARM, BP_L_HAND, BP_R_HAND)))
		return FALSE
	. = ..()
	if(.)
		user.visible_message(SPAN_DANGER("[user] размахивает руками, крича!"))
		to_chat(user, SPAN_DANGER("Вы выпускаете мощную псионическую волну, разметая всё вокруг!"))
		var/pk_rank = user.psi.get_rank(PSI_PSYCHOKINESIS)
		new /obj/temporary(get_turf(user),9, 'icons/effects/effects.dmi', "summoning")
		var/list/mobs = GLOB.alive_mobs + GLOB.dead_mobs
		for(var/mob/living/M in mobs)
			if(M == user)
				continue
			if(get_dist(user, M) > user.psi.get_rank(PSI_PSYCHOKINESIS))
				continue
			if(prob(20) && iscarbon(M))
				var/mob/living/carbon/C = M
				if(C.can_feel_pain())
					C.emote("scream")
			if(!M.anchored && !M.buckled)
				to_chat(M, SPAN_DANGER("Грубая сила ударяет в твоё тело, отправляя тебя в свободный полёт!"))
				new /obj/temporary(get_turf(M),4, 'icons/effects/effects.dmi', "smash")
				M.throw_at(get_edge_target_turf(M, get_dir(user, M)), pk_rank*2, pk_rank*2, user)
		return TRUE

///WHAT CAN'T BE PUCNED///

/obj
	var/can_be_telepunched = 1

/obj/structure/shuttle
	can_be_telepunched = 0

/obj/structure/sign
	can_be_telepunched = 0

/obj/structure/railing
	can_be_telepunched = 0

/obj/structure/pit
	can_be_telepunched = 0

/obj/structure/stairs
	can_be_telepunched = 0

/obj/structure/net
	can_be_telepunched = 0

/obj/structure/net
	can_be_telepunched = 0

/obj/structure/m_tray
	can_be_telepunched = 0

/obj/structure/lattice
	can_be_telepunched = 0

/obj/structure/ladder
	can_be_telepunched = 0

/obj/structure/hygiene/drain
	can_be_telepunched = 0

/obj/structure/holosign
	can_be_telepunched = 0

/obj/structure/holonet
	can_be_telepunched = 0

/obj/structure/holohoop
	can_be_telepunched = 0

/obj/structure/handrail
	can_be_telepunched = 0

/obj/structure/fuel_port
	can_be_telepunched = 0

/obj/structure/fountain
	can_be_telepunched = 0

/obj/structure/flora
	can_be_telepunched = 0
/obj/structure/flora/pottedplant
	can_be_telepunched = 1

/obj/structure/fireaxecabinet
	can_be_telepunched = 0

/obj/structure/catwalk
	can_be_telepunched = 0

/obj/structure/extinguisher_cabinet
	can_be_telepunched = 0

/obj/structure/disposalpipe
	can_be_telepunched = 0

/obj/structure/chorus
	can_be_telepunched = 0

/obj/structure/cable
	can_be_telepunched = 0

///

/obj/machinery/wish_granter
	can_be_telepunched = 0

/obj/machinery/bluespacedrive
	can_be_telepunched = 0

/obj/machinery/shield_diffuser
	can_be_telepunched = 0

/obj/machinery/self_destruct
	can_be_telepunched = 0

/obj/machinery/requests_console
	can_be_telepunched = 0

/obj/machinery/readybutton
	can_be_telepunched = 0

/obj/machinery/power
	can_be_telepunched = 0

/obj/machinery/pager
	can_be_telepunched = 0

/obj/machinery/newscaster
	can_be_telepunched = 0

/obj/machinery/navbeacon
	can_be_telepunched = 0

/obj/machinery/meter
	can_be_telepunched = 0

/obj/machinery/mech_recharger
	can_be_telepunched = 0

/obj/machinery/mass_driver
	can_be_telepunched = 0

/obj/machinery/magnetic_accelerator
	can_be_telepunched = 0

/obj/machinery/light_switch
	can_be_telepunched = 0

/obj/machinery/light_construct
	can_be_telepunched = 0

/obj/machinery/light
	can_be_telepunched = 0

/obj/machinery/keycard_auth
	can_be_telepunched = 0

/obj/machinery/igniter
	can_be_telepunched = 0

/obj/machinery/holosign
	can_be_telepunched = 0

/obj/machinery/hologram
	can_be_telepunched = 0

/obj/machinery/firealarm
	can_be_telepunched = 0
/obj/machinery/alarm
	can_be_telepunched = 0

/obj/machinery/door_timer
	can_be_telepunched = 0

/obj/machinery/disposal_switch
	can_be_telepunched = 0

/obj/machinery/conveyor_switch
	can_be_telepunched = 0

/obj/machinery/containment_field
	can_be_telepunched = 0

/obj/machinery/clamp
	can_be_telepunched = 0

/obj/machinery/button
	can_be_telepunched = 0

/obj/machinery/body_scanconsole
	can_be_telepunched = 0
/obj/machinery/body_scan_display
	can_be_telepunched = 0

/obj/machinery/atmospherics
	can_be_telepunched = 0

/obj/machinery/atm
	can_be_telepunched = 0

/obj/machinery/airlock_sensor
	can_be_telepunched = 0
/obj/machinery/air_sensor
	can_be_telepunched = 0
/obj/machinery/access_button
	can_be_telepunched = 0

/obj/machinery/ai_status_display
	can_be_telepunched = 0

/// ///

/singleton/psionic_power/psychokinesis/tele_punch
	name =           "Telekinetic Punch"
	cost =           40
	cooldown =       50
	use_ranged =     TRUE
	use_melee =      TRUE
	min_rank =       PSI_RANK_OPERANT
	use_description = "Выберите голову на красном интенте, а затем нажмите по цели, чтобы совершить усиленный телекинетический удар."

/singleton/psionic_power/psychokinesis/tele_punch/invoke(mob/living/carbon/user, mob/living/target)

	var/pk_rank_user = user.psi.get_rank(PSI_PSYCHOKINESIS)

	if(pk_rank_user < PSI_RANK_GRANDMASTER && get_dist(user, target) > 1)
		return FALSE

	var/obj/item/organ/external/E = user.organs_by_name[BP_L_HAND]
	if(!E || E.is_stump())
		return FALSE

	E = user.organs_by_name[BP_R_HAND]
	if(!E || E.is_stump())
		return FALSE

	if(user.zone_sel.selecting != BP_HEAD)
		return FALSE
	if(user.a_intent != I_HURT)
		return FALSE

//OBJ RELATED CHECKS START//

	if(istype(target, /obj/structure) || istype(target, /obj/machinery))
		var/obj/OBJ = target
		if(!OBJ.can_be_telepunched)
			return FALSE

//OBJ RELATED CHECKS END//

	. = ..()
	if(.)
		if(pk_rank_user <= PSI_RANK_OPERANT)
			if(istype(target, /obj/structure) || istype(target, /obj/machinery) || istype(target, /obj/item))
				var/obj/O = target
				if(O.anchored == TRUE)
					user.visible_message(SPAN_DANGER("[user] с неестественной скоростью бьет кулаком по [target]!"))
					new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "smash")
					O.damage_health(30, DAMAGE_BRUTE)
					user.apply_damage(rand(5,15), DAMAGE_BRUTE, pick(BP_L_HAND, BP_R_HAND))
					return TRUE
				new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "smash")
				user.visible_message(SPAN_DANGER("[user] толкает [target] вперёд!"))
				O.throw_at(get_edge_target_turf(O, get_dir(user, O)), 4, 2, user)
				return TRUE
			user.visible_message(SPAN_DANGER("[user] заносит руку назад и наносит удар с неестественной скоростью!"))


//ENEMY PSI CHECK START

			if(target.psi)
				var/pk_rank_target = target.psi.get_rank(PSI_PSYCHOKINESIS)
				if(pk_rank_target >= pk_rank_user && !target.psi.suppressed)
					if(prob(20))
						to_chat(target, SPAN_NOTICE("Каким-то чудом, [user] пробивается через ваше силовое поле, нанося сокрушительный урон!"))
						target.visible_message(SPAN_DANGER("[target] ловит лицом кулак, улетая назад!"))
						if(!user.skill_check(SKILL_HAULING, SKILL_EXPERIENCED))

							user.apply_damage(rand(10,20),DAMAGE_BRUTE, user.hand ? BP_L_ARM : BP_R_ARM)
							to_chat(user, SPAN_WARNING("Ваше неподготовленное тело не выдерживает отдачи от удара, и кожа на вашей руке стирается в кровь!"))

						for(var/zone in list(BP_CHEST, BP_GROIN, BP_HEAD))
							target.apply_damage(rand(10,20),DAMAGE_BRUTE,def_zone=zone)
						new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "smash")
						target.throw_at(get_edge_target_turf(target, get_dir(user, target)), 1, 2, user)
						return TRUE

					else
						to_chat(target, SPAN_NOTICE("Ваше силовое поле успешно сдержало удар, пускай на это и ушло приличное количество концентрации."))
						target.psi.spend_power(10)
						for(var/zone in list(BP_CHEST, BP_GROIN, BP_HEAD))
							user.apply_damage(rand(10,20),DAMAGE_BRUTE,def_zone=zone)
						new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "smash")
						user.throw_at(get_edge_target_turf(user, get_dir(target, user)), 1, 2, target)
						user.visible_message(SPAN_DANGER("Мощное силовое поле [target] отбрасывает [user] назад, создавая мощную обратную волну!"))
						return TRUE

//ENEMY PSI CHECK END

			if(!user.skill_check(SKILL_HAULING, SKILL_EXPERIENCED))

				user.apply_damage(rand(10,20),DAMAGE_BRUTE, user.hand ? BP_L_ARM : BP_R_ARM)
				to_chat(user, SPAN_WARNING("Ваше неподготовленное тело не выдерживает отдачи от удара, и кожа на вашей руке стирается в кровь!"))

			new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "smash")
			target.visible_message(SPAN_DANGER("[target] ловит лицом кулак, улетая назад!"))
			for(var/zone in list(BP_CHEST, BP_GROIN, BP_HEAD))
				target.apply_damage(rand(10,20),DAMAGE_BRUTE,def_zone=zone)

			target.throw_at(get_edge_target_turf(target, get_dir(user, target)), 1, 2, user)

			return TRUE


///MASTER///


		if(pk_rank_user == PSI_RANK_MASTER)
			if(istype(target, /obj/structure) || istype(target, /obj/machinery) || istype(target, /obj/item))
				var/obj/O = target
				if(O.anchored == TRUE)
					user.visible_message(SPAN_DANGER("[user] с неестественной скоростью бьет кулаком по [target]!"))
					new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "smash")
					O.damage_health(100, DAMAGE_BRUTE)
					user.apply_damage(rand(5,15), DAMAGE_BRUTE, pick(BP_L_HAND, BP_R_HAND))
					return TRUE
				new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "smash")
				user.visible_message(SPAN_DANGER("[user] толкает [target] вперёд!"))
				O.throw_at(get_edge_target_turf(O, get_dir(user, O)), 6, 2, user)
				return TRUE
			user.visible_message(SPAN_DANGER("[user] заносит руку назад и наносит удар с неестественной скоростью!"))


//ENEMY PSI CHECK START

			if(target.psi)
				var/pk_rank_target = target.psi.get_rank(PSI_PSYCHOKINESIS)
				if(pk_rank_target >= pk_rank_user && !target.psi.suppressed)
					if(prob(40))
						to_chat(target, SPAN_NOTICE("Каким-то чудом, [user] пробивается через ваше силовое поле, нанося сокрушительный урон!"))
						target.visible_message(SPAN_DANGER("[target] ловит лицом кулак, улетая назад!"))
						if(!user.skill_check(SKILL_HAULING, SKILL_EXPERIENCED))

							user.apply_damage(rand(30,40),DAMAGE_BRUTE, user.hand ? BP_L_ARM : BP_R_ARM)
							to_chat(user, SPAN_WARNING("Ваше неподготовленное тело не выдерживает отдачи от удара, и вашу руку выворачивает наизнанку!"))

						for(var/zone in list(BP_CHEST, BP_GROIN, BP_HEAD))
							target.apply_damage(rand(10,15),DAMAGE_BRUTE,def_zone=zone)
						new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "smash")
						new /obj/temporary(get_turf(target),6, 'mods/psionics/icons/effects/heavyimpact.dmi', "heavyimpact")
						target.throw_at(get_edge_target_turf(target, get_dir(user, target)), 3, 2, user)
						return TRUE

					else
						to_chat(target, SPAN_NOTICE("Ваше силовое поле успешно сдержало удар, пускай на это и ушло приличное количество концентрации."))
						target.psi.spend_power(10)
						for(var/zone in list(BP_CHEST, BP_GROIN, BP_HEAD))
							user.apply_damage(rand(10,25),DAMAGE_BRUTE,def_zone=zone)
						new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "smash")
						new /obj/temporary(get_turf(target),6, 'mods/psionics/icons/effects/heavyimpact.dmi', "heavyimpact")
						user.throw_at(get_edge_target_turf(user, get_dir(target, user)), 3, 2, target)
						user.visible_message(SPAN_DANGER("Мощное силовое поле [target] отбрасывает [user] назад, создавая мощную обратную волну!"))
						return TRUE

//ENEMY PSI CHECK END

			if(!user.skill_check(SKILL_HAULING, SKILL_EXPERIENCED))

				user.apply_damage(rand(10,15),DAMAGE_BRUTE, user.hand ? BP_L_ARM : BP_R_ARM)
				to_chat(user, SPAN_WARNING("Ваше неподготовленное тело не выдерживает отдачи от удара, и вашу руку выворачивает наизнанку!"))

			new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "smash")
			new /obj/temporary(get_turf(target),6, 'mods/psionics/icons/effects/heavyimpact.dmi', "heavyimpact")
			target.visible_message(SPAN_DANGER("[target] ловит лицом кулак, улетая назад!"))
			for(var/zone in list(BP_CHEST, BP_GROIN, BP_HEAD))
				target.apply_damage(rand(25,40),DAMAGE_BRUTE,def_zone=zone)

			target.throw_at(get_edge_target_turf(target, get_dir(user, target)), 3, 2, user)

			return TRUE


///GRANDMASTER///


		if(pk_rank_user == PSI_RANK_GRANDMASTER)
			if(istype(target, /obj/structure) || istype(target, /obj/machinery) || istype(target, /obj/item))
				var/obj/O = target
				if(O.anchored == TRUE)
					user.visible_message(SPAN_DANGER("[user] с сверхзвуковой скоростью бьет кулаком по [target]!"))
					new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "smash")
					O.damage_health(300, DAMAGE_BRUTE)
					user.apply_damage(rand(5,15), DAMAGE_BRUTE, pick(BP_L_HAND, BP_R_HAND))
					return TRUE
				new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "smash")
				user.visible_message(SPAN_DANGER("[user] толкает [target] вперёд!"))
				O.throw_at(get_edge_target_turf(O, get_dir(user, O)), 8, 4, user)
				return TRUE
			user.visible_message(SPAN_DANGER("[user] заносит руку назад и наносит удар с сверхзвуковой скоростью!"))

			var/mob/living/M = target
			if(get_dist(user, M) <= 6)
				var/turf/target_turf = get_step(get_turf(target), pick(GLOB.alldirs))
				var/list/line_list = getline(user, target_turf)
				for(var/i = 1 to length(line_list))
					var/turf/T = line_list[i]
					var/obj/temp_visual/decoy/D = new /obj/temp_visual/decoy(T, user.dir, user)
					D.alpha = min(150 + i*15, 255)
					animate(D, alpha = 0, time = 2 + i*2)
				user.forceMove(target_turf)

//ENEMY PSI CHECK START

			if(target.psi)
				var/pk_rank_target = target.psi.get_rank(PSI_PSYCHOKINESIS)
				if(pk_rank_target >= pk_rank_user && !target.psi.suppressed)
					if(prob(60))
						to_chat(target, SPAN_NOTICE("Каким-то чудом, [user] пробивается через ваше силовое поле, нанося сокрушительный урон!"))
						target.visible_message(SPAN_DANGER("[target] ловит лицом кулак, улетая назад!"))
						if(!user.skill_check(SKILL_HAULING, SKILL_EXPERIENCED))

							user.apply_damage(60,DAMAGE_BRUTE, user.hand ? BP_L_ARM : BP_R_ARM)
							to_chat(user, SPAN_WARNING("Ваше неподготовленное тело не выдерживает отдачи от удара, и вашу руку выворачивает наизнанку!"))

						for(var/zone in list(BP_CHEST, BP_GROIN, BP_HEAD))
							target.apply_damage(rand(20,60),DAMAGE_BRUTE,def_zone=zone)
						new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "smash")
						new /obj/temporary(get_turf(target),6, 'mods/psionics/icons/effects/heavyimpact.dmi', "heavyimpact")
						target.throw_at(get_edge_target_turf(target, get_dir(user, target)), 6, 2, user)
						return TRUE

					else
						to_chat(target, SPAN_NOTICE("Ваше силовое поле успешно сдержало удар, пускай на это и ушло приличное количество концентрации."))
						target.psi.spend_power(10)
						for(var/zone in list(BP_CHEST, BP_GROIN, BP_HEAD))
							user.apply_damage(rand(20,60),DAMAGE_BRUTE,def_zone=zone)
						new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "smash")
						new /obj/temporary(get_turf(target),6, 'mods/psionics/icons/effects/heavyimpact.dmi', "heavyimpact")
						user.throw_at(get_edge_target_turf(user, get_dir(target, user)), 6, 2, target)
						user.visible_message(SPAN_DANGER("Мощное силовое поле [target] отбрасывает [user] назад, создавая мощную обратную волну!"))
						return TRUE

//ENEMY PSI CHECK END

			if(!user.skill_check(SKILL_HAULING, SKILL_EXPERIENCED))

				user.apply_damage(60,DAMAGE_BRUTE, user.hand ? BP_L_ARM : BP_R_ARM)
				to_chat(user, SPAN_WARNING("Ваше неподготовленное тело не выдерживает отдачи от удара, и вашу руку выворачивает наизнанку!"))

			new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "smash")
			new /obj/temporary(get_turf(target),6, 'mods/psionics/icons/effects/heavyimpact.dmi', "heavyimpact")
			target.visible_message(SPAN_DANGER("[target] ловит лицом кулак, улетая назад!"))
			for(var/zone in list(BP_CHEST, BP_GROIN, BP_HEAD))
				target.apply_damage(rand(20,60),DAMAGE_BRUTE,def_zone=zone)

			target.throw_at(get_edge_target_turf(target, get_dir(user, target)), 6, 2, user)

			return TRUE

/obj/structure/girder/rock
	icon_state = "ground rock"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_HUMAN_LAYER
	w_class = ITEM_SIZE_NO_CONTAINER
	health_max = 200
	icon = 'mods/psionics/icons/effects/psi_effects.dmi'
	icon_state = "earth_pillar_2"

/obj/structure/girder/rock/use_tool(obj/item/W, mob/user)
	if (user.a_intent == I_HURT)
		..()
		return

	if(istype(W, /obj/item/pickaxe/diamonddrill))
		playsound(src.loc, 'sound/weapons/Genhit.ogg', 100, 1)
		if(do_after(user,reinf_material ? 60 : 40,src))
			to_chat(user, SPAN_DANGER("You drill through the rock!"))
			if(reinf_material)
				reinf_material.place_dismantled_product(get_turf(src))
			dismantle()
		return

/obj/structure/girder/rock/dismantle()
	qdel(src)

/singleton/psionic_power/psychokinesis/rock_shield
	name =           "Ground Shield"
	cost =           10
	cooldown =       30
	use_melee =      TRUE
	use_ranged =     TRUE
	min_rank =       PSI_RANK_OPERANT

	use_description = "Выберите любую ногу или пятку на жёлтом интенте, а затем нажмите по ближайшему куску земли, чтобы поднять его вверх."

/singleton/psionic_power/psychokinesis/rock_shield/invoke(mob/living/carbon/user, turf/simulated/target)
	if(!(user.zone_sel.selecting in list(BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT)))
		return FALSE

	if(!target)
		to_chat(user, SPAN_NOTICE("Данный материал слабо подойдёт для тех задач, для которых вы хотите использовать его!"))
		return FALSE

	. = ..()
	if(.)
		if(istype(target, /turf/simulated/floor/exoplanet))
			var/turf/A = target
			if(do_after(user, 10))
				user.visible_message(SPAN_DANGER("[user] возводит каменную стену!"))
				new /obj/temporary(A, 9, 'mods/psionics/icons/effects/psi_effects.dmi', "earth_pillar_0")
				spawn(1 SECONDS)
					new /obj/structure/girder/rock(get_turf(A))
				return TRUE
		else
			return FALSE
