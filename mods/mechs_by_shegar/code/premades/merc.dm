/mob/living/exosuit/premade/merc
	name = "Mercenary mech"
	desc = "A sleek, modern combat mech. Looks like just painted in red paint army mech. Stealed? Maybe."
	external_armor_type = null

/mob/living/exosuit/premade/merc/Initialize()
	if(!head)
		head = new /obj/item/mech_component/sensors/combat(src)
		head.color = COLOR_RED
	if(!body)
		body = new /obj/item/mech_component/chassis/combat/merc(src)
		body.color = COLOR_RED
	if(!L_arm)
		L_arm = new /obj/item/mech_component/manipulators/combat(src)
		L_arm.color = COLOR_RED
	if(!R_arm)
		R_arm = new /obj/item/mech_component/manipulators/combat(src)
		R_arm.color = COLOR_RED
		R_arm.side = RIGHT
		R_arm.setup_side()
	if(!L_leg)
		L_leg = new /obj/item/mech_component/propulsion/combat(src)
		L_leg.color = COLOR_RED
	if(!R_leg)
		R_leg = new /obj/item/mech_component/propulsion/combat(src)
		R_leg.color = COLOR_RED
		R_leg.side = RIGHT
		R_leg.setup_side()
	. = ..()

/obj/item/mech_component/chassis/combat/merc/prebuild()
	. = ..()
	QDEL_NULL(cell)
	cell = new /obj/item/cell/hyper(src)
	update_parts_images()

/mob/living/exosuit/premade/merc/spawn_mech_equipment()
	..()
	install_system(new /obj/item/mech_equipment/mounted_system/taser/laser(src), HARDPOINT_LEFT_HAND)
	install_system(new /obj/item/mech_equipment/light(src), HARDPOINT_RIGHT_SHOULDER)
	install_system(new /obj/item/mech_equipment/shields(src), HARDPOINT_BACK)


/obj/item/mech_equipment/mounted_system/taser/ballistic/smg/high_capacity
	name = "\improper Mounted \"SH-G\" prototype SMG"
	desc = "Prototype SMG, created by one of the ships R&D."
	icon_state = "mech_smg"
	holding_type = /obj/item/gun/projectile/automatic/mounted/smg/high_capacity

/obj/item/gun/projectile/automatic/mounted/smg/high_capacity
	max_shells = 600 //Мерк пулемёт очень вместим из-за пулек в 25(XD) урона

/obj/item/ammo_magazine/proto_smg/mech/high_capacity //Вместительный ящик под пули мех смг
	max_ammo = 600

//Мерк ракетомёт
/obj/item/mech_equipment/mounted_system/taser/ballistic/launcher/merc
	name = "\improper  \"GRA-D\" missle launcher system"
	desc = "Dangerous and load missle launcher system."
	icon_state = "mech_missilerack"
	holding_type = /obj/item/gun/projectile/automatic/rocket_launcher/merc
	restricted_hardpoints = list(HARDPOINT_LEFT_SHOULDER, HARDPOINT_RIGHT_SHOULDER)

/obj/item/gun/projectile/automatic/rocket_launcher/merc
	max_shells = 9

/obj/item/ammo_magazine/rockets_casing/fire/high_capacity
	max_ammo = 9
