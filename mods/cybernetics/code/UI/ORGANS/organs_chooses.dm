///Рисует возможные аугменты для выбранной конечности
//У меня где-то фундаментальная ошибка связанная с позиционированием КСС кала от чего вы можете
//Увидеть как функции augments_chooses и organ_chooses различаются в своих значениях. Почему - хз
//Как-то замаялся в сотый раз искать причину ошибки и решил просто поиграться со значениями y_add и top
//Исправите эту ошибку - будете молодцом.
/datum/category_item/player_setup_item/cybernetics/proc/draw_organ_chooses(mob/user, list/input_list)
	if(!choosed_organ_slot)
		return

	var/list/output = list()
	var/current_organ_in_slot_type = pref.organ_list[choosed_organ_slot]

	output += {"
	<style>
		.organ-scroll-container {
			position: absolute;
			width: 420px;
			height: 500px;
			left: 1080px;
			top: 200px;
			overflow-y: auto;
			border-radius: 5px;
			padding: 10px;
		}
		.organ-choose_button {
			position: relative;
			width: 350px;
			height: 30px;
			margin-bottom: 10px;
			background: #3A75C4;
			border: none;
			cursor: pointer;
			display: flex;
			align-items: center;
			justify-content: center;
			color: white;
			font-size: 13px;
			text-align: center;
			text-decoration: none;
			transition: all 0.2s ease;
			border-radius: 4px;
		}
		.organ-choose_button:hover {
			background: #5080B0;
			transform: scale(1.02);
			box-shadow: 0 0 8px rgba(58, 117, 196, 0.6);
		}
		.organ-choose_button.selected {
			background: #00AA00;
			box-shadow: 0 0 8px rgba(0, 170, 0, 0.7);
		}
		.organ-choose_button.selected:hover {
			background: #00CC00;
		}
		.organ-choose_button.unavailable {
			background: #AA0000;
			box-shadow: 0 0 8px rgba(170, 0, 0, 0.7);
		}
		.organ-choose_button.unavailable:hover {
			background: #CC0000;
		}
		.organ-choose_button-text {
			pointer-events: none;
			text-shadow: 1px 1px 2px black;
			padding: 0 10px;
			white-space: nowrap;
			overflow: hidden;
			text-overflow: ellipsis;
		}
		.organ-scroll-container::-webkit-scrollbar {
			width: 10px;
		}
		.organ-scroll-container::-webkit-scrollbar-track {
			background: rgba(0,0,0,0.1);
			border-radius: 5px;
		}
		.organ-scroll-container::-webkit-scrollbar-thumb {
			background: #3A75C4;
			border-radius: 5px;
			border: 2px solid rgba(0,0,0,0.2);
		}
		.organ-scroll-container::-webkit-scrollbar-thumb:hover {
			background: #5080B0;
		}
	</style>
	"}

	output += "<div class='organ-scroll-container'>"

	// Кнопка "Пусто"
	var/nothing_selected = (current_organ_in_slot_type == "Пусто")
	output += "<a class='organ-choose_button[nothing_selected ? " selected" : ""]' "
	output += "href='?src=\ref[src];select_organ=Пусто' "
	output += "title='Орган останется органическим'>"
	output += "<span class='organ-choose_button-text'>Пустота</span>"
	output += "</a>"

	// Кнопки органов
	for(var/organ in subtypesof(/singleton/cyber_choose/organ))
		var/singleton/cyber_choose/choose_prototype = GET_SINGLETON(organ)
		if(!(choosed_organ_slot in choose_prototype.avaible_hardpoints))
			continue

		var/is_selected = (current_organ_in_slot_type == "[organ]")
		var/is_available = choose_prototype.check_avaibility(pref)
		var/button_class = is_selected ? " selected" : ""
		if(!is_available)
			button_class += " unavailable"

		output += "<a class='organ-choose_button[button_class]' "
		output += "href='?src=\ref[src];select_organ=[choose_prototype.type]' "
		output += "title='[html_encode(choose_prototype.aug_description)]'>"
		output += "<span class='organ-choose_button-text'>[html_encode(choose_prototype.augment_name)]</span>"
		output += "</a>"

	output += "</div>"
	input_list += output
