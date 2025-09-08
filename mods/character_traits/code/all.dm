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

/datum/mod_trait/all/
	species_allowed = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_UNATHI, SPECIES_TAJARA, SPECIES_YEOSA, SPECIES_RESOMI, SPECIES_MULE, SPECIES_SPACER, SPECIES_TRITONIAN, SPECIES_GRAVWORLDER)

/datum/mod_trait/all/tritanopia
	name = "Colorblindness - Tritanopia"
	description = "Отсутствие коротковолновых (синих) колбочек. Спутан синий с зелёным, жёлтый с фиолетовым."
	incompatible_traits = list(/datum/mod_trait/all/monochrome, /datum/mod_trait/all/protanopia, /datum/mod_trait/all/deuteranopia)

/mob/proc/tritanovision()
	add_client_color(/datum/client_color/tritanopia)

/datum/mod_trait/all/tritanopia/apply_trait(mob/living/carbon/human/H)
	H.tritanovision()

/datum/mod_trait/all/protanopia
	name = "Colorblindness - Protanopia"
	description = "Отсутствие колбочек, чувствительных к длинноволновому (красному) свету. Снижена яркость и спутаны красные и зелёные оттенки."
	incompatible_traits = list(/datum/mod_trait/all/monochrome, /datum/mod_trait/all/deuteranopia, /datum/mod_trait/all/tritanopia)

/mob/proc/protanopiavision()
	add_client_color(/datum/client_color/protanopia)

/datum/mod_trait/all/protanopia/apply_trait(mob/living/carbon/human/H)
	H.protanopiavision()

/datum/mod_trait/all/deuteranopia
	name = "Colorblindness - Deuteranopia"
	description = "Отсутствие колбочек среднего спектра (зелёного). Нарушена дифференциация между красным и зелёным."
	incompatible_traits = list(/datum/mod_trait/all/monochrome, /datum/mod_trait/all/protanopia, /datum/mod_trait/all/tritanopia)

/mob/proc/deuteranopiavision()
	add_client_color(/datum/client_color/deuteranopia)

/datum/mod_trait/all/deuteranopia/apply_trait(mob/living/carbon/human/H)
	H.deuteranopiavision()

/datum/mod_trait/all/monochrome
	name = "Colorblindness - Monochrome"
	description = "Полное отсутствие функционирующих цветочувствительных колбочек. Зрение ограничено оттенками серого."
	incompatible_traits = list(/datum/mod_trait/all/tritanopia, /datum/mod_trait/all/protanopia, /datum/mod_trait/all/deuteranopia)

/datum/client_color/monochrome/disease
	client_color = list(
		0.33, 0.33, 0.33,
		0.33, 0.33, 0.33,
		0.33, 0.33, 0.33
	)
	order = 100

/mob/proc/monochromevision()
	add_client_color(/datum/client_color/monochrome/disease)

/datum/mod_trait/all/monochrome/apply_trait(mob/living/carbon/human/H)
	H.monochromevision()

/datum/mod_trait/all/headache
	name = "Disease - Headaches"
	description = "Периодически, вас будут одолевать мигрени."

/datum/mod_trait/all/headache/apply_trait(mob/living/carbon/human/H)
	H.add_headache()

/datum/mod_trait/all/hallucinations
	name = "Disease - Hallucinations"
	description = "Периодически, вас будут одолевать галлюцинации."

/datum/mod_trait/all/hallucinations/apply_trait(mob/living/carbon/human/H)
	H.add_hallucinations()

/datum/mod_trait/all/seizure
	name = "Disease - Seizures"
	description = "Периодически, вы будете страдать от припадков."

/datum/mod_trait/all/seizure/apply_trait(mob/living/carbon/human/H)
	H.add_seizures()

/datum/mod_trait/all/asthma
	name = "Disease - Asthma"
	description = "Нагрузки будут вызывать у вас нехватку воздуха. Дексалин может помочь с этим."

/datum/mod_trait/all/asthma/apply_trait(mob/living/carbon/human/H)
	if(H.species && H.species.name == SPECIES_FBP)
		return
	if(H.client?.prefs?.organ_data && (H.client.prefs.organ_data[BP_CHEST] == "cyborg"))
		return
	H.add_asthma()
