// Большие деревья

/obj/structure/flora/tree/jungle
	icon = 'mods/vr/icons/hdtrees.dmi'
	icon_state = "tree"
	pixel_x = -48
	pixel_y = -22

/obj/structure/flora/tree/jungle/Initialize()
	. = ..()
	var/state = rand(6)
	if (state)
		icon_state = "[initial(icon_state)]_[state]"

/obj/structure/flora/tree/leavy
	icon = 'mods/vr/icons/hdtrees.dmi'
	icon_state = "treeleavy"
	pixel_x = -48
	pixel_y = -22

/obj/structure/flora/tree/leavy/Initialize()
	. = ..()
	var/state = rand(4)
	if (state)
		icon_state = "[initial(icon_state)]_[state]"

/obj/structure/flora/tree/spooky
	icon = 'mods/vr/icons/hdtrees.dmi'
	icon_state = "spook"
	pixel_x = -48
	pixel_y = -22

/obj/structure/flora/tree/spooky/Initialize()
	. = ..()
	var/state = rand(2)
	if (state)
		icon_state = "[initial(icon_state)]_[state]"

/obj/structure/flora/tree/dead/snowless
	icon = 'mods/vr/icons/deadtrees.dmi'

/obj/structure/flora/tree/sakura
	icon = 'mods/vr/icons/oriental.dmi'
	icon_state = "spacesakura"
	pixel_x = -48
	pixel_y = -22

/obj/structure/flora/tree/sakura/Initialize()
	. = ..()
	AddOverlays(image(icon, "spacesakura-overlay"))

/obj/structure/flora/tree/sakura/on_death()
	. = ..()
	ClearOverlays()

// Кустарники и трава

/obj/structure/flora/ausbushes/rocky
	name = "rocky bush"
	icon = 'mods/vr/icons/jungleflora.dmi'
	icon_state = "rock_1"
	anchored = TRUE
	layer = PLANT_LAYER

/obj/structure/flora/ausbushes/rocky/New()
	..()
	icon_state = "rock_[rand(1, 5)]"

/obj/structure/flora/ausbushes/jungle_a
	name = "jungle bush"
	icon = 'mods/vr/icons/jungleflora.dmi'
	icon_state = "busha_1"
	anchored = TRUE
	layer = PLANT_LAYER

/obj/structure/flora/ausbushes/jungle_a/New()
	..()
	icon_state = "busha_[rand(1, 3)]"

/obj/structure/flora/ausbushes/jungle_b
	name = "jungle bush"
	icon = 'mods/vr/icons/jungleflora.dmi'
	icon_state = "bushb_1"
	anchored = TRUE
	layer = PLANT_LAYER

/obj/structure/flora/ausbushes/jungle_b/New()
	..()
	icon_state = "bushb_[rand(1, 3)]"

/obj/structure/flora/ausbushes/jungle_c
	name = "jungle bush"
	icon = 'mods/vr/icons/jungleflora.dmi'
	icon_state = "bushc_1"
	anchored = TRUE
	layer = PLANT_LAYER

/obj/structure/flora/ausbushes/jungle_c/New()
	..()
	icon_state = "bushc_[rand(1, 3)]"

/obj/structure/flora/grass/jungle_a
	name = "jungle grass"
	icon = 'mods/vr/icons/jungleflora.dmi'
	icon_state = "grassa"

/obj/structure/flora/grass/jungle_a/New()
	..()
	icon_state = "grassa_[rand(1, 5)]"

/obj/structure/flora/grass/jungle_b
	name = "jungle grass"
	icon = 'mods/vr/icons/jungleflora.dmi'
	icon_state = "grassb"

/obj/structure/flora/grass/jungle_b/New()
	..()
	icon_state = "grassb_[rand(1, 5)]"
