/*/obj/structure/closet/crate
	var/manufacturer

/singleton/hierarchy/supply_pack/prosthesis
	name = "Prosthetics"
	var/manufacturer


/singleton/hierarchy/supply_pack/prosthesis/proc/cargo_robotize_parts()
	var/list/crate_list = get_crate_list()
	for(var/obj/structure/closet/crate/c in crate_list)
		for(var/obj/item/organ/external/organ in c.contents)
			organ.robotize(c.manufacturer)

/singleton/hierarchy/supply_pack/prosthesis/spawn_contents()
	. = ..()
	addtimer(new Callback(src, PROC_REF(cargo_robotize_parts)), 1 SECONDS)


/singleton/hierarchy/supply_pack/prosthesis
	name = "Prosthetics"
	contains = list(
		/obj/item/organ/external/arm = 1,
		/obj/item/organ/external/arm/right = 1,
		/obj/item/organ/external/chest = 1,
		/obj/item/organ/external/groin = 1,
		/obj/item/organ/external/leg = 1,
		/obj/item/organ/external/leg/right = 1,
		/obj/item/organ/external/head = 1,
	)
	cost = 2

/singleton/hierarchy/supply_pack/prosthesis/proc/get_crate_list()
	var/list/crate_list = list()
	for(var/shuttle_name in SSshuttle.shuttles)
		if(istype(SSshuttle.shuttles[shuttle_name], /datum/shuttle/autodock/ferry/supply/drone))
			var/datum/shuttle/shuttle_datum = SSshuttle.shuttles[shuttle_name]
			for(var/area/a in shuttle_datum.shuttle_area)
				for(var/obj/structure/closet/crate/crate in a)
					if(findtext(crate.name, "prosthetics"))
						crate.manufacturer = manufacturer
						crate_list += crate
	return crate_list



/singleton/hierarchy/supply_pack/prosthesis/bishop

	name = "Bishop prosthetics"
	containername = "Set of Bishop prosthetics"
	manufacturer = "Bishop"
	cost = 5000

/singleton/hierarchy/supply_pack/prosthesis/nt

	name = "NanoTrasen prosthetics"
	containername = "Set of NanoTrasen prosthetics"
	manufacturer = "NanoTrasen"
	cost = 100

/singleton/hierarchy/supply_pack/prosthesis/nt

	name = "NanoTrasen prosthetics"
	containername = "Set of NanoTrasen prosthetics"
	manufacturer = "NanoTrasen"
	cost = 100

/singleton/hierarchy/supply_pack/prosthesis/nt

	name = "NanoTrasen prosthetics"
	containername = "Set of NanoTrasen prosthetics"
	manufacturer = "NanoTrasen"
	cost = 100

/singleton/hierarchy/supply_pack/prosthesis/nt

	name = "NanoTrasen prosthetics"
	containername = "Set of NanoTrasen prosthetics"
	manufacturer = "NanoTrasen"
	cost = 100

/singleton/hierarchy/supply_pack/prosthesis/nt

	name = "NanoTrasen prosthetics"
	containername = "Set of NanoTrasen prosthetics"
	manufacturer = "NanoTrasen"
	cost = 100

/singleton/hierarchy/supply_pack/prosthesis/nt

	name = "NanoTrasen prosthetics"
	containername = "Set of NanoTrasen prosthetics"
	manufacturer = "NanoTrasen"
	cost = 100

/singleton/hierarchy/supply_pack/prosthesis/nt

	name = "NanoTrasen prosthetics"
	containername = "Set of NanoTrasen prosthetics"
	manufacturer = "NanoTrasen"
	cost = 100

/singleton/hierarchy/supply_pack/prosthesis/nt

	name = "NanoTrasen prosthetics"
	containername = "Set of NanoTrasen prosthetics"
	manufacturer = "NanoTrasen"
	cost = 100

/singleton/hierarchy/supply_pack/prosthesis/nt

	name = "NanoTrasen prosthetics"
	containername = "Set of NanoTrasen prosthetics"
	manufacturer = "NanoTrasen"
	cost = 100
*/
