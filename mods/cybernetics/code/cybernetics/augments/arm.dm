
/singleton/cyber_choose/augment/circuit
	augment_name = "Каркас для установки интегрального устройства"
	aug_description = "Позволяет куда легче установить в вашу руку уже готовое интегральное устройство"
	neutral_sides = list("Для установки устройства в свой аугмент, кликните по персонажу этим устройством, перед этим выделив нижнюю руку в zone select")
	good_sides = list("Заранее подготовленный аугмент для установки интегрального устройства")
	avaible_hardpoints = list(BP_R_ARM)
	instal_aug_type = /obj/item/organ/internal/augment/active/item/circuit/right
	loadout_price = 4

/singleton/cyber_choose/augment/circuit/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_R_ARM] == "Пусто")
		return FALSE
	return TRUE

/singleton/cyber_choose/augment/circuit/get_reason_for_avaibility(datum/preferences/input_pref)
	return "Данный аугмент можно установить только в протез"

/singleton/cyber_choose/augment/circuit/left
	avaible_hardpoints = list(BP_L_ARM)
	instal_aug_type = /obj/item/organ/internal/augment/active/item/circuit/left

/singleton/cyber_choose/augment/circuit/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_L_ARM] == "Пусто")
		return FALSE
	return TRUE

/obj/item/organ/internal/augment/active/item/circuit/right
	parent_organ = BP_R_ARM
	organ_tag = "r_arm_aug"

/obj/item/organ/internal/augment/active/item/circuit/left
	parent_organ = BP_L_ARM
	organ_tag = "l_arm_aug"
