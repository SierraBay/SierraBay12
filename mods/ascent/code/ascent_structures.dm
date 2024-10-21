MANTIDIFY(/obj/structure/adherent_bath, "mantid mineral bath", "resting")

/obj/structure/wall_frame/titanium/ascent
	paint_color = COLOR_PURPLE

/obj/wallframe_spawn/reinforced_phoron/titanium/ascent
	frame_path = /obj/structure/wall_frame/titanium/ascent

/obj/structure/adherent_bath/ascent
	color = "#a33fbf"

/obj/structure/adherent_bath/ascent/return_air()
	var/datum/gas_mixture/ascentus = new(CELL_VOLUME, 310.15)
	ascentus.adjust_multi(GAS_METHYL_BROMIDE, MOLES_CELLSTANDARD * 0.5, GAS_OXYGEN, MOLES_CELLSTANDARD * 0.5)
	return ascentus
