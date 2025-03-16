//	Observer Pattern Implementation: EMPd
//		Registration type: /atom
//
//		Raised when: A /atom instance is EMPd.
//
//		Arguments that the called proc should expect:
//			/atom/empd_instance: The instance that was EMPd.
//			severity: The EMP severity

GLOBAL_TYPED_NEW(empd_event, /singleton/observ/empd)

/singleton/observ/empd
	name = "EMPd"
