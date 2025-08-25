#include "augments\arm.dm"
#include "augments\chest.dm"
#include "augments\groin.dm"
#include "augments\hand.dm"
#include "augments\head.dm"
#include "augments\leg.dm"

/singleton/cyber_choose/augment
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
	var/obj/item/organ/internal/augment/instal_aug_type
	var/custom_name_avaible = TRUE
	var/custom_desc_avaible = TRUE
	var/loadout_price = 0

/singleton/cyber_choose/augment/setup_description(max_line_length)
	. = ..()
	if(loadout_price > 0)
		aug_description_long += SPAN_BAD("Цена аугмента: [loadout_price] очков снаряжения.")
