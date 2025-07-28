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
	</style>
	<div class='limb-container'>
		<img class='limb-image' src='organs.png' width='400' height='640'
			style='left: -550px; top: 20px;' </a>

		<!-- ГЛАЗА -->
		<a class='limb-button[choosed_organ_slot == "[BP_EYES]" ? " selected" : ""]'
			href='?src=\ref[src];organ=[BP_EYES]'
			style='left: -480px; top: 75px;'
			title='Глаза'></a>

		<!-- ЛЁГКИЕ -->
		<a class='limb-button[choosed_organ_slot == "[BP_LUNGS]" ? " selected" : ""]'
			href='?src=\ref[src];organ=[BP_LUNGS]'
			style='left: -210px; top: 127px;'
			title='Лёгкие'></a>

		<!-- СЕРДЦЕ -->
		<a class='limb-button[choosed_organ_slot == "[BP_HEART]" ? " selected" : ""]'
			href='?src=\ref[src];organ=[BP_HEART]'
			style='left: -180px; top: 160px;'
			title='Сердце'></a>

		<!-- Почки -->
		<a class='limb-button[choosed_organ_slot == "[BP_KIDNEYS]" ? " selected" : ""]'
			href='?src=\ref[src];organ=[BP_KIDNEYS]'
			style='left: -150px; top: 193px;'
			title='Почки'></a>

		<!-- ПЕЧЕНЬ -->
		<a class='limb-button[choosed_organ_slot == "[BP_LIVER]" ? " selected" : ""]'
			href='?src=\ref[src];organ=[BP_LIVER]'
			style='left: -230px; top: 260px;'
			title='Печень'></a>

		<!-- ЖЕЛУДОК -->
		<a class='limb-button[choosed_organ_slot == "[BP_STOMACH]" ? " selected" : ""]'
			href='?src=\ref[src];organ=[BP_STOMACH]'
			style='left: -500px; top: 260px;'
			title='Желудок'></a>
	</div>
	"}
	draw_choosed_organ_desc(user, input_list)
	draw_organ_chooses(user, input_list)

/datum/category_item/player_setup_item/cybernetics/proc/organ_button_pressed(mob/user, list/href_list)
	choosed_organ_slot = href_list["organ"]

/datum/category_item/player_setup_item/cybernetics/proc/organ_select_button_pressed(mob/user, list/href_list)
	pref.organ_list[choosed_organ_slot] = href_list["select_organ"]
