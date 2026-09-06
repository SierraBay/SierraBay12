/singleton/psionic_power/consciousness/revelation
	name =            "Revelate fear"
	cost =            20
	cooldown =        50
	use_ranged =      TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "На дистанции, нажмите на цель, целясь ей в глаза, на зеленом интенте, чтобы наслать на него ужасающий образ"

/singleton/psionic_power/consciousness/revelation/invoke(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/con_rank_user = user.psi.get_rank(PSI_CONSCIOUSNESS)
	if(user.zone_sel.selecting != BP_EYES || user.a_intent != I_HELP)
		return FALSE
	. = ..()
	if(.)
		var/distance = get_dist(get_turf(user), get_turf(target))
		if(distance > user.psi.get_rank(PSI_CONSCIOUSNESS) * 5)
			to_chat(user, SPAN_WARNING("Я не могу сконцентрироватся настолько далеко."))
			return FALSE

		if(target.is_dead() || !target.client)
			return FALSE

		if(target != user)
			switch(con_rank_user)
				if(PSI_RANK_APPRENTICE)
					scream(user, target, "scary", 3)
					target.custom_emote(1, "[pick("кровоточит", "истекает кровью", "льет кровь", "капает кровью")] из носа")
				if(PSI_RANK_OPERANT)
					scream(user, target, "scary", 9)
					target.Stun(3)

					target.visible_message(SPAN_WARNING("[target] блюёт!"), SPAN_WARNING("[pick("Ужасная вонь", "Омерзительный лик", "Движения под кожей", "Зуд за глазами", "Движения в ушах", "Головокружение")], вынуждают меня блевать!"))
					playsound(target.loc, 'sound/effects/splat.ogg', 50, 1)
					new /obj/decal/cleanable/vomit(target.loc)
				if(PSI_RANK_MASTER)
					scream(user, target, "horrific", 6)
					target.Stun(3)
					target.mod_confused(5)

					target.visible_message(SPAN_WARNING("[target] блюёт!"), SPAN_WARNING("[pick("Ужасная вонь", "Омерзительный лик", "Движения под кожей", "Зуд за глазами", "Движения в ушах", "Головокружение")], вынуждают меня блевать!"))
					playsound(target.loc, 'sound/effects/splat.ogg', 50, 1)
					new /obj/decal/cleanable/vomit(target.loc)
				if(PSI_RANK_GRANDMASTER)
					scream(user, target, "horrific", 6)
					target.Stun(3)
					target.mod_confused(5)

					target.remove_blood(rand(20,30))
					target.visible_message(SPAN_DANGER("[target] блюёт кровью!"), SPAN_DANGER("[pick("Меня тошнит кровью", "Голова кружится, мой мозг отвергает мою кровь", "Кровь покидает мое тело из рта", "Мой рот заливается кровью", "Металлический вкус во рту, я рефлекторно блюю", "Мой мозг истощается, я отравлен, из моего рта выбирается кровь")]!"))
					playsound(target.loc, 'sound/effects/splat.ogg', 50, 1)

					var/obj/decal/cleanable/blood/blood_vomit = new /obj/decal/cleanable/blood(target.loc)
					blood_vomit.update_icon()
					if (prob(15))
						target.Weaken(5)
						target.add_chemical_effect(CE_VOICELOSS, 5)
					if (prob(30))
						target.eye_blurry = max(target.eye_blurry, 10)
			return TRUE

/singleton/psionic_power/consciousness/revelation/proc/scream(mob/living/carbon/human/user, mob/living/carbon/human/target, type, num)
	set waitfor = 0

	sound_to(target, sound('mods/psionics/sounds/screamer.ogg'))

	var/obj/screen/fullscreen/revelation = new /obj/screen/fullscreen()
	revelation.screen_loc = "1,1"
	revelation.icon = 'mods/psionics/icons/fullscreen.dmi'
	revelation.icon_state = "[type][rand(1,num)]"
	revelation.mouse_opacity = FALSE
	revelation.scale_to_view = TRUE

	if(prob(0.001))
		revelation.icon_state = "his_holyness" // DEEP LORE : Bearer of rating ALEPH 7

	target.client.screen += revelation
	sleep(1 SECOND)
	animate(revelation, 4 SECONDS, alpha = 0)
	QDEL_IN(revelation, 4 SECONDS)
