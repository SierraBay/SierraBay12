/mob/living/exosuit
	var/obj/item/device/gps/GPS
	var/obj/item/device/scanner/health/medscan
	var/list/menu_hud_elements = list()
	var/menu_status = FALSE
	// Passenger places
	// В связи с кор механом, пассажиры будут помещены в отдельный обьект, для того чтобы пассажиры не курили воздух внутри меха!
	var/obj/item/mech_component/passenger_compartment/passenger_compartment = null
	var/list/passenger_places = list(
		"Back",
		"Left back",
		"Right back"
	)
	var/passengers_ammount = 0 // Хранит в себе общее число пассажиров меха
	var/list/back_passengers_overlays // <- Изображение пассажира на спине
	var/list/left_back_passengers_overlays // <- Изображение пассажира на левом боку
	var/list/right_back_passengers_overlays // <- Изображение пассажира на правом боку
	var/Bumps = 0
	var/last_collision



/mob/living/exosuit/Initialize(mapload, obj/structure/heavy_vehicle_frame/source_frame)
	.=..()
	passenger_compartment = new(src)
	maxHealth = (body.mech_health + material.integrity) + head.max_damage + arms.max_damage + legs.max_damage
	health = maxHealth
	GPS = new(src)
	medscan = new(src)



/mob/living/exosuit/proc/refresh_menu_hud()
	if(LAZYLEN(pilots))
		for(var/thing in pilots)
			var/mob/pilot = thing
			if(pilot.client)
				if(menu_status == TRUE)
					pilot.client.screen |= menu_hud_elements //Врубаем меню худ
				else
					pilot.client.screen -= menu_hud_elements //Вырубаем меню худ



/mob/living/exosuit/dismantle()
	forced_leave_passenger(0 , MECH_DROP_ALL_PASSENGER , "dismantle of [src]") // Перед разбором, сбросим всех пассажиров
	.=..()

/mob/living/exosuit/Destroy()
	forced_leave_passenger(0 , MECH_DROP_ALL_PASSENGER , "dismantle of [src]") // Перед смертью меха, сбросим всех пассажиров
	. = ..()
