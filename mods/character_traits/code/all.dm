/*
/datum/mod_trait/clumsiness
	name = "All - clumsiness"
	description = "Добавляет мутацию неуклюжести."

/datum/mod_trait/clumsiness/apply_trait(mob/living/carbon/human/H)
	var/block = GLOB.CLUMSYBLOCK
	H.dna.check_integrity()
	H.dna.SetSEState(block, 1)
	domutcheck(H,null)
	to_chat(H, SPAN_NOTICE("Активирована черта персонажа <b>[name]</b>."))
*/