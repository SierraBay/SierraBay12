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
			to_chat(user, SPAN_WARNING("Моих сил недостаточно, чтобы достать до этого объекта."))
			return FALSE

		if(istype(target, /obj/machinery))
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
	cooldown =       100
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
		to_chat(user, SPAN_DANGER("Я выпускаю мощную волну, разметая всё вокруг!"))
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
				user.visible_message(SPAN_DANGER("[user] бьет по [target], отправляя в полёт!"))
				O.damage_health(15, DAMAGE_BRUTE)
				user.apply_damage(rand(5,15), DAMAGE_BRUTE, pick(BP_L_HAND, BP_R_HAND))
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
				user.visible_message(SPAN_DANGER("[user] бьет по [target], отправляя в полёт!"))
				O.damage_health(40, DAMAGE_BRUTE)
				user.apply_damage(rand(5,15), DAMAGE_BRUTE, pick(BP_L_HAND, BP_R_HAND))
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
				user.visible_message(SPAN_DANGER("[user] бьет по [target], отправляя в полёт!"))
				O.damage_health(40, DAMAGE_BRUTE)
				user.apply_damage(rand(5,15), DAMAGE_BRUTE, pick(BP_L_HAND, BP_R_HAND))
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

/singleton/psionic_power/psychokinesis/propel
	name =           "Propel"
	cost =           20
	cooldown =       40
	use_ranged =     TRUE
	min_rank =       PSI_RANK_APPRENTICE
	use_description = "Выберите любую ногу или пятку на жёлтом интенте, чтобы отправится в полёт."

/singleton/psionic_power/psychokinesis/propel/invoke(mob/living/carbon/user, turf/simulated/target)
	if(!(user.zone_sel.selecting in list(BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT)))
		return FALSE

	if(!target)
		return FALSE

	. = ..()
	if(.)
		var/user_rank = user.psi.get_rank(PSI_PSYCHOKINESIS)
		user.throw_at(target, user_rank, user_rank, user)
