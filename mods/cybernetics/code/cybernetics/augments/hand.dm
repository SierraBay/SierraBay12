//Инструментарий
/singleton/cyber_choose/augment/instrumental
	augment_name = "Раскладной набор инструментов"
	aug_description = "Раскладной набор инструментов в вашей кисти!"
	good_sides = list("Позволяет вытащить из руки следущие инструменты: отвёртка, лом, кусачки, малая сварка, мультитул.")
	avaible_hardpoints = list(BP_R_HAND)
	instal_aug_type = /obj/item/organ/internal/augment/active/polytool/engineer/right
	loadout_price = 6


/singleton/cyber_choose/augment/instrumental/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_R_HAND] == "Пусто")
		return FALSE
	return TRUE

/singleton/cyber_choose/augment/instrumental/get_reason_for_avaibility(datum/preferences/input_pref)
	return "Данный аугмент можно установить только в протез."

/singleton/cyber_choose/augment/instrumental/left
	avaible_hardpoints = list(BP_L_HAND)
	instal_aug_type = /obj/item/organ/internal/augment/active/polytool/engineer/left

/singleton/cyber_choose/augment/instrumental/left/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_L_HAND] == "Пусто")
		return FALSE
	return TRUE

/obj/item/organ/internal/augment/active/polytool/engineer/right
	parent_organ = BP_R_HAND
	organ_tag = "r_hand_aug"

/obj/item/organ/internal/augment/active/polytool/engineer/left
	parent_organ = BP_L_HAND
	organ_tag = "l_hand_aug"

////////////////////////////////////////////////////////////////////////////////////////////////////

/singleton/cyber_choose/augment/instrumental/surgical
	augment_name = "Раскладной набор хирургических инструментов"
	aug_description = "Раскладной набор хирургических инструментов в вашей кисти!"
	good_sides = list("Позволяет вытащить из руки следущие инструменты: скальпель, пила, гемостат, ретрактор, фиксовейн.")
	avaible_hardpoints = list(BP_R_HAND)
	instal_aug_type = /obj/item/organ/internal/augment/active/polytool/surgical/right

/singleton/cyber_choose/augment/instrumental/surgical/left
	avaible_hardpoints = list(BP_L_HAND)
	instal_aug_type = /obj/item/organ/internal/augment/active/polytool/surgical/left


/singleton/cyber_choose/augment/instrumental/surgical/left/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_L_HAND] == "Пусто")
		return FALSE
	return TRUE

/singleton/cyber_choose/augment/instrumental/surgical/left/get_reason_for_avaibility(datum/preferences/input_pref)
	return "Данный аугмент можно установить только в протез."

/obj/item/organ/internal/augment/active/polytool/surgical/right
	parent_organ = BP_R_HAND
	organ_tag = "r_hand_aug"

/obj/item/organ/internal/augment/active/polytool/surgical/left
	parent_organ = BP_L_HAND
	organ_tag = "l_hand_aug"
