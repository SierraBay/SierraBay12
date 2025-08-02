#include "limbs_chooses.dm"
#include "limbs_description.dm"
#include "limbs_spawn.dm"

//Рисует УИ протезов и конечностей
/datum/category_item/player_setup_item/cybernetics/proc/draw_limbs_content(mob/user, list/input_list)
	draw_main_buttons(input_list)
	var/icon/background_icon = icon('mods/cybernetics/icons/limbs_mode.png', "no name")
	send_rsc(user, background_icon, "augments_background.png")

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
		.limb-button:hover {
			opacity: 0.9;
			transform: scale(1.1);
		}
		.limb-button.selected {
			background: green;
			opacity: 0.7;
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
	<img class='limb-image' src='augments_background.png' width='400' height='640' style='left: -550px; top: 20px;'>
	<!-- Кнопка выбора -->
	<a class='limb-button'
		href='?src=\ref[src];set_limbs_corporation=[TRUE]'
		style='
			left: -500px;
			top: -15px;
			width: 280px;
			height: 30px;
		'
		title='При нажатии этой кнопки, вы сможете куда проще выставить все конечности определённой корпорации.'>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Выбрать корпорацию
	</a>
	"}

	// Координаты хардпоинтов
	var/list/cords = list(
		BP_HEAD = list("x" = -370, "y" = 40, "title" = "Голова"),
		BP_R_ARM = list("x" = -500, "y" = 210, "title" = "Правая рука"),
		BP_R_HAND = list("x" = -500, "y" = 340, "title" = "Правая кисть"),
		BP_L_ARM = list("x" = -240, "y" = 210, "title" = "Левая рука"),
		BP_L_HAND = list("x" = -240, "y" = 340, "title" = "Левая кисть"),
		BP_R_LEG = list("x" = -500, "y" = 460, "title" = "Правая нога"),
		BP_R_FOOT = list("x" = -500, "y" = 580, "title" = "Правая стопа"),
		BP_L_LEG = list("x" = -240, "y" = 460, "title" = "Левая нога"),
		BP_L_FOOT = list("x" = -240, "y" = 580, "title" = "Левая стопа"),
		BP_CHEST = list("x" = -370, "y" = 170, "title" = "Грудь"),
		BP_GROIN = list("x" = -370, "y" = 270, "title" = "Пах")
	)

	for(var/hardpoint in cords)
		var/is_selected = (choosed_limb_slot == hardpoint)
		var/limb_choose_type = pref.limb_list[hardpoint]
		var/singleton/cyber_choose/choose_prototype = GET_SINGLETON(text2path(limb_choose_type))
		var/is_available = choose_prototype? choose_prototype.check_avaibility(pref) : FALSE
		if(limb_choose_type == "Пусто")
			is_available = TRUE
		var/extra_class = !is_available ? "unavailable" : ""

		input_list += "<a class='limb-button[is_selected ? " selected" : ""] [extra_class]' \
					 href='?src=\ref[src];limb=[hardpoint]' \
					 style='left: [cords[hardpoint]["x"]]px; top: [cords[hardpoint]["y"]]px;'></a>"

	input_list += "</div>"
	draw_choosed_limb_desc(user, input_list)
	draw_limbs_chooses(user, input_list)


//Какую-то кнопушку нажааали
/datum/category_item/player_setup_item/cybernetics/proc/limbs_button_pressed(mob/user, list/href_list)
	choosed_limb_slot = href_list["limb"]

/datum/category_item/player_setup_item/cybernetics/proc/limb_select_button_pressed(mob/user, list/href_list)
	pref.limb_list[choosed_limb_slot] = href_list["select_limb"]
