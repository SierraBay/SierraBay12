// Structures that store things!
/obj/structure/storage
	name = "filing cabinet"
	desc = "A large cabinet with drawers."
	icon = 'mods/_fd/structure_storage/icons/storage.dmi'
	icon_state = "chestdrawer_white"
	density = TRUE
	anchored = TRUE
	atom_flags = ATOM_FLAG_NO_TEMP_CHANGE | ATOM_FLAG_CLIMBABLE
	obj_flags = OBJ_FLAG_ANCHORABLE
	var/obj/item/storage/internal/structure/storage
	/// The number of storage slots in this container.
	var/slots = 6
	/// Max size of objects that this object can store (in effect only if can_hold isn't set)
	var/max_w_class = ITEM_SIZE_NORMAL
	/// Total storage cost of items this can hold. Will be autoset based on storage_slots if left null.
	var/storage_space = null
	/// Mob can enter this container?
	var/mob_can_enter = FALSE

/obj/structure/storage/Initialize()
	. = ..()
	storage = new/obj/item/storage/internal/structure(src, slots, max_w_class, storage_space)

/obj/item/storage/internal/structure/New(obj/MI)
	..()

/obj/structure/storage/Destroy()
	QDEL_NULL(storage)
	. = ..()

/obj/structure/storage/attack_hand(mob/user as mob)
	if (storage.handle_attack_hand(user))
		..(user)

/obj/structure/storage/MouseDrop(obj/over_object as obj)
	if (mob_can_enter)
		if (storage.handle_mousedrop(usr, over_object))
			..(over_object)
	return

/obj/structure/storage/emp_act(severity)
	storage.emp_act(severity)
	..()

/obj/structure/storage/chestdrawer
	name = "chest drawer"
	icon_state = "chestdrawer_walnut"
	slots = 8
	storage_space = 15

/obj/structure/storage/nightstand
	name = "nightstand"
	icon_state = "nightstand"
	slots = null
	storage_space = 10
	max_w_class = ITEM_SIZE_SMALL

/obj/structure/storage/chest
	name = "chest"
	icon_state = "chestdrawer"
	slots = null
	storage_space = 25
	max_w_class = ITEM_SIZE_LARGE

/obj/structure/storage/chest/wardrobe
	name = "wardrobe"
	icon_state = "wardrobe"
	slots = null
	storage_space = 35
	max_w_class = ITEM_SIZE_LARGE

/obj/structure/storage/chest/wardrobe2
	name = "wardrobe"
	icon_state = "wardrobe2"
	slots = null
	storage_space = 32
	max_w_class = ITEM_SIZE_NORMAL

/obj/structure/storage/vehicles
	name = "containment unit"
	icon_state = "container"
	density = FALSE
	slots = null
	storage_space = 20
	max_w_class = ITEM_SIZE_NORMAL
	atom_flags = ATOM_FLAG_NO_TEMP_CHANGE
	obj_flags = OBJ_FLAG_CONDUCTIBLE

/obj/structure/storage/wall
	name = "wall cabinet"
	icon_state = "wallcabinet"
	density = FALSE
	slots = null
	storage_space = 10
	max_w_class = ITEM_SIZE_NORMAL
	atom_flags = ATOM_FLAG_NO_TEMP_CHANGE
	obj_flags = OBJ_FLAG_CONDUCTIBLE

/obj/structure/storage/table
	name = "table drawer"
	icon_state = "table_drawer"
	slots = null
	storage_space = 10
	density = FALSE
	max_w_class = ITEM_SIZE_SMALL
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	var/can_be_placed_on = /obj/structure/table
	var/should_be_destroyed = TRUE

/obj/structure/storage/table/Initialize()
	. = ..()
	var/obj/A = locate(can_be_placed_on) in loc
	if(!istype(A, can_be_placed_on))
		if(should_be_destroyed)
			no_place()
//	START_PROCESSING(SSprocessing, src)
/*
/obj/structure/storage/table/Process()
	. = ..()
	visible_message("[src] Нюхает тёрф под собой")
	var/obj/A = locate(can_be_placed_on) in loc
	visible_message("[src] Нашёл [A]!")
	if(!istype(A, can_be_placed_on))
		visible_message("МЫ НЕ МОЖЕМ ПОСТАВИТЬ [src] НА [A]")
		if(should_be_destroyed)
			visible_message("РАЗЪЁБЫВАЕМ [src]")
			no_place()
*/
/obj/structure/storage/table/proc/no_place()
	storage.empty_all()
	visible_message("<span class='warning'>\The [src] breaks down, scattering everything that was inside!</span>")
	new /obj/item/stack/material/steel(src.loc)
	src.Destroy()

/obj/structure/storage/table/attackby(obj/item/W, mob/user, click_params)
	if(isCrowbar(W) && user.a_intent == I_HURT)
		to_chat(user, "<span class='danger'>You are start to take down \the [src]!</span>")
		if(W.in_use)
			return
		W.in_use = 1
		if(!do_after(user, 30, W))
			W.in_use = 0
			to_chat(user, "<span class='danger'>You must be still to take down \the [src]!</span>")
			return
		W.in_use = 0
		no_place()
	..()

/obj/item/storage/internal/structure/New(newloc, slots, slot_size, storage_space)
	storage_slots = slots
	max_w_class = slot_size
	max_storage_space = storage_space
	..()

/obj/item/storage/internal/structure/handle_attack_hand(mob/user as mob)

	if(user in range(1, master_item.loc))
		src.add_fingerprint(user)
		src.open(user)
		return 0

	for(var/mob/M in range(1, master_item.loc))
		if (M.s_active == src)
			src.close(M)
	return 1

/obj/item/storage/proc/empty_all()
	var/turf/T = get_turf(src)
	for(var/obj/item/I in contents)
		remove_from_storage(I, T, 1)
	finish_bulk_removal()
