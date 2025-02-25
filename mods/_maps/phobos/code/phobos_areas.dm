/area/phobos
	icon = 'mods/_maps/phobos/icons/phobos_icons.dmi'
	req_access = (access_away_phobos)


/area/phobos/ven
	name = "\improper Telecomms Relay"
	icon_state = "phobos"

/area/phobos/bridge
	name = "\improper Patrol Craft Bridge"
	icon_state = "bridge"
	req_access = (access_away_phobos_bridge)

/area/phobos/bridge/co_office
	name = "\improper Commanding Officer Office"
	icon_state = "bridge"
	req_access = (access_away_phobos_commander)

/area/phobos/living
	name = "\improper Cryogenic Storage"
	icon_state = "cryo"

/area/phobos/living/mess
	name = "\improper Mess Hall"
	icon_state = "cryo"

/area/phobos/living/bunk
	name = "\improper Bunk Room"
	icon_state = "cryo"

/area/phobos/living/hydro
	name = "\improper Hydroponics"
	icon_state = "cryo"

/area/phobos/engine
	name = "\improper  Engineering"
	icon_state = "engineering"

/area/phobos/engine/thrusterport
	name = "\improper Port Thrusters"
	icon_state = "engineering"

/area/phobos/engine/thrusterstarboard
	name = "\improper Starboard Thrusters"
	icon_state = "engineering"

/area/phobos/engine/atmos
	name = "\improper Atmospherics"
	icon_state = "engineering"

/area/phobos/engine/solar
	name = "\improper Solars"
	area_flags = AREA_FLAG_EXTERNAL
	requires_power = 1
	always_unpowered = 1
	has_gravity = FALSE
	base_turf = /turf/space
/area/phobos/engine/solar/port
	name = "\improper Port Solars"
/area/phobos/engine/solar/starboard
	name = "\improper Starboard Solars"
/area/phobos/hallway
	name = "\improper Hallway"
	icon_state = "hallway"

/area/phobos/hallway/eva
	name = "\improper E.V.A."
	icon_state = "hallway"

/area/phobos/security
	name = "\improper Security"
	icon_state = "security"
	req_access = (access_away_phobos_security)

/area/phobos/security/lobby
	name = "\improper Security - Lobby"
	icon_state = "security"

/area/phobos/security/detective
	name = "\improper Security - Investigation"
	icon_state = "security"

/area/phobos/security/equipment
	name = "\improper Security - Equipment Room"
	icon_state = "security"

/area/phobos/security/questioning
	name = "\improper Security - Interview Room"
	icon_state = "security"

/area/phobos/medbay
	name = "\improper Medbay"
	icon_state = "medbay"

/area/phobos/medbay/chemistry
	name = "\improper Medbay - Infirmary"
	icon_state = "medbay"

/area/phobos/disperser
	name = "\improper Disperser"
	icon_state = "disperser"

/area/phobos/disperser/storage
	name = "\improper Disperser - Storage"
	icon_state = "disperser"

/area/phobos/maint
	name = "\improper Maintenance"
	icon_state = "maintcentral"

/area/phobos/maint/port
	name = "\improper - Port Maintenance"
	icon_state = "maintcentral"

/area/phobos/maint/starboard
	name = "\improper - Starboard Maintenance"
	icon_state = "maintcentral"

/area/phobos/maint/starboard/bridge
	name = "\improper - Bridge Starboard Maintenance"
	icon_state = "maintcentral"
