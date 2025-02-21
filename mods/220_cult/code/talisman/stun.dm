/obj/item/paper/talisman/stun // понерфленная, но не сломленная (раньше было 30 секунд стана типо чтооо)
	talisman_name = "stun"
	talisman_desc = "temporarily stuns a targeted mob with a blinding and disorienting flash of light"
	talisman_sound = 'sound/weapons/flash.ogg'
	valid_target_type = list(
		/mob/living/carbon,
		/mob/living/silicon,
		/mob/living/simple_animal
	)
/obj/item/paper/talisman/stun/invoke(mob/living/target, mob/living/user)
	user.say("Dream Sign: Evil Sealing Talisman!", all_languages[LANGUAGE_CULT]) //TODO: never change this shit
	if(issilicon(target))
		target.Weaken(2) // 4 секунды - хорошо комбинировать с ЭМИ!
		target.silent += 5 // 10 секунд молчания
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.silent += 5 // 10 секунд молчания
		C.Weaken(4) // 8 секунд
		C.Stun(3) // 6 секунд
	else
		var/obj/item/device/flash/flash = new(src)
		flash.do_flash(target)
		qdel(flash)
	admin_attack_log(user, target, "Used a stun talisman.", "Was victim of a stun talisman.", "used a stun talisman on")
