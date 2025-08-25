/datum/category_item/player_setup_item/cybernetics/proc/draw_bug_content(user, list/input_list)
	draw_main_buttons(input_list)
	input_list += "Критическая ошибка. Интерфейс не отображается. Обратитесь к разработчикам"
	var/icon/bug_icon = icon('mods/cybernetics/icons/critical_bug.jpg', "no name")
	send_rsc(user, bug_icon, "bug.png")
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
	</style>
	<div class='limb-container'>
		<img class='limb-image' src='bug.png' width='400' height='640'
			style='left: -550px; top: 20px;' </a>
	</div>
	"}
