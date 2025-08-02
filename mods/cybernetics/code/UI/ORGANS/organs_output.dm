#include "organs_chooses.dm"
#include "organs_description.dm"
#include "organs_spawn.dm"

//Рисует УИ внутренних органов
/datum/category_item/player_setup_item/cybernetics/proc/draw_organs_content(mob/user, list/input_list)
	draw_main_buttons(input_list)
	var/icon/background_icon = icon('mods/cybernetics/icons/organs_mode.png', "no name")
	send_rsc(user, background_icon, "organs.png")

	input_list += {"
	<style>
		.limb-container {
			position: relative;
			width: 400px;
			height: 640px;
			margin: 0 auto;
		}
		.limb-image {
			position: absolute;
			top: 0;
			left: 0;
			z-index: 1;
		}
		.limb-button {
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
		.limb-button.selected {
			background: green;
			opacity: 0.7;
		}
		.limb-button:hover {
			opacity: 0.9;
			transform: scale(1.1);
		}
		.limb-button.unavailable {
			background: #AA0000;
			opacity: 0.7;
		}
		.limb-button.unavailable:hover {
			background: #CC0000;
		}
	</style>
	<div class='limb-container'>
		<img class='limb-image' src='organs.png' width='400' height='640'
			style='left: -550px; top: 20px;'>
	"}

	var/list/organs = list(
		BP_EYES =	list("x" = -480, "y" = 75,  "title" = "Глаза"),
		BP_LUNGS =   list("x" = -210, "y" = 127, "title" = "Лёгкие"),
		BP_HEART =   list("x" = -180, "y" = 160, "title" = "Сердце"),
		BP_KIDNEYS = list("x" = -150, "y" = 193, "title" = "Почки"),
		BP_LIVER =   list("x" = -230, "y" = 260, "title" = "Печень"),
		BP_STOMACH = list("x" = -500, "y" = 260, "title" = "Желудок")
	)

	for(var/organ in organs)
		var/is_selected = (choosed_organ_slot == organ)
		var/organ_choose_type = pref.organ_list[organ]
		var/singleton/cyber_choose/choose_prototype = GET_SINGLETON(text2path(organ_choose_type))
		var/is_available = choose_prototype? choose_prototype.check_avaibility(pref) : FALSE
		if(organ_choose_type == "Пусто")
			is_available = TRUE
		var/extra_class = !is_available ? "unavailable" : ""

		input_list += "<a class='limb-button[is_selected ? " selected" : ""] [extra_class]' \
					 href='?src=\ref[src];organ=[organ]' \
					 style='left: [organs[organ]["x"]]px; top: [organs[organ]["y"]]px;'></a>"

	input_list += "</div>"
	draw_choosed_organ_desc(user, input_list)
	draw_organ_chooses(user, input_list)

/datum/category_item/player_setup_item/cybernetics/proc/organ_button_pressed(mob/user, list/href_list)
	choosed_organ_slot = href_list["organ"]

/datum/category_item/player_setup_item/cybernetics/proc/organ_select_button_pressed(mob/user, list/href_list)
	pref.organ_list[choosed_organ_slot] = href_list["select_organ"]
