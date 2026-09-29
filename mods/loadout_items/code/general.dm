// Big Gigachad Towels
/obj/item/rolled_towel
	name = "rolled big towel"
	desc = "A collapsed big towel - looks like you can't use it as a normal one... Try it on a beach."
	icon = 'packs/infinity/icons/obj/items.dmi'
	icon_state = "rolled_towel"
	w_class = 2

	force = 0.3 // Big soft towel is more harmless
	attack_verb = list("whipped")
	hitsound = 'sound/weapons/towelwhip.ogg'
	// SIERRA TODO: port to Bay12 drop sounds
	// drop_sound = 'sound/items/drop/cloth.ogg'
	// pickup_sound = 'sound/items/pickup/cloth.ogg'

	var/beach_towel = /obj/structure/towel

/obj/item/rolled_towel/attack_self(mob/living/user as mob)
	var/obj/item/rolled_towel/R = new beach_towel(user.loc)
	R.add_fingerprint(user)
	qdel(src)

/obj/structure/towel
	name = "big towel"
	icon = 'mods/loadout_items/icons/towels.dmi'
	icon_state = "beach_towel"
	anchored = FALSE
	var/rolled_towel = /obj/item/rolled_towel

/obj/structure/towel/attack_hand(mob/living/user as mob)
	..()
	if(!ishuman(user))
		return 0
	visible_message("<span class='notice'>[usr] rolled up [src].</span>")
	var/obj/item/rolled_towel/B = new rolled_towel(get_turf(src))
	usr.put_in_hands(B)
	qdel(src)

/obj/item/rolled_towel/black
	name = "black rolled towel"
	icon_state = "black_rolled_towel"
	beach_towel = /obj/structure/towel/black

/obj/structure/towel/black
	name = "black big towel"
	icon_state = "black_beach_towel"
	rolled_towel = /obj/item/rolled_towel/black

/obj/item/rolled_towel/blue_stripped
	name = "blue rolled towel"
	icon_state = "bluestripp_towel"
	beach_towel = /obj/structure/towel/blue_stripped

/obj/structure/towel/blue_stripped
	name = "blue big towel"
	icon_state = "bluestripp_beach"
	rolled_towel = /obj/item/rolled_towel/blue_stripped

/obj/item/rolled_towel/red_stripped
	name = "red rolled towel"
	icon_state = "redstripp_towel"
	beach_towel = /obj/structure/towel/red_stripped

/obj/structure/towel/red_stripped
	name = "red big towel"
	icon_state = "redstripp_beach"
	rolled_towel = /obj/item/rolled_towel/red_stripped

/obj/item/rolled_towel/green_stripped
	name = "green rolled towel"
	icon_state = "greenstripp_towel"
	beach_towel = /obj/structure/towel/green_stripped

/obj/structure/towel/green_stripped
	name = "green big towel"
	icon_state = "greenstripp_beach"
	rolled_towel = /obj/item/rolled_towel/green_stripped

/obj/item/rolled_towel/yellow_stripped
	name = "yellow rolled towel"
	icon_state = "yellowstripp_towel"
	beach_towel = /obj/structure/towel/yellow_stripped

/obj/structure/towel/yellow_stripped
	name = "green big towel"
	icon_state = "yellowstripp_beach"
	rolled_towel = /obj/item/rolled_towel/yellow_stripped

/obj/item/rolled_towel/pink_stripped
	name = "pink rolled towel"
	icon_state = "pinkstripp_towel"
	beach_towel = /obj/structure/towel/pink_stripped

/obj/structure/towel/pink_stripped
	name = "green big towel"
	icon_state = "pinkstripp_beach"
	rolled_towel = /obj/item/rolled_towel/pink_stripped

/obj/item/rolled_towel/ilove
	name = "*i <3 you* rolled towel"
	icon_state = "rolled_towel"
	beach_towel = /obj/structure/towel/ilove

/obj/structure/towel/ilove
	name = "*i <3 you* big towel"
	icon_state = "ilove_beach"
	rolled_towel = /obj/item/rolled_towel/ilove

/obj/item/rolled_towel/fitness
	name = "rolled fitness mat"
	desc = "A fitness mat - place it in a gym for better training.."
	icon_state = "rolled_gym_beach"
	beach_towel = /obj/structure/towel/fitness

/obj/structure/towel/fitness
	name = "fitness mat"
	icon_state = "gym_beach"
	rolled_towel = /obj/item/rolled_towel/fitness

/obj/structure/towel/holo
	name = "big holographic towel"
	icon = 'mods/loadout_items/icons/towels.dmi'
	icon_state = "beach_towel"
	anchored = TRUE
	rolled_towel = null

/obj/structure/towel/holo/attack_hand(mob/living/user as mob)
	return

/obj/structure/towel/holo/ilove
	name = "*i <3 you* big towel"
	icon_state = "ilove_beach"

/obj/structure/towel/holo/blue_stripped
	name = "blue big towel"
	icon_state = "bluestripp_beach"

// Cards

/obj/item/deck/compact
	name = "compact deck of cards"
	desc = "A deck of playing cards. Looks like this one hasn't numbers from two to five, and jokers."
	icon_state = "deck"

/obj/item/deck/compact/New()
	..()

	var/datum/playingcard/P
	for(var/suit in list("spades", "clubs", "diamonds", "hearts"))

		var/colour
		if(suit == "spades" || suit == "clubs")
			colour = "black_"
		else
			colour = "red_"

		for(var/number in list("ace", "six", "seven", "eight", "nine", "ten"))
			P = new()
			P.name = "[number] of [suit]"
			P.card_icon = "[colour]num"
			P.back_icon = "card_back"
			cards += P

		for(var/number in list("jack", "queen", "king"))
			P = new()
			P.name = "[number] of [suit]"
			P.card_icon = "[colour]col"
			P.back_icon = "card_back"
			cards += P

// Zippo

/obj/item/flame/lighter/zippo/fancy
	name = "engraved zippo"
	icon = 'mods/loadout_items/icons/lighters.dmi'
	icon_state = "engraved"

/obj/item/flame/lighter/zippo/fancy/gold
	name = "golden zippo"
	icon_state = "gold"

/obj/item/flame/lighter/zippo/fancy/station
	name = "13'th zippo "
	icon_state = "13"

/obj/item/flame/lighter/zippo/fancy/black
	name = "cross zippo"
	icon_state = "black"

/obj/item/flame/lighter/zippo/fancy/blue
	name = "blue zippo"
	icon_state = "bluezippo"

/obj/item/flame/lighter/zippo/fancy/red
	name = "red-white zippo"
	icon_state = "redzippo"

/obj/item/flame/lighter/zippo/fancy/butterfly
	name = "butterfly zippo"
	icon_state = "butterzippo"

/obj/item/flame/lighter/zippo/fancy/fancy
	name = "flower zippo"
	icon_state = "fancyzippo"

/obj/item/flame/lighter/zippo/fancy/on_update_icon()
	var/datum/extension/base_icon_state/bis = get_extension(src, /datum/extension/base_icon_state)

	if(lit)
		icon_state = "[bis.base_icon_state]_on"
		item_state = "[bis.base_icon_state]_on"
	else
		icon_state = "[bis.base_icon_state]"
		item_state = "[bis.base_icon_state]"

// Wheelchair

/obj/item/wheelchair_kit
	name = "compressed wheelchair kit"
	desc = "Collapsed parts, prepared to immediately spring into the shape of a wheelchair."
	icon = 'packs/infinity/icons/obj/items.dmi'
	icon_state = "wheelchair-item"
	item_state = "rbed"
	w_class = ITEM_SIZE_LARGE

/obj/item/wheelchair_kit/attack_self(mob/user)
	visible_message("<b>[user]</b> starts lay out \the [src.name].")
	if(do_after(user, 4 SECONDS, src))
		var/obj/structure/bed/chair/wheelchair/W = new /obj/structure/bed/chair/wheelchair(get_turf(user))
		visible_message(SPAN_NOTICE("<b>[user]</b> lay out \the [W.name]."))
		W.add_fingerprint(user)
		qdel(src)

/obj/item/clothing/suit/storage/solgov/service/expeditionary/scg_kit
	var/chosen_rank_label
	var/chosen_patch_label
	var/chosen_scarf_label

/obj/item/clothing/suit/storage/solgov/service/expeditionary/scg_kit/proc/setup_kit(mob/living/carbon/human/user)
	if (!istype(user))
		return

	var/static/list/rank_type_by_label = list(
		"E-3 (Explorer)" = /obj/item/clothing/accessory/solgov/rank/ec/enlisted/e3,
		"E-5 (Senior Explorer)" = /obj/item/clothing/accessory/solgov/rank/ec/enlisted/e5,
		"E-7 (Chief Explorer)" = /obj/item/clothing/accessory/solgov/rank/ec/enlisted/e7,
		"O-1 (Ensign)" = /obj/item/clothing/accessory/solgov/rank/ec/officer
	)
	var/static/list/patch_type_by_label = list(
		"Observatory patch" = /obj/item/clothing/accessory/solgov/ec_patch,
		"Field Operations patch" = /obj/item/clothing/accessory/solgov/ec_patch/fieldops,
		"Cultural Exchange patch" = /obj/item/clothing/accessory/solgov/cultex_patch
	)
	var/static/list/scarf_type_by_label = list(
		"Observatory scarf" = /obj/item/clothing/accessory/solgov/ec_scarf/observatory,
		"Field Operations scarf" = /obj/item/clothing/accessory/solgov/ec_scarf/fieldops
	)
	var/static/list/department_insignia_by_word = list(
		"command" = /obj/item/clothing/accessory/solgov/department/command/service,
		"engineering" = /obj/item/clothing/accessory/solgov/department/engineering/service,
		"security" = /obj/item/clothing/accessory/solgov/department/security/service,
		"medical" = /obj/item/clothing/accessory/solgov/department/medical/service,
		"research" = /obj/item/clothing/accessory/solgov/department/research/service,
		"supply" = /obj/item/clothing/accessory/solgov/department/supply/service,
		"exploration" = /obj/item/clothing/accessory/solgov/department/exploration/service,
		"service" = /obj/item/clothing/accessory/solgov/department/service/service
	)
	var/static/list/gloves_by_department = list(
		"command" = /obj/item/clothing/gloves/thick/duty/solgov/cmd,
		"engineering" = /obj/item/clothing/gloves/thick/duty/solgov/eng,
		"security" = /obj/item/clothing/gloves/thick/duty/solgov/sec,
		"medical" = /obj/item/clothing/gloves/thick/duty/solgov/med,
		"research" = /obj/item/clothing/gloves/thick/duty/solgov/sci,
		"supply" = /obj/item/clothing/gloves/thick/duty/solgov/sup,
		"exploration" = /obj/item/clothing/gloves/thick/duty/solgov/exp,
		"service" = /obj/item/clothing/gloves/thick/duty/solgov/svc
	)

	var/rank_type = rank_type_by_label[chosen_rank_label] || rank_type_by_label["E-3 (Enlisted Explorer)"]
	var/patch_type = patch_type_by_label[chosen_patch_label] || patch_type_by_label["Observatory patch"]
	var/scarf_type = scarf_type_by_label[chosen_scarf_label] || scarf_type_by_label["Observatory scarf"]
	var/is_officer = (chosen_rank_label == "O-1 (Officer Ensign)")

	if (is_officer)
		icon_state = "ecservice_officer"
		item_state = "ecservice_officer"

	var/dept_word = get_department_word(user)
	var/insignia_type = department_insignia_by_word[dept_word]

	attach_accessory(null, new insignia_type(src))
	attach_accessory(null, new patch_type(src))
	attach_accessory(null, new rank_type(src))
	attach_accessory(null, new scarf_type(src))

	var/uniform_type = is_officer ? /obj/item/clothing/under/scg_expeditonary/officer : /obj/item/clothing/under/scg_expeditonary
	var/obj/item/clothing/under/uniform = new uniform_type(user)
	uniform.attach_accessory(null, new insignia_type(uniform))
	user.equip_to_slot_if_possible(uniform, slot_w_uniform, TRYEQUIP_REDRAW | TRYEQUIP_DESTROY | TRYEQUIP_FORCE | TRYEQUIP_INSTANT)

	var/glove_type = gloves_by_department[dept_word]
	user.equip_to_slot_if_possible(new glove_type(user), slot_gloves, TRYEQUIP_REDRAW | TRYEQUIP_DESTROY | TRYEQUIP_FORCE | TRYEQUIP_INSTANT)

	user.equip_to_slot_if_possible(new /obj/item/clothing/head/soft/solgov/expedition(user), slot_head, TRYEQUIP_REDRAW | TRYEQUIP_DESTROY | TRYEQUIP_FORCE | TRYEQUIP_INSTANT)

/obj/item/clothing/suit/storage/solgov/service/expeditionary/scg_kit/proc/get_department_word(mob/user)
	var/dept_flag = 0
	if (user.mind && user.mind.assigned_role)
		var/datum/job/job = SSjobs.get_by_title(user.mind.assigned_role)
		if (job)
			dept_flag = job.department_flag

	if (dept_flag & (COM|SPT))
		return "command"
	if (dept_flag & ENG)
		return "engineering"
	if (dept_flag & SEC)
		return "security"
	if (dept_flag & MED)
		return "medical"
	if (dept_flag & SCI)
		return "research"
	if (dept_flag & SUP)
		return "supply"
	if (dept_flag & EXP)
		return "exploration"
	return "service" // Civilian/misc/unassigned roles default to the service department's cut.

/datum/gear_tweak/custom_var/scg_kit_rank
	var_to_tweak = "chosen_rank_label"
	content_text = "Rank"
	input_message = "Choose your rank."

/datum/gear_tweak/custom_var/scg_kit_patch
	var_to_tweak = "chosen_patch_label"
	content_text = "Patch"
	input_message = "Choose your patch."

/datum/gear_tweak/custom_var/scg_kit_scarf
	var_to_tweak = "chosen_scarf_label"
	content_text = "Scarf"
	input_message = "Choose your scarf."
