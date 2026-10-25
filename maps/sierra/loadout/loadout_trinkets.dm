/datum/gear/trinket/misc_challenge_coin
	display_name = "misc challenge coin selection"
	description = "A selection of challenge coins for identification, collection or simply bragging rights."
	path = /obj/item/material/coin/challenge/misc
	cost = 1


/datum/gear/trinket/misc_challenge_coin/New()
	..()
	var/list/options = list()
	options["SAARE"] = /obj/item/material/coin/challenge/misc/saare
	gear_tweaks += new /datum/gear_tweak/path (options)
