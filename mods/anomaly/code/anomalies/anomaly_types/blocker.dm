//Аномалия блокирует всех тех кто пытается пройти без детектора.
//Применяется в картах, где мы не хотим чтоб свинные лутеры лезли и мешали эк или верне
/obj/anomaly_blocker
	name = "Плотный воздух"
	icon = 'icons/effects/effects.dmi'
	icon_state = "m_shield"
	anchored = TRUE
	density = TRUE
	opacity = FALSE
	invisibility = 60 //Видят ток призраки

//Выполняется исключительно для людей. Ищет детектор в человеке.
/proc/have_anomaly_detector(mob/living/carbon/human/input_human)
	if(ishuman(input_human))
		if(locate(/obj/item/clothing/gloves/anomaly_detector) in input_human.contents)
			return TRUE
		for(var/obj/item/picked_item in input_human.contents)
			if(locate(/obj/item/clothing/gloves/anomaly_detector) in picked_item.contents)
				return TRUE
			if(locate(/obj/item/rig_module/device/anomaly_detector) in picked_item.contents)
				return TRUE
		return FALSE

//увы Cross не работает
/obj/anomaly_blocker/Bumped(AM)
	. = ..()
	if(ishuman(AM))
		if(have_anomaly_detector(AM))
			var/mob/living/carbon/human/human = AM
			human.forceMove(get_turf(src))
			return TRUE //Пускаем
		else
			do_block_effect()
			return FALSE //Не пускаем

/obj/anomaly_blocker/proc/do_block_effect()
	set waitfor = FALSE
	var/obj/spawned_effect = new /obj/effect/warp/labirint(get_turf(src))
	animate(spawned_effect, alpha = 40, time = 2 SECOND, easing = SINE_EASING)
	sleep(1 SECONDS)
	spawned_effect.Destroy()
