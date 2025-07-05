#include "_UI_output.dm"
#include "_UI_process.dm" //Здесь мы обрабатываем ввод пользователя
#include "bug_ui.dm" 	//Здесь мы выводим ошибочное сообщение
#include "main_buttons_ui.dm" //Это подфункция которая рисует 3 верхние кнопки
#include "limbs_ui.dm" //Здесь мы выводим меню в режиме Протезы конечностей
#include "organs_ui.dm" //Здесь мы выводим меню в режиме Внутренние органы
#include "implants_ui.dm" //Здесь мы выводим меню в режиме Импланты

/datum/category_group/player_setup_category/cybernetics
	name = "Кибернетика"
	sort_order = 10
	category_item_type = /datum/category_item/player_setup_item/cybernetics

/datum/category_item/player_setup_item/cybernetics
	name = "Loadout"
	sort_order = 1
	var/current_tab = "Протезирование"
