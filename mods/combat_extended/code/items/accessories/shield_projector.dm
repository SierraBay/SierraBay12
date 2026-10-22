/*
	COMBAT_EXTENDED — прожектор на щит, первый аксессуар щита (`code/shields.dm`).

	Кнопка действия щита включает и выключает свет — как у аварийного прожектора
	(`/obj/machinery/floodlight`): та же дальность, сила и конус вперёд. Светит сам щит: Bay поднимает
	свет только на один уровень вверх, и свет прожектора внутри щита в руках не пошёл бы за
	носителем.

	Альт-клик куда угодно, пока горит прожектор на щите в руке, — вспышка; альт-клик по самому щиту
	в руке — тоже, про запас. Своей дальности и ширины у вспышки нет: она слепит тех, кого луч уже
	освещает (`affecting_turfs` источника света) и кто смотрит на носителя. Луч, упёршийся в стену,
	дальше не слепит. Защита глаз работает, как от вспышки (`eyecheck()`).
	Вспышка не оглушает и не сбивает с ног: только слепит, мутит взгляд и сбивает с толку.

	Выдаётся пока только админами и картой.
*/

/obj/item/ce_shield_accessory/projector
	name = "shield projector"
	desc = "A compact floodlight that mounts on a large shield. Bright enough to dazzle anyone who stares into it."
	icon = 'icons/obj/tools/flashlights.dmi'
	icon_state = "biglight"
	item_state = "biglight"
	action_name = "Toggle Projector"
	/// Горит ли свет.
	var/on = FALSE
	/// Свет — как у `/obj/machinery/floodlight`: дальность, сила и конус.
	var/beam_range = 8
	var/beam_power = 2.5
	var/beam_angle = LIGHT_VERY_WIDE
	/// Перезарядка вспышки.
	var/dazzle_cooldown = 15 SECONDS
	/// `world.time`, с которого вспышка снова готова.
	var/next_dazzle = 0
	/// Сила вспышки: муть в глазах на столько, растерянность — на 2 больше. Середина разброса
	/// `/obj/item/device/flash` (2–7).
	var/dazzle_strength = 5
	/// На свет смотрит тот, у кого носитель щита в этой дуге вокруг взгляда, градусы.
	var/dazzle_view_degrees = 90


/obj/item/ce_shield_accessory/projector/on_update_icon()
	icon_state = on ? "biglight-on" : "biglight"


/obj/item/ce_shield_accessory/projector/activate(mob/living/user, obj/item/shield/shield)
	set_on(!on, shield)
	playsound(shield, 'sound/effects/flashlight.ogg', 50, TRUE)
	to_chat(user, SPAN_NOTICE("You switch \the [src] [on ? "on" : "off"]."))


/obj/item/ce_shield_accessory/projector/on_removed(obj/item/shield/shield, mob/living/user)
	set_on(FALSE, shield)


/obj/item/ce_shield_accessory/projector/get_shield_examine_lines(obj/item/shield/shield)
	. = list(SPAN_NOTICE("Its projector is [on ? "on" : "off"]."))
	if(on)
		. += SPAN_NOTICE("Alt-click anywhere while holding shield in hands to flare the projector.")


/// Включает или выключает свет. Светит сам щит.
/obj/item/ce_shield_accessory/projector/proc/set_on(new_on, obj/item/shield/shield)
	on = new_on
	if(on)
		shield.set_light(beam_range, beam_power, angle = beam_angle)
	else
		shield.set_light(0)
	update_icon()


/obj/item/ce_shield_accessory/projector/alt_activate(mob/living/user, obj/item/shield/shield)
	if(user.incapacitated())
		return FALSE
	if(!on)
		to_chat(user, SPAN_WARNING("Switch \the [src] on first."))
		return TRUE
	if(world.time < next_dazzle)
		to_chat(user, SPAN_WARNING("\The [src] is still recovering from the last flare."))
		return TRUE
	dazzle(user, shield)
	return TRUE


/**
 * Вспышка по альт-клику куда угодно, из `human/AltClickOn()` в `_master_files`: в бою в режиме
 * боя мышь смотрит туда же, куда носитель, и тянуть её вниз к щиту в руке значило бы развернуться
 * к югу. Клик разбирается, только пока прожектор на щите в руке горит, — иначе альт-клик
 * работает как обычно. Вспышка светит туда, куда носитель смотрит, а не в точку клика.
 * TRUE — клик разобран.
 */
/mob/living/carbon/human/proc/ce_flare_held_projector()
	for(var/obj/item/shield/shield in list(l_hand, r_hand))
		var/obj/item/ce_shield_accessory/projector/projector = shield.ce_accessory
		if(istype(projector) && projector.on)
			return projector.alt_activate(src, shield)
	return FALSE


/**
 * Вспышка: слепит всех, кого луч освещает и кто смотрит на носителя. Кого луч освещает, но кто
 * смотрит в сторону, и самого носителя — лишь слегка засвечивает, без ослепления. Освещённое —
 * клетки, до которых дошёл свет щита, с его конусом и стенами. Возвращает ослеплённых.
 */
/obj/item/ce_shield_accessory/projector/proc/dazzle(mob/living/user, obj/item/shield/shield)
	RETURN_TYPE(/list)
	next_dazzle = world.time + dazzle_cooldown
	playsound(shield, 'sound/weapons/flash.ogg', 100, TRUE)
	user.visible_message(
		SPAN_DANGER("\The [user] flares \the [src] on \the [shield]!"),
		SPAN_DANGER("You flare \the [src]!")
	)
	. = list()
	glare_target(user)
	var/datum/light_source/beam = shield.light
	if(!beam)
		return
	var/turf/user_turf = get_turf(user)
	for(var/turf/lit as anything in beam.affecting_turfs)
		if(lit == user_turf)
			continue
		for(var/mob/living/target in lit)
			if(target.stat == DEAD || issilicon(target))
				continue
			if(!ce_is_in_arc(lit, user_turf, dir2angle(target.dir), dazzle_view_degrees))
				glare_target(target)
			else if(dazzle_target(target))
				. += target


/// Защита глаз от вспышки прожектора, как от `/obj/item/device/flash`: `eyecheck()`, null — умеренная
/// и выше устояла целиком.
/obj/item/ce_shield_accessory/projector/proc/get_eye_safety(mob/living/target)
	var/safety = target.eyecheck()
	return safety < FLASH_PROTECTION_MODERATE ? safety : null


/// Слепит одного, как вспышка `/obj/item/device/flash`, но без оглушения. FALSE — защита глаз устояла.
/obj/item/ce_shield_accessory/projector/proc/dazzle_target(mob/living/target)
	var/safety = get_eye_safety(target)
	if(isnull(safety))
		return FALSE
	var/strength = dazzle_strength
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		strength = round(H.getFlashMod() * strength)
	if(safety > FLASH_PROTECTION_NONE)
		strength /= 2
	if(strength <= 0)
		return FALSE
	target.flash_eyes(FLASH_PROTECTION_MODERATE - safety)
	target.eye_blurry = max(target.eye_blurry, strength)
	target.set_confused(strength + 2)
	to_chat(target, SPAN_DANGER("You are dazzled by the glare of \the [src]!"))
	return TRUE


/**
 * Лёгкая вспышка без ослепления: тот же `flash_eyes()`, что у полной, но без мути в глазах и
 * растерянности. Защита глаз — та же. FALSE — защита глаз устояла.
 */
/obj/item/ce_shield_accessory/projector/proc/glare_target(mob/living/target)
	var/safety = get_eye_safety(target)
	if(isnull(safety))
		return FALSE
	target.flash_eyes(FLASH_PROTECTION_MODERATE - safety)
	return TRUE
