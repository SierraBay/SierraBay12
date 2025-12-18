/turf/simulated/floor/exoplanet/titan_water/proc/drown_human(mob/user)
	if(effect_to_drowning == KILL)
		user.client.play_screentext_on_client_screen(input_text = "Вы ушли на дно морское", holding_on_screen_time = 3 SECONDS, delay_between_words = 0.025 SECONDS)
		qdel(user)
	else if(effect_to_drowning == DEEQUIP)
		if(user.client)
			user.client.play_screentext_on_client_screen(input_text = "Тону! Скидываю с себя всё что только можно!", holding_on_screen_time = 3 SECONDS, delay_between_words = 0.025 SECONDS)
		user.dir = SOUTH
		user.resting = TRUE
		user.UpdateLyingBuckledAndVerbStatus()
		user.Stun(2)
		user.adjust_stamina(-100)
		unequip_human_clotches(user)

/turf/simulated/floor/exoplanet/titan_water/proc/drown_item(obj/input)
	input.anchored = TRUE
	visible_message(message = SPAN_BAD("[input] уходит на дно."), range = 7)
	animate(input, alpha = 0, time = 1 SECONDS, easing = EASE_OUT)
	sleep(1.1 SECONDS)
	qdel(input)

/turf/simulated/floor/exoplanet/titan_water/proc/drown_structure(obj/input)
	input.anchored = TRUE
	if(input.pulledby)
		input.pulledby.stop_pulling()
	for(var/mob/living/mobik in input.contents)
		mobik.forceMove(get_turf(src))
	visible_message(message = SPAN_BAD("[input] уходит на дно."), range = 7)
	animate(input, alpha = 0, time = 1 SECONDS, easing = EASE_OUT)
	sleep(1.1 SECONDS)
	qdel(input)

/turf/simulated/floor/exoplanet/titan_water/proc/drown_mech(mob/living/exosuit/mech)
	mech.anchored = TRUE
	visible_message(message = SPAN_BAD("[mech] уходит на дно."), range = 7)
	animate(mech, alpha = 0, time = 1 SECONDS, easing = EASE_OUT)
	sleep(1.1 SECONDS)
	mech.Destroy()

//Снимем с персонажа:.
	//Рюкзак
	//Все карманы
	//Пояс
	//Аксессуары
/turf/simulated/floor/exoplanet/titan_water/proc/unequip_human_clotches(mob/user, list/dequip_stuffs_list = list(slot_back, slot_belt, slot_l_store, slot_r_store))
	if(!ishuman(user) || !LAZYLEN(dequip_stuffs_list))
		return
	var/mob/living/carbon/human/detected_human = user
	for(var/i in dequip_stuffs_list)
		detected_human.drop_from_inventory(detected_human.get_equipped_item(i))
