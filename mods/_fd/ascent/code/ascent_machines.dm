MANTIDIFY(/obj/machinery/power/apc/hyper, "mantid power node", "power controller")
MANTIDIFY(/obj/machinery/atmospherics/unary/vent_pump/on, "mantid atmosphere outlet", "vent")
MANTIDIFY(/obj/machinery/atmospherics/unary/vent_scrubber/on, "mantid atmosphere intake", "scrubber")
MANTIDIFY(/obj/machinery/hologram/holopad/longrange, "mantid holopad", "holopad")
MANTIDIFY(/obj/machinery/optable, "mantid operating table", "operating table")
MANTIDIFY(/obj/machinery/door/airlock/external/bolted, "mantid airlock", "door")
MANTIDIFY(/obj/machinery/porta_turret, "mantid automatic alien-lifeform defense system", "turret")
MANTIDIFY(/obj/machinery/power/shield_generator, "mantid shield generator", "shield")

/obj/machinery/optable/ascent
	construct_state = /singleton/machine_construction/default/no_deconstruct
	base_type = /obj/machinery/optable
	color = "#952abf"

/obj/machinery/portable_atmospherics/hydroponics/ascent
	name = "mantid algae vat"
	desc = "Some kind of strange alien hydroponics technology."
	icon = 'mods/_fd/ascent/icons/mantid_hydroponics.dmi'
	closed_system = TRUE
	construct_state = /singleton/machine_construction/default/no_deconstruct
	base_type = /obj/machinery/portable_atmospherics/hydroponics

// No maintenance needed.
/obj/machinery/portable_atmospherics/hydroponics/ascent/Process()
	if(dead)
		seed = null
		update_icon()
	if(!seed)
		seed = SSplants.seeds["algae"]
		update_icon()
	waterlevel = 100
	nutrilevel = 10
	pestlevel = 0
	weedlevel = 0
	mutation_level = 0
	health = 100
	sampled = 0
	. = ..()

/obj/machinery/atmospherics/unary/vent_scrubber/on/ascent/reset_scrubbing()
	. = ..()
	remove_from_scrubbing(GAS_METHYL_BROMIDE)
	add_to_scrubbing(GAS_NITROGEN)

/obj/machinery/atmospherics/unary/vent_scrubber/on/ascent/shuttle
	stock_part_presets = list(
		/singleton/stock_part_preset/radio/receiver/vent_scrubber/shuttle = 1,
		/singleton/stock_part_preset/radio/event_transmitter/vent_scrubber/shuttle = 1
	)
/obj/machinery/recharge_station/ascent
	name = "mantid recharging dock"
	desc = "An oddly organic aperture stuffed with power connectors."
	icon = 'mods/_fd/ascent/icons/mantid_charger.dmi'
	overlay_icon = 'mods/_fd/ascent/icons/mantid_charger.dmi'
	construct_state = /singleton/machine_construction/default/no_deconstruct
	base_type = /obj/machinery/recharge_station

/obj/machinery/body_scanconsole/ascent
	name = "mantid scanner console"
	desc = "Some kind of strange alien console technology."
	req_access = list(access_ascent)
	icon = 'mods/_fd/ascent/icons/ascent_sleepers.dmi'
	construct_state = /singleton/machine_construction/default/no_deconstruct
	base_type = /obj/machinery/body_scanconsole

/obj/machinery/bodyscanner/ascent
	name = "mantid body scanner"
	desc = "Some kind of strange alien body scanning technology."
	icon = 'mods/_fd/ascent/icons/ascent_sleepers.dmi'
	construct_state = /singleton/machine_construction/default/no_deconstruct
	base_type = /obj/machinery/bodyscanner

/obj/machinery/sleeper/ascent
	name = "mantid sleeper"
	desc = "Some kind of strange alien sleeper technology."
	icon = 'mods/_fd/ascent/icons/ascent_sleepers.dmi'
	base_type = /obj/machinery/sleeper
	construct_state = /singleton/machine_construction/default/no_deconstruct
	base_chemicals = list("Spaceacillin" = /datum/reagent/spaceacillin, "Bromide" = /datum/reagent/toxin/bromide, "Dylovene" = /datum/reagent/dylovene, "Inaprovaline" = /datum/reagent/inaprovaline)

/obj/machinery/fabricator/ascent
	name = "\improper Ascent nanofabricator"
	desc = "A squat, complicated fabrication system clad in purple polymer."
	icon = 'icons/obj/machines/fabricators/nanofabricator.dmi'
	icon_state = "nanofab"
	base_icon_state = "nanofab"
	req_access = list(access_ascent)
	base_type = /obj/machinery/fabricator
	construct_state = /singleton/machine_construction/default/no_deconstruct

/obj/machinery/power/apc/hyper/ascent
	req_access = list(access_ascent)
	base_type = /obj/machinery/power/apc

/obj/machinery/hologram/holopad/longrange/ascent
	req_access = list(access_ascent)

/obj/catwalk_plated/ascent
	plating_type = /singleton/flooring/tiling_ascent

/obj/machinery/door/airlock/ascent
	desc = "Some kind of strange alien door technology."
	icon =                'mods/_fd/ascent/icons/doors/base.dmi'
	bolts_file =          'mods/_fd/ascent/icons/doors/lights_bolts.dmi'
	deny_file =           'mods/_fd/ascent/icons/doors/lights_deny.dmi'
	lights_file =         'mods/_fd/ascent/icons/doors/lights_green.dmi'
	panel_file =          'mods/_fd/ascent/icons/doors/panel.dmi'
	sparks_damaged_file = 'mods/_fd/ascent/icons/doors/sparks_damaged.dmi'
	sparks_broken_file =  'mods/_fd/ascent/icons/doors/sparks_broken.dmi'
	welded_file =         'mods/_fd/ascent/icons/doors/welded.dmi'
	emag_file =           'mods/_fd/ascent/icons/doors/emag.dmi'

/obj/machinery/door/airlock/ascent/set_airlock_overlays(state)
	return

/obj/machinery/door/airlock/external/bolted/ascent
	door_color = COLOR_PURPLE
	stripe_color = COLOR_GRAY40

/obj/machinery/power/apc/hyper/ascent/north
	name = "north bump"
	pixel_x = 0
	pixel_y = 24
	dir = NORTH

/obj/machinery/power/apc/hyper/ascent/south
	name = "south bump"
	pixel_x = 0
	pixel_y = -24
	dir = SOUTH

/obj/machinery/power/apc/hyper/ascent/east
	name = "east bump"
	pixel_x = 24
	pixel_y = 0
	dir = EAST

/obj/machinery/power/apc/hyper/ascent/west
	name = "west bump"
	pixel_x = -24
	pixel_y = 0
	dir = WEST

/obj/machinery/light/ascent
	name = "mantid light"
	light_type = /obj/item/light/tube/ascent
	desc = "Some kind of strange alien lighting technology."

/obj/machinery/computer/ship/helm/ascent
	icon_state = "ascent"
	icon_keyboard = "ascent_key"
	icon_screen = "ascent_screen"
	req_access = list(access_ascent)
	construct_state = /singleton/machine_construction/default/panel_closed/computer/no_deconstruct
	base_type = /obj/machinery/computer/ship/helm

/obj/machinery/computer/ship/engines/ascent
	icon_state = "ascent"
	icon_keyboard = "ascent_key"
	icon_screen = "ascent_screen"
	req_access = list(access_ascent)
	construct_state = /singleton/machine_construction/default/panel_closed/computer/no_deconstruct
	base_type = /obj/machinery/computer/ship/engines

/obj/machinery/computer/ship/navigation/ascent
	icon_state = "ascent"
	icon_keyboard = "ascent_key"
	icon_screen = "ascent_screen"
	req_access = list(access_ascent)
	construct_state = /singleton/machine_construction/default/panel_closed/computer/no_deconstruct
	base_type = /obj/machinery/computer/ship/navigation

/obj/machinery/computer/ship/sensors/ascent
	icon_state = "ascent"
	icon_keyboard = "ascent_key"
	icon_screen = "ascent_screen"
	req_access = list(access_ascent)
	construct_state = /singleton/machine_construction/default/panel_closed/computer/no_deconstruct
	base_type = /obj/machinery/computer/ship/sensors
	print_language = LANGUAGE_MANTID_VOCAL

/obj/machinery/computer/ship/missiles/ascent
	icon_state = "ascent"
	icon_keyboard = "ascent_key"
	icon_screen = "ascent_screen"
	req_access = list(access_ascent)
	construct_state = /singleton/machine_construction/default/panel_closed/computer/no_deconstruct
	base_type = /obj/machinery/computer/ship/missiles

/obj/machinery/computer/air_control/ascent
	icon_state = "ascent"
	icon_keyboard = "ascent_key"
	req_access = list(access_ascent)
	construct_state = /singleton/machine_construction/default/panel_closed/computer/no_deconstruct
	base_type = /obj/machinery/computer/air_control/ascent

// This is an absolutely stupid machine. Basically the same as the debug one with some alterations.
// It is a placeholder for a proper reactor setup (probably a RUST descendant)
/obj/machinery/power/ascent_reactor
	name = "mantid fusion stack"
	desc = "A tall, gleaming assemblage of advanced alien machinery. It hums and crackles with restrained power."
	icon = 'icons/obj/machines/power/fusion_core.dmi'
	icon_state = "core1"
	density = TRUE
	color = COLOR_PURPLE
	var/on = TRUE
	var/output_power = 9000 KILOWATTS
	var/image/field_image
	var/field_color = COLOR_CYAN

/obj/machinery/power/ascent_reactor/attack_hand(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species.name != SPECIES_MANTID_GYNE && H.species.name != SPECIES_MONARCH_QUEEN)
			to_chat(H, SPAN_WARNING("You have no idea how to use \the [src]."))
			return
	else if(!istype(user, /mob/living/silicon/robot/flying/ascent))
		to_chat(user, SPAN_WARNING("You have no idea how to interface with \the [src]."))
		return

	user.visible_message(SPAN_NOTICE("\The [user] switches \the [src] [on ? "off" : "on"]."))
	on = !on
	update_icon()

/obj/machinery/power/ascent_reactor/on_update_icon()
	. = ..()

	if(!field_image)
		field_image = image(icon = 'icons/obj/machines/power/fusion_field.dmi', icon_state = "emfield_s1")
		field_image.color = field_color
		field_image.alpha = 50
		field_image.layer = SINGULARITY_LAYER
		field_image.appearance_flags |= RESET_COLOR

		var/matrix/M = matrix()
		M.Scale(3)
		field_image.transform = M

	if(on)
		overlays |= field_image
		set_light(0.8, 1, 6, l_color = COLOR_CYAN)
		icon_state = "core1"
	else
		overlays -= field_image
		set_light(0)
		icon_state = "core0"

/obj/machinery/power/ascent_reactor/Initialize()
	. = ..()
	update_icon()

/obj/machinery/power/ascent_reactor/Process()
	if(on)
		add_avail(output_power)

/obj/machinery/power/smes/buildable/preset/ascent
	name = "mantid battery"
	desc = "Some kind of strange alien SMES technology."
	icon = 'mods/_fd/ascent/icons/mantid_smes.dmi'
	overlay_icon = 'mods/_fd/ascent/icons/mantid_smes.dmi'
	uncreated_component_parts = list(
		/obj/item/stock_parts/smes_coil/advanced = 3
	)
	_input_maxed = TRUE
	_output_maxed = TRUE
	_input_on = TRUE
	_output_on = TRUE
	_fully_charged = TRUE

/obj/machinery/cryopod/ascent_spawn
	name = "mantid cryotank"
	desc = "A liquid-filled, cloudy tank with strange forms twitching inside."
	icon = 'icons/obj/machines/medical/cryogenics.dmi'
	icon_state = "cellold2"
	layer = 4.1

	base_icon_state = "cellold2"
	occupied_icon_state = "cellold2" //The cell looks the same whether something is in it or not
	on_store_visible_message = "lets out a quiet hiss as $occupant$ disappears into the cloudy liquid."
	on_enter_occupant_message = "You feel a cool touch on your skin as the cryogenic liquid permeates throughout your body. You go numb as your senses turn inward."
	announce_despawn = FALSE

/obj/machinery/computer/cryopod/ascent_spawn
	name = "cryotank oversight console"
	desc = "An interface between the gyne's brood and the cryotank oversight system."
	color = COLOR_VIOLET
	construct_state = null
	storage_type = "lifeforms"
	storage_name = "Cryotank Oversight Control"

	var/mob/living/carbon/announcer


/obj/machinery/computer/cryopod/ascent_spawn/Initialize()
	. = ..()
	announcer = new /mob/living/carbon(src)
	announcer.status_flags |= GODMODE
	announcer.name = "Cryotank Oversight"
	announcer.add_language(LANGUAGE_MANTID_BROADCAST)

/obj/machinery/computer/cryopod/ascent_spawn/Destroy()
	qdel(announcer)
	. = ..()

/obj/machinery/power/ascent_reactor/damaged
	name = "unstable mantid fusion stack"
	output_power = 2631 KILOWATTS
	field_color = COLOR_RED

/obj/machinery/porta_turret/ascent
	ailock = 1
	check_synth	 = 0
	check_access = 1
	check_anomalies = 1
	check_arrest = 0
	check_records = 0
	req_access = list(access_ascent)
	installation = /obj/item/gun/energy/particle
	shot_sound = 'sound/weapons/Laser3.ogg'

/obj/machinery/power/shield_generator/ascent
	base_type = /obj/machinery/power/shield_generator/ascent
	spinup_delay = 10

/obj/item/stock_parts/circuitboard/shield_generator/ascent
	name = "circuit board (mantid shield generator)"
	board_type = "machine"
	build_path = /obj/machinery/power/shield_generator/ascent
	origin_tech = list(TECH_MAGNET = 7, TECH_POWER = 5)
	req_components = list(
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/capacitor/super = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/smes_coil/advanced = 1)
	additional_spawn_components = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/keyboard = 1,
		/obj/item/stock_parts/power/apc/buildable = 1
	)
