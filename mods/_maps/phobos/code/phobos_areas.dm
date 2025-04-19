/area/ship/phobos
	icon = 'mods/_maps/phobos/icons/phobos_icons.dmi'
	req_access = list("ACCESS_PHOBOS")

/area/ship/phobos/ven
	name = "\improper Telecomms Relay"
	icon_state = "phobos"


/area/ship/phobos/bridge
	name = "\improper Patrol Craft Bridge"
	icon_state = "bridge"
	req_access = list(access_away_phobos, access_away_phobos_bridge)
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/ship/phobos/bridge/co_office
	name = "\improper Commanding Officer Office"
	icon_state = "bridge"
	req_access = list(access_away_phobos, access_away_phobos_commander)
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/ship/phobos/living
	name = "\improper Cryogenic Storage"
	icon_state = "cryo"

	holomap_color = HOLOMAP_AREACOLOR_CREW

/area/ship/phobos/living/mess
	name = "\improper Mess Hall"
	icon_state = "cryo"

	holomap_color = HOLOMAP_AREACOLOR_CREW

/area/ship/phobos/living/bunk
	name = "\improper Bunk Room"
	icon_state = "cryo"

	holomap_color = HOLOMAP_AREACOLOR_CREW

/area/ship/phobos/living/hydro
	name = "\improper Hydroponics"
	icon_state = "cryo"

	holomap_color = HOLOMAP_AREACOLOR_CREW

/area/ship/phobos/engine
	name = "\improper  Engineering"
	icon_state = "engineering"

	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/ship/phobos/engine/thrusterport
	name = "\improper Port Thrusters"
	icon_state = "engineering"

	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/ship/phobos/engine/thrusterstarboard
	name = "\improper Starboard Thrusters"
	icon_state = "engineering"

	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/ship/phobos/engine/atmos
	name = "\improper Atmospherics"
	icon_state = "engineering"

	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/ship/phobos/engine/solar
	name = "\improper Solars"
	area_flags = AREA_FLAG_EXTERNAL
	requires_power = 1
	always_unpowered = 1
	has_gravity = FALSE
	base_turf = /turf/space

/area/ship/phobos/engine/solar/port
	name = "\improper Port Solars"


/area/ship/phobos/engine/solar/starboard
	name = "\improper Starboard Solars"


/area/ship/phobos/hallway
	name = "\improper Hallway"
	icon_state = "hallway"

	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/ship/phobos/hallway/eva
	name = "\improper E.V.A."
	icon_state = "hallway"

	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/ship/phobos/security
	name = "\improper Security"
	icon_state = "security"
	req_access = list(access_away_phobos, access_away_phobos_security)
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/ship/phobos/security/lobby
	name = "\improper Security - Lobby"
	icon_state = "security"
	req_access = list(access_away_phobos, access_away_phobos_security)
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/ship/phobos/security/detective
	name = "\improper Security - Investigation"
	icon_state = "security"
	req_access = list(access_away_phobos, access_away_phobos_security)
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/ship/phobos/security/equipment
	name = "\improper Security - Equipment Room"
	icon_state = "security"
	req_access = list(access_away_phobos, access_away_phobos_security)
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/ship/phobos/security/questioning
	name = "\improper Security - Interview Room"
	icon_state = "security"
	req_access = list(access_away_phobos, access_away_phobos_security)
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/ship/phobos/medbay
	name = "\improper Medbay"
	icon_state = "medbay"

	holomap_color = HOLOMAP_AREACOLOR_MEDICAL
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/ship/phobos/medbay/chemistry
	name = "\improper Medbay - Infirmary"
	icon_state = "medbay"

	holomap_color = HOLOMAP_AREACOLOR_MEDICAL

/area/ship/phobos/disperser
	name = "\improper Disperser"
	icon_state = "disperser"

	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/ship/phobos/disperser/storage
	name = "\improper Disperser - Storage"
	icon_state = "disperser"

	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/ship/phobos/maint
	name = "\improper Maintenance"
	icon_state = "maintcentral"

	area_flags = AREA_FLAG_RAD_SHIELDED

/area/ship/phobos/maint/port
	name = "\improper - Port Maintenance"
	icon_state = "maintcentral"


/area/ship/phobos/maint/starboard
	name = "\improper - Starboard Maintenance"
	icon_state = "maintcentral"


/area/ship/phobos/maint/starboard/bridge
	name = "\improper - Bridge Starboard Maintenance"
	icon_state = "maintcentral"
