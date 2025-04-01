/*ВНИЗУ РАБОЧЕЕ, НЕ ТРОГАТЬ
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
*/
