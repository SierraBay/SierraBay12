/*
	COMBAT_EXTENDED — светошумовая граната (`code/game/objects/items/weapons/grenades/flashbang.dm`).

	В Bay `bang()` оглушает и вспышкой, и звуком: звук станит на 1–3 тика по расстоянию поверх
	замешательства. Каска уши защищает наполовину — вплотную всё равно стан и замешательство. Граната,
	взорвавшаяся в руке, самой руке ничего не делает.

	С модом:
	- звук больше не станит: остаются замешательство, урон ушей и глухота Bay;
	- любая каска (`/obj/item/clothing/head/helmet`, с ней шлемы скафандров и РИГов) снимает звуковую
	  часть целиком, как защита ушей;
	- вспышка — как в Bay: без защиты глаз стан и замешательство;
	- граната в руке бьёт и обжигает кисть (`ce_flashbang_hand_brute`, `ce_flashbang_hand_burn`),
	  через броню `bomb` перчаток.

	Оверрайд `bang()` лежит в самом моде, а не в `_master_files`, и это нарочно. У модпака
	`mechs_by_shegar` свой оверрайд `bang()` — пилот закрытой кабины гранату не слышит и не видит, — и
	он должен остаться внешним. Мод подключается раньше `mechs_by_shegar` (`mods/global_modpacks.dm`),
	поэтому тот зовёт этот через `..()`. Из `_master_files`, которые подключаются после всех модов,
	этот оверрайд стал бы внешним и проверку кабины обошёл бы.
*/

// Порог защиты ушей Bay: громкость, ниже которой `bang()` и `ex_act()` уши не трогают.
#define CE_EARS_PROTECTED_VOLUME 0.2


/// С модом — `ce_bang()`, без него — граната Bay.
/obj/item/grenade/flashbang/bang(turf/T, mob/living/carbon/M)
	if(!ce_flashbang_enabled)
		return ..()
	ce_bang(T, M)


/// `bang()` по правилам мода. Числа вспышки, замешательства и ушей — Bay.
/obj/item/grenade/flashbang/proc/ce_bang(turf/T, mob/living/carbon/M)
	to_chat(M, SPAN_DANGER("BANG"))
	playsound(loc, 'sound/effects/bang.ogg', 50, 1, 30)

	var/eye_safety = M.eyecheck()
	M.flash_eyes(FLASH_PROTECTION_MODERATE)
	if(eye_safety < FLASH_PROTECTION_MODERATE)
		M.Stun(2)
		M.mod_confused(5)

	ce_hurt_holding_hand(M)
	if(!ce_ears_protected(M))
		ce_deafen(M, get_dist(M, T))

	if(M.ear_damage >= 15)
		to_chat(M, SPAN_DANGER("Your ears start to ring badly!"))
	else if(M.ear_damage >= 5)
		to_chat(M, SPAN_DANGER("Your ears start to ring!"))


/// Защищены ли уши от звуковой части: защитой ушей, как в Bay, или любой каской.
/obj/item/grenade/flashbang/proc/ce_ears_protected(mob/living/carbon/M)
	if(!ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M
	return H.get_sound_volume_multiplier() < CE_EARS_PROTECTED_VOLUME || istype(H.head, /obj/item/clothing/head/helmet)


/// Звуковая часть на расстоянии `distance` от взрыва: замешательство, урон ушей и глухота Bay, без стана.
/obj/item/grenade/flashbang/proc/ce_deafen(mob/living/carbon/M, distance)
	if(distance <= 2)
		M.mod_confused(8)
		M.ear_damage += rand(0, 5)
		M.ear_deaf = max(M.ear_deaf, 15)
	else if(distance <= 5)
		M.mod_confused(5)
		M.ear_damage += rand(0, 3)
		M.ear_deaf = max(M.ear_deaf, 10)
	else
		M.mod_confused(3)
		M.ear_damage += rand(0, 1)
		M.ear_deaf = max(M.ear_deaf, 5)


/// Граната, взорвавшаяся в руке, бьёт и обжигает эту кисть. Её бережёт только броня `bomb` перчаток.
/obj/item/grenade/flashbang/proc/ce_hurt_holding_hand(mob/living/carbon/M)
	var/hand_zone
	if(M.l_hand == src)
		hand_zone = BP_L_HAND
	else if(M.r_hand == src)
		hand_zone = BP_R_HAND
	else
		return
	to_chat(M, SPAN_DANGER("\The [src] goes off in your hand!"))
	M.apply_damage(ce_flashbang_hand_brute, DAMAGE_BRUTE, hand_zone, DAMAGE_FLAG_EXPLODE, used_weapon = src)
	M.apply_damage(ce_flashbang_hand_burn, DAMAGE_BURN, hand_zone, DAMAGE_FLAG_EXPLODE, used_weapon = src)


#undef CE_EARS_PROTECTED_VOLUME
