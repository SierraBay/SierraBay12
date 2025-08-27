//	Observer Pattern Implementation: Equipped
//		Registration type: /mob
//
//		Raised when: A mob equips an item.
//
//		Arguments that the called proc should expect:
//			/mob/equipper:  The mob that equipped the item.
//			/obj/item/item: The equipped item.
//			slot:           The slot equipped to.

GLOBAL_TYPED_NEW(mob_equipped_event, /singleton/observ/mob_equipped)

/singleton/observ/mob_equipped
	name = "Mob Equipped"
	expected_type = /mob

//	Observer Pattern Implementation: Equipped
//		Registration type: /obj/item
//
//		Raised when: A mob equips an item.
//
//		Arguments that the called proc should expect:
//			/obj/item/item: The equipped item.
//			/mob/equipper:  The mob that equipped the item.
//			slot:           The slot equipped to.

GLOBAL_TYPED_NEW(item_equipped_event, /singleton/observ/item_equipped)

/singleton/observ/item_equipped
	name = "Item Equipped"
	expected_type = /obj/item
