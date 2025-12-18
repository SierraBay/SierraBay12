/*
Недоделка
/mob/living/exosuit
	var/list/displays_list = list()

/obj/screen/exosuit/part_display
	var/obj/item/mech_component/captured_component

/mob/living/exosuit/proc/Initialize_parts_status()
	var/number = 1
	for(var/obj/item/mech_component/I in parts_list)
		var/obj/screen/exosuit/part_display/part_display = new /obj/screen(src) //Для текста
		part_display.maptext = "[I.current_hp]/[I.max_damage]<br>UNR:[I.unrepairable_damage]<br>F:[I.front_modificator_damage] B:[I.back_modificator_damage]"
		part_display.captured_component = I
		part_display.maptext_width = 64
		part_display.icon_state = "blank"
		if(number == 1)//head
			part_display.name = "head_display"
			part_display.screen_loc = "CENTER-2.45,CENTER+1.1"
		else if(number == 2)//body
			part_display.name = "body_display"
			part_display.screen_loc = "CENTER-2.45,CENTER-0.4"
		else if(number == 3)//arms
			part_display.name = "arms_display"
			part_display.screen_loc = "CENTER+3.8,CENTER-0.4"
		else if(number == 4)//legs
			part_display.name = "legs_display"
			part_display.screen_loc = "CENTER+3.8,CENTER+1.1"
		menu_hud_elements |= part_display
		displays_list |= part_display
		number++

/mob/living/exosuit/proc/update_displays_data()
	for(var/obj/screen/exosuit/part_display/picked in displays_list)
		picked.maptext = "[picked.captured_component.current_hp]/[picked.captured_component.max_damage]<br>UNR:[picked.captured_component.unrepairable_damage]<br>F:[picked.captured_component.front_modificator_damage] B:[picked.captured_component.back_modificator_damage]"
*/
