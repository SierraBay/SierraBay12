/obj/item/clothing/suit/storage/hooded/asamblee
	name = "red mantle"
	desc = "The red robe with yellow ornamentation features vibrant patterns that stand out against the deep crimson fabric."
	icon = 'mods/psionics/icons/asamblee/asamblee.dmi'
	item_icons = list(slot_wear_suit_str = 'mods/psionics/icons/asamblee/asamblee_onmob.dmi')
	icon_state = "asamblee_red"
	action_button_name = "Toggle Mantle Hood"
	hoodtype = /obj/item/clothing/head/asamblee

/obj/item/clothing/head/asamblee
	name = "red mantle hood"
	desc = "The red hood with yellow ornamentation features some symbol that stand out against the deep crimson fabric."
	icon = 'mods/psionics/icons/asamblee/asamblee.dmi'
	icon_state = "asamblee_red_hood"
	item_icons = list(slot_head_str = 'mods/psionics/icons/asamblee/asamblee_onmob.dmi')
	flags_inv = HIDEEARS | BLOCKHAIR

/obj/item/clothing/head/asamblee/attack_hand(mob/living/carbon/human/H)
	if(src == H.head)
		return
	..()
// ^ У Hooded одежды есть проблема, что капюшон можно снять, из-за чего будут видны волосы, но капюшон останется. Эта штука блокирует снятие капюшона рукой

/obj/item/clothing/suit/storage/hooded/asamblee/blackc
	name = "black cloak"
	desc = "The black cloak loose and flowing, resembling an undertaker's attire."
	icon_state = "black_cloak"
	hoodtype = /obj/item/clothing/head/asamblee/blackc

/obj/item/clothing/head/asamblee/blackc
	name = "black cloak hood"
	desc = "Grim dark hood resembling an undertaker's attire."
	icon_state = "black_cloak_hood"

/obj/item/clothing/suit/storage/hooded/asamblee/blackr
	name = "black robe"
	desc = "The plain black robe, understated and timeless, offering a classic and minimalist look"
	icon_state = "black_mantle"
	hoodtype = /obj/item/clothing/head/asamblee/blackr

/obj/item/clothing/head/asamblee/blackr
	name = "black robe hood"
	desc = "The plain black robe hood, understated and timeless, offering a classic and minimalist look"
	icon_state = "black_mantle_hood"

/obj/item/clothing/suit/storage/hooded/asamblee/stargazer
	name = "purple robe"
	desc = "The vividly purple robe resembles stars, with a luxurious hue that commands attention"
	icon_state = "star_mantle"
	hoodtype = /obj/item/clothing/head/asamblee/stargazer

/obj/item/clothing/head/asamblee/stargazer
	name = "purple robe hood"
	desc = "The vividly purple robe hood resembles stars, with a luxurious hue that commands attention"
	icon_state = "star_mantle_hood"

/obj/item/clothing/suit/storage/hooded/asamblee/red
	name = "red robe"
	desc = "The red robe made with smooth, flowing fabric in a solid, vibrant crimson shade without additional patterns or embellishments."
	icon_state = "red_mantle"
	hoodtype = /obj/item/clothing/head/asamblee/red

/obj/item/clothing/head/asamblee/red
	name = "purple robe hood"
	desc = "The red hood made with smooth, flowing fabric in a solid, vibrant crimson shade without additional patterns or embellishments."
	icon_state = "red_mantle_hood"

/obj/item/clothing/suit/storage/hooded/asamblee/gold
	name = "black mantle with gold trim"
	desc = "The black robe with yellow ornamentation features vibrant patterns that stand out against the dark gray fabric."
	icon_state = "asamblee_bg"
	hoodtype = /obj/item/clothing/head/asamblee/gold

/obj/item/clothing/head/asamblee/gold
	name = "black hood"
	desc = "The black hood with yellow ornamentation features some symbol that stand out against the dark gray fabric."
	icon_state = "asamblee_bg_hood"

/obj/item/clothing/suit/storage/hooded/asamblee/silver
	name = "black mantle with silver trim"
	desc = "The black robe with gray ornamentation features vibrant patterns that stand out against the dark gray fabric."
	icon_state = "asamblee_bs"
	hoodtype = /obj/item/clothing/head/asamblee/silver

/obj/item/clothing/head/asamblee/silver
	name = "black hood"
	desc = "The black hood with gray ornamentation features some symbol that stand out against the dark gray fabric."
	icon_state = "asamblee_bs_hood"

/obj/item/clothing/suit/storage/hooded/asamblee/gray
	name = "gray mantle"
	desc = "Blank dark gray robe with no ornamentation"
	icon_state = "asamblee_b"
	hoodtype = /obj/item/clothing/head/asamblee/gray

/obj/item/clothing/head/asamblee/gray
	name = "gray hood"
	desc = "Blank dark gray hood with no ornamentation"
	icon_state = "asamblee_b_hood"

/obj/item/clothing/suit/storage/hooded/asamblee/darkr
	name = "dark robe"
	desc = "Robe made with smooth fabric in a solid, vibrant black shade"
	icon_state = "black_robe"
	hoodtype = /obj/item/clothing/head/asamblee/darkr

/obj/item/clothing/head/asamblee/darkr
	name = "dark robe hood"
	desc = "Robe hood made with smooth fabric in a solid, vibrant black shade"
	icon_state = "black_robe_hood"

/obj/item/clothing/suit/storage/hooded/asamblee/femine
	name = "white robe"
	desc = "Femine like white robe, looking like a wedding dress"
	icon_state = "femine_robe"
	hoodtype = /obj/item/clothing/head/asamblee/femine

/obj/item/clothing/head/asamblee/femine
	name = "white robe hood"
	desc = "Femine like white hood, looking like a wedding"
	icon_state = "femine_robe_hood"

// Маски
/obj/item/clothing/mask/fakemoustache/asamblee
	name = "gold mask"
	desc = "A mask made of artificial gold, with a simple design that covers the face"
	icon = 'mods/psionics/icons/asamblee/asamblee.dmi'
	icon_state = "gold_mask"
	item_state = "gold_mask"
	item_icons = list(slot_wear_mask_str = 'mods/psionics/icons/asamblee/asamblee_onmob.dmi')
	on_turf_icon = 'mods/psionics/icons/asamblee/asamblee_tiny.dmi'
	visible_name = "Unknown"

/obj/item/clothing/mask/fakemoustache/asamblee/steel
	name = "steel mask"
	desc = "A mask made of steel-looking plastic, with a simple design that covers the face"
	icon_state = "steel_mask"
	item_state = "steel_mask"

/obj/item/clothing/mask/fakemoustache/asamblee/shy
	name = "shy clown mask"
	desc = "Mask made of plastic, that resembles a shy clown."
	icon_state = "shyclown_mask"
	item_state = "shyclown_mask"

/obj/item/clothing/mask/fakemoustache/asamblee/blush
	name = "blush clown mask"
	desc = "Mask made of plastic, that resembles a clown."
	icon_state = "blush_mask"
	item_state = "blush_mask"

/obj/item/clothing/mask/fakemoustache/asamblee/black
	name = "black mask"
	desc = "Mask made of plastic, that resembles a balaclava."
	icon_state = "black_mask"
	item_state = "black_mask"

/obj/item/clothing/mask/fakemoustache/asamblee/target
	name = "mask with target"
	desc = "Mask made of plastic, that resembles a shooting target."
	icon_state = "target_mask"
	item_state = "target_mask"

/obj/item/clothing/mask/fakemoustache/asamblee/smiley
	name = "smiley mask"
	desc = "Mask made of plastic, that resembles a creepy smiley face."
	icon_state = "smiley_mask"
	item_state = "smiley_mask"

/obj/item/clothing/mask/fakemoustache/asamblee/happy
	name = "mask with a smiley face"
	desc = "Mask made of plastic, that resembles a smiley face."
	icon_state = "happy_mask"
	item_state = "happy_mask"

/obj/item/clothing/mask/fakemoustache/asamblee/neutral
	name = "mask with a neutral face"
	desc = "Mask made of plastic, that resembles a neutral face."
	icon_state = "neutral_mask"
	item_state = "neutral_mask"

/obj/item/clothing/mask/fakemoustache/asamblee/angry
	name = "mask with a angry face"
	desc = "Mask made of plastic, that resembles an angry face."
	icon_state = "angry_mask"
	item_state = "angry_mask"

/obj/item/clothing/mask/fakemoustache/asamblee/sad
	name = "mask with a sad face"
	desc = "Mask made of plastic, that resembles a sad face."
	icon_state = "sad_mask"
	item_state = "sad_mask"

/obj/item/clothing/mask/fakemoustache/asamblee/half
	name = "half-mask"
	desc = "Mask made of plastic, that has a very long nose."
	icon_state = "half_mask"
	item_state = "half_mask"

/obj/item/clothing/mask/fakemoustache/asamblee/stoneo
	name = "stone mask with a symbol"
	desc = "Mask made of plastic, that has an some strange symbol engraved."
	icon_state = "stoneo_mask"
	item_state = "stoneo_mask"

/obj/item/clothing/mask/fakemoustache/asamblee/stone
	name = "stone mask"
	desc = "Mask made of plastic."
	icon_state = "stone_mask"
	item_state = "stone_mask"

/obj/item/clothing/mask/fakemoustache/asamblee/stonetarget
	name = "stone target mask"
	desc = "Mask made of plastic with a target engraved."
	icon_state = "stonetarget_mask"
	item_state = "stonetarget_mask"

/obj/item/card/assamblee_card
	name = "assamblee insignia card"
	icon = 'mods/psionics/icons/asamblee/asamblee.dmi'
	on_turf_icon = 'mods/psionics/icons/asamblee/asamblee_tiny.dmi'
	icon_state = "insignia_closed"
	desc = "Faux-leather case with some papers inside."
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("whipped")
	hitsound = 'sound/weapons/towelwhip.ogg'
	var/info
	var/use_rating
	var/residence
	var/closed = TRUE
	var/open_icon = "insignia"

/obj/item/card/assamblee_card/proc/set_info(mob/living/carbon/human/human)
	if(!istype(human))
		return
	var/singleton/cultural_info/culture = human.get_cultural_value(TAG_HOMEWORLD)
	var/residence = culture
	if (!culture.name || culture.name == HOME_SYSTEM_OTHER)
		residence = "Unset"
	switch(human.psi?.rating)
		if(0)
			use_rating = "Отщепенец. Он даже не знает что у него написано в карте."
		if(1)
			use_rating = "Неофит, скорее всего он еще не пробужден."
		if(2)
			use_rating = "Ревнитель. Он еще не переступил Первую Ступень, ему уже не нужен наставник."
		if(3)
			use_rating = "Младший Адепт. Это полноценный посвященный Ассамблеи."
		if(4)
			use_rating = "Старший Адепт. Скорее всего это известный и уважаемый наставник первых ступеней."
		if(5)
			use_rating = "Эпопт или Поборник. Великий мастер."
		if (6 to INFINITY)
			use_rating = "Оракул. Царь над царями, член Оракульства."
		else
			use_rating = "Отщепенец. Он даже не знает что у него написано в карте."

	info = {"\
		Assigned to: [human.real_name]\n\
		Residence: [residence]\n\
		Fingerprint: [human.dna?.uni_identity ? md5(human.dna.uni_identity) : "N/A"]
	"}

/obj/item/card/assamblee_card/attack_self(mob/living/user)
	closed = !closed
	update_icon()
	/*user.visible_message(
		SPAN_ITALIC("\The [user] examines \a [src]."),
		SPAN_ITALIC("You examine \the [src]."),
		3
	)
	to_chat(user, info || SPAN_WARNING("\The [src] is completely blank!"))
	if(user.psi)
		to_chat(user, SPAN_DANGER("As a psionic, your mind was penetrated by encoded message, that imply, that owner of this card is a [use_rating]"))*/

/obj/item/card/assamblee_card/examine(mob/living/user)
	if(closed)
		. = ..()
	else
		to_chat(user, info || SPAN_WARNING("[src] пуста!"))
		if(user.psi)
			to_chat(user, SPAN_DANGER("Ты видишь незримое для непробужденного, тебе становится ясно что носитель [use_rating]"))

/obj/item/card/assamblee_card/on_update_icon()
	if(!closed)
		icon_state = open_icon
	else
		icon_state = initial(icon_state)
