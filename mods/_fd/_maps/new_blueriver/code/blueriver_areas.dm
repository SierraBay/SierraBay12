//remap
/area/map_template/bluespaceriver
	name = "\improper Bluespace River"
	icon_state = "3"
	ambience = list('sound/ambience/spookyspace1.ogg', 'sound/ambience/spookyspace2.ogg')

/area/map_template/bluespaceriver/horizon
	name = "\improper NSV Horizon"
	icon_state = "1"

/area/map_template/bluespaceriver/village
	name = "\improper Planet Village"
	icon_state = "4"
	requires_power = FALSE

/area/map_template/bluespaceriver/village/h1
	name = "\improper House 1"
	icon_state = "a"

/area/map_template/bluespaceriver/village/h2
	name = "\improper House 2"
	icon_state = "b"

/area/map_template/bluespaceriver/village/h3
	name = "\improper House 3"
	icon_state = "c"

/area/map_template/bluespaceriver/village/h4
	name = "\improper House 4"
	icon_state = "d"

/area/map_template/bluespaceriver/village/h5
	name = "\improper House 5"
	icon_state = "e"

/area/map_template/bluespaceriver/village/h6
	name = "\improper House 6"
	icon_state = "f"

/area/map_template/bluespaceriver/village/h6/a
	name = "\improper House 6-A"

/area/map_template/bluespaceriver/village/h6/b
	name = "\improper House 6-B"

/area/map_template/bluespaceriver/village/h6/c
	name = "\improper House 6-C"

/area/map_template/bluespaceriver/village/mansion
	name = "\improper Mansion"
	icon_state = "4"

/area/map_template/bluespaceriver/village/mansion/garage
	name = "\improper Mansion Garage"
	icon_state = "4"

/area/map_template/bluespaceriver/village/mansion/hall
	name = "\improper Mansion Hall"
	icon_state = "5"

/area/map_template/bluespaceriver/village/mansion/library
	name = "\improper Mansion Library"
	icon_state = "6"

/area/map_template/bluespaceriver/village/mansion/kitchen
	name = "\improper Mansion Kitchen"
	icon_state = "6"

/area/map_template/bluespaceriver/village/mansion/office
	name = "\improper Mansion"
	icon_state = "7"

/area/map_template/bluespaceriver/village/mansion/lounge
	name = "\improper Mansion Lounge"
	icon_state = "7"

/area/map_template/bluespaceriver/village/mansion/cloakroom
	name = "\improper Mansion Cloakroom"
	icon_state = "8"

/area/map_template/bluespaceriver/village/mansion/main_bath
	name = "\improper Mansion Bathroom"
	icon_state = "9"

/area/map_template/bluespaceriver/village/mansion/rooms
	name = "\improper Mansion Rooms"
	icon_state = "4"

/area/map_template/bluespaceriver/village/mansion/rooms/a
	name = "\improper Mansion Room A"
	icon_state = "a"

/area/map_template/bluespaceriver/village/mansion/rooms/a/office
	name = "\improper Mansion Room A Office"

/area/map_template/bluespaceriver/village/mansion/rooms/a/bath
	name = "\improper Mansion Room A Bathroom"

/area/map_template/bluespaceriver/village/mansion/rooms/b
	name = "\improper Mansion Room B"
	icon_state = "b"

/area/map_template/bluespaceriver/village/mansion/rooms/b/office
	name = "\improper Mansion Room B Office"

/area/map_template/bluespaceriver/village/mansion/rooms/b/bath
	name = "\improper Mansion Room B Bathroom"

/area/map_template/bluespaceriver/village/mansion/rooms/c
	name = "\improper Mansion Room C"
	icon_state = "c"

/area/map_template/bluespaceriver/village/mansion/rooms/c/office
	name = "\improper Mansion Room C Office"

/area/map_template/bluespaceriver/village/mansion/rooms/c/bath
	name = "\improper Mansion Room C Bathroom"

/area/map_template/bluespaceriver/village/mansion/rooms/d
	name = "\improper Mansion Room D"
	icon_state = "d"

/area/map_template/bluespaceriver/village/mansion/rooms/d/office
	name = "\improper Mansion Room D Office"

/area/map_template/bluespaceriver/village/mansion/rooms/d/bath
	name = "\improper Mansion Room D Bathroom"

/area/map_template/bluespaceriver/sector
	name = "\improper Sector-0"
	icon_state = "7"
	requires_power = FALSE

/area/map_template/bluespaceriver/sector/cp
	name = "\improper Sector-0 Checkpoint"
	icon_state = "8"

/area/map_template/bluespaceriver/sector/inner
	name = "\improper Sector-0 Indoors"
	icon_state = "9"

/area/map_template/bluespaceriver/sector/barrack
	name = "\improper Sector-0 Barracks"
	icon_state = "11"

/area/map_template/bluespaceriver/sector/command
	name = "\improper Sector-0 HQ"
	icon_state = "12"

/area/map_template/bluespaceriver/sector/hospital
	name = "\improper Sector-0 Hospital"
	icon_state = "13"

/area/map_template/bluespaceriver/sector/mess
	name = "\improper Sector-0 Galley"
	icon_state = "14"

/area/map_template/bluespaceriver/sector/main_build
	name = "\improper Sector-0 Main Building"
	icon_state = "15"

/area/map_template/bluespaceriver/sector/main_build/virology
	name = "\improper Sector-0 Virology"
	icon_state = "16"

/area/map_template/bluespaceriver/sector/main_build/office
	name = "\improper Sector-0 Office"
	icon_state = "16"

/area/map_template/bluespaceriver/sector/main_build/storage
	name = "\improper Sector-0 Storage"
	icon_state = "17"

/area/map_template/bluespaceriver/surface
	name = "\improper Arctic Planet Surface"
	icon_state = "2"
	ambience = list('mods/_fd/_maps/new_blueriver/sounds/cold_outside1.ogg', 'mods/_fd/_maps/new_blueriver/sounds/cold_outside2.ogg')
	sound_env = FOREST
	base_turf = /turf/simulated/floor/exoplanet/snow
	planetary_surface = TRUE

/area/map_template/bluespaceriver/underground
	name = "\improper Arctic Planet Underground"
	icon_state = "18"
	sound_env = CAVE
	base_turf = /turf/simulated/floor/exoplanet/barren
	planetary_surface = TRUE

/area/map_template/bluespaceriver/underground/cave
	name = "\improper Underground Cave"
	icon_state = "17"
	sound_env = PSYCHOTIC
