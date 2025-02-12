/mob/living/exosuit/proc/Initialize_hardpoints()
	var/i = 1
	for(var/hardpoint in hardpoints)
		var/obj/screen/movable/exosuit/hardpoint/H = new(src, hardpoint)
		H.screen_loc = "1:6,[15-i]" //temp
		hardpoints_menu_elements |= H
		hardpoint_hud_elements[hardpoint] = H
		i++
	hardpoints_menu = new /obj/screen/exosuit/hardpoints_menu(src)
	hardpoints_menu.screen_loc = "1:6,14.5"
	hardpoints_menu.open_position = "1:6,[15.25-i]"
	hud_elements |= hardpoints_menu
