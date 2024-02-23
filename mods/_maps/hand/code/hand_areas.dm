/area/ship/hand
	name = "\improper Salvage Ship"
	icon_state = "shuttle2"
	req_access = list(access_away_hand)
	area_flags = AREA_FLAG_RAD_SHIELDED | AREA_FLAG_ION_SHIELDED

// HAND TODO BELOW

/area/ship/hand/crew
	name = "Cryo Storage"
	icon_state = "cryo"

/area/ship/hand/crew/miner_one
	name = "Prospectors Dormintories - One"
	icon_state = "crew_quarters"

/area/ship/hand/crew/miner_two
	name = "Prospectors Dormintories - Two"
	icon_state = "crew_quarters"

/area/ship/hand/crew/miner_three
	name = "Prospectors Dormintories - Three"
	icon_state = "crew_quarters"

/area/ship/hand/crew/miner_four
	name = "Prospectors Dormintories - Four"
	icon_state = "crew_quarters"


/area/ship/hand/crew/hallway/lower
	name = "\improper Lower Hallway - Center"

/area/ship/hand/crew/hallway/lower/fore
	name = "\improper Lower Hallway - Fore"
	icon_state = "hallF"

/area/ship/hand/crew/hallway/lower/aft
	name = "\improper Lower Hallway - Aft"
	icon_state = "hallA"

/area/ship/hand/crew/hallway/upper
	name = "\improper Upper Hallway - Center"

/area/ship/hand/crew/hallway/upper/fore
	name = "\improper Upper Hallway - Fore"
	icon_state = "hallF"

/area/ship/hand/crew/hallway/upper/aft
	name = "\improper Upper Hallway - Aft"
	icon_state = "hallA"

/area/ship/hand/crew/kitchen
	name = "\improper Galley"
	icon_state = "kitchen"
	req_access = list(access_away_hand)

/area/ship/hand/crew/toilet
	name = "\improper Head"
	icon_state = "locker"
	req_access = list(access_away_hand)

/area/ship/hand/cargo
	name = "Cargo Hold"
	icon_state = "quartstorage"

/area/ship/hand/cargo/emergency_armory
	name = "Emergency Armory"
	icon_state = "locker"

/area/ship/hand/engineering/hallway
	name = "\improper Engineering Hallway"
	icon_state = "green"
	req_access = list(access_away_hand)

/area/ship/hand/engineering/equipment
	name = "\improper Engineering Equipment"
	icon_state = "green"
	req_access = list(access_away_hand)

/area/ship/hand/engineering/storage
	name = "\improper Engineering Storage"
	icon_state = "green"
	req_access = list(access_away_hand)

/area/ship/hand/engineering/shield
	name = "\improper Shield Generator"
	icon_state = "green"
	req_access = list(access_away_hand)

/area/ship/hand/engineering/fussion
	name = "\improper Fussion Zone"
	icon_state = "red"
	req_access = list(access_away_hand)

/area/ship/hand/engineering/fussion/control
	name = "\improper Fussion Control"
	icon_state = "green"
	req_access = list(access_away_hand)



/area/ship/hand/medbay
	name = "\improper Medical Bay"
	icon_state = "medbay"
	req_access = list(access_away_hand)

/area/ship/hand/medbay/storage
	name = "\improper Medical Bay Lobby"
	icon_state = "medbay"
	req_access = list(access_away_hand)





/area/ship/hand/maintenance/lower
	name = "\improper Maintenance Lower Fore"
	icon_state = "amaint"
	req_access = list(access_away_hand)

/area/ship/hand/maintenance/upper/munition
	name = "\improper Ammunition Storage"
	req_access = list(access_away_hand)

/area/ship/hand/maintenance/upper/waste
	name = "\improper Waste Disposal"
	req_access = list(access_away_hand)

#define HAND_ENG_AMBIENCE list('sound/ambience/ambiatm1.ogg')
/area/ship/hand/maintenance/atmos
	name = "\improper Atmospherics Comparment"
	icon_state = "atmos"
	ambience = HAND_ENG_AMBIENCE
	req_access = list(access_away_hand)

/area/ship/hand/maintenance/atmos/fuel
	name = "\improper Fuel Comparment"

/area/ship/hand/maintenance/engine
	icon_state = "engine"
	ambience = HAND_ENG_AMBIENCE
	req_access = list(access_away_hand)

/area/ship/hand/maintenance/engine/port
	name = "\improper Port Thruster"

/area/ship/hand/maintenance/engine/starboard
	name = "\improper Starboard Thruster"

#undef HAND_ENG_AMBIENCE



/area/ship/hand/command/bridge
	name = "\improper Bridge"
	icon_state = "bridge"
	req_access = list(access_away_hand)

/area/ship/hand/command/eva
	name = "\improper Fleet EVA"
	req_access = list(access_away_hand)

/area/ship/hand/command/equipment
	name = "\improper Fleet Equipment"
	req_access = list(access_away_hand)

/area/ship/hand/command/hangar
	name = "\improper Hangar"
	icon_state = "purple"
	req_access = list(access_away_hand)

/area/ship/hand/command/cannon
	name = "\improper Impulse Cannon"
	icon_state = "yellow"
	req_access = list(access_away_hand)



/area/ship/hand/dock
	name = "\improper Docking Bay"
	icon_state = "entry_1"
	req_access = list(access_away_hand)
