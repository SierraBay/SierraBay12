//Кейбинд на управление политулом
/datum/keybinding/human
	hotkey_keys = list("None")
	name = "Polytool activating"
	full_name = "Toggle Polytool"
	description = "При наличии аугмента \"Набор инструментов\" позволяет складывать и раскладывать его содержимое одной кнопкой."


/datum/keybinding/human/down(client/user)
	var/obj/item/organ/internal/augment/active/polytool/polytool = get_current_polytool()
	if(polytool)
		polytool.activate()


///Задача функции - найти какой политул сейчас активен у игрока. Не та рука - не можем найти.
/datum/keybinding/human/proc/get_current_polytool()
	var/mob/living/carbon/human/owner = usr

	//Ловим
	if(owner.hand) //Левая кисть
		return owner.internal_organs_by_name["l_hand_aug"]
	else //Правая кисть
		return owner.internal_organs_by_name["r_hand_aug"]
