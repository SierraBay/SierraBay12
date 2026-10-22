/*
	COMBAT_EXTENDED — набор кузнеца.

	Правит любую жёсткую броню, керамику в том числе, и предел починки не опускает, а поднимает.
	Числа — у его хлама, `/singleton/ce_armor_repair/blacksmith_kit` в `code/armor_repair.dm`. В игре
	его пока не достать — только админам и на картах; где его брать, решается в «TODO» README.
*/

/obj/item/ce_blacksmith_kit
	name = "blacksmith kit"
	desc = "A roll of hammers, dollies and alloy patches for beating damaged hard armor back into shape, ceramic included."
	icon = 'icons/obj/modkit.dmi'
	icon_state = "modkit"
	w_class = ITEM_SIZE_NORMAL
	/// Сколько починок в наборе. Последняя тратит набор целиком.
	var/uses = 1

/obj/item/ce_blacksmith_kit/examine(mob/user, distance, is_adjacent)
	. = ..()
	to_chat(user, "It has parts for [uses] repair\s.")
