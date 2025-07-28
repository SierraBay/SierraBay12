///Рисует возможные аугменты для выбранной конечности
/datum/category_item/player_setup_item/cybernetics/proc/draw_implants_chooses(mob/user, list/input_list)
	var/list/output = list()
	var/y_add = -600
	var/x_add = 1000
	var/y_changer_counter = 0

	output += {"
	<style>
		.implant-container {
			position: relative;
			width: 100%;
			height: 100%;
		}
		.implant-choose_button {
			position: absolute;
			z-index: 2;
			background: #3A75C4;
			border: none;
			width: 200px;
			height: 25px;
			cursor: pointer;
			display: flex;
			align-items: center;
			justify-content: center;
			color: white;
			font-size: 12px;
			text-align: center;
			text-decoration: none;
			transition: all 0.3s ease;
			border-radius: 3px;
		}
		.implant-choose_button:hover {
			opacity: 0.9;
			transform: scale(1.1);
		}
		.implant-choose_button.selected {
			background: #0006AA;
			box-shadow: 0 0 5px rgba(0,255,0,0.7);
		}
		.implant-choose_button.sumbited {
			background: #00AA00;
			box-shadow: 0 0 5px rgba(0,255,0,0.7);
		}
		.implant-choose_button-text {
			pointer-events: none;
			text-shadow: 1px 1px 1px black;
		}
	</style>
	"}

	output += "<div class='implant-container'>"

	// Кнопки имплантов
	for(var/implant_data in subtypesof(/singleton/cyber_choose/implant))
		var/singleton/cyber_choose/choose_prototype = GET_SINGLETON(implant_data)
		var/is_submitted = (choose_prototype in pref.implants_list) // Проверяем наличие в списке
		var/is_selected = (choose_prototype == pref.choosed_implant_prototype) // Проверяем текущий выбор

		output += "<a class='implant-choose_button[is_selected ? " selected" : ""][is_submitted ? " sumbited" : ""]' "
		output += "href='?src=\ref[src];implant=[choose_prototype.type]' "
		output += "style='left: [x_add]px; top: [y_add]px;' "
		output += "title='[html_encode(choose_prototype.aug_description)]'>"
		output += "<span class='implant-choose_button-text'>[html_encode(choose_prototype.augment_name)]</span>"
		output += "</a>"

		if(x_add == 1230)
			x_add = 1000
		else
			x_add = 1230

		//Мини механизм что обеспечит размещение столба шириною в 2 кнопки
		if(y_changer_counter == 1)
			y_changer_counter = 0
			y_add += 40
		else
			y_changer_counter = 1

	output += "</div>"
	input_list += output
