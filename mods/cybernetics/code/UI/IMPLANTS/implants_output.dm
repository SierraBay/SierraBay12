#include "implants_chooses.dm"
#include "implants_description.dm"
#include "implants_spawn.dm"

/datum/category_item/player_setup_item/cybernetics/proc/draw_implants_content(mob/user, list/input_list)
	draw_main_buttons(input_list)
	var/icon/background_icon = icon('mods/cybernetics/icons/implants_mode.png', "no name")
	send_rsc(user, background_icon, "implants_background.png")

	//Дальше рисуем интерактивные кнопачки поверх задника
	input_list += {"
	<style>
		.implants-container {
			position: relative;
			width: 400px;
			height: 640px;
			margin: 0 auto;
		}
		.implants-image {
			position: absolute;
			top: 0;
			left: 0;
			z-index: 1;
		}
		.implants-button {
			position: absolute;
			z-index: 2;
			background: transparent;
			border: none;
			width: 30px;
			height: 30px;
			display: flex;
			cursor: pointer;
			transition: all 0.3s ease;
			border-radius: 3px;
		}
	</style>
	<div class='implants-container'>
		<img class='implants-image' src='implants_background.png' width='400' height='640'
			style='left: -550px; top: 20px;' </a>
	</div>
	"}
	draw_choosed_implant_desc(user, input_list)
	draw_implants_chooses(user, input_list)

/datum/category_item/player_setup_item/cybernetics/proc/implant_button_pressed(mob/user, list/href_list)
	pref.choosed_implant_prototype = href_list["implant"]

/datum/category_item/player_setup_item/cybernetics/proc/implant_sumbition_pressed(mob/user, list/href_list)
	var/singleton_type = href_list["submit_implant"]
	var/singleton = GET_SINGLETON(text2path(singleton_type))
	if(singleton in pref.implants_list)
		LAZYREMOVE(pref.implants_list, singleton)
	else
		LAZYADD(pref.implants_list, singleton)
