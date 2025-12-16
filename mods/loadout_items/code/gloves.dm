/obj/item/clothing/gloves/insulated/black
	name = "black insulated gloves"
	desc = "These gloves will protect the wearer from electric shocks. A great choice for stylish hackers."
	color = COLOR_GRAY20
	icon_state = "white"
	item_state = "lgloves"

/obj/item/clothing/gloves/insulated/white
	name = "white insulated gloves"
	desc = "These gloves will protect the wearer from electric shocks. A great choice for ladies and gentlemen."
	color = COLOR_WHITE
	icon_state = "white"
	item_state = "lgloves"

/obj/item/clothing/gloves/kms
	desc = "Your best bet, when you have to pull someone from a flaming wreck."
	name = "KMS duty gloves"
	icon = 'mods/loadout_items/icons/obj_hands.dmi'
	item_icons = list(slot_gloves_str = 'mods/loadout_items/icons/onmob_hands.dmi')
	icon_state = "kms_gloves"
	item_state = "kms_gloves"
	siemens_coefficient = 0.50
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	item_flags = ITEM_FLAG_THICKMATERIAL | ITEM_FLAG_WASHER_ALLOWED
	body_parts_covered = HANDS
	cold_protection = HANDS
	heat_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HANDS
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	max_pressure_protection = FIRESUIT_MAX_PRESSURE

/obj/item/clothing/gloves/driving_gloves
	name = "leather driving gloves"
	desc = "A pair of leather gloves with a cutout on the back of the hand, designed for driving. They are made of synthetic leather and have a label that says they were made in Iolaus."
	icon = 'mods/loadout_items/icons/obj_hands.dmi'
	item_icons = list(slot_gloves_str = 'mods/loadout_items/icons/onmob_hands.dmi')
	icon_state = "leather_gloves"
	item_state = "leather_gloves"

/obj/item/clothing/gloves/driving_gloves/gray
	name = "gray driving gloves"
	desc = "A pair of gray leather gloves with a cutout on the back of the hand, designed for driving. They are made of synthetic leather and have a label that says they were made in Iolaus."
	icon_state = "grayleather_gloves"
	item_state = "grayleather_gloves"

/obj/item/clothing/gloves/fingerless
	name = "fingerless gloves"
	desc = "A pair of gloves without fingers. Badass!"
	icon = 'mods/loadout_items/icons/obj_hands.dmi'
	item_icons =  list(slot_gloves_str = 'mods/loadout_items/icons/onmob_hands.dmi')
	icon_state = "fingerless_gloves"
	item_state = "fingerless_gloves"