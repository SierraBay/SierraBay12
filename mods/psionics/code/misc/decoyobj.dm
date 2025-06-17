/obj/temp_visual/decoy
	desc = "It's a decoy!"
	duration = 15
/obj/temp_visual/decoy/Initialize(mapload, set_dir, atom/mimiced_atom, modified_duration = 15)
	duration = modified_duration
	. = ..()
	alpha = initial(alpha)
	if(mimiced_atom)
		name = "The Illusion"
		appearance = mimiced_atom.appearance
		set_dir(set_dir)
		mouse_opacity = 0
