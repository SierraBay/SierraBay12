#include "limbs_chooses.dm"
#include "limbs_description.dm"
#include "limbs_spawn.dm"

//Рисует УИ протезов и конечностей
/datum/category_item/player_setup_item/cybernetics/proc/draw_limbs_content(mob/user, list/input_list)
	draw_main_buttons(input_list)
	//Задник человечка
	var/icon/background_icon = icon('mods/cybernetics/icons/limbs_mode.png', "no name")
	send_rsc(user, background_icon, "augments_background.png")

	//Дальше рисуем интерактивные кнопачки поверх задника
	// Создаем HTML-контейнер с абсолютным позиционированием
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
	</style>
	<div class='limb-container'>
		<img class='limb-image' src='augments_background.png' width='400' height='640'
			style='left: -550px; top: 20px;' </a>
		<!-- Кнопка головы -->
		<a class='limb-button[choosed_limb_slot == "[BP_HEAD]" ? " selected" : ""]'
			href='?src=\ref[src];limb=[BP_HEAD]'
			style='left: -370px; top: 40px;'
			title='Голова'></a>

		<!-- Кнопка для правой руки -->
		<a class='limb-button[choosed_limb_slot == "[BP_R_ARM]" ? " selected" : ""]'
			href='?src=\ref[src];limb=[BP_R_ARM]'
			style='left: -500px; top: 210px;'
			title='Правая рука'></a>
		<!-- Кнопка для правой кисти -->
		<a class='limb-button[choosed_limb_slot == "[BP_R_HAND]" ? " selected" : ""]'
			href='?src=\ref[src];limb=[BP_R_HAND]'
			style='left: -500px; top: 340px;'
			title='Правая кисть'></a>

		<!-- Кнопка левой руки -->
		<a class='limb-button[choosed_limb_slot == "[BP_L_ARM]" ? " selected" : ""]'
			href='?src=\ref[src];limb=[BP_L_ARM]'
			style='left: -240px; top: 210px;'
			title='Левая рука'></a>
		<!-- Кнопка для левой кисти -->
		<a class='limb-button[choosed_limb_slot == "[BP_L_HAND]" ? " selected" : ""]'
			href='?src=\ref[src];limb=[BP_L_HAND]'
			style='left: -240px; top: 340px;'
			title='Левая кисть'></a>

		<!-- Кнопка для правой ноги -->
		<a class='limb-button[choosed_limb_slot == "[BP_R_LEG]" ? " selected" : ""]'
			href='?src=\ref[src];limb=[BP_R_LEG]'
			style='left: -500px; top: 460px;'
			title='Правая нога'></a>
		<!-- Кнопка для правой стопы -->
		<a class='limb-button[choosed_limb_slot == "[BP_R_FOOT]" ? " selected" : ""]'
			href='?src=\ref[src];limb=[BP_R_FOOT]'
			style='left: -500px; top: 580px;'
			title='Правая стопа'></a>

		<!-- Кнопка для левой ноги -->
		 <a class='limb-button[choosed_limb_slot == "[BP_L_LEG]" ? " selected" : ""]'
			href='?src=\ref[src];limb=[BP_L_LEG]'
			style='left: -240px; top: 460px;'
			title='Левая нога'></a>
		<!-- Кнопка для левой стопы -->
		 <a class='limb-button[choosed_limb_slot == "[BP_L_FOOT]" ? " selected" : ""]'
			href='?src=\ref[src];limb=[BP_L_FOOT]'
			style='left: -240px; top: 580px;'
			title='Левая стопа'></a>

		<!-- Кнопка для груди -->
		<a class='limb-button[choosed_limb_slot == "[BP_CHEST]" ? " selected" : ""]'
			href='?src=\ref[src];limb=[BP_CHEST]'
			style='left: -370px; top: 170px;'
			title='Грудь'></a>

		<!-- Кнопка для паха -->
		 <a class='limb-button[choosed_limb_slot == "[BP_GROIN]" ? " selected" : ""]'
			href='?src=\ref[src];limb=[BP_GROIN]'
			style='left: -370px; top: 270px;'
			title='Пах'></a>
	</div>
	"}
	draw_choosed_limb_desc(user, input_list)
	draw_limbs_chooses(user, input_list)


//Какую-то кнопушку нажааали
/datum/category_item/player_setup_item/cybernetics/proc/limbs_button_pressed(mob/user, list/href_list)
	choosed_limb_slot = href_list["limb"]

/datum/category_item/player_setup_item/cybernetics/proc/limb_select_button_pressed(mob/user, list/href_list)
	pref.limb_list[choosed_limb_slot] = href_list["select_limb"]
