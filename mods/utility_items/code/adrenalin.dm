// Костыль чтобы тесты нашли реагент
/datum/reagent/nitritozadole/adrenalin

/obj/item/implant/adrenalin
	var/activation_emote
	var/imp_reagents = list(/datum/reagent/adrenaline = 5, /datum/reagent/opiate/oxycodone = 10, /datum/reagent/nitritozadole/adrenalin = 1, /datum/reagent/synaptizine = 1)

/obj/item/implant/adrenalin/New()
	uses = rand(1, 5)
	..()
	return

/obj/item/implant/adrenalin/implanted(mob/living/carbon/source)
	src.activation_emote = input("Choose activation emote:") in list("blink", "blink_r", "eyebrow", "chuckle", "twitch_v", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "slowclap", "smile", "pale", "sniff", "whimper", "wink")
	source.StoreMemory("Adrenaline implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", /singleton/memory_options/system)
	to_chat(source, "The implanted adrenaline implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.")
	return TRUE

/obj/item/implant/adrenalin/trigger(emote, mob/source)
	if (emote == src.activation_emote)
		activate()

/obj/item/implant/adrenalin/activate()
	if (uses < 1 || malfunction || !imp_in || !iscarbon(imp_in)) 	return FALSE
	uses--
	to_chat(imp_in, SPAN_NOTICE("You feel a sudden surge of energy!"))
	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.SetParalysis(0)
	for(var/reagent in src.imp_reagents)
		var/amount = imp_reagents[reagent]
		imp_in.reagents.add_reagent(reagent, amount)

/datum/uplink_item/item/implants/imp_adrenalin
	name = "Adrenaline Implant"
	desc = "An implant with an emotive trigger that can help you escape worst scenarios. Adrenaline containing product!"
	item_cost = 36
	path = /obj/item/storage/box/syndie_kit/imp_adrenalin

/obj/item/storage/box/syndie_kit/imp_adrenalin
	startswith = list(/obj/item/implanter/adrenalin)
