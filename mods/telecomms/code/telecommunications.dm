/obj/machinery/telecomms/server/proc/setcode(t)
	if(t)
		if(istext(t))
			rawcode = t

/obj/machinery/telecomms/server/proc/compile()
	if(Compiler)
		return Compiler.Compile(rawcode)
