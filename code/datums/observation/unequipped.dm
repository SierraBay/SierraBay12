//	Observer Pattern Implementation: Unequipped (dropped)
//		Registration type: /mob
//
//		Raised when: A mob unequips/drops an item.
//
//		Arguments that the called proc should expect:
//			/mob/equipped:  The mob that unequipped/dropped the item.
//			/obj/item/item: The unequipped item.

GLOBAL_TYPED_NEW(mob_unequipped_event, /singleton/observ/mob_unequipped)

/singleton/observ/mob_unequipped
	name = "Mob Unequipped"
	expected_type = /mob

//	Observer Pattern Implementation: Unequipped (dropped)
//		Registration type: /obj/item
//
//		Raised when: A mob unequips/drops an item.
//
//		Arguments that the called proc should expect:
//			/obj/item/item: The unequipped item.
//			/mob/equipped:  The mob that unequipped/dropped the item.

GLOBAL_TYPED_NEW(item_unequipped_event, /singleton/observ/item_unequipped)

/singleton/observ/item_unequipped
	name = "Item Unequipped"
	expected_type = /obj/item
