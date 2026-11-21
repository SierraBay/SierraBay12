// Begin psi armour toggle.
/obj/screen/psi/armour
	name = "Psi-Armour"
	icon_state = "psiarmour_off"

/obj/screen/psi/armour/on_update_icon()
	..()
	if(invisibility == 0)
		icon_state = owner.psi.use_psi_armour ? "psiarmour_on" : "psiarmour_off"

/mob/living/carbon/human
	var/levitation = FALSE

/mob/living/carbon/human/Life()
	if(src.levitation)
		src.psi.spend_power(8)
	..()

/obj/screen/psi/armour/Click()
	if(!owner.psi)
		return
	owner.psi.use_psi_armour = !owner.psi.use_psi_armour
	if(owner.psi.use_psi_armour)
		to_chat(owner, SPAN_NOTICE("Теперь ты защищаешься от остальных атак с помощью псионики."))
	else
		to_chat(owner, SPAN_NOTICE("Теперь ты не защищаешься от остальных атак с помощью псионики."))
	update_icon()

// End psi armour toggle.

// Menu toggle.
/obj/screen/psi/toggle_psi_menu
	name = "Show/Hide Psi UI"
	icon_state = "arrow_left"
	var/obj/screen/psi/hub/controller

/obj/screen/psi/toggle_psi_menu/Initialize(mapload, obj/screen/psi/hub/_controller)
	. = ..()
	controller = _controller

/obj/screen/psi/toggle_psi_menu/Click()
	var/set_hidden = !hidden
	for(var/thing in controller.components)
		var/obj/screen/psi/psi = thing
		psi.hidden = set_hidden
	controller.update_icon()

/obj/screen/psi/toggle_psi_menu/on_update_icon()
	if(hidden)
		icon_state = "arrow_left"
	else
		icon_state = "arrow_right"
// End menu toggle.

// Facility toggle.
/obj/screen/psi/toggle_faculty
	var/image/disable_overlay
	var/faculty_id

/obj/screen/psi/toggle_faculty/New(mob/living/owner, id)
	disable_overlay = image(icon, "cooldown")
	faculty_id = id

	var/singleton/psionic_faculty/faculty = SSpsi.get_faculty(id)
	name = "Переключить школу [faculty ? faculty.name : id]"
	icon_state = faculty?.ui_icon_state || "[faculty_id]"
	..(owner)

/obj/screen/psi/toggle_faculty/on_update_icon()
	..()
	if(invisibility != 0)
		return

	if(owner.psi.ranks_stat[faculty_id])
		ClearOverlays()
	else
		AddOverlays(disable_overlay)

/obj/screen/psi/toggle_faculty/Click()
	if(!owner.psi)
		return

	var/faculty_stat = owner.psi.ranks_stat[faculty_id]
	owner.psi.ranks_stat[faculty_id] = !faculty_stat

	if(faculty_stat)
		sound_to(owner, sound('sound/effects/psi/power_fail.ogg', volume = 40))
		to_chat(owner, SPAN_NOTICE("Вы более не будете использовать силы школы [faculty_id]."))
	else
		sound_to(owner, sound('sound/effects/psi/power_unlock.ogg', volume = 40))
		to_chat(owner, SPAN_NOTICE("Вы вновь можете использовать силы школы [faculty_id]."))
	update_icon()
// End facility toggle
