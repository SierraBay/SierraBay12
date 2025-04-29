											//***БОЕВОЙ ДЕД***//
/mob/living/exosuit/premade/death_combat
	name = "Gygax"
	desc = "This mech is the successor to the first combat mechs - the Gygax. This army model has all the latest innovations in the field of military robotics and is a natural nightmare for its enemies."

/obj/item/mech_component/manipulators/combat/death_combat //Лапы
	max_damage = 300
	melee_damage = 50
	action_delay = 5

/obj/item/mech_component/propulsion/combat/death_combat //Ноги
	max_damage = 300
	bump_type = HARD_BUMP
	bump_safety = TRUE
	can_strafe = TRUE
	good_in_strafe = TRUE //Выпускайте кракена

/obj/item/mech_component/sensors/combat/death_combat //Голова
	max_damage = 300

/obj/item/mech_component/chassis/combat/death_combat //Пузо
	max_damage = 500

/obj/item/robot_parts/robot_component/armour/exosuit/combat/tactical
	name = "tactical combat plating"
	desc = "Special combat plating, designed for operating in field of battle."
	armor = list(
		melee = ARMOR_MELEE_VERY_HIGH,
		bullet = ARMOR_BALLISTIC_RIFLE,
		laser = ARMOR_LASER_RIFLES,
		energy = ARMOR_ENERGY_STRONG,
		bomb = ARMOR_BOMB_RESISTANT,
		rad = ARMOR_RAD_RESISTANT,
		bio = ARMOR_BIO_SHIELDED
		)
	origin_tech = list(TECH_MATERIAL = 7)

/mob/living/exosuit/premade/death_combat/Initialize()
	if(!arms)
		arms = new /obj/item/mech_component/manipulators/combat/death_combat(src)
		arms.color = COLOR_BLACK
	if(!legs)
		legs = new /obj/item/mech_component/propulsion/combat/death_combat(src)
		legs.color = COLOR_BLACK
	if(!head)
		head = new /obj/item/mech_component/sensors/combat/death_combat(src)
		head.color = COLOR_BLACK
	if(!body)
		body = new /obj/item/mech_component/chassis/combat/death_combat(src)
		body.color = COLOR_BLACK
	material = SSmaterials.get_material_by_name(MATERIAL_DIAMOND)
	. = ..()

/obj/item/mech_component/chassis/combat/death_combat/prebuild()
	. = ..()
	QDEL_NULL(cell)
	QDEL_NULL(m_armour)
	cell = new /obj/item/cell/infinite(src)
	m_armour = new /obj/item/robot_parts/robot_component/armour/exosuit/combat/tactical(src)

/mob/living/exosuit/premade/death_combat/spawn_mech_equipment()
	..()
	install_system(new /obj/item/mech_equipment/shields(src), HARDPOINT_BACK)
	install_system(new /obj/item/mech_equipment/mounted_system/taser/ballistic/launcher(src), HARDPOINT_LEFT_SHOULDER)
	install_system(new /obj/item/mech_equipment/mounted_system/taser/ballistic/launcher(src), HARDPOINT_RIGHT_SHOULDER)
	install_system(new /obj/item/mech_equipment/mounted_system/taser/ballistic/autoshotgun(src), HARDPOINT_RIGHT_HAND)
	install_system(new /obj/item/mech_equipment/mounted_system/flamethrower/death_preloaded(src), HARDPOINT_LEFT_HAND)




											//***ТЯЖЁЛЫЙ ДЕД***//


/mob/living/exosuit/premade/death_heavy
	name = "Durand"
	desc = "This Mech is the tank of a modern army, equipped to withstand the most colossal damage and the most powerful attacks in modern warfare. This Mech will be EXTREMELY difficult to destroy without anti-tank weapons."

/obj/item/mech_component/manipulators/heavy/death_heavy //Лапы
	max_damage = 1000
	melee_damage = 50
	action_delay = 10


/obj/item/mech_component/propulsion/heavy/death_heavy //Ноги
	max_damage = 1000
	bump_type = HARD_BUMP
	bump_safety = TRUE
	can_strafe = TRUE
	good_in_strafe = TRUE //Выпускайте кракена

/obj/item/mech_component/sensors/heavy/death_heavy //Голова
	max_damage = 1000

/obj/item/mech_component/chassis/heavy/death_heavy //Пузо
	max_damage = 1000


/mob/living/exosuit/premade/death_heavy/Initialize()
	if(!arms)
		arms = new /obj/item/mech_component/manipulators/heavy/death_heavy(src)
		arms.color = COLOR_BLACK
	if(!legs)
		legs = new /obj/item/mech_component/propulsion/heavy/death_heavy(src)
		legs.color = COLOR_BLACK
	if(!head)
		head = new /obj/item/mech_component/sensors/heavy/death_heavy(src)
		head.color = COLOR_BLACK
	if(!body)
		body = new /obj/item/mech_component/chassis/heavy/death_heavy(src)
		body.color = COLOR_BLACK
	material = SSmaterials.get_material_by_name(MATERIAL_DIAMOND)
	. = ..()


/obj/item/mech_component/sensors/heavy/death_heavy/prebuild()
	. = ..()
	QDEL_NULL(software)
	software = new(src)
	software.installed_software = list(MECH_SOFTWARE_WEAPONS, MECH_SOFTWARE_UTILITY)

/obj/item/mech_component/chassis/heavy/death_heavy/prebuild()
	. = ..()
	QDEL_NULL(cell)
	QDEL_NULL(m_armour)
	cell = new /obj/item/cell/infinite(src)
	m_armour = new /obj/item/robot_parts/robot_component/armour/exosuit/combat/tactical(src)

/mob/living/exosuit/premade/death_heavy/spawn_mech_equipment()
	..()
	install_system(new /obj/item/mech_equipment/shields(src), HARDPOINT_BACK)
	install_system(new /obj/item/mech_equipment/mounted_system/taser/ballistic/minigun(src), HARDPOINT_RIGHT_HAND)
	install_system(new /obj/item/mech_equipment/ballistic_shield(src), HARDPOINT_LEFT_HAND)

											//***ЛЁГКИЙ ДЕД***//

/mob/living/exosuit/premade/death_light
	name = "Phason"
	desc = "SOSI"

/obj/item/mech_component/manipulators/light/death_light //Лапы
	max_damage = 160
	melee_damage = 50

/obj/item/mech_component/propulsion/light/death_light //Ноги
	max_damage = 160
	bump_type = HARD_BUMP
	bump_safety = TRUE
	can_strafe = TRUE
	good_in_strafe = TRUE //Выпускайте кракена

/obj/item/mech_component/sensors/light/death_light //Голова
	max_damage = 160

/obj/item/mech_component/chassis/light/death_light //Пузо
	max_damage = 240

/mob/living/exosuit/premade/death_light/Initialize()
	if(!arms)
		arms = new /obj/item/mech_component/manipulators/light/death_light(src)
		arms.color = COLOR_BLACK
	if(!legs)
		legs = new /obj/item/mech_component/propulsion/light/death_light(src)
		legs.color = COLOR_BLACK
	if(!head)
		head = new /obj/item/mech_component/sensors/light/death_light(src)
		head.color = COLOR_BLACK
	if(!body)
		body = new /obj/item/mech_component/chassis/light/death_light(src)
		body.color = COLOR_BLACK
	material = SSmaterials.get_material_by_name(MATERIAL_DIAMOND)
	. = ..()

/obj/item/mech_component/sensors/light/death_light/prebuild()
	. = ..()
	QDEL_NULL(software)
	software = new(src)
	software.installed_software = list(MECH_SOFTWARE_WEAPONS, MECH_SOFTWARE_UTILITY)

/obj/item/mech_component/chassis/light/death_light/prebuild()
	. = ..()
	QDEL_NULL(cell)
	QDEL_NULL(m_armour)
	cell = new /obj/item/cell/infinite(src)
	m_armour = new /obj/item/robot_parts/robot_component/armour/exosuit/combat/tactical(src)

/mob/living/exosuit/premade/death_light/spawn_mech_equipment()
	..()
	install_system(new /obj/item/mech_equipment/shields(src), HARDPOINT_BACK)
	install_system(new /obj/item/mech_equipment/mounted_system/melee/mechete/energy(src), HARDPOINT_LEFT_HAND)
	//ФАЗОННЫЙ МЕЧ В ЛЕВУЮ РУКУ
	//ТЕЛЕПУШКА В ПРАВУЮ РУКУ


											//***ДОПОЛНИТЕЛЬНОЕ СНАРЯЖЕНИЕ***//
														//Огнемёт
/obj/item/mech_equipment/mounted_system/flamethrower/death_preloaded
	holding_type = /obj/item/flamethrower/full/mech/loaded

/obj/item/flamethrower/full/mech/loaded
	max_beaker = ITEM_SIZE_LARGE
	range = 10
	desc = "A Hephaestus brand 'Prometheus' flamethrower. Bigger and better."


/obj/item/flamethrower/full/mech/loaded/Initialize()
	. = ..()
	QDEL_NULL(beaker)
	beaker = new /obj/item/reagent_containers/chem_disp_cartridge/mech(src)
	beaker.reagents.add_reagent(/datum/reagent/napalm, 1000)

/obj/item/reagent_containers/chem_disp_cartridge/mech
	volume = 1000

															//Миниган

/obj/item/mech_equipment/mounted_system/taser/ballistic/minigun
	name = "\improper Military \"GE M134\" Minigun"
	desc = "Military mounted minigun for combat mechs and tanks."
	icon_state = "mech_minigun"
	holding_type = /obj/item/gun/projectile/automatic/assault_rifle/mounted/minigun

/obj/item/gun/projectile/automatic/assault_rifle/mounted/minigun
	max_shells = 1000
	ammo_type = /obj/item/ammo_casing/rifle/military
	allowed_magazines = /obj/item/ammo_magazine/rifle/mech_minigun
	caliber = CALIBER_RIFLE_MILITARY
	burst = 10
	fire_sound = 'mods/mechs_by_shegar/sounds/mecha_minigun.ogg'
	firemodes = list(
		list(mode_name="semi auto", burst=10, fire_delay=null, move_delay=null, one_hand_penalty=8, burst_accuracy=null, dispersion=null),
		)

/obj/item/ammo_magazine/rifle/mech_minigun
	caliber = CALIBER_RIFLE_MILITARY
	max_ammo = 1000
	icon_state = "machinegun"
	mag_type = SPEEDLOADER
	w_class = ITEM_SIZE_HUGE
	ammo_type = /obj/item/ammo_casing/rifle/military

													//ENERGY BLAAAADE
/obj/item/mech_equipment/mounted_system/melee/mechete/energy
	icon_state = "mech_energy_blade"
	holding_type = /obj/item/material/hatchet/machete/mech/energy

/obj/item/material/hatchet/machete/mech/energy
	hitsound = 'sound/weapons/blade1.ogg'
	atom_flags = ATOM_FLAG_NO_TEMP_CHANGE | ATOM_FLAG_NO_BLOOD
	force = 110
	armor_penetration = 100
	max_force = 120 // If we want to edit the force, use this number! The one below is prone to be changed when anything material gets modified.
	force_multiplier = 1
	attack_cooldown_modifier = 3
