// THROWAWAY: live numbers of the spread ring. Delete with its include line.
/client/var/ce_ring_debug = FALSE

/client/verb/ce_ring_debug_toggle()
	set name = "CE Ring Debug"
	set category = "Debug"
	ce_ring_debug = !ce_ring_debug
	to_chat(src, "CE ring debug [ce_ring_debug ? "ON: every cursor change is printed" : "OFF"]")
	if(!ce_ring_debug)
		return
	var/mob/living/carbon/shooter = mob
	if(!istype(shooter))
		to_chat(src, "not a carbon mob")
		return
	var/obj/item/gun/held = shooter.get_active_hand()
	to_chat(src, "view=[view] view-size=[winget(src, "mapwindow.map", "view-size")] zoom=[winget(src, "mapwindow.map", "zoom")] icon-size=[winget(src, "mapwindow.map", "icon-size")] map size=[winget(src, "mapwindow.map", "size")]")
	to_chat(src, "pixel aim=[ce_pixel_aim_enabled] physical hits=[ce_physical_hits_enabled] weapons skill=[shooter.get_skill_value(SKILL_WEAPONS)] gun=[held] ring gun=[shooter.ce_get_spread_ring_gun()]")
	if(istype(held))
		to_chat(src, "dispersion=[json_encode(held.dispersion)] one_hand_penalty=[held.one_hand_penalty] screen_shake=[held.screen_shake] next arcs=[json_encode(held.ce_get_next_spread_arcs(shooter))] stack gain=[held.ce_get_recoil_stack_gain(shooter)]")
	var/datum/extension/ce_spread_ring/ring = get_extension(shooter, /datum/extension/ce_spread_ring)
	if(ring)
		ring.ce_debug_print("now")
	else
		to_chat(src, "no ring extension")

/datum/extension/ce_spread_ring/proc/ce_debug_print(label)
	var/mob/living/carbon/shooter = holder
	if(!shooter.client?.ce_ring_debug)
		return
	var/atom/target = get_aim_target()
	var/turf/apex = shooter.loc
	var/distance = "?"
	if(target && isturf(apex))
		var/list/aim = target.ce_get_aim_point(hover_icon_x, hover_icon_y)
		var/list/center = apex.ce_get_tile_center()
		if(aim)
			distance = round(sqrt((aim[1] - center[1]) ** 2 + (aim[2] - center[2]) ** 2), 0.1)
	to_chat(shooter, "[label] t=[world.time]: radius=[radius] arc=[round(arc, 0.01)] stacks=[round(shooter.ce_get_recoil_stacks(), 0.01)] scale=[screen_scale] scale_view=[scale_view] target=[target] ([target?.type]) px=[hover_icon_x],[hover_icon_y] dist=[distance] tick=[recoil_tick_time]")

/datum/extension/ce_spread_ring/show()
	ce_debug_print("show")
	..()

/datum/extension/ce_spread_ring/read_screen_scale()
	..()
	ce_debug_print("scale read")

/mob/living/carbon/update_mouse_pointer()
	..()
	var/datum/extension/ce_spread_ring/ring = get_extension(src, /datum/extension/ce_spread_ring)
	ring?.ce_debug_print("update_mouse_pointer")
