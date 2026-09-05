#define UI_COMBAT_MODE ui_stamina

/mob/living
	var/obj/screen/combat_mode/combat_mode_icon

/obj/screen/combat_mode
	name = "combat mode"
	icon = 'mods/combat_mode/icons/combat_mode.dmi'
	icon_state = "combat_off"
	screen_loc = UI_COMBAT_MODE
	layer = HUD_BASE_LAYER

/obj/screen/combat_mode/Click()
	if(!usr || usr.stat)
		return
	var/mob/living/L = usr
	if(!istype(L))
		return
	L.toggle_combat_mode()

/obj/screen/combat_mode/proc/update_combat_icon(enabled)
	icon_state = enabled ? "combat_on" : "combat_off"

/datum/hud/human/FinalizeInstantiation(ui_style = 'icons/mob/screen1_White.dmi', ui_color = "#ffffff", ui_alpha = 255)
	. = ..()
	var/mob/living/L = mymob
	if(!istype(L) || !L.client)
		return

	var/obj/screen/combat_mode/button = new
	button.color = ui_color
	button.alpha = ui_alpha
	button.update_combat_icon(L.combat_mode)
	L.combat_mode_icon = button
	if(stamina_bar)
		stamina_bar.layer = HUD_ITEM_LAYER
	L.client.screen += button

/mob/living/remove_screen_obj_references()
	combat_mode_icon = null
	return ..()

#undef UI_COMBAT_MODE
