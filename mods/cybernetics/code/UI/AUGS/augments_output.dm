#include "augments_chooses.dm"
#include "augments_descriptions.dm"
#include "augments_spawn.dm"

//Рисует УИ протезов и конечностей
/datum/category_item/player_setup_item/cybernetics/proc/draw_augemnts_content(mob/user, list/input_list)
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
	</style>
	<div class='augment-container'>
		<img class='augment-image' src='augments_background.png' width='400' height='640'
			style='left: -550px; top: 20px;' </a>
		<!-- Кнопка головы -->
		<a class='augment-button[choosed_augment_slot == "[BP_HEAD]" ? " selected" : ""]'
			href='?src=\ref[src];augment=[BP_HEAD]'
			style='left: -370px; top: 40px;'
			title='Голова'></a>

		<!-- Кнопка для правой руки -->
		<a class='augment-button[choosed_augment_slot == "[BP_R_ARM]" ? " selected" : ""]'
			href='?src=\ref[src];augment=[BP_R_ARM]'
			style='left: -500px; top: 210px;'
			title='Правая рука'></a>
		<!-- Кнопка для правой кисти -->
		<a class='augment-button[choosed_augment_slot == "[BP_R_HAND]" ? " selected" : ""]'
			href='?src=\ref[src];augment=[BP_R_HAND]'
			style='left: -500px; top: 340px;'
			title='Правая кисть'></a>

		<!-- Кнопка левой руки -->
		<a class='augment-button[choosed_augment_slot == "[BP_L_ARM]" ? " selected" : ""]'
			href='?src=\ref[src];augment=[BP_L_ARM]'
			style='left: -240px; top: 210px;'
			title='Левая рука'></a>
		<!-- Кнопка для левой кисти -->
		<a class='augment-button[choosed_augment_slot == "[BP_L_HAND]" ? " selected" : ""]'
			href='?src=\ref[src];augment=[BP_L_HAND]'
			style='left: -240px; top: 340px;'
			title='Левая кисть'></a>

		<!-- Кнопка для правой ноги -->
		<a class='augment-button[choosed_augment_slot == "[BP_R_LEG]" ? " selected" : ""]'
			href='?src=\ref[src];augment=[BP_R_LEG]'
			style='left: -500px; top: 460px;'
			title='Правая нога'></a>
		<!-- Кнопка для правой стопы -->
		<a class='augment-button[choosed_augment_slot == "[BP_R_FOOT]" ? " selected" : ""]'
			href='?src=\ref[src];augment=[BP_R_FOOT]'
			style='left: -500px; top: 580px;'
			title='Правая стопа'></a>

		<!-- Кнопка для левой ноги -->
		<a class='augment-button[choosed_augment_slot == "[BP_L_LEG]" ? " selected" : ""]'
			href='?src=\ref[src];augment=[BP_L_LEG]'
			style='left: -240px; top: 460px;'
			title='Левая нога'></a>
		<!-- Кнопка для левой стопы -->
		<a class='augment-button[choosed_augment_slot == "[BP_L_FOOT]" ? " selected" : ""]'
			href='?src=\ref[src];augment=[BP_L_FOOT]'
			style='left: -240px; top: 580px;'
			title='Левая стопа'></a>

		<!-- Кнопка для груди -->
		<a class='augment-button[choosed_augment_slot == "[BP_CHEST]" ? " selected" : ""]'
			href='?src=\ref[src];augment=[BP_CHEST]'
			style='left: -370px; top: 170px;'
			title='Грудь'></a>
		<!-- Кнопка для паха -->
		<a class='augment-button[choosed_augment_slot == "[BP_GROIN]" ? " selected" : ""]'
			href='?src=\ref[src];augment=[BP_GROIN]'
			style='left: -370px; top: 270px;'
			title='Пах'></a>
	</div>
	"}
	draw_choosed_augment_desc(user, input_list)
	draw_augments_chooses(user, input_list)


/datum/category_item/player_setup_item/cybernetics/proc/augment_button_pressed(mob/user, list/href_list)
	choosed_augment_slot = href_list["augment"]

/datum/category_item/player_setup_item/cybernetics/proc/augment_select_button_pressed(mob/user, list/href_list)
	pref.augments_list[choosed_augment_slot] = href_list["select_augment"]
