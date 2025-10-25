/singleton/psionic_faculty/redaction
	id = PSI_REDACTION
	name = "Redaction"
	associated_intent = I_HELP
	armour_types = list("bio", "rad")

/singleton/psionic_power/redaction
	faculty = PSI_REDACTION
	admin_log = FALSE
	abstract_type = /singleton/psionic_power/redaction

/singleton/psionic_power/redaction/proc/check_dead(mob/living/target)
	if(!istype(target))
		return FALSE
	if(target.is_dead())
		return TRUE
	return FALSE

/singleton/psionic_power/redaction/invoke(mob/living/user, mob/living/target)
	if(check_dead(target))
		return FALSE
	. = ..()

/singleton/psionic_power/redaction/skinsight
	name =            "Skinsight"
	cost =            3
	cooldown =        30
	use_grab =        TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Схватите цель, выберите верхнюю часть тела и переключитесь на зелёный интент, затем нажмите по цели захватом ещё раз, чтобы проверить физическое состояние цели."

/singleton/psionic_power/redaction/skinsight/invoke(mob/living/user, mob/living/target)
	if(user.zone_sel.selecting != BP_CHEST)
		return FALSE
	. = ..()
	if(.)
		user.visible_message(SPAN_NOTICE("[user] кладёт руку на [target]."))
		to_chat(user, medical_scan_results(target, TRUE, user.get_skill_value(SKILL_MEDICAL)))
		return TRUE

/singleton/psionic_power/redaction/mend
	name =            "Mend"
	cost =            7
	cooldown =        50
	use_melee =       TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Выберите любую часть тела на зелёном интенте и нажмите по цели, чтобы убрать возможные ранения с указанной зоны."

//UPDATED

/singleton/psionic_power/redaction/mend/invoke(mob/living/user, mob/living/carbon/human/target)
	if(!isliving(target))
		return
	var/red_rank = user.psi.get_rank(PSI_REDACTION)
	var/pk_rank = user.psi.get_rank(PSI_PSYCHOKINESIS)
	var/obj/item/organ/external/E = target.get_organ(user.zone_sel.selecting)
	if(!istype(user) || !istype(target))
		return FALSE
	. = ..()
	if(.)
		var/option = input(user, "Выберите что-нибудь!", "Какую помощь вы хотите оказать [target]?") in list("Кровотечение", "Переломы", "Травмы", "Конечности", "Органы")
		user.psi.set_cooldown(cooldown)
		if (!option)
			return
		if(option == "Травмы")
			if(red_rank < PSI_RANK_GRANDMASTER)
				to_chat(user, SPAN_WARNING("Ваших сил недостаточно для проведения этой операции!"))
				return 0
			if(do_after(user, 20))
				user.visible_message(SPAN_NOTICE("<i>[user] кладёт руки на плечи [target]...</i>"))
				to_chat(target, SPAN_NOTICE("Вы ощущаете приятное тепло...ваши раны заживают."))
				new /obj/temporary(get_turf(target),8, 'icons/effects/effects.dmi', "pink_sparkles")

				if(user.skill_check(SKILL_ANATOMY, SKILL_TRAINED) && user.skill_check(SKILL_MEDICAL, SKILL_TRAINED))
					to_chat(user, SPAN_NOTICE("Благодаря имеющимся навыкам, вам удалось эффективно залечить некоторые раны[target]."))
					target.adjustBruteLoss(-rand(20,40))
					target.adjustFireLoss(-rand(20,40))

				target.adjustBruteLoss(-(rand(10,20) * red_rank))
				target.adjustFireLoss(-(rand(10,20) * red_rank))
				if(pk_rank >= PSI_RANK_GRANDMASTER)
					var/removal_size = clamp(5-pk_rank, 0, 5)
					var/valid_objects = list()
					for(var/thing in E.implants)
						var/obj/imp = thing

						if(!imp)
							continue

						if(imp.w_class >= removal_size && !istype(imp, /obj/item/implant))
							valid_objects += imp
					if(LAZYLEN(valid_objects))
						var/removing = pick(valid_objects)
						target.remove_implant(removing, TRUE)
						to_chat(user, SPAN_NOTICE("Вы извлекли [removing] из [E.name] вашего пациента."))
				return 1
		if(option == "Переломы")

//It's easier to repair severed tendon, than put bones in place or either repair it structure, so no rank check

			if(E.status & ORGAN_TENDON_CUT)
				if(do_after(user, 40))
					new /obj/temporary(get_turf(target),8, 'icons/effects/effects.dmi', "pink_sparkles")
					to_chat(user, SPAN_NOTICE("Вы сплели новое сухожилие на месте повреждённого в [E.name]."))
					E.status &= ~ORGAN_TENDON_CUT
					return 1

			if(red_rank < PSI_RANK_OPERANT)
				to_chat(user, SPAN_WARNING("Ваших сил недостаточно для проведения этой операции!"))
				return 0
			if(!E)
				to_chat(user, SPAN_WARNING("Эта конечность отсутствует!"))
				return 0
			if(BP_IS_ROBOTIC(E))
				to_chat(user, SPAN_WARNING("Эта конечность заменена протезом."))
				return 0
			if(E.is_stump())
				to_chat(user, SPAN_WARNING("Нет смысла тратить силы на этот обрубок. Здесь вы бессильны."))
				return 0
			if(E.status & ORGAN_BROKEN)
				user.visible_message(SPAN_NOTICE("<i>[user] кладёт руку на [target]'s [E.name]...</i>"))
				if(do_after(user, 60))
					new /obj/temporary(get_turf(target),8, 'icons/effects/effects.dmi', "pink_sparkles")
					if(!user.skill_check(SKILL_ANATOMY, SKILL_BASIC))
						if(prob(30))
							to_chat(user, SPAN_WARNING("Вы кое-как попытались вновь соединить кости [target], однако сделали своей неопытностью только хуже."))
							target.apply_damage(20,DAMAGE_BRUTE,E)
							return 0
					to_chat(user, SPAN_NOTICE("Вы установили кости на их прежнее место, заделав образовавшиеся на их поверхности трещины."))
					E.status &= ~ORGAN_BROKEN
					E.stage = 0
					to_chat(target, SPAN_NOTICE("Вы ощущаете неприятное движение в районе [E.name]...кости начинают вставать на место."))
					return 1
			else
				to_chat(user, SPAN_WARNING("[E.name] не имеет никаких внутренних повреждений!"))
				return 0

		if(option == "Кровотечение")
			if(red_rank < PSI_RANK_APPRENTICE)
				to_chat(user, SPAN_WARNING("Ваших сил недостаточно для проведения этой операции!"))
				return 0
			if(!E)
				to_chat(user, SPAN_WARNING("Эта конечность отсутствует!"))
				return 0
			if(BP_IS_ROBOTIC(E))
				to_chat(user, SPAN_WARNING("Эта конечность не жива."))
				return 0
			if(E.is_stump())
				to_chat(user, SPAN_WARNING("Нет смысла тратить силы на этот обрубок. Здесь вы бессильны."))
				return 0
			if(E.status & ORGAN_ARTERY_CUT && red_rank >= PSI_RANK_OPERANT)
				if(do_after(user, 60))
					new /obj/temporary(get_turf(target),8, 'icons/effects/effects.dmi', "pink_sparkles")
					if(!user.skill_check(SKILL_ANATOMY, SKILL_BASIC))
						if(prob(30))
							to_chat(user, SPAN_WARNING("Ваша попытка связать разорванные артерии в [E.name] закончились ужасным провалом."))
							target.apply_damage(20,DAMAGE_BRUTE,E)
							return 0
					to_chat(user, SPAN_NOTICE("Вы вновь связали разованные артерии в [E.name], останавливая внутреннее кровотечение."))
					to_chat(target, SPAN_NOTICE("Вы ощущаете неприятное чувство в районе [E.name]...словно кто-то вновь сплетает ваши вены воедино."))
					E.status &= ~ORGAN_ARTERY_CUT
					return 1
			for(var/datum/wound/W in E.wounds)
				if(W.bleeding())
					if(W.wound_damage() < 30)
						if(do_after(user, 30))
							to_chat(user, SPAN_NOTICE("Вы останавливаете кровь в [E.name]."))
							to_chat(target, SPAN_NOTICE("Вы ощущаете как ваша кожа смыкается в [E.name]..."))
							new /obj/temporary(get_turf(target),8, 'icons/effects/effects.dmi', "pink_sparkles")
							W.bleed_timer = 0
							W.clamped = TRUE
							E.status &= ~ORGAN_BLEEDING
							return 1
					else
						to_chat(user, SPAN_NOTICE("Эта рваная рана, слишком разтерзана, чтобы ее закрыть."))
						return 0
				else
					to_chat(user, SPAN_WARNING("[E.name] не имеет никаких внутренних повреждений!"))
					return 0

		if(option == "Конечности")
			if(red_rank < PSI_RANK_MASTER)
				to_chat(user, SPAN_WARNING("Ваших сил недостаточно для проведения этой операции!"))
				return 0
			if(red_rank >= PSI_RANK_MASTER)

				if(!E)
					var/o_type = user.zone_sel.selecting
					var/what =  alert(user, "Вы уверены, что хотите прибегнуть к трансплантации?", "Обратная связь", "Да", "Нет")
					switch(what)
						if("Да")
							if(do_after(user, 120))
								new /obj/temporary(get_turf(target),8, 'icons/effects/effects.dmi', "pink_sparkles")
								var/list/missing_limbs = target.species.has_limbs - target.organs_by_name
								missing_limbs -= o_type
								var/limb_type = target.species.has_limbs[o_type]["path"]
								var/obj/new_limb = new limb_type(target)
								target.visible_message(SPAN_DANGER("На теле [target], начала вырастать новая [new_limb.name]!"))
								E = target.get_organ(o_type)
								if(!user.skill_check(SKILL_ANATOMY, SKILL_TRAINED) || !user.skill_check(SKILL_MEDICAL, SKILL_BASIC))
									if(prob(40))
										to_chat(user, SPAN_WARNING("Ваша некомпетентность привела к тому что Вы неправильно сформировали [new_limb.name]!"))
										E.mutate()
								user.apply_damage(20, DAMAGE_BRUTE, o_type)
								user.psi.spend_power(50)
								target.regenerate_icons()
						else
							return 0
				if(E.is_stump())
					if(do_after(user, 120))
						E.droplimb(0,DROPLIMB_BLUNT)
						new /obj/temporary(get_turf(target),8, 'icons/effects/effects.dmi', "pink_sparkles")

		if(option == "Органы")
			if(red_rank < PSI_RANK_MASTER)
				to_chat(user, SPAN_WARNING("Ваших сил недостаточно для проведения этой операции!"))
				return 0
			if(red_rank >= PSI_RANK_MASTER)
				for(var/obj/item/organ/internal/I in E.internal_organs)
					if(!BP_IS_ROBOTIC(I) && !BP_IS_CRYSTAL(I) && I.damage > 0)
						if(do_after(user, 120))
							to_chat(user, SPAN_NOTICE("Вы вторгаетесь в [target], восстанавливая: [I]."))
							new /obj/temporary(get_turf(target),8, 'icons/effects/effects.dmi', "pink_sparkles")
							var/heal_rate = red_rank
							if(!user.skill_check(SKILL_ANATOMY, SKILL_TRAINED) || !user.skill_check(SKILL_MEDICAL, SKILL_BASIC))
								if(prob(60))
									to_chat(user, SPAN_WARNING("Ваша неопытность приводит к тому, что вы лишь усугубили состояние [target]!"))
									I.damage = max(0, I.damage + rand(5,10))
									return 0
							I.damage = max(0, I.damage - rand(heal_rate,heal_rate*3))
							return 1

/singleton/psionic_power/redaction/cleanse
	name =            "Cleanse"
	cost =            9
	cooldown =        60
	use_melee =       TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Нажмите по цели на зелёном интенте, чтобы очистить его от генетических отклонений и воздействий радиации."

/singleton/psionic_power/redaction/cleanse/invoke(mob/living/user, mob/living/carbon/human/target)
	if(!istype(user) || !istype(target))
		return FALSE
	. = ..()
	if(.)
		// No messages, as Mend procs them even if it fails to heal anything, and Cleanse is always checked after Mend.
		var/removing = rand(20,25)
		if(target.radiation)
			to_chat(user, SPAN_NOTICE("Вы выводите нежелательные частицы из тела [target]..."))
			if(target.radiation > removing)
				target.radiation -= removing
			else
				target.radiation = 0
			return TRUE
		if(target.getCloneLoss())
			to_chat(user, SPAN_NOTICE("Вы с трудом восстанавливаете прежнюю структуру ДНК [target]..."))
			if(target.getCloneLoss() >= removing)
				target.adjustCloneLoss(-removing)
			else
				target.adjustCloneLoss(-(target.getCloneLoss()))
			return TRUE
		to_chat(user, SPAN_NOTICE("У [target] нет ни радиационного заражения, ни генетических отклонений."))
		return FALSE

/singleton/psionic_power/revive
	name =            "Revive"
	cost =            25
	cooldown =        80
	use_grab =        TRUE
	min_rank =        PSI_RANK_GRANDMASTER
	faculty =         PSI_REDACTION
	use_description = "Схватите цель, выберите голову и зелёный интент, затем нажмите по нему захватом, чтобы попытаться вернуть его к жизни."
	admin_log = FALSE

/singleton/psionic_power/revive/invoke(mob/living/user, mob/living/target)
	if(!isliving(target) || !istype(target) || user.zone_sel.selecting != BP_HEAD)
		return FALSE
	. = ..()
	if(.)
		if(!target.is_dead())
			to_chat(user, SPAN_WARNING("Этот человек ещё жив!"))
			return TRUE

		if((world.time - target.timeofdeath) > 6000)
			to_chat(user, SPAN_WARNING("[target] пролежал здесь слишком долго. Нет никакой надежды на то, что его выйдет оживить."))
			return TRUE

		user.visible_message(SPAN_NOTICE("<i>[user] кладёт обе руки на тело [target]...</i>"))
		new /obj/temporary(get_turf(target),6, 'icons/effects/effects.dmi', "green_sparkles")
		if(!do_after(user, 100, target))
			user.psi.backblast(rand(10,25))
			return TRUE

		for(var/mob/observer/G in GLOB.dead_mobs)
			if(G.mind && G.mind.current == target && G.client)
				to_chat(G, SPAN_NOTICE("<font size = 3><b>Your body has been revived, <b>Re-Enter Corpse</b> to return to it.</b></font>"))
				break
		to_chat(target, SPAN_NOTICE("<font size = 3><b>Вы просыпаетесь от вечного сна, вместе с ужасающими воспоминаниями с того света.</b></font>"))
		target.visible_message(SPAN_NOTICE("[target] трясётся в ужасе!"))
		new /obj/temporary(get_turf(target),8, 'icons/effects/effects.dmi', "rune_convert")
		target.adjustOxyLoss(-rand(30,45))
		target.basic_revival()
		return TRUE
