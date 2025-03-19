//	Observer Pattern Implementation: Shuttle Added
//		Registration type: /datum/shuttle (register for the global event only)
//
//		Raised when: After a shuttle is initialized.
//
//		Arguments that the called proc should expect:
//			/datum/shuttle/shuttle: the new shuttle

GLOBAL_TYPED_NEW(shuttle_added, /singleton/observ/shuttle_added)

/singleton/observ/shuttle_added
	name = "Shuttle Added"
	expected_type = /datum/shuttle

/*****************************
*  Shuttle Added Handling *
*****************************/

/datum/controller/subsystem/shuttle/initialize_shuttle()
	. = ..()
	if(.)
		GLOB.shuttle_added.raise_event(.)
