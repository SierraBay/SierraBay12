///Рисует возможные аугменты для выбранной конечности
/datum/category_item/player_setup_item/cybernetics/proc/draw_limbs_chooses(mob/user, list/input_list)
	if(!choosed_limb_slot)
		return

	var/list/output = list()
	var/current_limb_in_slot_type = pref.limb_list[choosed_limb_slot]

	output += {"
	<style>
		.limb-scroll-container {
			position: absolute;
			width: 420px;
			height: 500px;
			left: 1000px;
			top: 200px;
			overflow-y: auto;
			border-radius: 5px;
			padding: 10px;
		}
		.limb-choose_button {
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
		.limb-choose_button:hover {
			background: #5080B0;
			transform: scale(1.02);
			box-shadow: 0 0 8px rgba(58, 117, 196, 0.6);
		}
		.limb-choose_button.selected {
			background: #00AA00;
			box-shadow: 0 0 8px rgba(0, 170, 0, 0.7);
		}
		.limb-choose_button.selected:hover {
			background: #00CC00;
		}
		.limb-choose_button-text {
			pointer-events: none;
			text-shadow: 1px 1px 2px black;
			padding: 0 10px;
			white-space: nowrap;
			overflow: hidden;
			text-overflow: ellipsis;
		}
		/* Стилизация скроллбара */
		.limb-scroll-container::-webkit-scrollbar {
			width: 10px;
		}
		.limb-scroll-container::-webkit-scrollbar-track {
			background: rgba(0,0,0,0.1);
			border-radius: 5px;
		}
		.limb-scroll-container::-webkit-scrollbar-thumb {
			background: #3A75C4;
			border-radius: 5px;
			border: 2px solid rgba(0,0,0,0.2);
		}
		.limb-scroll-container::-webkit-scrollbar-thumb:hover {
			background: #5080B0;
		}
	</style>
	"}

	output += "<div class='limb-scroll-container'>"

	// Кнопка "Пусто"
	var/nothing_selected = (current_limb_in_slot_type == "Пусто")
	output += "<a class='limb-choose_button[nothing_selected ? " selected" : ""]' "
	output += "href='?src=\ref[src];select_limb=Пусто' "
	output += "title='Конечность не будет заменена протезом'>"
	output += "<span class='limb-choose_button-text'>Пустота</span>"
	output += "</a>"

	// Кнопки протезов
	for(var/limb_data in subtypesof(/singleton/cyber_choose/limb))
		var/singleton/cyber_choose/choose_prototype = GET_SINGLETON(limb_data)
		if(!(choosed_limb_slot in choose_prototype.avaible_hardpoints))
			continue

		var/is_selected = (current_limb_in_slot_type == "[limb_data]")
		output += "<a class='limb-choose_button[is_selected ? " selected" : ""]' "
		output += "href='?src=\ref[src];select_limb=[choose_prototype.type]' "
		output += "title='[html_encode(choose_prototype.aug_description)]'>"
		output += "<span class='limb-choose_button-text'>[html_encode(choose_prototype.augment_name)]</span>"
		output += "</a>"

	output += "</div>"
	input_list += output
