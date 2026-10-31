/*
	COMBAT_EXTENDED — щиты через проход по слоям (`mods/combat_extended/code/shields.dm`).

	`check_shields()` сначала спрашивает Bay: псионический отбив, парирование энергомечом, реактивную
	броню. Щиты Bay там больше не бросают шанс блока (`shield/handle_shield()` в `_master_files`), а
	встречают атаку здесь, по зонам и дуге.

	Встретить атаку щитом можно двумя способами. Попадание, урон которого дальше пройдёт броню,
	получает щит слоем брони: проход по слоям решит, пробит ли щит. Проверку без урона —
	обезоруживание, захват, прыжок, укол шприцем — щит блокирует сам. Какой из двух случаев, знают
	только вызывающие, поэтому четыре пути урона помечают свой вызов (`ce_shield_armor_call`).

	Парирование оружием (`weapon_parry.dm`) случается раньше, внутри `..()`, и встречает удар так же —
	первым слоем брони. Тогда щит этот удар уже не встречает.
*/
/mob/living/carbon/human/check_shields(damage = 0, atom/damage_source = null, mob/attacker = null, def_zone = null, attack_text = "the attack")
	ce_shield_hit = null
	. = ..()
	if(. || !ce_shields_enabled || ce_shield_hit)
		return
	return ce_meet_shield(damage_source, attacker, def_zone, attack_text)


/**
 * Щит на пути попадания — внешний слой брони, подкожная броня — внутренний
 * (`mods/combat_extended/code/subdermal_armor.dm`). Для прохода по слоям и для процентного пути Bay.
 */
/mob/living/carbon/human/get_armors_by_zone(obj/item/organ/external/def_zone, damage_type, damage_flags)
	. = ..()
	var/datum/extension/armor/shield_armor = ce_get_shield_armor(def_zone)
	if(shield_armor)
		. = list(shield_armor) + .
	. += ce_get_subdermal_armors()


/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone)
	var/outer_call = ce_shield_armor_call
	ce_shield_armor_call = TRUE
	. = ..()
	ce_shield_armor_call = outer_call


/mob/living/carbon/human/hitby(atom/movable/AM, datum/thrownthing/TT)
	var/outer_call = ce_shield_armor_call
	ce_shield_armor_call = TRUE
	. = ..()
	ce_shield_armor_call = outer_call


/// Удар предметом. Урон наносится позже, в `hit_with_weapon()`, — щит ждёт его до конца тика.
/mob/living/carbon/human/resolve_item_attack(obj/item/I, mob/living/user, target_zone)
	if(user != src && ishuman(user))
		var/mob/living/carbon/human/attacker = user
		attacker.ce_note_melee_attack(attacker.get_attack_speed(I))
	var/outer_call = ce_shield_armor_call
	ce_shield_armor_call = TRUE
	. = ..()
	ce_shield_armor_call = outer_call


/mob/living/carbon/human/resolve_hand_attack(damage, mob/living/user, target_zone)
	if(user != src && ishuman(user))
		var/mob/living/carbon/human/attacker = user
		attacker.ce_note_melee_attack(DEFAULT_ATTACK_COOLDOWN)
	var/outer_call = ce_shield_armor_call
	ce_shield_armor_call = TRUE
	. = ..()
	ce_shield_armor_call = outer_call
