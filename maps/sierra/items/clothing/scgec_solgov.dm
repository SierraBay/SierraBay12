/obj/item/clothing/gloves/thick/duty/solgov
	name = "solgov duty gloves parent object"
	desc = "You should never see this."
	icon_state = null
	item_icons = list(slot_gloves_str = 'maps/torch/icons/mob/onmob_hands_solgov.dmi')
	icon = 'maps/torch/icons/obj/obj_hands_solgov.dmi'
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_hands_solgov_unathi.dmi'
	)

/obj/item/clothing/gloves/thick/duty/solgov/exp
	name = "exploration duty gloves"
	desc = "These black duty gloves are made from durable synthetic materials, and have a lovely purple accent color."
	icon_state = "duty_gloves_exp"
	item_state = "duty_gloves_exp"

/obj/item/clothing/gloves/thick/duty/solgov/sci
	name = "science duty gloves"
	desc = "These black duty gloves are made from durable synthetic materials, and have a lovely heather accent color."
	icon_state = "duty_gloves_sci"
	item_state = "duty_gloves_sci"

/obj/item/clothing/gloves/thick/duty/solgov/med
	name = "medical duty gloves"
	desc = "These black duty gloves are made from durable synthetic materials, and have a lovely blue accent color."
	icon_state = "duty_gloves_med"
	item_state = "duty_gloves_med"

/obj/item/clothing/gloves/thick/duty/solgov/sec
	name = "security duty gloves"
	desc = "These black duty gloves are made from durable synthetic materials, and have a lovely red accent color."
	icon_state = "duty_gloves_sec"
	item_state = "duty_gloves_sec"

/obj/item/clothing/gloves/thick/duty/solgov/sup
	name = "supply duty gloves"
	desc = "These black duty gloves are made from durable synthetic materials, and have a lovely brown accent color."
	icon_state = "duty_gloves_sup"
	item_state = "duty_gloves_sup"


/obj/item/clothing/head/beret/solgov/expedition
	name = "expeditionary beret"
	desc = "A black beret belonging to the SCG Expeditionary Corps. For personnel that are more inclined towards style than safety."
	icon_state = "beret_black"

/obj/item/clothing/head/beret/solgov/expedition/security
	name = "expeditionary security beret"
	desc = "An SCG Expeditionary Corps beret with a security crest. For personnel that are more inclined towards style than safety."
	icon_state = "beret_black_security"

/obj/item/clothing/head/beret/solgov/expedition/medical
	name = "expeditionary medical beret"
	desc = "An SCG Expeditionary Corps beret with a medical crest. For personnel that are more inclined towards style than safety."
	icon_state = "beret_black_medical"

/obj/item/clothing/head/beret/solgov/expedition/supply
	name = "expeditionary supply beret"
	desc = "An SCG Expeditionary Corps beret with a supply crest. For personnel that are more inclined towards style than safety."
	icon_state = "beret_black_supply"

/obj/item/clothing/head/beret/solgov/expedition/exploration
	name = "expeditionary exploration beret"
	desc = "An SCG Expeditionary Corps beret with an exploration crest. For personnel that are more inclined towards style than safety."
	icon_state = "beret_black_exploration"

/obj/item/clothing/head/beret/solgov/expedition/branch
	name = "\improper Field Operations beret"
	desc = "An SCG Expeditionary Corps beret carrying the insignia of the Field Operations section. For personnel that are more inclined towards style than safety."
	icon_state = "beret_black_fieldOps"

/obj/item/clothing/head/beret/solgov/expedition/branch/observatory
	name = "\improper Observatory beret"
	desc = "An SCG Expeditionary Corps beret carrying the insignia of the Observatory section. For personnel that are more inclined towards style than safety."
	icon_state = "beret_black_observatory"

/obj/item/clothing/accessory/solgov/ec_patch
	name = "\improper Observatory patch"
	desc = "A laminated shoulder patch, carrying the symbol of the Sol Central Government Expeditionary Corps Observatory, or SCGEO for short, the eyes and ears of the Expeditionary Corps' missions."
	icon_state = "ecpatch1"
	on_rolled_down = ACCESSORY_ROLLED_NONE
	slot = ACCESSORY_SLOT_INSIGNIA

/obj/item/clothing/accessory/solgov/ec_patch/fieldops
	name = "\improper Field Operations patch"
	desc = "A radiation-shielded shoulder patch, carrying the symbol of the Sol Central Government Expeditionary Corps Field Operations, or SCGECFO for short, the hands-on workers of every Expeditionary Corps mission."
	icon_state = "ecpatch2"

/obj/item/clothing/accessory/solgov/specialty
	name = "speciality blaze"
	desc = "A color blaze denoting fleet personnel in some special role. This one is silver."
	icon_state = "fleetspec"
	slot = ACCESSORY_SLOT_INSIGNIA
	on_rolled_down = ACCESSORY_ROLLED_NONE

/obj/item/clothing/accessory/solgov/specialty/pilot
	name = "pilot's qualification pin"
	desc = "An iron pin denoting the qualification to fly SCG spacecraft."
	icon_state = "pin_pilot"

/obj/item/clothing/accessory/solgov/department
	name = "department insignia"
	desc = "Insignia denoting assignment to a department. These appear blank."
	icon_state = "dept_exped"
	on_rolled_down = "dept_exped_rolled"
	on_rolled_sleeves = "dept_exped_sleeves"
	slot = ACCESSORY_SLOT_FLASH
	accessory_flags = FLAGS_OFF

/obj/item/clothing/accessory/solgov/department/security
	name = "security insignia"
	desc = "Insignia denoting assignment to the security department. These fit Expeditionary Corps uniforms."
	color = "#bf0000"

/obj/item/clothing/accessory/solgov/department/medical
	name = "medical insignia"
	desc = "Insignia denoting assignment to the medical department. These fit Expeditionary Corps uniforms."
	color = "#4c9ce4"

/obj/item/clothing/accessory/solgov/department/research
	name = "research insignia"
	desc = "Insignia denoting assignment to the research department. These fit Expeditionary Corps uniforms."
	color = COLOR_RESEARCH

/obj/item/clothing/accessory/solgov/department/supply
	name = "supply insignia"
	desc = "Insignia denoting assignment to the supply department. These fit Expeditionary Corps uniforms."
	color = "#bb9042"

/obj/item/clothing/accessory/solgov/department/exploration
	name = "exploration insignia"
	desc = "Insignia denoting assignment to the exploration department. These fit Expeditionary Corps uniforms."
	color = "#68099e"

/obj/item/clothing/under/solgov/utility/expeditionary
	name = "expeditionary uniform"
	desc = "The utility uniform of the SCG Expeditionary Corps, made from biohazard resistant material. This one has silver trim."
	icon = 'maps/torch/icons/obj/obj_under_solgov.dmi'
	item_icons = list(slot_w_uniform_str = 'maps/torch/icons/mob/onmob_under_solgov.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_under_solgov_unathi.dmi'
		)
	siemens_coefficient = 0.8
	gender_icons = 1
	icon_state = "blackutility_crew"
	worn_state = "blackutility_crew"
	armor = list(
		melee = ARMOR_MELEE_MINOR,
		energy = ARMOR_ENERGY_MINOR
		)

/obj/item/clothing/under/solgov/utility/expeditionary/security
	accessories = list(/obj/item/clothing/accessory/solgov/department/security)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/medical
	accessories = list(/obj/item/clothing/accessory/solgov/department/medical)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/research
	accessories = list(/obj/item/clothing/accessory/solgov/department/research)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/supply
	accessories = list(/obj/item/clothing/accessory/solgov/department/supply)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/exploration
	accessories = list(/obj/item/clothing/accessory/solgov/department/exploration)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/officer
	name = "expeditionary officer's uniform"
	desc = "The utility uniform of the SCG Expeditionary Corps, made from biohazard resistant material. This one has gold trim."
	icon_state = "blackutility_com"
	worn_state = "blackutility_com"

/obj/item/clothing/under/solgov/utility/expeditionary/officer/security
	accessories = list(/obj/item/clothing/accessory/solgov/department/security)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/officer/medical
	accessories = list(/obj/item/clothing/accessory/solgov/department/medical)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/officer/research
	accessories = list(/obj/item/clothing/accessory/solgov/department/research)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/officer/supply
	accessories = list(/obj/item/clothing/accessory/solgov/department/supply)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/officer/exploration
	accessories = list(/obj/item/clothing/accessory/solgov/department/exploration)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON
