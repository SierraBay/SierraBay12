/obj/item/paimod/memory
	name = "unknown memory PAImod"
	desc = "This is the root memory PAImod. You should not have this."
	icon_state = "memory_root"
	var/memory = 1
	special_limit_tag = "memory"

/obj/item/paimod/memory/on_recalculate(mob/living/silicon/pai/P)
	. = ..()
	P.update_memory()

/obj/item/paimod/memory/on_update_memory(mob/living/silicon/pai/P)
	. = ..()
	P.ram += memory

/obj/item/paimod/memory/standard
	name = "standard memory PAImod"
	desc = "This is the standard 'DAIS-NTDC-2080' memory PAImod, which is used to increase memory of your PAI. On its back is written \"Memory: 5\""
	icon_state = "memory_stdc"
	memory = 5

/obj/item/paimod/memory/advanced
	name = "advanced memory PAImod"
	desc = "This is the advanced 'DAIS-RAZR-4090' memory PAImod, which is used to increase memory of your PAI. On its back is written \"Memory: 20\""
	icon_state = "memory_adv"
	memory = 20

/obj/item/paimod/memory/lambda
	name = "lambda memory PAImod"
	desc = "This is the '<font color='#8c5fc7'>DAIS-LMBD-9560</font>' memory PAImod, beyond a small display you can notice some purple crystals. This is used to vastly increase memory of your PAI. On its back is written \"Memory: 50\""
	icon_state = "memory_lambda"
	memory = 50
	mod_integrity = 40
