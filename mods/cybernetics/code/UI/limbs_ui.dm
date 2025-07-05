//Рисует УИ протезов и конечностей
/datum/category_item/player_setup_item/cybernetics/proc/draw_limbs_content(mob/user, list/input_list)
	draw_main_buttons(input_list)
	//Задник человечка
	var/icon/background_icon = icon('mods/cybernetics/icons/limbs_mode.dmi', "no name")
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
			cursor: pointer;
		}
	</style>
	<div class='limb-container'>
		<img class='limb-image' src='augments_background.png' width='400' height='640'>
		<!-- Кнопка правой руки -->
		<a class='limb-button'
			href='?src=\ref[src];limb=left_arm'
			style='left: 200px; top: 20px;'
			title='Голова'></a>
		<!-- Кнопка правой руки -->
		<a class='limb-button'
			href='?src=\ref[src];limb=left_arm'
			style='left: 37px; top: 150px;'
			title='Правая рука'></a>
		<!-- Кнопка для правой кисти -->
		<a class='limb-button'
			href='?src=\ref[src];limb=left_arm'
			style='left: 37px; top: 250px;'
			title='Правая кисть'></a>
		<!-- Кнопка левой руки -->
		<a class='limb-button'
			href='?src=\ref[src];limb=left_arm'
			style='left: 325px; top: 150px;'
			title='Левая рука'></a>
		<!-- Кнопка для левой кисти -->
		<a class='limb-button'
			href='?src=\ref[src];limb=left_arm'
			style='left: 325px; top: 250px;'
			title='Левая кисть'></a>
		<!-- Кнопка для правой ноги -->
		<a class='limb-button'
			href='?src=\ref[src];limb=right_leg'
			style='left: 37px; top: 400px;'
			title='Правая нога'></a>
		<!-- Кнопка для правой стопы -->
		<a class='limb-button'
			href='?src=\ref[src];limb=right_leg'
			style='left: 37px; top: 575px;'
			title='Правая стопа'></a>
		<!-- Кнопка для левой ноги -->
		<a class='limb-button'
			href='?src=\ref[src];limb=right_leg'
			style='left: 325px; top: 400px;'
			title='Левая нога'></a>
		<!-- Кнопка для левой стопы -->
		<a class='limb-button'
			href='?src=\ref[src];limb=right_leg'
			style='left: 325px; top: 575px;'
			title='Левая стопа'></a>
		<!-- Кнопка для груди -->
		<a class='limb-button'
			href='?src=\ref[src];limb=right_leg'
			style='left: 150px; top: 600px;'
			title='Грудь'></a>
		<!-- Кнопка для паха -->
		<a class='limb-button'
			href='?src=\ref[src];limb=right_leg'
			style='left: 250px; top: 600px;'
			title='Пах'></a>
	</div>
	"}
