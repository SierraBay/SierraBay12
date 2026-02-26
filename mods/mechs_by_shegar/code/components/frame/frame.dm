#include "cart_check.dm"
#include "render.dm"
#include "tags_check.dm"
#include "use_tool.dm"

#include "use_tool\arms_install.dm"
#include "use_tool\body_install.dm"
#include "use_tool\cable_coil.dm"
#include "use_tool\crowbar.dm"
#include "use_tool\doubled_leg_instalation.dm"
#include "use_tool\legs_install.dm"
#include "use_tool\material_install.dm"
#include "use_tool\screwdriver_interaction.dm"
#include "use_tool\sensors_install.dm"
#include "use_tool\welder_interaction.dm"
#include "use_tool\wirecutter_interactio.dm"
#include "use_tool\wrench_interaction.dm"

/obj/structure/heavy_vehicle_frame
	name = "exosuit frame"
	desc = "The frame for an exosuit, apparently."
	icon = 'mods/mechs_by_shegar/icons/mech_parts.dmi'
	icon_state = "backbone"
	density = TRUE
	w_class = ITEM_SIZE_GARGANTUAN
	anchored = TRUE
	pixel_x = -8

	// Holders for the final product.
	var/obj/item/mech_component/sensors/head
	var/obj/item/mech_component/chassis/body
	var/obj/item/mech_component/manipulators/L_arm
	var/obj/item/mech_component/manipulators/R_arm
	var/obj/item/mech_component/propulsion/L_leg
	var/obj/item/mech_component/propulsion/R_leg
	var/is_wired = 0
	var/is_reinforced = 0
	var/set_name
	dir = SOUTH

/obj/item/frame_holder
	matter = list(MATERIAL_STEEL = 175000, MATERIAL_PLASTIC = 50000, MATERIAL_OSMIUM = 30000)

/obj/item/frame_holder/Initialize(mapload, newloc)
	..()
	new /obj/structure/heavy_vehicle_frame(newloc)
	return  INITIALIZE_HINT_QDEL

/obj/structure/heavy_vehicle_frame/set_color(new_colour)
	var/painted_component = FALSE
	for(var/obj/item/mech_component/comp in list(head, body, L_arm, R_arm, L_leg, R_leg))
		if(comp.set_color(new_colour))
			painted_component = TRUE
	if(painted_component)
		queue_icon_update()

/obj/structure/heavy_vehicle_frame/Destroy()
	QDEL_NULL(head)
	QDEL_NULL(body)
	QDEL_NULL(L_arm)
	QDEL_NULL(R_arm)
	QDEL_NULL(L_leg)
	QDEL_NULL(R_leg)
	. = ..()

/obj/structure/heavy_vehicle_frame/examine(mob/user)
	. = ..()
	if(!head)
		to_chat(user, SPAN_WARNING("It is missing sensors."))
	if(!body)
		to_chat(user, SPAN_WARNING("It is missing a chassis."))
	if(!L_arm)
		to_chat(user, SPAN_WARNING("It is missing left manipulator."))
	if(!R_arm)
		to_chat(user, SPAN_WARNING("It is missing left manipulator."))
	if(!L_leg)
		to_chat(user, SPAN_WARNING("It is missing left propulsion."))
	if(!R_leg)
		to_chat(user, SPAN_WARNING("It is missing left propulsion."))
	if(is_wired == FRAME_WIRED)
		to_chat(user, SPAN_WARNING("It has not had its wiring adjusted."))
	else if(!is_wired)
		to_chat(user, SPAN_WARNING("It has not yet been wired."))
	if(is_reinforced == FRAME_REINFORCED)
		to_chat(user, SPAN_WARNING("It has not had its internal reinforcement secured."))
	else if(is_reinforced == FRAME_REINFORCED_SECURE)
		to_chat(user, SPAN_WARNING("It has not had its internal reinforcement welded in."))
	else if(!is_reinforced)
		to_chat(user, SPAN_WARNING("It does not have any internal reinforcement."))

/obj/structure/heavy_vehicle_frame/on_update_icon()
	var/list/new_overlays = get_mech_images(list(head, body, L_arm, R_arm, L_leg, R_leg), layer)
	update_parts_images()
	if(body)
		set_density(TRUE)
		AddOverlays(get_mech_image(null, "[body.icon_state]_cockpit", body.icon, body.color))
		if(body.pilot_coverage < 100 || body.transparent_cabin)
			new_overlays += get_mech_image(null, "[body.icon_state]_open_overlay", body.icon, body.color)
	else
		set_density(FALSE)
	SetOverlays(new_overlays)
	if(density != opacity)
		set_opacity(density)

/obj/structure/heavy_vehicle_frame/set_dir()
	..(SOUTH)

/obj/structure/heavy_vehicle_frame/proc/install_component(obj/item/thing, mob/user)
	var/obj/item/mech_component/MC = thing
	if(istype(MC) && !MC.ready_to_install())
		to_chat(user, SPAN_WARNING("\The [MC] [MC.gender == PLURAL ? "are" : "is"] not ready to install."))
		return 0
	if(user)
		visible_message(SPAN_NOTICE("\The [user] begins installing \the [thing] into \the [src]."))
		if(!user.canUnEquip(thing) || !do_after(user, 3 SECONDS * user.skill_delay_mult(SKILL_DEVICES), src, DO_PUBLIC_UNIQUE) || user.get_active_hand() != thing)
			return
		if(!user.unEquip(thing))
			return
	thing.forceMove(src)
	visible_message(SPAN_NOTICE("\The [user] installs \the [thing] into \the [src]."))
	playsound(user.loc, 'sound/machines/click.ogg', 50, 1)
	return 1

/obj/structure/heavy_vehicle_frame/proc/uninstall_component(obj/item/component, mob/user)
	if(!istype(component) || (component.loc != src) || !istype(user))
		return FALSE
	if(!do_after(user, 4 SECONDS * user.skill_delay_mult(SKILL_DEVICES), src, DO_PUBLIC_UNIQUE) || component.loc != src)
		return FALSE
	user.visible_message(SPAN_NOTICE("\The [user] crowbars \the [component] off \the [src]."))
	component.forceMove(get_turf(src))
	user.put_in_hands(component)
	if(user.mob_size >= MOB_LARGE)
		to_chat(user, SPAN_NOTICE("You remove \the [component] off \the [src] without paying attention to its weight."))
	if(user.mob_size == MOB_MEDIUM)
		user.adjust_stamina(-15)
		to_chat(user, SPAN_WARNING("You feel a little unsteady when you remove \the [component] off \the [src]."))
	if(user.mob_size <= MOB_SMALL)
		user.adjust_stamina(-30)
		to_chat(user, SPAN_WARNING("You bend under the weight of \the [component] when you remove it off \the [src]."))
	playsound(user.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	return TRUE

/*
/obj/structure/heavy_vehicle_frame/proc/install_component(obj/item/thing, mob/user)
	var/obj/item/mech_component/MC = thing
	if(istype(MC) && !MC.ready_to_install())
		to_chat(user, SPAN_WARNING("\The [MC] [MC.gender == PLURAL ? "are" : "is"] not ready to install."))
		return 0
	if(user)
		visible_message(SPAN_NOTICE("\The [user] begins installing \the [thing] into \the [src]."))
		if(!do_after(user, 3 SECONDS * user.skill_delay_mult(SKILL_DEVICES), src, DO_PUBLIC_UNIQUE))
			return
	cart_check(thing)
	thing.forceMove(src)
	visible_message(SPAN_NOTICE("\The [user] installs \the [thing] into \the [src]."))
	playsound(user.loc, 'sound/machines/click.ogg', 50, 1)
	return 1

/obj/structure/heavy_vehicle_frame/proc/uninstall_component(obj/item/mech_component/component, mob/user)
	if(component.doubled_owner)
		component = component.doubled_owner
	if(!istype(component) || !istype(user))
		if(!component.doubled_owner && component.loc != src)
			return FALSE
		if(component.loc != src)
			return FALSE
	if(!do_after(user, 4 SECONDS * user.skill_delay_mult(SKILL_DEVICES), src, DO_PUBLIC_UNIQUE))
		return FALSE
	if(component.doubled_owner && component.loc != src)
		return FALSE
	user.visible_message(SPAN_NOTICE("\The [user] crowbars \the [component] off \the [src]."))
	component.forceMove(get_turf(src))
	playsound(user.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	return TRUE
*/

/obj/structure/heavy_vehicle_frame/proc/paint_spray_interaction(mob/living/user, color)
	var/obj/item/mech_component/choice = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	if(choice)
		choice.set_color(color)
		update_icon()
		update_parts_images()
		return TRUE
	return FALSE

/obj/structure/heavy_vehicle_frame/Initialize()
	. = ..()
	update_parts_images()

/obj/structure/heavy_vehicle_frame/on_update_icon()
	.=..()
	update_parts_images()
