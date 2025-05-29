/obj/item/cryokinesis
	name = "ice"
	icon = 'mods/psionics/icons/psychic_powers.dmi'

	item_icons = list(
		slot_l_hand_str = 'mods/psionics/icons/psi_fd/lefthand.dmi',
		slot_r_hand_str = 'mods/psionics/icons/psi_fd/righthand.dmi',
		)

	icon_state = "cryo"

	var/delete_on_drop = 0 //should we delete this item, if it isn't in our inventory?
	var/uses = 5 //amount of time we can use this item before it shutters, similar to glass spear

/obj/item/cryokinesis/New()
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/cryokinesis/Process()
	if(uses <= 0)
		Destroy()

/obj/item/cryokinesis/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	uses -= 1
	..()

/obj/item/cryokinesis/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob)
	uses -= 1

/obj/item/cryokinesis/Destroy()
	playsound(src, "shatter", 70, 1)
	src.visible_message(SPAN_DANGER("[src] рассыпается на тысячи мелких льдинок!"))
	..()

/obj/item/cryokinesis/dropped(mob/living/user as mob)
	..()
	if(delete_on_drop)
		Destroy()

/obj/item/cryokinesis/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/cryokinesis/fists
	name = "ice fists"
	icon_state = "icefists"
	desc = "A pair of cold, icy, punching gloves"
	uses = 10
	delete_on_drop = 1
	force = 15
	attack_cooldown = 8

	base_parry_chance = 10
/*
	lunge_dist = 5
	fail_chance = 10
	melee_strikes = list(/singleton/combo_strike/swipe_strike/blunt_swing/mixed_combo, /singleton/combo_strike/circle_strike/blunt)
*/
/obj/item/cryokinesis/fists/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	if(user.psi)
		var/tele_rank = user.psi.get_rank(PSI_PSYCHOKINESIS)
		if(tele_rank >= PSI_RANK_OPERANT && !user.psi.suppressed)
			force = 35
	..()

/obj/item/cryokinesis/rapier
	name = "ice sword"
	icon_state = "iceblade"
	desc = "Sword, made of very fragile and sharp ice"
	uses = 5
	force = 25
	attack_cooldown = 4

	sharp = TRUE
	edge = TRUE

	base_parry_chance = 40
/*
	lunge_dist = 3
	fail_chance = 50
	melee_strikes = list(/singleton/combo_strike/swipe_strike/sword_slashes,/singleton/combo_strike/swipe_strike/mixed_combo)
*/
