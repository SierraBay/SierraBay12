/mob/living/exosuit/proc/offer_passenger_place(mob/living/carbon/user)
	if(!user.Adjacent(src) || !ishuman(user)) // <- Мех рядом?
		return FALSE
	if(user.mob_size > MOB_MEDIUM)
		to_chat(user,SPAN_NOTICE("Не залезу."))
		return
	if(user.r_hand != null || user.l_hand != null)
		to_chat(user,SPAN_NOTICE("Мне нужна хотя бы одна свободная рука."))
		return
	var/local_dir = get_dir(src, user)
	// Y Y Y
	// Y M Y  ↓ (направление меха)
	// N N N
	// M - Мех, N - Нельзя, Y - Можно
	if(local_dir != turn(dir, 90) && local_dir != turn(dir, -90) && local_dir != turn(dir, -135) && local_dir != turn(dir, 135) && local_dir != turn(dir, 180))
		to_chat(user, SPAN_WARNING("С этой стороны, за [src] мне не ухватиться."))
		return FALSE
	var/list/options = list(
		"Левый бок" = mutable_appearance('mods/mechs_by_shegar/icons/radial_menu.dmi', "left shoulder"),
		"Спина" = mutable_appearance('mods/mechs_by_shegar/icons/radial_menu.dmi', "head"),
		"Правый бок" = mutable_appearance('mods/mechs_by_shegar/icons/radial_menu.dmi', "right shoulder")
		)
	var/choosed_place = show_radial_menu(user, user, options, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	check_passenger(user, choosed_place)
