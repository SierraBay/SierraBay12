/datum/category_item/player_setup_item/cybernetics/proc/draw_bug_content(list/input_list)
	draw_main_buttons(input_list)
	input_list += "По каким-то воистину волшебным причинам, ваш интерфейс не отобразился. Передайте разработчику алгоритм действий и попробуйте перезайти."
	var/icon/bug_icon = icon('mods/cybernetics/icons/critical_bug.dmi', "no name")
	input_list += {"<br /><div class="statusDisplay" style="text-align:center"><img src="augments_background.png" width="400" height="640"></div>"}
