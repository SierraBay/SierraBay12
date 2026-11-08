/*
	COMBAT_EXTENDED: спрайты патронов Хонка (`icons/ce_ammo.dmi`, `icons/ce_ammo_boxes.dmi`).

	- Гильза с `ce_sprite_caliber` берёт спрайт из `ce_ammo.dmi`. Тип со своим спрайтом (FMJ, AP, HP)
	  задаёт его в `icon_state`. Тип без своего (`ce_tinted_tip`) лежит на спрайте FMJ, а пока в
	  гильзе пуля, поверх идёт кончик `<калибр>_tip` в цвет типа (`ce_ammo_color`), у двухцветных ещё
	  задняя половина кончика `<калибр>_tip2`. Патрон 12g без своего спрайта собран из трёх частей:
	  латунное дно `shell-base`, корпус `shell-hull` и поясок `shell-band` в цвета типа.
	- Стреляную и вытряхнутую из магазина гильзу поворачивает случайный `transform`: кор крутит её
	  `set_dir()`, а у спрайтов Хонка одно направление.
	- Магазин показывает метку `<состояние>_mark` из `ce_ammo.dmi`, если она нарисована, в цвет
	  верхнего патрона, а пустой в цвет патрона, которым он снаряжается. Метка заменяет полосы резины
	  и учебных, которые кор `on_update_icon()` перечисляет по типам и берёт по `ammo_type`, а не по
	  тому, что в магазине лежит.
	- An ammo box shows the box of its round type (`ce_box_sprite`). The fill frame comes from
	  `ammo_count / ammo_max`. An empty box keeps the box of the last type. A type with no box and
	  spent casings use the core `ammo` box.
	- A type with no box of its own can use the box of another type with a layer in its color
	  (`ce_box_tint_sprite`): the rubber 10mm box is the FMJ box with the round tips in the rubber
	  color. The layer is part of the box icon, not an overlay, because the fabricator UI shows
	  only `icon` and `icon_state`.

	Какой гильзе, магазину и коробке какой спрайт: `code/items/guns/casings.dm` и
	`code/items/guns/magazines.dm`. Цвета: `code/__defines/~mods/combat_extended.dm`.
*/

/obj/item/ammo_casing
	/// Метка калибра в именах спрайтов `ce_ammo.dmi`: "10mm" у `10mm_fmj`, `10mm_tip`, `10mm-spent`.
	/// Просто метка, из `caliber` не собирается. null: у гильзы кор спрайт.
	var/ce_sprite_caliber
	/// The color of the round type: the tip of a type with no sprite of its own, the hull of a 12g
	/// shell, the magazine mark and the box layer (`ce_box_tint_sprite`).
	var/ce_ammo_color
	/// Второй цвет двухцветных типов (AP-I, AP-HE): задняя половина кончика, поясок патрона 12g.
	var/ce_ammo_color_2
	/// У типа нет своего спрайта: он показан спрайтом FMJ с кончиком в свой цвет, патрон 12g собран
	/// из частей.
	var/ce_tinted_tip = FALSE
	/// The ammo box of this type in `ce_ammo_boxes.dmi`, with no fill frame: "10mm_fmj", "12g_slug",
	/// "14mmR". Null: the core `ammo` box.
	var/ce_box_sprite
	/// A gray layer in `ce_ammo_boxes.dmi` that goes on `ce_box_sprite` in `ce_ammo_color`, with no
	/// fill frame: "12g_shells", "10mm_tip". It must have the same fill frames as `ce_box_sprite`.
	var/ce_box_tint_sprite


/obj/item/ammo_casing/Initialize(mapload, spawn_empty = FALSE)
	. = ..()
	// Кор `Initialize()` обновляет вид только пустой гильзе, а кончик нужен и живой.
	if(ce_tinted_tip && !spawn_empty)
		update_icon()


/obj/item/ammo_casing/on_update_icon()
	..()
	if(!ce_tinted_tip)
		return
	// Срезаются оба вида слоёв, живой и стреляной гильзы: чужие оверлеи, кровь например, остаются.
	CutOverlays(ce_get_tint_overlays(TRUE) + ce_get_tint_overlays(FALSE))
	AddOverlays(ce_get_tint_overlays(!isnull(BB)))


/// Слои в цвет типа: кончик, пока в гильзе пуля. У стреляной гильзы кончика нет.
/obj/item/ammo_casing/proc/ce_get_tint_overlays(loaded)
	RETURN_TYPE(/list)
	. = list()
	if(!loaded)
		return
	. += ce_make_ammo_tint(CE_AMMO_ICON, "[ce_sprite_caliber]_tip", ce_ammo_color)
	if(ce_ammo_color_2)
		. += ce_make_ammo_tint(CE_AMMO_ICON, "[ce_sprite_caliber]_tip2", ce_ammo_color_2)


/// Корпус и поясок патрона 12g, у стреляного тоже: они остаются на гильзе.
/obj/item/ammo_casing/shotgun/ce_get_tint_overlays(loaded)
	var/suffix = loaded ? "" : "-spent"
	return list(
		ce_make_ammo_tint(CE_AMMO_ICON, "shell-hull[suffix]", ce_ammo_color),
		ce_make_ammo_tint(CE_AMMO_ICON, "shell-band[suffix]", ce_ammo_color_2 || ce_ammo_color)
	)


/obj/item/ammo_casing/expend()
	. = ..()
	ce_spin()


/// Случайный поворот лежащей гильзы.
/obj/item/ammo_casing/proc/ce_spin()
	transform = turn(matrix(), rand(0, 359))


/obj/item/ammo_magazine/dump_all_casings(mob/living/user, atom/target = get_turf(src))
	. = ..()
	if(!islist(.))
		return
	for(var/obj/item/ammo_casing/casing as anything in .)
		casing.ce_spin()


/obj/item/ammo_magazine/on_update_icon()
	..()
	// Из оверлеев кор кладёт только полосы резины и учебных, перечисленные по типам: их заменяет
	// метка. Кадр наполнения кор уже выбрал.
	ClearOverlays()
	AddOverlays(ce_get_mark_overlay())


/// Метка типа патрона: `<состояние>_mark` из `ce_ammo.dmi`, если такая нарисована. null: метки нет.
/obj/item/ammo_magazine/proc/ce_get_mark_overlay()
	RETURN_TYPE(/image)
	// Метки нарисованы по магазинам кор файла и мода. Состояние с тем же именем в чужом файле может
	// быть другим магазином.
	if(icon != 'icons/obj/weapons/ammo.dmi' && icon != CE_AMMO_ICON)
		return
	var/state = "[icon_state]_mark"
	if(!ce_ammo_sprite_exists(state))
		return
	var/mark_color = ce_get_mark_color()
	if(!mark_color)
		return
	return ce_make_ammo_tint(CE_AMMO_ICON, state, mark_color)


/// Цвет метки: у верхнего патрона, который пойдёт в ствол первым. У пустого магазина у патрона,
/// которым он снаряжается.
/obj/item/ammo_magazine/proc/ce_get_mark_color()
	if(length(stored_ammo))
		var/obj/item/ammo_casing/top = stored_ammo[length(stored_ammo)]
		return top.ce_ammo_color
	var/obj/item/ammo_casing/nominal = ammo_type
	return initial(nominal.ce_ammo_color)


/obj/item/ammobox
	/// The round type of the box that the box shows. It stays when the box becomes empty.
	var/obj/item/ammo_casing/ce_shown_ammo_type


/obj/item/ammobox/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL || QDELETED(src))
		return
	update_icon()


/obj/item/ammobox/insert_casing(obj/item/ammo_casing/ammo_casing, mob/user, skip_check = FALSE)
	. = ..()
	if(.)
		update_icon()


/obj/item/ammobox/remove_casing(mob/user, atom/target)
	. = ..()
	update_icon()


/obj/item/ammobox/on_update_icon()
	if(ammo_type)
		ce_shown_ammo_type = ammo_type
	var/box_sprite = ce_get_box_sprite()
	var/state = ce_get_box_state(box_sprite)
	if(!state)
		icon = initial(icon)
		icon_state = initial(icon_state)
		return
	icon_state = state
	var/tint_sprite = initial(ce_shown_ammo_type.ce_box_tint_sprite)
	// An empty box has no rounds, so it gets no layer.
	if(!ammo_count || !tint_sprite)
		icon = CE_AMMO_BOXES_ICON
		return
	icon = ce_get_tinted_box_icon(box_sprite, tint_sprite, initial(ce_shown_ammo_type.ce_ammo_color))


/// Коробка содержимого без кадра наполнения. null: своей коробки нет, у стреляных гильз тоже.
/obj/item/ammobox/proc/ce_get_box_sprite()
	if(!ce_shown_ammo_type || (ammo_count && ammo_spent))
		return
	return initial(ce_shown_ammo_type.ce_box_sprite)


/**
 * Состояние коробки `box_sprite` в `ce_ammo_boxes.dmi` с кадром наполнения или null, если такой
 * Коробки нет. Кадр берётся наименьший из тех, что не меньше доли `ammo_count / ammo_max` от полного.
 * У непустой коробки он не нулевой. Пустая коробка 12g одна на все типы (`0_12g`), поэтому пустой
 * Берётся нулевой кадр самой коробки, а если его нет, то нулевой кадр её калибра.
 */
/obj/item/ammobox/proc/ce_get_box_state(box_sprite)
	if(!box_sprite)
		return
	var/list/frames = ce_get_ammo_box_frames(box_sprite)
	if(!length(frames))
		return
	if(!ammo_count)
		if(frames[1] == 0)
			return "0_[box_sprite]"
		var/caliber_sprite = copytext(box_sprite, 1, findtext(box_sprite, "_"))
		var/list/caliber_frames = ce_get_ammo_box_frames(caliber_sprite)
		if(length(caliber_frames) && caliber_frames[1] == 0)
			return "0_[caliber_sprite]"
		return
	var/needed = min(ammo_count / ammo_max, 1) * frames[length(frames)]
	for(var/frame in frames)
		if(frame > 0 && frame >= needed)
			return "[frame]_[box_sprite]"


/// Есть ли в `ce_ammo.dmi` такое состояние.
/proc/ce_ammo_sprite_exists(state)
	var/static/list/states
	if(!states)
		states = list()
		for(var/existing in icon_states(CE_AMMO_ICON))
			states[existing] = TRUE
	return !!states[state]


/// Кадры наполнения коробки в `ce_ammo_boxes.dmi` по возрастанию: 0, 25, 50, 100 у "10mm_fmj".
/proc/ce_get_ammo_box_frames(box_sprite)
	RETURN_TYPE(/list)
	var/static/list/frames_by_sprite
	if(!frames_by_sprite)
		frames_by_sprite = list()
		for(var/state in icon_states(CE_AMMO_BOXES_ICON))
			var/split = findtext(state, "_")
			var/state_sprite = copytext(state, split + 1)
			LAZYADD(frames_by_sprite[state_sprite], text2num(copytext(state, 1, split)))
		for(var/state_sprite in frames_by_sprite)
			sortTim(frames_by_sprite[state_sprite], GLOBAL_PROC_REF(cmp_numeric_asc))
	return frames_by_sprite[box_sprite]


/**
 * The loaded frames of the box `box_sprite`, each with its frame of the layer `tint_sprite` in the
 * color `tint_color`. The frames keep the state names of `box_sprite`, so `ce_get_box_state()` finds
 * them. The proc makes the icon one time for each set of arguments and keeps it as a cache file.
 */
/proc/ce_get_tinted_box_icon(box_sprite, tint_sprite, tint_color)
	var/static/list/icons_by_key = list()
	var/key = "[box_sprite]:[tint_sprite]:[tint_color]"
	if(icons_by_key[key])
		return icons_by_key[key]
	var/list/tint_frames = ce_get_ammo_box_frames(tint_sprite) || list()
	var/icon/result = new /icon()
	for(var/frame in ce_get_ammo_box_frames(box_sprite))
		if(!frame)
			continue
		var/icon/frame_icon = icon(CE_AMMO_BOXES_ICON, "[frame]_[box_sprite]")
		if(frame in tint_frames)
			var/icon/tint = icon(CE_AMMO_BOXES_ICON, "[frame]_[tint_sprite]")
			tint.Blend(tint_color, ICON_MULTIPLY)
			frame_icon.Blend(tint, ICON_OVERLAY)
		result.Insert(frame_icon, "[frame]_[box_sprite]")
	var/cached_icon = fcopy_rsc(result)
	icons_by_key[key] = cached_icon
	return cached_icon


/// Слой спрайта патрона в цвет типа.
/proc/ce_make_ammo_tint(icon_file, state, tint_color)
	RETURN_TYPE(/image)
	var/image/tint = image(icon_file, state)
	tint.color = tint_color
	return tint
