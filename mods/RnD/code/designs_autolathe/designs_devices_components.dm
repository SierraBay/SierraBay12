/datum/design/autolathe/device_component
	build_path = /obj/item/stock_parts/console_screen
	category = list("Devices and Components")
	time = 8

/datum/design/autolathe/device_component/keyboard
	build_path = /obj/item/stock_parts/keyboard

/datum/design/autolathe/device_component/tesla_component
	build_path = /obj/item/stock_parts/power/apc/buildable

/datum/design/autolathe/device_component/radio_transmitter
	build_path = /obj/item/stock_parts/radio/transmitter/basic/buildable

/datum/design/autolathe/device_component/radio_transmitter_event
	build_path = /obj/item/stock_parts/radio/transmitter/on_event/buildable

/datum/design/autolathe/device_component/radio_receiver
	build_path = /obj/item/stock_parts/radio/receiver/buildable

/datum/design/autolathe/device_component/battery_backup_crap
	name = "battery backup (weak)"
	build_path = /obj/item/stock_parts/power/battery/buildable/crap

/datum/design/autolathe/device_component/battery_backup_stock
	name = "battery backup (standard)"
	build_path = /obj/item/stock_parts/power/battery/buildable/stock

/datum/design/autolathe/device_component/battery_backup_turbo
	name = "battery backup (rapid)"
	build_path = /obj/item/stock_parts/power/battery/buildable/turbo

/datum/design/autolathe/device_component/battery_backup_responsive
	name = "battery backup (responsive)"
	build_path = /obj/item/stock_parts/power/battery/buildable/responsive

/datum/design/autolathe/device_component/terminal
	build_path = /obj/item/stock_parts/power/terminal/buildable

/datum/design/autolathe/device_component/igniter
	build_path = /obj/item/device/assembly/igniter

/datum/design/autolathe/device_component/signaler
	build_path = /obj/item/device/assembly/signaler

/datum/design/autolathe/device_component/sensor_infra
	build_path = /obj/item/device/assembly/infra

/datum/design/autolathe/device_component/timer
	build_path = /obj/item/device/assembly/timer

/datum/design/autolathe/device_component/sensor_prox
	build_path = /obj/item/device/assembly/prox_sensor

/datum/design/autolathe/device_component/cable_coil
	build_path = /obj/item/stack/cable_coil/single

/datum/design/autolathe/device_component/electropack
	build_path = /obj/item/device/radio/electropack
	hidden = TRUE

/datum/design/autolathe/device_component/beartrap
	build_path = /obj/item/beartrap
	hidden = TRUE

/datum/design/autolathe/device_component/cell_device
	build_path = /obj/item/cell/device/standard

/datum/design/autolathe/device_component/ecigcartridge
	build_path = /obj/item/reagent_containers/ecig_cartridge/blank

/datum/design/autolathe/device_component/conveyor_construct
	build_path = /obj/item/conveyor_construct

/datum/design/autolathe/device_component/conveyor_switch_construct
	build_path = /obj/item/conveyor_switch_construct

/datum/design/autolathe/device_component/conveyor_switch_oneway_construct
	build_path = /obj/item/conveyor_switch_construct/oneway



///////COMPONENTS ITEMS MATTERS///////
/obj/item/device/assembly/igniter
	name = "igniter"
	matter = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 50)

/obj/item/device/assembly/infra
	name = "infrared emitter"
	matter = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 500)

/obj/item/device/assembly/mousetrap
	name = "mousetrap"
	matter = list(MATERIAL_STEEL = 100)

/obj/item/device/assembly/prox_sensor
	name = "proximity sensor"
	matter = list(MATERIAL_STEEL = 800, MATERIAL_GLASS = 200)

/obj/item/device/assembly/signaler
	name = "remote signaling device"

	origin_tech = list(TECH_MAGNET = 1)
	matter = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 200)

/obj/item/device/assembly/timer
	name = "timer"
	matter = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 50)

/obj/item/device/assembly/voice
	name = "voice analyzer"
	matter = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 50)
