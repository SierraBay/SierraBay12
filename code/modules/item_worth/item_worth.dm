GLOBAL_LIST_EMPTY(price_cache)
/proc/get_value(atom/A, include_contents = TRUE) // [SIERRA-EDIT] TRADE: optional appraisal of the object alone.
	if(!A || (!ispath(A, /atom) && !istype(A))) // [SIERRA-EDIT] TRADE: reject non-atom catalog metadata.
		return 0
	var/atom/t = ispath(A) ? A : A.type
	while(!(t in worths)) // Find the first parent that is in the list
		t = PARENT(t)
		if(!t)
			return 0
	var/value = worths[t]
	if(value >= 0) // Value zero or greater than zero, all instances have same value
		return value
	else 
		if(ispath(A)) // Build a cache for tricky pricing types
			t = A
			// [SIERRA-ADD] TRADE: never put an incomplete valuation in the shared cache.
			if(!include_contents)
				A = new A
				var/result = A.Value(-value, FALSE)
				qdel(A)
				return result
			// [/SIERRA-ADD]
			if(!GLOB.price_cache[A])
				A = new A
				GLOB.price_cache[A.type] = A.Value(-value)
				qdel(A)
			return GLOB.price_cache[t]
		else
			return A.Value(-value, include_contents) // [SIERRA-EDIT] TRADE
