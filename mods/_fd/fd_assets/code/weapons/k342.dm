/obj/item/projectile/plasma
	name = "plasma bolt"
	icon_state = "plasma_bolt"
	fire_sound='mods/_fd/fd_assets/sounds/incinerate.ogg'
	armor_penetration = 25
	damage = 33
	damage_type = DAMAGE_BURN
	step_delay = 0.5

	muzzle_type = /obj/projectile/plasma/muzzle
	impact_type = /obj/projectile/plasma/impact

/obj/projectile/plasma
	light_color = COLOR_BLUE
	layer = ABOVE_LIGHTING_LAYER

/obj/projectile/plasma/heavy
	light_color = COLOR_RED

/obj/projectile/plasma/stun
	light_color = COLOR_YELLOW

/obj/projectile/plasma/net
	light_color = COLOR_GREEN

/obj/projectile/plasma/muzzle
	icon_state = "muzzle_plasma"

/obj/projectile/plasma/impact
	icon_state = "impact_plasma"

/obj/projectile/plasma/heavy/muzzle
	icon_state = "muzzle_plasma"

/obj/projectile/plasma/heavy/impact
	icon_state = "impact_plasma"

/obj/projectile/plasma/stun/muzzle
	icon_state = "muzzle_plasma"

/obj/projectile/plasma/stun/impact
	icon_state = "impact_plasma"

/obj/projectile/plasma/net/muzzle
	icon_state = "muzzle_plasma"

/obj/projectile/plasma/net/impact
	icon_state = "impact_plasma"

/obj/item/projectile/plasma/sniper
	name = "sniper plasma bolt"
	fire_sound='mods/_fd/fd_assets/sounds/vaporize.ogg'
	armor_penetration = 35
	damage = 45
	agony = 5
	step_delay = 0.4

/obj/item/projectile/plasma/heavy
	name = "heavy plasma bolt"
	fire_sound='mods/_fd/fd_assets/sounds/vaporize.ogg'
	armor_penetration = 50
	damage = 60

	muzzle_type = /obj/projectile/plasma/heavy/muzzle
	impact_type = /obj/projectile/plasma/heavy/impact

/obj/item/projectile/plasma/heavy/sniper
	name = "heavy sniper plasma bolt"
	fire_sound='mods/_fd/fd_assets/sounds/vaporize.ogg'
	armor_penetration = 75
	agony = 15
	damage = 90
	step_delay = 0.4

	muzzle_type = /obj/projectile/plasma/heavy/muzzle
	impact_type = /obj/projectile/plasma/heavy/impact

/obj/item/projectile/plasma/stun
	name = "stun plasma bolt"
	fire_sound='mods/_fd/fd_assets/sounds/burn.ogg'
	damage = 2
	agony = 40
	eyeblur = 1
	muzzle_type = /obj/projectile/plasma/stun/muzzle
	impact_type = /obj/projectile/plasma/stun/impact

/obj/item/projectile/plasma/stun/sniper
	name = "sniper stun plasma bolt"
	damage = 2
	agony = 60
	step_delay = 0.4

/obj/item/projectile/plasma/stun/net
	name = "plasma net"
	agony = 20
	damage = 0
	damage_type = null
	muzzle_type = /obj/projectile/plasma/net/muzzle
	impact_type = /obj/projectile/plasma/net/impact

/obj/item/projectile/plasma/stun/net/on_hit(atom/target, blocked = 0, def_zone = null)
	var/obj/item/energy_net/net = new(loc)
	net.try_capture_mob(target)
	return TRUE

/obj/item/gun/energy/k342
	name = "plasma rifle"
	desc = "K342 Barrakuda is the latest plasma weapon created by NanoTrasen. It can fire several types of charges: stunning, incendiary and lethal."
	icon = 'mods/_fd/fd_assets/icons/obj/k342.dmi'
	w_class = ITEM_SIZE_LARGE
	item_icons = list(
		slot_l_hand_str = 'mods/_fd/fd_assets/icons/onmob/lefthand-guns.dmi',
		slot_r_hand_str = 'mods/_fd/fd_assets/icons/onmob/righthand-guns.dmi',
		slot_back_str = 'mods/_fd/fd_assets/icons/onmob/back-guns.dmi'
		)
	slot_flags = SLOT_BACK|SLOT_BELT
	icon_state = "barrakuda_off"
	item_state = "barrakuda"
	origin_tech = list(TECH_COMBAT=4, TECH_MATERIAL=3, TECH_POWER=5)
	wielded_item_state = "barrakuda-wielded"
	req_access = list(list(access_brig, access_bridge))
	authorized_modes = list(ALWAYS_AUTHORIZED)
	screen_shake = 0
	firemodes = list(
		list(mode_name="stun charge", projectile_type=/obj/item/projectile/plasma/stun, charge_cost=20, fire_delay=4, projectile_color=COLOR_YELLOW),
		list(mode_name="plasma charge", projectile_type=/obj/item/projectile/plasma, charge_cost=20, fire_delay=4, projectile_color=COLOR_BLUE_LIGHT),
		list(mode_name="heavy plasma charge", projectile_type=/obj/item/projectile/plasma/heavy, charge_cost=50, fire_delay=8, projectile_color=COLOR_RED)
	)

/obj/item/gun/energy/k342/prereg
	authorized_modes = list(ALWAYS_AUTHORIZED, AUTHORIZED, AUTHORIZED)

/obj/item/gun/energy/k342/on_update_icon()
	. = ..()
	if(power_supply)
		icon_state = "[initial(item_state)]_on"
		var/i = ""
		switch(power_supply.percent())
			if(70 to 100)
				i = "g_70+"
			if(35 to 69)
				i = "g_35+"
			if(0.05 to 34)
				i = "g_0+"
		if(i)
			overlays += image(icon, i)
			var/datum/firemode/current_mode = firemodes[sel_mode]
			overlays += image(icon, splittext(current_mode.name, " ")[1])
	else
		icon_state = "[initial(item_state)]_off"

/obj/item/gun/energy/k342/sniper
	name = "plasma sniper rifle"
	desc = "K480 Skat is the latest heavy plasma weapon created by NanoTrasen for SolGov snipers, capable to fire several types of charges: stunning, incendiary, and lethal bolts. Advanced magnetic constriction technology improves accuracy and firepower."
	icon = 'mods/_fd/fd_assets/icons/obj/k480.dmi'
	icon_state = "mantis_off"
	item_state = "mantis"
	w_class = ITEM_SIZE_LARGE
	slot_flags = SLOT_BACK
	scoped_accuracy = 6
	scope_zoom = 1.5
	firemodes = list(
		list(mode_name="stun charge", projectile_type=/obj/item/projectile/plasma/stun/sniper, charge_cost=60, fire_delay=6, projectile_color=COLOR_YELLOW),
		list(mode_name="plasma charge", projectile_type=/obj/item/projectile/plasma/sniper, charge_cost=60, fire_delay=6, projectile_color=COLOR_BLUE_LIGHT),
		list(mode_name="heavy plasma charge", projectile_type=/obj/item/projectile/plasma/heavy/sniper, charge_cost=120, fire_delay=10, projectile_color=COLOR_RED)
	)

/datum/design/item/weapon/k342
	id = "k342"
	req_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 3, TECH_POWER = 5)
	materials = list(MATERIAL_SILVER = 7000, MATERIAL_GLASS = 2000, MATERIAL_STEEL = 10000, MATERIAL_URANIUM = 2000)
	build_path = /obj/item/gun/energy/k342
	sort_string = "TAEAA"
