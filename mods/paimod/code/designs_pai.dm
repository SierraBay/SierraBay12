//сами дизайны

/datum/design/item/pai/memory_std
	name = "standard memory PAImod"
	category = list("AI")
	desc = "Allows to increase PAI's operating memory by 5 GQ."
	id = "pai_memstd"
	req_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)
	materials = list(MATERIAL_STEEL = 900)
	build_path = /obj/item/paimod/memory/standard
	sort_string = "NBAAA"

/datum/design/item/pai/memory_adv
	name = "advanced memory PAImod"
	category = list("AI")
	desc = "Allows to increase PAI's operating memory by 20 GQ."
	id = "pai_memadv"
	req_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 3)
	materials = list(MATERIAL_STEEL = 700)
	build_path = /obj/item/paimod/memory/advanced
	sort_string = "NBAAB"

/datum/design/item/pai/memory_lambda
	name = "lambda memory PAImod"
	category = list("AI")
	desc = "Allows to increase PAI's operating memory by 50 GQ."
	id = "pai_memlambda"
	req_tech = list(TECH_DATA = 6, TECH_ENGINEERING = 4)
	materials = list(MATERIAL_STEEL = 600, MATERIAL_GLASS = 600)
	build_path = /obj/item/paimod/memory/lambda
	sort_string = "NBAAC"

/datum/design/item/pai/hack_std
	name = "standard encryption PAImod"
	category = list("AI")
	desc = "Allows to double PAI's hacking speed."
	id = "pai_hackstd"
	req_tech = list(TECH_DATA = 4)
	materials = list(MATERIAL_STEEL = 100, MATERIAL_GLASS = 500)
	build_path = /obj/item/paimod/hack_speed/standard
	sort_string = "NBAAD"

/datum/design/item/pai/hack_adv
	name = "advanced encryption PAImod"
	category = list("AI")
	desc = "Allows to quadruple PAI's hacking speed."
	id = "pai_hackadv"
	req_tech = list(TECH_DATA = 5)
	materials = list(MATERIAL_STEEL = 100, MATERIAL_GLASS = 200)
	build_path = /obj/item/paimod/hack_speed/advanced
	sort_string = "NBAAE"

/datum/design/item/pai/hack_camo
	name = "hacking camouflage PAImod"
	category = list("AI")
	desc = "Encrypts PAI's hacking sessions, hiding it from central AI."
	id = "pai_camo"
	req_tech = list(TECH_DATA = 4)
	materials = list(MATERIAL_STEEL = 200, MATERIAL_GLASS = 800)
	build_path = /obj/item/paimod/special/hack_camo
	sort_string = "NBAAF"

/datum/design/item/pai/adv_holo
	name = "advanced holo projector PAImod"
	category = list("AI")
	desc = "Grants an ability to change PAI's holograms, as well as choose some premium ones."
	id = "pai_holo"
	req_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2, TECH_MAGNET = 2)
	materials = list(MATERIAL_STEEL = 200)
	build_path = /obj/item/paimod/special/advanced_holo
	sort_string = "NBAAG"

/datum/design/item/pai/holoskin_woman
	name = "PAI women models' data card"
	category = list("AI")
	id = "pai_holoskin_woman"
	materials = list(MATERIAL_STEEL = 200)
	build_path = /obj/item/paimod/holoskins/paiwoman
	sort_string = "NBABG"
