/mob/living/silicon/pai
	name = "pAI"
	icon = 'mods/paimod/icons/pai.dmi'
	icon_state = "drone"

/mob/living/silicon/pai/proc/update_verbs()
	if(is_advanced_holo)
		verbs += /mob/living/silicon/pai/proc/choose_chassis

/mob/living/silicon/pai/proc/choose_chassis()
	set category = "pAI Commands"
	set name = "Choose Hologram"

	var/choice
	var/finalized = "No"
	while(finalized == "No" && src.client)

		choice = input(usr,"What would you like to use for your mobile chassis icon? This decision can only be made once.") as null|anything in GLOB.possible_chassis
		if(!choice) return

		chassis = GLOB.possible_chassis[choice]
		icon_state = GLOB.possible_chassis[choice]
		finalized = alert("Look at your sprite. Is this what you wish to use?",,"No","Yes")

	if(!is_advanced_holo)
		verbs -= /mob/living/silicon/pai/proc/choose_chassis
	verbs += /mob/living/proc/hide

/mob/living/silicon/pai/proc/update_memory()
	ram = initial(ram)
	for(var/i in software)
		var/datum/pai_software/S = software[i]
		if(S && (ram >= S.ram_cost))
			ram -= S.ram_cost
	for(var/obj/item/paimod/P in card.contents)
		P.on_update_memory(src)
