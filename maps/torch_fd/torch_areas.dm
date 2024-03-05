/area/bubble_hangar/start
	name = "\improper Bubble"
	icon_state = "shuttlered"
	requires_power = 1
	dynamic_lighting = 1
	area_flags = AREA_FLAG_RAD_SHIELDED | AREA_FLAG_ION_SHIELDED
	req_access = list(access_guppy)

/area/butterfly_hangar
	name = "\improper Butterfly"
	icon_state = "shuttlered"
	requires_power = 1
	dynamic_lighting = 1
	area_flags = AREA_FLAG_RAD_SHIELDED | AREA_FLAG_ION_SHIELDED

/area/butterfly_hangar/cockpit

/area/quartermaster/garage
	name = "\improper 'Triceratops' Garage"
	icon_state = "toxstorage"
	req_access = list(list(access_hangar, access_cargo))

/area/quartermaster/hangar/top
	name = "\improper Hangar Upper Walkway"
	req_access = list()

/area/quartermaster/flightcontrol
	name = "\improper Flight Control Tower"
	icon_state = "hangar"
	req_access = list(access_hangar)

/area/hydroponics/storage
	name = "\improper Hydroponics Storage"

/area/tcommsat/storage
	name = "\improper Telecoms Storage"
	icon_state = "tcomsatstore"

/area/crew_quarters/head/sauna2
	name = "\improper Second Bathhouse"
	icon_state = "sauna"

/area/crew_quarters/sleep/cryo/cabin1
	name = "\improper Third Deck General Cabin #1"

/area/crew_quarters/sleep/cryo/cabin2
	name = "\improper Third Deck General Cabin #2"

/area/crew_quarters/sleep/cryo/cabin3
	name = "\improper Third Deck General Cabin #3"

/area/crew_quarters/sleep/cryo/cabin4
	name = "\improper Third Deck General Cabin #4"

/area/turret_protected/ai_upload
	name = "\improper AI Upload Chamber"
	icon_state = "ai_upload"
	ambience = list('sound/ambience/ambimalf.ogg')
	req_access = list(access_ai_upload)

/area/turret_protected/ai_upload_foyer
	name = "\improper  AI Upload Access"
	icon_state = "ai_foyer"
	ambience = list('sound/ambience/ambimalf.ogg')
	sound_env = SMALL_ENCLOSED
	req_access = list(access_ai_upload)

/area/engineering/drone_fabrication
	name = "\improper Engineering Drone Fabrication"
	icon_state = "drone_fab"
	sound_env = SMALL_ENCLOSED
	req_access = list(access_robotics)

/area/crew_quarters/head/aux
	name = "\improper First Deck Head"

/area/rnd/rnd_sec
	name = "\improper Research Checkpoint"
	icon_state = "rnd_sec"
	req_access = list(list(access_liaison, access_research_security))

/area/turret_protected/ai
	name = "\improper AI Chamber"
	icon_state = "ai_chamber"
	ambience = list('sound/ambience/ambimalf.ogg')
	req_access = list(access_ai_upload)

/area/turret_protected/ai_foyer
	name = "\improper AI Chamber Foyer"
	icon_state = "ai_foyer"
	sound_env = SMALL_ENCLOSED
	req_access = list(access_ai_upload)

/area/turret_protected/ai_outer_chamber
	name = "\improper Outer AI Chamber"
	icon_state = "ai_chamber"
	sound_env = SMALL_ENCLOSED
	req_access = list(access_ai_upload)

/area/aquila/head
	name = "\improper SEV Aquila - Head"

/area/aquila/mess
	name = "\improper SEV Aquila - Mess Hall"

/area/aquila/passenger
	name = "\improper SEV Aquila - Passenger Compartment"

/area/aquila/maintenance
	name = "\improper SEV Aquila - Maintenance"
	req_access = list(access_solgov_crew)

/area/aquila/secure_storage
	name = "\improper SEV Aquila - Secure Storage"
	req_access = list(access_aquila)

/area/fd/end
	name = "\improper Centcom"
	icon_state = "centcom"
	requires_power = 0
	dynamic_lighting = 1

/area/centcom
	name = "\improper SCG Observatory"
	base_turf = /turf/unsimulated/floor/plating

/area/centcom/control/command
	name = "Observatory Command"

/area/centcom/control/hallways
	name = "Observatory Command Hallways"

/area/centcom/control/meeting
	name = "Observatory Command Meeting Room"

/area/centcom/control/conference
	name = "Observatory Command Conference Room"

/area/centcom/control/lounge
	name = "Observatory Command Lounge"

/area/centcom/hallway
	name = "Observatory Hallway"

/area/centcom/hallway/adherent
	name = "Observatory Adherent Maint"

/area/centcom/engineering
	name = "Observatory Engineering"

/area/centcom/engineering/reactor
	name = "Observatory Reactor"

/area/centcom/engineering/control
	name = "Observatory Reactor Control"

/area/centcom/engineering/equipment
	name = "Observatory Engineering Equipment"

/area/centcom/arrivals
	name = "Observatory Arrivals"

/area/centcom/arrivals/docks
	name = "Observatory Docks"

/area/centcom/mess
	name = "Observatory Mess Hall"

/area/centcom/mess/kitchen
	name = "Observatory Kitchen"

/area/centcom/office
	name = "Observatory Office"

/area/centcom/office/iccgn
	name = "Observatory ICCGN Representative"

/area/centcom/office/hephaestus
	name = "Observatory Hephaestus Representative"

/area/centcom/office/screll
	name = "Observatory Scrells Representative"

/area/centcom/office/dais
	name = "Observatory DAIS Representative"

/area/centcom/office/takahashi
	name = "Observatory Ward-Takahashi Representative"

/area/centcom/office/nanotrasen
	name = "Observatory Nanotrasen Representative"

/area/centcom/office/ftu
	name = "Observatory FTU Representative"

/area/centcom/office/zeng
	name = "Observatory Zeng-Hu Representative"

/area/centcom/office/grayson
	name = "Observatory GML Representative"

/area/centcom/beauro
	name = "Beauro 12"

/area/centcom/test
	name = "\improper Observatory Testing Facility"
