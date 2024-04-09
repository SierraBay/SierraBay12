/obj/vehicles/large/warthog
	name = "M12 Warthog LRV"
	desc = "A nimble vehicle capable of providing anti-infantry support and small-scale troop transport."

	icon = 'mods/_fd/multitile_vehicles/icons/GCPD_Warthog.dmi'
	icon_state = "Warthog"
	anchored = 1

	bound_height = 64
	bound_width = 64

	comp_prof = /datum/component_profile/warthog

	occupants = list(1,1)
	exposed_positions = list("driver" = 0,"passenger" = 5)

	vehicle_size = ITEM_SIZE_VEHICLE
	capacity_flag = ITEM_SIZE_VEHICLE

	vehicle_view_modifier = 1.5

	acceleration = 2
	min_speed = 8.5
	max_speed = 2.5

	interior_template = /datum/map_template/ambulance
	size_x = 5
	size_y = 6

/datum/map_template/ambulance
	name = "Ambulance"
	mappaths = list("mods/_fd/multitile_vehicles/maps/ambulance.dmm")

/obj/vehicles/large/warthog/on_death()
	. = ..()

/obj/item/vehicle_component/health_manager/warthog
	integrity = 500
	resistances = list("bullet"=65,"energy"=65,"emp"=25,"bomb"=45)

/datum/component_profile/warthog
	vital_components = newlist(/obj/item/vehicle_component/health_manager/warthog)
