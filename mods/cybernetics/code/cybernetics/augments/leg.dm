/singleton/cyber_choose/augment/muscles
	augment_name = "Эндоскелет"
	aug_description = "Эндоскелет встраиваемый в протез или плоть, усиливая ваши физические показатели"
	good_sides = list(
		"Уровень атлетики +1.",
		"Усиливает дистанцию прыжка.")
	neutral_sides = list("Для работы аугмента, требуется точно такой же и в другую ногу.")
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





/singleton/cyber_choose/augment/cabluk
	augment_name = "Киберкаблук"
	aug_description = "Корона всех настоящих мужчин."
	good_sides = list("+1 см роста.")
	neutral_sides = list("Корона всех настоящих мужчин.")
	bad_sides = list("-100 к равновесию")
	avaible_hardpoints = list(
		BP_R_FOOT,
		BP_L_FOOT)
	loadout_price = 1000000
