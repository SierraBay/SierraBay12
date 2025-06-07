/mob/start_pulling(atom/movable/AM)
	if(lying)
		to_chat(src, SPAN_BAD("I can't pulls thing in this position!"))
		return
	.=..()
