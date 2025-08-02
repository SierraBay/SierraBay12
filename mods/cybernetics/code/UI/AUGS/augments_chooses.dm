///Рисует возможные аугменты для выбранной конечности
/datum/category_item/player_setup_item/cybernetics/proc/draw_augments_chooses(mob/user, list/input_list)
	if(!choosed_augment_slot)
		return

	var/list/output = list()
	var/current_aug_in_slot_type = pref.augments_list[choosed_augment_slot]

	output += {"
	<style>
		.augment-scroll-container {
			position: absolute;
			width: 420px;
			height: 500px;
			left: 1080px;
			top: 200px;
			overflow-y: auto;
			border-radius: 5px;
			padding: 10px;
		}
		.augment-choose_button {
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
			font-size: 12px;
			text-align: center;
			text-decoration: none;
			transition: all 0.3s ease;
			border-radius: 3px;
			left: 0;
		}
		.augment-choose_button:hover {
			opacity: 0.9;
			transform: scale(1.02);
		}
		.augment-choose_button.selected {
			background: #00AA00;
			box-shadow: 0 0 5px rgba(0,255,0,0.7);
		}
		.augment-choose_button-text {
			pointer-events: none;
			text-shadow: 1px 1px 1px black;
		}
		/* Стили для скроллбара */
		.augment-scroll-container::-webkit-scrollbar {
			width: 8px;
		}
		.augment-scroll-container::-webkit-scrollbar-track {
			background: rgba(0,0,0,0.2);
			border-radius: 4px;
		}
		.augment-scroll-container::-webkit-scrollbar-thumb {
			background: #3A75C4;
			border-radius: 4px;
		}
		.augment-scroll-container::-webkit-scrollbar-thumb:hover {
			background: #5080B0;
		}
	</style>
	"}

	output += "<div class='augment-scroll-container'>"

	// Кнопка "Пусто"
	var/nothing_selected = (current_aug_in_slot_type == "Пусто")
	output += "<a class='augment-choose_button[nothing_selected ? " selected" : ""]' "
	output += "href='?src=\ref[src];select_augment=Пусто' "
	output += "title='Никаких аугментаций установлено не будет'>"
	output += "<span class='augment-choose_button-text'>Пустота</span>"
	output += "</a>"

	// Кнопки аугментов
	for(var/aug_data in subtypesof(/singleton/cyber_choose/augment))
		var/singleton/cyber_choose/choose_prototype = GET_SINGLETON(aug_data)
		if(!(choosed_augment_slot in choose_prototype.avaible_hardpoints))
			continue

		var/is_selected = (current_aug_in_slot_type == "[aug_data]")
		output += "<a class='augment-choose_button[is_selected ? " selected" : ""]' "
		output += "href='?src=\ref[src];select_augment=[choose_prototype.type]' "
		output += "title='[html_encode(choose_prototype.aug_description)]'>"
		output += "<span class='augment-choose_button-text'>[html_encode(choose_prototype.augment_name)]</span>"
		output += "</a>"

	output += "</div>"
	input_list += output
