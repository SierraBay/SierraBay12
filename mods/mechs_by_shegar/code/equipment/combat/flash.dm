/obj/item/mech_equipment/flash
	name = "mech flash"
	icon_state = "mech_flash"
	var/flash_min = 7
	var/flash_max = 9
	var/flash_range = 3
	restricted_hardpoints = list(HARDPOINT_LEFT_SHOULDER, HARDPOINT_RIGHT_SHOULDER)
	restricted_software = list(MECH_SOFTWARE_WEAPONS)
	active_power_use = 7 KILOWATTS
	var/next_use = 0
	origin_tech = list(TECH_MAGNET = 2, TECH_COMBAT = 2)
	heat_generation = 15

/obj/item/mech_equipment/flash/have_specific_melee_attack()
	return TRUE

/obj/item/mech_equipment/flash/proc/area_flash()
	playsound(src.loc, 'sound/weapons/flash.ogg', 100, 1)
	var/flash_time = (rand(flash_min,flash_max) - 1)

	var/obj/item/cell/C = owner.get_cell()
	C.use(active_power_use * CELLRATE)

	for (var/mob/living/O in oviewers(flash_range, owner))
		if(istype(O))
			var/protection = O.eyecheck()
			if(protection >= FLASH_PROTECTION_MODERATE)
				return

			if(protection >= FLASH_PROTECTION_MINOR)
				flash_time /= 2

			if(ishuman(O))
				var/mob/living/carbon/human/H = O
				flash_time = round(H.getFlashMod() * flash_time)
				if(flash_time <= 0)
					return

			if(!O.blinded)
				O.flash_eyes(FLASH_PROTECTION_MODERATE - protection)
				O.eye_blurry += flash_time
				O.mod_confused(flash_time + 2)

/obj/item/mech_equipment/flash/attack_self(mob/user)
	. = ..()
	if(.)
		if(world.time < next_use)
			to_chat(user, SPAN_WARNING("\The [src] is recharging!"))
			return
		next_use = world.time + 20
		area_flash()
		owner.setClickCooldown(5)

/obj/item/mech_equipment/flash/afterattack(atom/target, mob/living/user, inrange, params)
	. = ..()
	if(.)
		if(world.time < next_use)
			to_chat(user, SPAN_WARNING("\The [src] is recharging!"))
			return
		var/mob/living/O = target
		owner.setClickCooldown(5)
		next_use = world.time + 15

		if(istype(O))

			playsound(src.loc, 'sound/weapons/flash.ogg', 100, 1)
			var/flash_time = (rand(flash_min,flash_max))

			var/obj/item/cell/C = owner.get_cell()
			C.use(active_power_use * CELLRATE)

			var/protection = O.eyecheck()
			if(protection >= FLASH_PROTECTION_MAJOR)
				return

			if(protection >= FLASH_PROTECTION_MODERATE)
				flash_time /= 2

			if(ishuman(O))
				var/mob/living/carbon/human/H = O
				flash_time = round(H.getFlashMod() * flash_time)
				if(flash_time <= 0)
					return

			if(!O.blinded)
				O.flash_eyes(FLASH_PROTECTION_MAJOR - protection)
				O.eye_blurry += flash_time
				O.mod_confused(flash_time + 2)

				if(isanimal(O)) //Hit animals a bit harder
					O.Stun(flash_time)
				else
					O.Stun(flash_time / 2)

				if(flash_time > 3)
					O.drop_l_hand()
					O.drop_r_hand()
				if(flash_time > 5)
					O.Weaken(3)
