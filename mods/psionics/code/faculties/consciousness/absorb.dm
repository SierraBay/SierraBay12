/singleton/psionic_power/consciousness/absorb
	name =            "Absorption"
	cost =            10
	cooldown =        40
	use_ranged =      TRUE
	use_melee =       TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Выберите верхнюю часть тела на зелёном интенте, и затем нажмите по цели с любого расстояния, чтобы попытаться поглотить часть псионической силы жертвы."

/singleton/psionic_power/consciousness/absorb/invoke(mob/living/user, mob/living/target)
	var/con_rank_user = user.psi.get_rank(PSI_CONSCIOUSNESS)
	if(user.zone_sel.selecting != BP_CHEST || user.a_intent != I_HELP)
		return FALSE
	. = ..()
	if(.)
		if(target == user)
			return FALSE
		if(target.psi)
			var/con_rank_target = target.psi.get_rank(PSI_CONSCIOUSNESS)
			if(con_rank_user > con_rank_target)
				sound_to(user, 'sound/effects/psi/power_fail.ogg')
				if(prob(30))
					to_chat(user, SPAN_DANGER("Я попытался проникнуть в разум [target], но тот ускользнул из под моего воздействия."))
					to_chat(target, SPAN_WARNING("Я рефлекторно избежал губительного воздействия [user] на ваш разум."))
					return FALSE
				to_chat(user, SPAN_NOTICE("Я разбил защиту [target]."))
				to_chat(target, SPAN_DANGER("Я ощущаю сильную головную боль, пока [user] пристально сверлит меня взглядом."))
				target.apply_damage(10, DAMAGE_PAIN, BP_HEAD)
				user.psi.stamina = min(user.psi.max_stamina, user.psi.stamina + rand(25,30))
				target.psi.spend_power(rand(15,25))
			if(con_rank_user == con_rank_target)
				sound_to(user, 'sound/effects/psi/power_fail.ogg')
				if(prob(50))
					to_chat(user, SPAN_WARNING("Я попытался проникнуть в разум [target], но в ходе битвы сам получил значительный урон!"))
					to_chat(target, SPAN_DANGER("Я сопротивлялся [user] повлиять на мой разум, но в конечном счёте всё равно проиграл."))
					user.psi.stamina = min(user.psi.max_stamina, user.psi.stamina + rand(10,20))
					target.psi.spend_power(rand(10,20))
					user.apply_damage(10, DAMAGE_PAIN, BP_HEAD)
					target.apply_damage(10, DAMAGE_PAIN, BP_HEAD)
					user.emote("scream")
					target.emote("scream")
					return 0
				to_chat(user, SPAN_WARNING("Я с лёгкостью разбил защиту [target], забрав часть его сил себе."))
				to_chat(target, SPAN_DANGER("Я ощущаю сильную головную боль, пока [user] пристально сверлит вас взглядом."))
				target.apply_damage(10, DAMAGE_PAIN, BP_HEAD)
				user.psi.stamina = min(user.psi.max_stamina, user.psi.stamina + rand(25,30))
				target.psi.spend_power(rand(15,25))
			if(con_rank_user < con_rank_target)
				sound_to(user, 'sound/effects/psi/power_fail.ogg')
				if(prob(30))
					to_chat(user, SPAN_WARNING("Мне удалось пробиться через псионическую завесу [target]!"))
					to_chat(target, SPAN_DANGER("[user] пробился в мой разум чистой, грубой силой, нанеся в процессе значительный урон."))
					target.apply_damage(10, DAMAGE_PAIN, BP_HEAD)
					user.psi.stamina = min(user.psi.max_stamina, user.psi.stamina + rand(30,45))
					target.psi.spend_power(10)
					return 0
				to_chat(user, SPAN_DANGER("Я пытаюсь пробиться через барьер [target], но встречаю серьёзное сопротивление!"))
				to_chat(target, SPAN_NOTICE("[user] попытался пробиться в мое сознание."))
				user.emote("scream")
				user.apply_damage(10, DAMAGE_PAIN, BP_HEAD)
				user.psi.spend_power(50)
		else
			to_chat(user, SPAN_NOTICE("У [target] нет пробужденного псионического потенциала."))
			return 0
