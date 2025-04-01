//	Observer Pattern Implementation: Hands Swapped
//		Registration type: /mob
//
//		Raised when: A mob has swapped hands.
//
//		Arguments that the called proc should expect:
//			/mob/swapper: The mob that swapped hands.
//

GLOBAL_TYPED_NEW(hands_swapped_event, /singleton/observ/hands_swapped)

/singleton/observ/hands_swapped
	name = "Hands Swapped"
	expected_type = /mob
