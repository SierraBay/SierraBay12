//Что-либо плавает в водичке
/obj/structure/water_drown_structures
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	anchored = TRUE
	density = FALSE
	icon = 'mods/anomaly/icons/floating_clutter.dmi'
	icon_state = "wooden_crate"
	var/list/possible_icon_states = list()

/obj/structure/water_drown_structures/Initialize()
	. = ..()
	if(LAZYLEN(possible_icon_states))
		icon_state = pick(possible_icon_states)

/obj/structure/water_drown_structures/wooden_crates
	icon_state = "wooden_crate"
	density = TRUE

/obj/structure/water_drown_structures/wooden_crates_damaged
	icon_state = "wooden_crate_damaged"
	density = TRUE

/obj/structure/water_drown_structures/small_woden_boxes
	icon_state = "wooden_boxes"

/obj/structure/water_drown_structures/wooden_planks
	icon_state = "wooden_planks"

/obj/structure/water_drown_structures/paper
	icon_state = "paper_1"
	possible_icon_states = list("paper_1", "paper_2", "paper_3")
