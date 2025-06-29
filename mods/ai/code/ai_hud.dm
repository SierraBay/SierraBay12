// HUD Code

/mob/living/silicon/ai
	hud_type = /datum/hud/ai

/datum/hud/ai/FinalizeInstantiation()

	if(!isAI(mymob))
		return

	var/mob/living/silicon/ai/A = mymob

	adding = list()
	adding += new /obj/screen/ai_button(null,
			ui_ai_core,
			"AI Core",
			"ai_core",
			/mob/living/silicon/ai/proc/core
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_announcement,
			"AI Announcement",
			"announcement",
			/mob/living/silicon/ai/proc/ai_announcement
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_cam_track,
			"Track With Camera",
			"track",
			/mob/living/silicon/ai/proc/ai_camera_track,
			list(TYPE_PROC_REF(/mob/living/silicon/ai, trackable_mobs) = (AI_BUTTON_PROC_BELONGS_TO_CALLER|AI_BUTTON_INPUT_REQUIRES_SELECTION))
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_cam_light,
			"Toggle Camera Lights",
			"camera_light",
			/mob/living/silicon/ai/proc/toggle_camera_light
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_cam_change_network,
			"Jump to Network",
			"camera",
			/mob/living/silicon/ai/proc/ai_network_change,
			list(TYPE_PROC_REF(/mob/living/silicon/ai, get_camera_network_list) = (AI_BUTTON_PROC_BELONGS_TO_CALLER|AI_BUTTON_INPUT_REQUIRES_SELECTION))
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_sensor,
			"Set Sensor Mode",
			"ai_sensor",
			/mob/living/silicon/ai/proc/sensor_mode
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_crew_manifest,
			"Show Crew Manifest",
			"manifest",
			/mob/living/silicon/ai/proc/show_crew_manifest
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_take_image,
			"Toggle Camera Mode",
			"take_picture",
			/mob/living/silicon/ai/proc/ai_take_image
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_view_images,
			"View Images",
			"view_images",
			/mob/living/silicon/ai/proc/ai_view_images
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_state_laws,
			"State Laws",
			"state_laws",
			/mob/living/silicon/ai/proc/ai_checklaws
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_call_shuttle,
			"Call Shuttle",
			"call_shuttle",
			/mob/living/silicon/ai/proc/ai_call_shuttle
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_up,
			"Move Upwards",
			"ai_up",
			/mob/verb/up
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_down,
			"Move Downwards",
			"ai_down",
			/mob/verb/down
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_color,
			"Change Floor Color",
			"ai_floor",
			/mob/living/silicon/ai/proc/change_floor
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_holo_change,
			"Change Hologram",
			"ai_holo_change",
			/mob/living/silicon/ai/proc/ai_hologram_change
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_crew_mon,
			"Crew Monitor",
			"crew_monitor",
			/mob/living/silicon/ai/proc/show_crew_monitor
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_power_override,
			"Toggle Power Override",
			"ai_p_override",
			/mob/living/silicon/ai/proc/ai_power_override
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_shutdown,
			"Shutdown",
			"ai_shutdown",
			/mob/living/silicon/ai/proc/ai_shutdown
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_holo_mov,
			"Toggle Hologram Movement",
			"ai_holo_mov",
			/mob/living/silicon/ai/proc/toggle_hologram_movement
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_core_icon,
			"Pick Icon",
			"ai_core_pick",
			/mob/living/silicon/ai/proc/pick_icon
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_status,
			"Pick Status",
			"ai_status",
			/mob/living/silicon/ai/proc/ai_statuschange
			)

	adding += new /obj/screen/ai_button(null,
			ui_ai_crew_rec,
			"Crew Records",
			"ai_crew_rec",
			/mob/living/silicon/ai/proc/show_crew_records
			)

	if(A.malfunctioning)
		adding += new /obj/screen/ai_button(null,
			ui_ai_research,
				"Select Research",
				"ai_research",
				/datum/game_mode/malfunction/verb/ai_select_research
				)

	if(A.malfunctioning && A.hardware == null)
		adding += new /obj/screen/ai_button(null,
			ui_ai_hardware,
				"Select Hardware",
				"ai_hardware",
				/datum/game_mode/malfunction/verb/ai_select_hardware
				)

	if(A.malfunctioning && A.hardware == /datum/malf_hardware/apu_gen)
		adding += new /obj/screen/ai_button(null,
			ui_ai_apu,
				"Toggle APU Generator",
				"ai_hardware",
				/datum/game_mode/malfunction/verb/ai_toggle_apu
				)

	if(A.malfunctioning && A.hardware == /datum/malf_hardware/core_bomb)
		adding += new /obj/screen/ai_button(null,
			ui_ai_self_destruct,
				"Self-Destruct Explosives",
				"ai_hardware",
				/datum/game_mode/malfunction/verb/ai_self_destruct
				)

	if(A.malfunctioning && A.system_override == 2)
		adding += new /obj/screen/ai_button(null,
			ui_ai_destroy,
				"Destroy Installation",
				"ai_hardware",
				/datum/game_mode/malfunction/verb/ai_destroy_station
				)

	A.client.screen = list()
	A.client.screen.Add(adding)

/mob/living/silicon/ai/update_hud()
	if(client)
		client.screen |= contents
