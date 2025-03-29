/atom
	var/overdrive_layer

/atom/reset_plane_and_layer()
	plane = initial(plane)
	if(overdrive_layer)
		layer = overdrive_layer
	else
		layer = initial(layer)

/obj/overlay/water_mask

/mob/living
	///Оверлей для воды с планеты Титан
	var/image/water_overlay

//Используется ATOM_ICON_CACHE_PROTECTED чтоб никто без ведома кода воды не снимал оверлей
//Без этого оверлей спадает если встать в воде или поднять предмет в ней
/mob/living/proc/setup_water_overlay(image/new_water_overlay)
	if(!new_water_overlay)
		return
	if(water_overlay)
		CutOverlays(water_overlay)
	water_overlay = new_water_overlay
	AddOverlays(water_overlay, cache_target = ATOM_ICON_CACHE_PROTECTED)

/mob/living/proc/desetup_water_overlay()
	if(water_overlay)
		CutOverlays(water_overlay, cache_target = ATOM_ICON_CACHE_PROTECTED)
	water_overlay = null

/turf/simulated/floor/exoplanet/titan_water/proc/add_water_mask_to_living(mob/input_mob, mask_icon_state = "middle_deep", called_by_lying = FALSE)
	var/icon/mask_icon = icon('mods/new_planets/icons/titan_water.dmi', mask_icon_state)
	//Хуманы и прочие нецельные мобики(Мехи, адхеранты, скреллы и прочие обьекты состоящие из оверлеев)
	//довольно сложны для обработки (я хз как заставить фильтры работать с ними адекватно)
	//От чего все эти существа будут прятаться под воду, а уже поверх воды будет вылезать копия их
	//Спрайта подвергнутая изменениям.
	if(ishuman(input_mob) || ismech(input_mob))
		var/mob/living/mobik = input_mob
		//Снос оверлеев
		if(mobik.lying)
			mobik.desetup_water_overlay() //Если чувачок лежит - пусть лежит дальше
			return
		input_mob.overdrive_layer = 0.1 //Суём моба под всё что только можно
		input_mob.reset_plane_and_layer()
		var/image/draw_swimmer = new
		draw_swimmer.appearance = input_mob
		draw_swimmer.layer = WATER_OVERLAY
		draw_swimmer.appearance_flags = KEEP_TOGETHER
		if(called_by_lying)
			draw_swimmer.SetTransform(rotation = 0)
		draw_swimmer.filters = filter(type = "alpha", icon = mask_icon, x = 0, y = 8)
		mobik.setup_water_overlay(draw_swimmer)
	//Все прочие простые мобики будут просто изменяться фильтром
	else
		input_mob.filters = filter(type="alpha", icon = mask_icon)

/turf/simulated/floor/exoplanet/titan_water/proc/remove_water_mask_from_living(mob/input_mob)
	if(ishuman(input_mob) || ismech(input_mob))
		var/mob/living/living = input_mob
		living.overdrive_layer = null
		living.reset_plane_and_layer()
		living.desetup_water_overlay()
		return
	else
		input_mob.filters = null

/*
//1. Предмет начинает почучуть двигаться вверх вниз имитируя воду
*/
/turf/simulated/floor/exoplanet/titan_water/proc/add_water_mask_to_item(atom/movable/input_item)
	if(isitem(input_item))
		var/X,Y
		X = 60*rand() - 30
		Y = 60*rand() - 30
		input_item.filters = filter(type="wave", x = X, y = Y)

/turf/simulated/floor/exoplanet/titan_water/proc/remove_water_mask_from_to_item(atom/movable/input_item)
	input_item.filters = null





/*ВНИЗУ РАБОЧЕЕ, НЕ ТРОГАТЬ
/turf/simulated/floor/exoplanet/titan_water/proc/add_water_mask_to_living(mob/living/carbon/human/user, mask_icon_state = "middle_deep")
	var/image/draw_swimmer = new
	draw_swimmer.appearance = user
	draw_swimmer.layer = 12
	draw_swimmer.plane = FLOAT_PLANE
	draw_swimmer.appearance_flags = KEEP_TOGETHER
	var/icon/mask_icon = icon('mods/anomaly/icons/titan_water.dmi', mask_icon_state)
	draw_swimmer.filters = filter(type = "alpha", icon = mask_icon, x = 0, y = 0)
	user.overlays += draw_swimmer
*/
