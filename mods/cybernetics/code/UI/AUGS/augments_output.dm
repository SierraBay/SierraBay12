#include "augments_chooses.dm"
#include "augments_descriptions.dm"
#include "augments_spawn.dm"

//Рисует УИ протезов и конечностей
/datum/category_item/player_setup_item/cybernetics/proc/draw_augments_content(mob/user, list/input_list)
	draw_main_buttons(input_list)
	var/icon/background_icon = icon('mods/cybernetics/icons/limbs_mode.png', "no name")
	send_rsc(user, background_icon, "augments_background.png")

	input_list += {"
	<style>
		.augment-container {
			position: relative;
			width: 400px;
			height: 640px;
			margin: 0 auto;
		}
		.augment-image {
			position: absolute;
			top: 0;
			left: 0;
			z-index: 1;
		}
		.augment-button {
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
		.augment-button.selected {
			background: green;
			opacity: 0.7;
		}
		.augment-button:hover {
			opacity: 0.9;
			transform: scale(1.1);
		}
		.augment-button.unavailable {
			background: #AA0000;
			opacity: 0.7;
		}
		.augment-button.unavailable:hover {
			background: #CC0000;
		}
	</style>
	<div class='augment-container'>
		<img class='augment-image' src='augments_background.png' width='400' height='640'
			style='left: -550px; top: 20px;'>
	"}

	var/list/augments = list(
		BP_HEAD =   list("x" = -370, "y" = 40,  "title" = "Голова"),
		BP_R_ARM =  list("x" = -500, "y" = 210, "title" = "Правая рука"),
		BP_R_HAND = list("x" = -500, "y" = 340, "title" = "Правая кисть"),
		BP_L_ARM =  list("x" = -240, "y" = 210, "title" = "Левая рука"),
		BP_L_HAND = list("x" = -240, "y" = 340, "title" = "Левая кисть"),
		BP_R_LEG =  list("x" = -500, "y" = 460, "title" = "Правая нога"),
		BP_R_FOOT = list("x" = -500, "y" = 580, "title" = "Правая стопа"),
		BP_L_LEG =  list("x" = -240, "y" = 460, "title" = "Левая нога"),
		BP_L_FOOT = list("x" = -240, "y" = 580, "title" = "Левая стопа"),
		BP_CHEST =  list("x" = -370, "y" = 170, "title" = "Грудь"),
		BP_GROIN =  list("x" = -370, "y" = 270, "title" = "Пах")
	)

	for(var/augment in augments)
		var/is_selected = (choosed_augment_slot == augment)
		var/augment_choose_type = pref.augments_list[augment]
		var/singleton/cyber_choose/choose_prototype = GET_SINGLETON(text2path(augment_choose_type))
		var/is_available = choose_prototype? choose_prototype.check_avaibility(pref) : FALSE
		if(augment_choose_type == "Пусто")
			is_available = TRUE
		var/extra_class = !is_available ? "unavailable" : ""

		input_list += "<a class='augment-button[is_selected ? " selected" : ""] [extra_class]' \
					 href='?src=\ref[src];augment=[augment]' \
					 style='left: [augments[augment]["x"]]px; top: [augments[augment]["y"]]px;'></a>"

	input_list += "</div>"
	draw_choosed_augment_desc(user, input_list)
	draw_augments_chooses(user, input_list)


/datum/category_item/player_setup_item/cybernetics/proc/augment_button_pressed(mob/user, list/href_list)
	choosed_augment_slot = href_list["augment"]

/datum/category_item/player_setup_item/cybernetics/proc/augment_select_button_pressed(mob/user, list/href_list)
	pref.augments_list[choosed_augment_slot] = href_list["select_augment"]
