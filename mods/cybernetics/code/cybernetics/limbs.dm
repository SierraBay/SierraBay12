#include "limbs\body.dm"
#include "limbs\groin.dm"
#include "limbs\head.dm"
#include "limbs\left_arm.dm"
#include "limbs\left_foot.dm"
#include "limbs\left_hand.dm"
#include "limbs\left_leg.dm"
#include "limbs\right_arm.dm"
#include "limbs\right_foot.dm"
#include "limbs\right_hand.dm"
#include "limbs\right_leg.dm"

/singleton/cyber_choose/limb
	avaible_hardpoints = list(
		BP_HEAD,
		BP_CHEST,
		BP_GROIN,
		BP_R_ARM,
		BP_R_HAND,
		BP_L_ARM,
		BP_L_HAND,
		BP_R_LEG,
		BP_R_FOOT,
		BP_L_LEG,
		BP_L_FOOT
	)
	good_sides = list(
		"В отличии от мясных конечностей, протезы можно ремонтировать.",
		"Повреждения протезов вызывает не настоящую боль - голоболь, что не может остановить ваше сердце.",
		"Протез не обладает кровотоком, а значит, не может кровоточить."
	)
	bad_sides = list(
		"Страдает от ЭМИ",
		"В отличии от мясных конечностей, протезы не могут регенерировать сами по себе.",
		"Разнообразная медицина не может влиять на конечность, по типу регенерации от бикардина")
	//Прототип, с которого и будет подсасываться разнообразные значения и описания
	var/datum/robolimb/robolimb_data = /datum/robolimb

/singleton/cyber_choose/limb/setup_description(max_line_length)
	. = ..()
	if(robolimb_data)
		var/datum/robolimb/local_robolimb = new robolimb_data(src)
		var/list/armor_data = local_robolimb.armor
		var/speed = local_robolimb.speed_modifier
		var/cooling = local_robolimb.coolingefficiency

		// Форматируем характеристики в красивый блок
		var/list/stats_block = list(
			"<hr>",
			"<div style='margin-top: 5px; margin-bottom: 5px;'>",
			"<b><font color='#55ccff'>ХАРАКТЕРИСТИКИ ПРОТЕЗА:</font></b>",
			"<table style='border-collapse: collapse; width: 100%; margin-top: 5px;'>",
			"<tr><td style='padding: 2px 5px; width: 60%;'><b>Броня:</b></td><td style='padding: 2px 5px;'>[create_armour_text(armor_data)]</td></tr>",
			"<tr><td style='padding: 2px 5px;'><b>Модификатор скорости:</b></td><td style='padding: 2px 5px;'>[speed]</td></tr>",
			"<tr><td style='padding: 2px 5px;'><b>Модификатор охлаждения:</b></td><td style='padding: 2px 5px;'>[cooling]</td></tr>",
			"</table>",
			"</div>",
			"<hr>"
		)

		aug_description_long += jointext(stats_block, "")
		if(robolimb_data.expensive)
			aug_description_long += SPAN_BAD("ВНИМАНИЕ: Этот протез требует особого ухода при ремонте. Любые повреждения потребуют вскрытия обшивки.")
		qdel(local_robolimb)

/proc/create_armour_text(list/armor)
	var/list/armor_lines = list()

	if(armor["melee"])
		armor_lines += "<span style='color: #ff5555'>Удар:</span> [armor["melee"]]"
	if(armor["bullet"])
		armor_lines += "<span style='color: #55ff55'>Пули:</span> [armor["bullet"]]"
	if(armor["laser"])
		armor_lines += "<span style='color: #5555ff'>Лазер:</span> [armor["laser"]]"
	if(armor["energy"])
		armor_lines += "<span style='color: #ffff55'>Энергия:</span> [armor["energy"]]"
	if(armor["bomb"])
		armor_lines += "<span style='color: #ff55ff'>Взрыв:</span> [armor["bomb"]]"

	return jointext(armor_lines, ", ")



/singleton/cyber_choose/limb/remove_limb
	augment_name = "Отсутствие конечности"
	aug_description = "Конечность будет отсутствовать."
	avaible_hardpoints = list(
		BP_R_ARM,
		BP_R_HAND,
		BP_L_ARM,
		BP_L_HAND,
		BP_R_LEG,
		BP_R_FOOT,
		BP_L_LEG,
		BP_L_FOOT
		)
	good_sides = list("Хорошего в этом мало. Например, в отсутствующую конечность нельзя попасть атакой.")
	neutral_sides = list("В случае отсутствия одной из ног, вам выдадут коляску.")
	bad_sides = list("Конечность полностью отсутствует")
	robolimb_data = null


/obj/item/organ/external/head/robotize(company, skip_prosthetics, keep_organs)
	. = ..()
	for(var/obj/item/organ/internal/brain/brainz in src.owner)
		brainz.mechassist()
	for(var/obj/item/organ/internal/eyes/eyez in src.owner)
		eyez.robotize()
