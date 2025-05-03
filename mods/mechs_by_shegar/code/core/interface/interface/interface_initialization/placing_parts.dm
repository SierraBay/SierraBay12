/datum/exosuit_holder
	var/list/parts = list() // Список для хранения кнопок

/obj/screen/part_button
	//Часть меха с которой связана кнопка. Используется для чтения данных.
	var/obj/item/mech_component/memored_component

/obj/item/mech_component
	//Кнопка использующеся в меню меха. Ссылка требуется для его обновления из-за событий.
	var/obj/screen/part_button/memored_screen_obj

/obj/screen/part_button/MouseEntered(location, control, params)
	. = ..()
	var/output_message = "Current HP: [memored_component.current_hp], Max HP: [memored_component.max_hp] <br> Current unrepaible damage: [memored_component.unrepairable_damage] <br>Heat capacity: [memored_component.max_heat] <br> Heat cooling: [memored_component.heat_cooling] <br> Front damage mod: [memored_component.front_modificator_damage], Back damage mod:[memored_component.back_modificator_damage] <br> Material for repair: [memored_component.req_material]"
	openToolTip(usr, src, params, title = output_message)

/obj/screen/part_button/MouseExited(location, control, params)
	. = ..()
	closeToolTip(usr)

/mob/living/exosuit/proc/Initialize_menu_parts()
	if(!exosuit_data)
		exosuit_data = new /datum/exosuit_holder(src)
	//Спавн состовляющих для общего спрайта меха
	var/list/main_image_parts = list(
		"head" = list("part" = head, "screen_loc" = "CENTER+0.8,CENTER-0.3"),
		"body" = list("part" = body, "screen_loc" = "CENTER+0.8,CENTER-0.3"),
		"R_arm" = list("part" = R_arm, "screen_loc" = "CENTER+0.8,CENTER-0.3"),
		"L_arm" = list("part" = L_arm, "screen_loc" = "CENTER+0.8,CENTER-0.3"),
		"R_leg" = list("part" = R_leg, "screen_loc" = "CENTER+0.8,CENTER-0.3"),
		"L_leg" = list("part" = L_leg, "screen_loc" = "CENTER+0.8,CENTER-0.3")
	)
	for(var/part_name in main_image_parts)
		var/obj/item/mech_component/part = main_image_parts[part_name]["part"]
		if(part)
			var/obj/screen/button = new()
			button.icon = 'mods/mechs_by_shegar/icons/mech_parts.dmi'
			button.icon_state = part.icon_state
			button.layer = 4
			button.screen_loc = main_image_parts[part_name]["screen_loc"]

			menu_hud_elements |= button

	// Список частей меха и их координат на экране
	var/list/parts = list(
		"head" = list("part" = head, "screen_loc" = "CENTER+0.8,CENTER+0.6"),
		"body" = list("part" = body, "screen_loc" = "CENTER+0.85,CENTER-1.7"),
		"R_arm" = list("part" = R_arm, "screen_loc" = "CENTER,CENTER+0.1"),
		"L_arm" = list("part" = L_arm, "screen_loc" = "CENTER+1.7,CENTER+0.1"),
		"R_leg" = list("part" = R_leg, "screen_loc" = "CENTER,CENTER-0.5"),
		"L_leg" = list("part" = L_leg, "screen_loc" = "CENTER+1.7,CENTER-0.5")
	)

	// Создаем кнопки для каждой части меха
	for(var/part_name in parts)
		var/obj/item/mech_component/part = parts[part_name]["part"]
		if(part)
			var/obj/screen/part_button/button = new()
			button.memored_component = part
			part.memored_screen_obj = button
			button.icon = 'mods/mechs_by_shegar/icons/mech_parts.dmi'
			button.icon_state = part.icon_state
			button.name = part.name
			button.layer = 4 //
			button.screen_loc = parts[part_name]["screen_loc"]

			// Добавляем кнопку в список parts в exosuit_data
			exosuit_data.parts[part_name] = button

			menu_hud_elements |= button
