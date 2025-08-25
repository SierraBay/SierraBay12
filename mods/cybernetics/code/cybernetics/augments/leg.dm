/singleton/cyber_choose/augment/muscles
	augment_name = "Усилители мышц ног"
	aug_description = "Нановолоконные сухожилия, увеличивающие скорость и ловкость пользователя"
	good_sides = list(
		"Увеличение уровня атлетики на один.",
		"Увеличение дистанции прыжка")
	neutral_sides = list("Аугмент работает только при установке в паре, в обеих ногах")
	avaible_hardpoints = list(BP_R_LEG)
	instal_aug_type = /obj/item/organ/internal/augment/boost/muscle/right
	loadout_price = 4

/singleton/cyber_choose/augment/muscles/check_avaibility(datum/preferences/input_pref)
	if(input_pref.augments_list[BP_R_LEG] != "/singleton/cyber_choose/augment/muscles" || input_pref.augments_list[BP_L_LEG] != "/singleton/cyber_choose/augment/muscles/left")
		return FALSE
	return TRUE

/singleton/cyber_choose/augment/muscles/get_reason_for_avaibility(datum/preferences/input_pref)
	return "Для установки этого аугмента, этот аугмент должен быть выбран в обеих ногах."

/singleton/cyber_choose/augment/muscles/left
	avaible_hardpoints = list(BP_L_LEG)
	instal_aug_type = /obj/item/organ/internal/augment/boost/muscle/left

/obj/item/organ/internal/augment/boost/muscle/right
	organ_tag = "r_leg_aug"
	parent_organ = BP_R_LEG

/obj/item/organ/internal/augment/boost/muscle/left
	organ_tag = "l_leg_aug"
	parent_organ = BP_L_LEG
