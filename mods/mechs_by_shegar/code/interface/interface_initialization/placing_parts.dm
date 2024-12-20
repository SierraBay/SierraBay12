/obj/screen/part_button
	var/obj/item/mech_component/memored_component

//Жмяк на кнопушку
/obj/screen/part_button/Click()
	to_chat(usr, "Current HP: [memored_component.total_damage ], Max HP: [memored_component.max_damage]")
	to_chat(usr, "Current unrepaible damage: [memored_component.unrepairable_damage]")
	to_chat(usr, "Front damage mod: [memored_component.front_modificator_damage], Back damage mod:[memored_component.back_modificator_damage]")
	to_chat(usr, "Material for repair: [memored_component.req_material]")

/mob/living/exosuit/proc/Initialize_menu_parts()
	var/number = 1
	for(var/obj/item/mech_component/I in parts_list)
		var/obj/screen/part_button/part_button = new /obj/screen/part_button(src) //Для отдельного спрайта части
		var/obj/screen/second_part_button = new /obj/screen(src)
		part_button.memored_component = I
		part_button.layer = 3
		//part_button.memored_component = I
		//голова
		if(number == 1)//head
			part_button.screen_loc = "CENTER-1.5,CENTER+0.5"
			second_part_button.screen_loc = "CENTER+0.5,CENTER+0.2"
			second_part_button.layer = 5

		//Тело
		else if(number == 2)//body
			part_button.screen_loc = "CENTER+2.5,CENTER+0.9"
			second_part_button.screen_loc = "CENTER+0.5,CENTER+0.2"
			second_part_button.layer = MECH_COCKPIT_LAYER

		//Руки
		else if(number == 3)//arms
			part_button.screen_loc = "CENTER+2.5,CENTER-0.6"
			second_part_button.screen_loc = "CENTER+0.5,CENTER+0.2"
			second_part_button.layer = MECH_ARM_LAYER

		//Ноги
		else if(number == 4)//legs
			part_button.screen_loc = "CENTER-1.5,CENTER-0.2"
			second_part_button.screen_loc = "CENTER+0.5,CENTER+0.2"
			second_part_button.layer = MECH_LEG_LAYER

		part_button.icon = 'icons/mecha/mech_parts.dmi'
		second_part_button.icon = 'icons/mecha/mech_parts.dmi'
		part_button.icon_state = I.icon_state
		second_part_button.icon_state = I.icon_state
		menu_hud_elements |= part_button
		menu_hud_elements |= second_part_button
		number++
