/datum/design/item/implant
	materials = list(MATERIAL_ALUMINIUM = 500, MATERIAL_GLASS = 500, MATERIAL_PLASTIC = 500)
	category = list("Implant")

/datum/design/item/implant/chemical
	name = "chemical"
	id = "implant_chem"
	req_tech = list(TECH_MATERIAL = 2, TECH_BIO = 3)
	build_path = /obj/item/implantcase/chem
	sort_string = "MFAAA"

/datum/design/item/implant/death_alarm
	name = "death alarm"
	id = "implant_death"
	req_tech = list(TECH_MATERIAL = 2, TECH_BIO = 3, TECH_DATA = 2)
	build_path = /obj/item/implantcase/death_alarm
	sort_string = "MFAAB"

/datum/design/item/implant/tracking
	name = "tracking"
	id = "implant_tracking"
	req_tech = list(TECH_MATERIAL = 2, TECH_BIO = 3, TECH_BLUESPACE = 3)
	build_path = /obj/item/implantcase/tracking
	sort_string = "MFAAC"

/datum/design/item/implant/imprinting
	name = "imprinting"
	id = "implant_imprinting"
	req_tech = list(TECH_MATERIAL = 2, TECH_BIO = 3, TECH_DATA = 4)
	build_path = /obj/item/implantcase/imprinting
	sort_string = "MFAAD"

/datum/design/item/implant/adrenaline
	name = "adrenaline"
	id = "implant_adrenaline"
	req_tech = list(TECH_MATERIAL = 2, TECH_BIO = 3, TECH_ESOTERIC = 3)
	build_path = /obj/item/implantcase/adrenalin
	sort_string = "MFAAE"

/datum/design/item/implant/freedom
	name = "freedom"
	id = "implant_free"
	req_tech = list(TECH_MATERIAL = 2, TECH_BIO = 3, TECH_ESOTERIC = 3)
	build_path = /obj/item/implantcase/freedom
	sort_string = "MFAAF"

/datum/design/item/implant/explosive
	name = "explosive"
	id = "implant_explosive"
	req_tech = list(TECH_MATERIAL = 2, TECH_BIO = 3, TECH_ESOTERIC = 4)
	build_path = /obj/item/implantcase/explosive
	sort_string = "MFAAG"

/datum/design/item/implant/implanter
	name = "implanter"
	id = "implanter"
	req_tech = list(TECH_MATERIAL = 1, TECH_BIO = 2)
	materials = list(MATERIAL_ALUMINIUM = 2000, MATERIAL_GLASS = 2000, MATERIAL_PLASTIC = 2000)
	build_path = /obj/item/implanter
	sort_string = "MFBAG"

/datum/design/item/implant/implant_pad
	name = "implant pad"
	id = "implant_pad"
	req_tech = list(TECH_MATERIAL = 2, TECH_BIO = 2)
	materials = list(MATERIAL_ALUMINIUM = 4000, MATERIAL_GLASS = 2000, MATERIAL_PLASTIC = 4000)
	build_path = /obj/item/implantpad
	sort_string = "MFBBG"
