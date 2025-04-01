//	Observer Pattern Implementation: Destroyed
//		Registration type: /datum
//
//		Raised when: A /datum instance is destroyed.
//
//		Arguments that the called proc should expect:
//			/datum/destroyed_instance: The instance that was destroyed.

GLOBAL_TYPED_NEW(destroyed_event, /singleton/observ/destroyed)

/singleton/observ/destroyed
	name = "Destroyed"
