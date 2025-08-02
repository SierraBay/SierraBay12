///Выводит описание выбранного аугмента
/datum/category_item/player_setup_item/cybernetics/proc/draw_choosed_implant_desc(user, input_list)
	var/result_text
	if(!istype(pref.choosed_implant_prototype, /singleton))
		pref.choosed_implant_prototype = GET_SINGLETON(text2path(pref.choosed_implant_prototype))
	if(!pref.choosed_implant_prototype)
		result_text = "<br><span class='bad'>Имплант не выбран</span>"
	else
		if(pref.choosed_implant_prototype && pref.choosed_implant_prototype.aug_description_long)
			result_text = pref.choosed_implant_prototype.aug_description_long
		else if(!pref.choosed_implant_prototype.check_avaibility(pref)) //Протез/аугмент/имплант недоступен
			result_text = pref.choosed_implant_prototype.get_reason_for_avaibility(pref)
		else
			result_text = "<span class='bad'> КОНДУКТОР, У НАС ПРОБЛЕМЫ!!! Код выкинул неожиданный для своей работы результат и не знает что с вами делать. Сообщите о ошибке разработчику или в #фича-репорт </span>"

	input_list += {"
	<style>
		.implant_submit_button {
			position: absolute;
			z-index: 2;
			background: #3A75C4;
			border: none;
			width: 350px;
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
		.implant_submit_button:hover {
			background: #5080B0;
			transform: scale(1.1);
		}
		.implant_submit_button:active {
			background: #2A5590;
		}
		.implant-choose_button-text {
			pointer-events: none;
			text-shadow: 1px 1px 1px black;
		}
	</style>
	<div class='implant-desc-container' style='position: absolute; left: 600px; top: 150px; width: 400px;'>
		[result_text]
	</div>
	"}

	input_list += {"
	<a class='implant_submit_button'
	href='?src=\ref[src];submit_implant=[pref.choosed_implant_prototype]'
	style='left: 600px; top: 400px;'
	title='[pref.choosed_implant_prototype ? "Установить [pref.choosed_implant_prototype.augment_name]" : "Никаких имплантов установлено не будет"]'>
	<span class='implant-choose_button-text'>[pref.choosed_implant_prototype ? "Установить имплант" : "Отменить выбор"]</span></a>"}
