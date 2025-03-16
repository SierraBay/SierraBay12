//	Observer Pattern Implementation: Life
//		Registration type: /mob
//
//		Raised when: A mob is added to the life_mob_list
//
//		Arguments that the called proc should expect:
//			/mob/dead: The mob that was added to the life_mob_list

GLOBAL_TYPED_NEW(life_event, /singleton/observ/life)

/singleton/observ/life
	name = "Life"
	expected_type = /mob

/*****************
* Life Handling *
*****************/

/mob/add_to_living_mob_list()
	. = ..()
	if(.)
		GLOB.life_event.raise_event(src)
