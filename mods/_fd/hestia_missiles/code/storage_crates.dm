/*
THRUSTERS
*/
/obj/structure/closet/crate/munitions/thruster
	name = "\improper Missile thruster crate"
	desc = "A crate containing missile thrusters."

/obj/structure/closet/crate/munitions/thruster/point
	name = "\improper Missile point thruster crate"
	desc = "A crate containing point thrusters."

/obj/structure/closet/crate/munitions/thruster/planet
	name = "\improper Missile planet thruster crate"
	desc = "A crate containing missile planet thrusters."

/obj/structure/closet/crate/munitions/thruster/hunter
	name = "\improper Missile hunter thruster crate"
	desc = "A crate containing missile planet thrusters."


/obj/structure/closet/crate/munitions/thruster/WillContain()
	return list(
		/obj/item/missile_equipment/thruster = 20,
		)

/obj/structure/closet/crate/munitions/thruster/point/WillContain()
	return list(
		/obj/item/missile_equipment/thruster/point = 10,
		)

/obj/structure/closet/crate/munitions/thruster/planet/WillContain()
	return list(
		/obj/item/missile_equipment/thruster/planet = 10,
		)

/obj/structure/closet/crate/munitions/thruster/hunter/WillContain()
	return list(
		/obj/item/missile_equipment/thruster/hunter = 10,
		)

/*
PAYLOADS
*/

/obj/structure/closet/crate/munitions/payload
	name = "\improper Missile payload crate"
	desc = "A crate containing missile payloads."

/obj/structure/closet/crate/munitions/payload/diffuser
	name = "\improper Missile diffuser payload crate"
	desc = "A crate containing diffuser missile payloads."

/obj/structure/closet/crate/munitions/payload/emp
	name = "\improper Missile EMP payload crate"
	desc = "A crate containing EMP missile payloads."

/obj/structure/closet/crate/munitions/payload/explosive
	name = "\improper Missile explosive payload crate"
	desc = "A crate containing explosive missile payloads."

/obj/structure/closet/crate/munitions/payload/antimissile
	name = "\improper Missile antimissile payload crate"
	desc = "A crate containing antimissile missile payloads."



/obj/structure/closet/crate/munitions/payload/diffuser/WillContain()
	return list(
		/obj/item/missile_equipment/payload/diffuser = 5,
		)

/obj/structure/closet/crate/munitions/payload/emp/WillContain()
	return list(
		/obj/item/missile_equipment/payload/emp = 5,
		)

/obj/structure/closet/crate/munitions/payload/explosive/WillContain()
	return list(
		/obj/item/missile_equipment/payload/explosive = 15,
		)

/obj/structure/closet/crate/munitions/payload/antimissile/WillContain()
	return list(
		/obj/item/missile_equipment/payload/antimissile = 10,
		)
/*
Equipment
*/

/obj/structure/closet/crate/munitions/equipment
	name = "\improper Missile equipment crate"
	desc = "A crate containing explosive missile equipment."

/obj/structure/closet/crate/munitions/equipment/autoarm
	name = "\improper Missile autoarm crate"
	desc = "A crate containing autoarm missile equipment."

/obj/structure/closet/crate/munitions/equipment/autoarm/WillContain()
	return list(
		/obj/item/missile_equipment/autoarm = 20,
		)