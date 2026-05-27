/*
	Everything is encoded as strings because apparently that's how Byond rolls.

	"1,1" is the bottom left square of the user's screen.  This aligns perfectly with the turf grid.
	"1:2,3:4" is the square (1,3) with pixel offsets (+2, +4); slightly right and slightly above the turf grid.
	Pixel offsets are used so you don't perfectly hide the turf under them, that would be crappy.

	The size of the user's screen is defined by client.view (indirectly by world.view), in our case "15x15".
	Therefore, the top right corner (except during admin shenanigans) is at "15,15"
*/

// AI button defines
#define AI_BUTTON_PROC_BELONGS_TO_CALLER 1
#define AI_BUTTON_INPUT_REQUIRES_SELECTION 2

// AI HUD DEFINES
#define ui_ai_core "LEFT:6,BOTTOM:5"
#define ui_ai_announcement "LEFT+1:10,BOTTOM:5"
#define ui_ai_cam_track "LEFT+2:12,BOTTOM:5"
#define ui_ai_cam_light "LEFT+3:14,BOTTOM:5"
#define ui_ai_cam_change_network "LEFT+4:16,BOTTOM:5"
#define ui_ai_sensor "CENTER-2:18,BOTTOM:5"
#define ui_ai_crew_manifest "CENTER-1:20,BOTTOM:5"
#define ui_ai_take_image "CENTER:22,BOTTOM:5"
#define ui_ai_view_images "CENTER+1:24,BOTTOM:5"
#define ui_ai_state_laws "CENTER+2:26,BOTTOM:5"
#define ui_ai_call_shuttle "RIGHT-4:28,BOTTOM:5"

#define ui_ai_up "RIGHT-1:30,BOTTOM+1:5"
#define ui_ai_down "RIGHT-1:30,BOTTOM:5"

// AI: Customization
#define ui_ai_holo_change "RIGHT-1:30,BOTTOM+2:5"
#define ui_ai_color "RIGHT-1:30,BOTTOM+3:5"
#define ui_ai_core_icon "RIGHT-1:30,BOTTOM+4:5"
#define ui_ai_status "RIGHT-1:30,BOTTOM+5:5"

// AI: Tools
#define ui_ai_power_override "LEFT:6,TOP:0"
#define ui_ai_shutdown "LEFT+1:6,TOP:0"
#define ui_ai_holo_mov "LEFT:6, TOP-1:0"

// AI: Crew
#define ui_ai_crew_mon "RIGHT-1:30,TOP:0"
#define ui_ai_crew_rec "RIGHT-2:30, TOP:0"

// AI: Malf
#define ui_ai_malf_modules "LEFT:6, TOP-2:0"


// HUD Code

/mob/living/silicon/ai
	hud_type = /datum/hud/ai

/datum/hud/ai/proc/add_ai_button(screen_loc, name, icon_state, ai_verb, list/input_procs = null, list/input_args = null)
	adding += new /obj/screen/ai_button(null, screen_loc, name, icon_state, ai_verb, input_procs, input_args)

/datum/hud/ai/proc/sync_malf_buttons()
	if(!mymob || QDELETED(mymob) || !isAI(mymob))
		return

	var/mob/living/silicon/ai/A = mymob
	var/obj/screen/ai_button/malf_modules_button
	if(adding)
		for(var/obj/screen/ai_button/button in adding)
			if(button && !QDELETED(button) && button.ai_verb == /mob/living/silicon/ai/proc/ai_malf_modules)
				malf_modules_button = button
				break

	if(A.malfunctioning)
		if(!malf_modules_button)
			add_ai_button(ui_ai_malf_modules, "Malf Modules", "ai_research", /mob/living/silicon/ai/proc/ai_malf_modules)
			if(adding && length(adding))
				malf_modules_button = adding[length(adding)]
				if(A.client && hud_shown && malf_modules_button)
					A.client.screen |= malf_modules_button
	else if(malf_modules_button)
		if(A.client)
			A.client.screen -= malf_modules_button
		if(adding)
			adding -= malf_modules_button
		qdel(malf_modules_button)

/datum/hud/ai/FinalizeInstantiation()

	if(!isAI(mymob))
		return

	var/mob/living/silicon/ai/A = mymob
	if(!A.client)
		return

	src.adding = list()
	src.other = list()

	add_ai_button(ui_ai_core, "AI Core", "ai_core", /mob/living/silicon/ai/proc/core)
	add_ai_button(ui_ai_announcement, "AI Announcement", "announcement", /mob/living/silicon/ai/proc/ai_announcement)
	add_ai_button(ui_ai_cam_track, "Track With Camera", "track", /mob/living/silicon/ai/proc/ai_camera_track, list(TYPE_PROC_REF(/mob/living/silicon/ai, trackable_mobs) = (AI_BUTTON_PROC_BELONGS_TO_CALLER|AI_BUTTON_INPUT_REQUIRES_SELECTION)))
	add_ai_button(ui_ai_cam_light, "Toggle Camera Lights", "camera_light", /mob/living/silicon/ai/proc/toggle_camera_light)
	add_ai_button(ui_ai_cam_change_network, "Jump to Network", "camera", /mob/living/silicon/ai/proc/ai_network_change, list(TYPE_PROC_REF(/mob/living/silicon/ai, get_camera_network_list) = (AI_BUTTON_PROC_BELONGS_TO_CALLER|AI_BUTTON_INPUT_REQUIRES_SELECTION)))
	add_ai_button(ui_ai_sensor, "Set Sensor Mode", "ai_sensor", /mob/living/silicon/ai/proc/sensor_mode)
	add_ai_button(ui_ai_crew_manifest, "Show Crew Manifest", "manifest", /mob/living/silicon/ai/proc/show_crew_manifest)
	add_ai_button(ui_ai_take_image, "Toggle Camera Mode", "take_picture", /mob/living/silicon/ai/proc/ai_take_image)
	add_ai_button(ui_ai_view_images, "View Images", "view_images", /mob/living/silicon/ai/proc/ai_view_images)
	add_ai_button(ui_ai_state_laws, "State Laws", "state_laws", /mob/living/silicon/ai/proc/ai_checklaws)
	add_ai_button(ui_ai_call_shuttle, "Call Shuttle", "call_shuttle", /mob/living/silicon/ai/proc/ai_call_shuttle)
	add_ai_button(ui_ai_up, "Move Upwards", "ai_up", /mob/verb/up)
	add_ai_button(ui_ai_down, "Move Downwards", "ai_down", /mob/verb/down)
	add_ai_button(ui_ai_color, "Change Floor Color", "ai_floor", /mob/living/silicon/ai/proc/change_floor)
	add_ai_button(ui_ai_holo_change, "Change Hologram", "ai_holo_change", /mob/living/silicon/ai/proc/ai_hologram_change)
	add_ai_button(ui_ai_crew_mon, "Crew Monitor", "crew_monitor", /mob/living/silicon/ai/proc/show_crew_monitor)
	add_ai_button(ui_ai_power_override, "Toggle Power Override", "ai_p_override", /mob/living/silicon/ai/proc/ai_power_override)
	add_ai_button(ui_ai_shutdown, "Shutdown", "ai_shutdown", /mob/living/silicon/ai/proc/ai_shutdown)
	add_ai_button(ui_ai_holo_mov, "Toggle Hologram Movement", "ai_holo_mov", /mob/living/silicon/ai/proc/toggle_hologram_movement)
	add_ai_button(ui_ai_core_icon, "Pick Icon", "ai_core_pick", /mob/living/silicon/ai/proc/pick_icon)
	add_ai_button(ui_ai_status, "Pick Status", "ai_status", /mob/living/silicon/ai/proc/ai_statuschange)
	add_ai_button(ui_ai_crew_rec, "Crew Records", "ai_crew_rec", /mob/living/silicon/ai/proc/show_crew_records)

	sync_malf_buttons()

	A.client.screen = list()
	A.client.screen += src.adding + src.other

/mob/living/silicon/ai/update_hud()
	if(client)
		client.screen |= contents

// Undef
#undef ui_ai_core
#undef ui_ai_announcement
#undef ui_ai_cam_track
#undef ui_ai_cam_light
#undef ui_ai_cam_change_network
#undef ui_ai_sensor
#undef ui_ai_crew_manifest
#undef ui_ai_take_image
#undef ui_ai_view_images
#undef ui_ai_state_laws
#undef ui_ai_call_shuttle

#undef ui_ai_up
#undef ui_ai_down

#undef ui_ai_holo_change
#undef ui_ai_color
#undef ui_ai_core_icon
#undef ui_ai_status

#undef ui_ai_power_override
#undef ui_ai_shutdown
#undef ui_ai_holo_mov

#undef ui_ai_crew_mon
#undef ui_ai_crew_rec

#undef ui_ai_malf_modules
