/* FOUNDATION RIG AND VOIDSUIT
 * ========
 */

/obj/item/clothing/head/helmet/space/void/foundation
	name = "foundation voidsuit helmet"
	desc = "A pitch-black voidsuit helmet with light armor. Notable only for the green colors of the Cuchulain Foundation."
	icon = 'mods/hardsuits/icons/voidsuits/obj_head.dmi'
	icon_state = "foundation"
	item_state = "foundation"
	item_icons = list(slot_head_str = 'mods/hardsuits/icons/voidsuits/onmob_head.dmi')
	light_overlay = "helmet_light_dual_green"
	armor = list(
		melee = ARMOR_MELEE_VERY_HIGH,
		bullet = ARMOR_BALLISTIC_SMALL,
		laser = ARMOR_LASER_SMALL,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_MINOR)

	max_pressure_protection = VOIDSUIT_MAX_PRESSURE

/obj/item/clothing/suit/space/void/foundation
	name = "foundation voidsuit"
	desc = "A pitch-black voidsuit with light armor. Notable only for the green colors of the Cuchulain Foundation."
	icon = 'mods/hardsuits/icons/voidsuits/obj_suit.dmi'
	icon_state = "foundation"
	item_state = "foundation"
	item_icons = list(slot_wear_suit_str = 'mods/hardsuits/icons/voidsuits/onmob_suit.dmi')
	max_pressure_protection = VOIDSUIT_MAX_PRESSURE
	armor = list(
		melee = ARMOR_MELEE_VERY_HIGH,
		bullet = ARMOR_BALLISTIC_SMALL,
		laser = ARMOR_LASER_SMALL,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_MINOR)
	allowed = list(/obj/item/gun,/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/melee/baton)

/obj/item/rig/light/ninja/foundation
	name = "white suit control module"
	desc = "A light hardsuit with clad-white armor plating. The control panel marks it as a Hexenhammer C-8. It's marked with small pale-blue radiotelescope on side of the panel."
	icon = 'mods/hardsuits/icons/rigs/rig_modules.dmi'
	suit_type = "foundation"
	icon_state = "foundation_rig"
	online_slowdown = -1 ///speedster suit
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_RESISTANT,
		laser = ARMOR_LASER_HANDGUNS,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED
	)

	chest_type = /obj/item/clothing/suit/space/rig/foundation
	helm_type =  /obj/item/clothing/head/helmet/space/rig/foundation
	boot_type =  /obj/item/clothing/shoes/magboots/rig/foundation
	glove_type = /obj/item/clothing/gloves/rig/foundation

	initial_modules = list(
		/obj/item/rig_module/banshee,
		/obj/item/rig_module/mounted/wolverine,
		/obj/item/rig_module/mounted/energy/ion,
		/obj/item/rig_module/vision,
		/obj/item/rig_module/chem_dispenser/ninja,
		/obj/item/rig_module/voice,
		/obj/item/rig_module/grenade_launcher/ninja,
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/power_sink,
		/obj/item/rig_module/datajack,
		/obj/item/rig_module/self_destruct,
		/obj/item/rig_module/cooling_unit,
		/obj/item/rig_module/maneuvering_jets
		)

/obj/item/clothing/gloves/rig/foundation
	icon = 'mods/hardsuits/icons/rigs/obj_hands.dmi'
	item_icons = list(slot_gloves_str = 'mods/hardsuits/icons/rigs/onmob_hands.dmi')
	siemens_coefficient = 0

/obj/item/clothing/shoes/magboots/rig/foundation
	icon = 'mods/hardsuits/icons/rigs/obj_feet.dmi'
	item_icons = list(slot_shoes_str = 'mods/hardsuits/icons/rigs/onmob_feet.dmi')

/obj/item/clothing/head/helmet/space/rig/foundation
	icon = 'mods/hardsuits/icons/rigs/obj_head.dmi'
	item_icons = list(slot_head_str = 'mods/hardsuits/icons/rigs/onmob_head.dmi')

/obj/item/clothing/suit/space/rig/foundation
	icon = 'mods/hardsuits/icons/rigs/obj_suit.dmi'
	item_icons = list(slot_wear_suit_str = 'mods/hardsuits/icons/rigs/onmob_suit.dmi')

/obj/item/rig/light/ninja/foundation/on_update_icon(update_mob_icon)

	ClearOverlays()
	if(!mob_icon || update_mob_icon)
		var/species_icon = 'mods/hardsuits/icons/rigs/onmob_rig_back.dmi'
		if(wearer && sprite_sheets && sprite_sheets[wearer.species.get_bodytype(wearer)])
			species_icon =  sprite_sheets[wearer.species.get_bodytype(wearer)]
		mob_icon = image("icon" = species_icon, "icon_state" = "[icon_state]")

	if(equipment_overlay_icon && LAZYLEN(installed_modules))
		for(var/obj/item/rig_module/module in installed_modules)
			if(module.suit_overlay)
				var/overlay = image("icon" = equipment_overlay_icon, "icon_state" = "[module.suit_overlay]", "dir" = SOUTH)
				chest.AddOverlays(overlay)

	if(wearer)
		wearer.update_inv_shoes()
		wearer.update_inv_gloves()
		wearer.update_inv_head()
		wearer.update_inv_wear_mask()
		wearer.update_inv_wear_suit()
		wearer.update_inv_w_uniform()
		wearer.update_inv_back()
	return


/obj/item/rig_module/banshee
	name = "hardsuit siren module"
	desc = {"\
		A pair of speakers installed in the helmet. In the center of the device is a strange red stone, \
		enclosed in a cage of conductive elements. Module marked with small pale-blue radiotelescope on side of the panel. \
	"}
	icon = 'mods/hardsuits/icons/rigs/rig_modules.dmi'
	icon_state = "banshee"
	interface_name = "sound impact module"
	interface_desc = {"\
		Cuchulain Foundation PID \"Banshee\" sound impact module allows to stun nearby enemies \
		after engaging of module. Module have a considerable time for recharging and moderate enegry usage.\
	"}

	use_power_cost = 600 KILOWATTS
	module_cooldown = 30 SECONDS
	toggleable = FALSE
	selectable = TRUE
	usable = TRUE
	engage_string = "Engage Sonic Vail"

// Claws

/obj/item/rig_module/banshee/engage(atom/target)

	if(!..())
		return 0

	var/mob/living/H = holder.wearer

	H.visible_message(SPAN_DANGER("Из динамиков [H] издаётся неописуемый визг!"))
	to_chat(H, SPAN_DANGER("Вы издаёте пронзительный крик, оглушая всех вокруг!"))
	for(var/mob/living/M in range(4))
		if(M == H)
			continue
		if(M.disrupts_psionics())
			return
		if(prob(3 * 20) && iscarbon(M))
			var/mob/living/carbon/C = M
			if(C.can_feel_pain())
				M.emote("scream")
		to_chat(M, SPAN_DANGER("Ты ощущаешь, как земля уходит у тебя из под ног!"))
		M.flash_eyes()
		new /obj/temporary(get_turf(H),6, 'icons/effects/effects.dmi', "sonar_ping")
		new /obj/temporary(get_turf(M),3, 'icons/effects/effects.dmi', "blue_electricity_constant")
		M.eye_blind = max(M.eye_blind,3)
		M.ear_deaf = max(M.ear_deaf,3 * 2)
		M.mod_confused(3 * rand(1,3))

	return 1

/obj/item/rig_module/mounted/wolverine

	name = "hand-mounted wolverine claws"
	desc = "An array of laser claws to be mounted onto a hardsuit."
	icon = 'icons/obj/augment.dmi'
	icon_state = "wolverine"

	suit_overlay_active = null

	activate_string = "Extend Claws"
	deactivate_string = "Retract Claws"

	interface_name = "forearm-mounted blade"
	interface_desc = "A pair of laser armblades built into each forearm of your hardsuit."

	usable = 0
	selectable = 0
	toggleable = 1
	use_power_cost = 10 KILOWATTS
	active_power_cost = 0.5 KILOWATTS
	passive_power_cost = 0

/obj/item/rig_module/mounted/wolverine/Process()

	if(holder && holder.wearer)
		if(!(locate(/obj/item/material/armblade/claws) in holder.wearer))
			deactivate()
			return 0

	return ..()

/obj/item/rig_module/mounted/wolverine/activate()
	var/mob/living/M = holder.wearer

	if (!M.HasFreeHand())
		to_chat(M, SPAN_DANGER("Your hands are full."))
		deactivate()
		return

	var/obj/item/material/armblade/claws/blade = new(M)
	blade.canremove = FALSE
	M.put_in_hands(blade)

	if(!..())
		return 0

/obj/item/rig_module/mounted/wolverine/deactivate()

	..()

	var/mob/living/M = holder.wearer

	if(!M)
		return

	for(var/obj/item/material/armblade/claws/blade in M.contents)
		qdel(blade)
