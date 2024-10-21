/obj/structure/panic_button
	name = "distress beacon trigger"
	desc = "WARNING: Will deploy ship's distress beacon and request help. Misuse may result in fines and jail time."
	icon = 'packs/infinity/icons/obj/panicbutton.dmi'
	icon_state = "panicbutton"
	anchored = TRUE

	var/glass = TRUE
	var/launched = FALSE


/obj/structure/panic_button/on_update_icon()
	if(launched)
		icon_state = "[initial(icon_state)]_launched"
	else if(!glass)
		icon_state = "[initial(icon_state)]_open"
	else
		icon_state = "[initial(icon_state)]"

/obj/structure/panic_button/attack_hand(mob/living/user)
	if(!istype(user))
		return ..()

	if(user.incapacitated())
		return

	// Already launched
	if(launched)
		to_chat(user, "<span class='warning'>The button is already depressed; the beacon has been launched already.</span>")
	// Glass present
	else if(glass)
		if(user.a_intent == I_HURT)
			user.custom_emote(VISIBLE_MESSAGE, "smashes the glass on [src]!")
			glass = FALSE
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg')
			update_icon()
		else
			user.custom_emote(VISIBLE_MESSAGE, "pats [src] in a friendly manner.")
			to_chat(user, "<span class='warning'>If you're trying to break the glass, you'll have to hit it harder than that...</span>")
	// Must be !glass and !launched
	else if(!glass && !launched)
		user.custom_emote(VISIBLE_MESSAGE, "pushes the button on [src]!")
		playsound(src, get_sfx("button"))
		update_icon()
		launch(usr)

/obj/structure/panic_button/proc/launch(mob/living/user)
	var/sound/SND = sound('packs/infinity/sound/misc/emergency_beacon_launched.ogg') // Inside the loop because playsound_local modifies it for each person, so, need separate instances

	if(launched)
		return
	launched = TRUE

	var/overmap_sector

	if(GLOB.using_map.use_overmap)
		overmap_sector = map_sectors["[z]"]

	var/obj/overmap/visitable/S = overmap_sector
	if(!S)
		error("Distress button hit on z[z] but that's not an overmap sector...")
		return
	S.distress(user)
	playsound(src, SND, 25)
