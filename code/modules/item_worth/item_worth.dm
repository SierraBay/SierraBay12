GLOBAL_LIST_EMPTY(price_cache)
/proc/get_value(atom/A) // A can be either type *or* instance; ie get_value(/obj) is valid, as is get_value(new /obj)
// [SIERRA-ADD]
	if(istype(A, /obj/machinery/portable_atmospherics/canister))
		var/obj/machinery/portable_atmospherics/canister/C = A
		if(C.return_pressure() < 10 * ONE_ATMOSPHERE)
			var/empty_val = worths[/obj/machinery/portable_atmospherics/canister/empty]
			return MACHINE_IS_BROKEN(C) ? round(empty_val * 0.5) : empty_val
// [/SIERRA-ADD]
	var/atom/t = ispath(A) ? A : A.type
	while(!(t in worths)) // Find the first parent that is in the list
		t = PARENT(t)
		if(!t)
			return 0
	var/value = worths[t]
	if(value >= 0) // Value zero or greater than zero, all instances have same value
		return value
	else 
// [SIERRA-EDIT]
		if(ispath(A)) // Build a cache for tricky pricing types
			t = A
			if(!GLOB.price_cache[A])
				try
					A = new A
					GLOB.price_cache[A.type] = A.Value(-value)
					qdel(A)
				catch
					GLOB.price_cache[t] = -value
			return GLOB.price_cache[t]
		else
			return A.Value(-value)
// [/SIERRA-EDIT]