/obj/item/organ/internal/augment/armor
	name = "subdermal armor"
	augment_slots = AUGMENT_ARMOR
	icon_state = "armor-chest"
	desc = "A flexible composite mesh designed to prevent tearing and puncturing of underlying tissue."
	augment_flags = AUGMENT_MECHANICAL | AUGMENT_BIOLOGICAL | AUGMENT_SCANNABLE | AUGMENT_INSPECTABLE
	var/brute_mult = 0.8
	var/burn_mult = 1

/obj/item/organ/internal/augment/armor/changeling
	name = "organic armor"
	icon_state = "endoarmor"
	augment_flags = AUGMENT_BIOLOGICAL
	status = ORGAN_CONFIGURE
	desc = "A collection of bone, chitin and tissue carefully wrapped around the chest cavity."
	brute_mult = 0.75

/obj/item/organ/internal/augment/armor/changeling/emp_act()
	SHOULD_CALL_PARENT(FALSE)
	return

/obj/item/organ/internal/augment/armor/changeling/Initialize()
	. = ..()
	if(ismob(loc))
		return
	visible_message(SPAN_DANGER("\The [src] rapidly decays and melts into a puddle of slime!"))
	new /obj/decal/cleanable/ling_vomit(loc)
	return QDEL_HINT_QUEUE
