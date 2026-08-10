/obj/item/storage/pill_bottle/blister
	name = "blister pack"
	desc = "commonly used as unit-dose packaging for pharmaceutical tablets, capsules or lozenges"
	icon = 'mods/medical/icons/blister.dmi'
	icon_state = "blister6"
	w_class = ITEM_SIZE_TINY
	storage_slots = 6
	contents_allowed = list(/obj/item/reagent_containers/pill)
	allow_quick_gather = FALSE
	allow_quick_empty = FALSE
	var/pill_color = "#ffffffff"

/obj/item/storage/pill_bottle/blister/on_update_icon()
	if(LAZYLEN(contents) && pill_color == "#ffffffff")
		var/obj/item/reagent_containers/pill/P = contents[1]
		pill_color = P.reagents.get_color()
		name = "[P.name] blister"
	var/image/I = image('mods/medical/icons/blister.dmi', icon_state = "[LAZYLEN(contents)]")
	I.color = pill_color
	ClearOverlays()
	AddOverlays(I)

/obj/item/storage/pill_bottle/blister/Initialize()
	. = ..()
	update_icon()

/obj/item/storage/pill_bottle/blister/use_after(mob/living/carbon/human/target, mob/living/user, click_parameters)
	if(!istype(target) || target.incapacitated() || isnull(target.client))
		return
	var/obj/item/reagent_containers/pill/I = contents[1]
	if(!I)
		return

	usr.visible_message(SPAN_NOTICE("\The [usr] holds out \the [I] to \the [target]."), SPAN_NOTICE("You hold out \the [I] to \the [target], waiting for them to accept it."))
	if(alert(target,"[usr] wants to give you \a [I]. Will you accept it?",,"Yes","No") == "No")
		target.visible_message(SPAN_NOTICE("\The [usr] tried to hand \the [I] to \the [target], but \the [target] didn't want it."))
		return

	if(!I) return
	if(!user.Adjacent(target))
		to_chat(usr, SPAN_WARNING("You need to stay in reaching distance while giving an object."))
		to_chat(target, SPAN_WARNING("\The [usr] moved too far away."))
		return
	if (contents[1] != I)
		to_chat(usr, SPAN_WARNING("You already gave this pill to someone."))
		to_chat(target, SPAN_WARNING("\The [usr] seems to have giving wrong pill to you."))
		return
	if (!target.HasFreeHand())
		to_chat(target, SPAN_WARNING("Your hands are full."))
		to_chat(usr, SPAN_WARNING("Their hands are full."))
		return
	if(user.incapacitated())
		return
	target.put_in_hands(I) // If this fails it will just end up on the floor, but that's fitting for things like dionaea.
	usr.visible_message(SPAN_NOTICE("\The [usr] handed \the [I] to \the [target]."), SPAN_NOTICE("You give \the [I] to \the [target]."))

/obj/item/storage/pill_bottle/blister/can_be_inserted()
	return 0

/obj/item/storage/pill_bottle/blister/two
	storage_slots = 2
	icon_state = "blister2"

/obj/item/storage/pill_bottle/blister/four
	storage_slots = 4
	icon_state = "blister4"
