#include "combat.dm"
#include "death_squad.dm"
#include "ert.dm"
#include "heavy.dm"
#include "light.dm"
#include "merc.dm"
#include "powerloader.dm"
#include "security.dm"

/mob/living/exosuit/premade
	name = "impossible mech"
	desc = "Убейте меня"
	var/decal

/mob/living/exosuit/premade/Initialize()
	if(head)
		head.decal = decal
		head.prebuild()
	if(body)
		body.decal = decal
		body.prebuild()
	if(R_arm)
		R_arm.decal = decal
		R_arm.prebuild()
		R_arm.side = RIGHT
		R_arm.setup_side()
	if(L_arm)
		L_arm.decal = decal
		L_arm.prebuild()
		L_arm.side = LEFT
		L_arm.setup_side()
	if(R_leg && L_leg && R_leg.should_have_doubled_owner && L_leg.should_have_doubled_owner)
		var/obj/item/mech_component/doubled_legs/spawned_double_legs = new R_leg.doubled_owner_type (src)
		qdel(R_leg)
		qdel(L_leg)
		R_leg = null
		L_leg = null
		R_leg = spawned_double_legs.R_stored_leg
		spawned_double_legs.R_stored_leg.forceMove(src)
		R_leg.decal = decal
		R_leg.prebuild()
		R_leg.side = RIGHT
		R_leg.setup_side()
		L_leg = spawned_double_legs.L_stored_leg
		spawned_double_legs.L_stored_leg.forceMove(src)
		L_leg.decal = decal
		L_leg.prebuild()
	if(R_leg && !R_leg.should_have_doubled_owner)
		R_leg.decal = decal
		R_leg.prebuild()
		R_leg.side = RIGHT
		R_leg.setup_side()
	if(L_leg && !L_leg.should_have_doubled_owner)
		L_leg.decal = decal
		L_leg.prebuild()
		L_leg.side = LEFT
		L_leg.setup_side()

	if(!material)
		material = SSmaterials.get_material_by_name(MATERIAL_STEEL)
	. = ..()

	spawn_mech_equipment()

/mob/living/exosuit/premade/proc/spawn_mech_equipment()
	set waitfor = FALSE
	install_system(new /obj/item/mech_equipment/light(src), HARDPOINT_HEAD)

/mob/living/exosuit/premade/random
	name = "mismatched mech"
	desc = "It seems to have been roughly thrown together and then spraypainted a single colour."

/mob/living/exosuit/premade/random/Initialize(mapload, obj/structure/heavy_vehicle_frame/source_frame, super_random = FALSE, using_boring_colours = FALSE)
	//if(!prob(100/(LAZYLEN(GLOB.mech_decals)+1)))
	//	decal = pick(GLOB.mech_decals)

	var/list/use_colours
	if(using_boring_colours)
		use_colours = list(
			COLOR_DARK_GRAY,
			COLOR_GRAY40,
			COLOR_DARK_BROWN,
			COLOR_GRAY,
			COLOR_RED_GRAY,
			COLOR_BROWN,
			COLOR_GREEN_GRAY,
			COLOR_BLUE_GRAY,
			COLOR_PURPLE_GRAY,
			COLOR_BEIGE,
			COLOR_PALE_GREEN_GRAY,
			COLOR_PALE_RED_GRAY,
			COLOR_PALE_PURPLE_GRAY,
			COLOR_PALE_BLUE_GRAY,
			COLOR_SILVER,
			COLOR_GRAY80,
			COLOR_OFF_WHITE,
			COLOR_GUNMETAL,
			COLOR_SOL,
			COLOR_TITANIUM,
			COLOR_DARK_GUNMETAL,
			COLOR_BRONZE,
			COLOR_BRASS
		)
	else
		use_colours = list(
			COLOR_NAVY_BLUE,
			COLOR_GREEN,
			COLOR_DARK_GRAY,
			COLOR_MAROON,
			COLOR_PURPLE,
			COLOR_VIOLET,
			COLOR_OLIVE,
			COLOR_BROWN_ORANGE,
			COLOR_DARK_ORANGE,
			COLOR_GRAY40,
			COLOR_SEDONA,
			COLOR_DARK_BROWN,
			COLOR_BLUE,
			COLOR_DEEP_SKY_BLUE,
			COLOR_LIME,
			COLOR_CYAN,
			COLOR_TEAL,
			COLOR_RED,
			COLOR_PINK,
			COLOR_ORANGE,
			COLOR_YELLOW,
			COLOR_GRAY,
			COLOR_RED_GRAY,
			COLOR_BROWN,
			COLOR_GREEN_GRAY,
			COLOR_BLUE_GRAY,
			COLOR_SUN,
			COLOR_PURPLE_GRAY,
			COLOR_BLUE_LIGHT,
			COLOR_RED_LIGHT,
			COLOR_BEIGE,
			COLOR_PALE_GREEN_GRAY,
			COLOR_PALE_RED_GRAY,
			COLOR_PALE_PURPLE_GRAY,
			COLOR_PALE_BLUE_GRAY,
			COLOR_LUMINOL,
			COLOR_SILVER,
			COLOR_GRAY80,
			COLOR_OFF_WHITE,
			COLOR_NT_RED,
			COLOR_BOTTLE_GREEN,
			COLOR_PALE_BTL_GREEN,
			COLOR_GUNMETAL,
			COLOR_MUZZLE_FLASH,
			COLOR_CHESTNUT,
			COLOR_BEASTY_BROWN,
			COLOR_WHEAT,
			COLOR_CYAN_BLUE,
			COLOR_LIGHT_CYAN,
			COLOR_PAKISTAN_GREEN,
			COLOR_SOL,
			COLOR_AMBER,
			COLOR_COMMAND_BLUE,
			COLOR_SKY_BLUE,
			COLOR_PALE_ORANGE,
			COLOR_CIVIE_GREEN,
			COLOR_TITANIUM,
			COLOR_DARK_GUNMETAL,
			COLOR_BRONZE,
			COLOR_BRASS,
			COLOR_INDIGO
		)

	var/mech_colour = super_random ? FALSE : pick(use_colours)
	if(!head)
		var/headtype = pick(typesof(/obj/item/mech_component/sensors)-/obj/item/mech_component/sensors)
		head = new headtype(src)
		head.color = mech_colour ? mech_colour : pick(use_colours)
	if(!body)
		var/bodytype = pick(typesof(/obj/item/mech_component/chassis)-/obj/item/mech_component/chassis)
		body = new bodytype(src)
		body.color = mech_colour ? mech_colour : pick(use_colours)
	if(!R_arm)
		var/armstype = pick(typesof(/obj/item/mech_component/manipulators)-/obj/item/mech_component/manipulators)
		R_arm = new armstype(src)
		R_arm.color = mech_colour ? mech_colour : pick(use_colours)
		R_arm.side = RIGHT
		R_arm.setup_side()
	if(!L_arm)
		var/armstype = pick(typesof(/obj/item/mech_component/manipulators)-/obj/item/mech_component/manipulators)
		L_arm = new armstype(src)
		L_arm.color = mech_colour ? mech_colour : pick(use_colours)
		L_arm.side = LEFT
		L_arm.setup_side()
	if(!R_leg)
		var/legstype = pick(typesof(/obj/item/mech_component/propulsion)-/obj/item/mech_component/propulsion)
		R_leg = new legstype(src)
		//Если ноги сдвоенные по умолчанию, мы спавним его держателя, а уже держателя ставим в меха и коннектим к меху, рандомно его крася
		if(R_leg.should_have_doubled_owner)
			qdel(R_leg)
			R_leg = null
			var/doubled_legs_type = pick(typesof(/obj/item/mech_component/doubled_legs)-/obj/item/mech_component/doubled_legs)
			var/obj/item/mech_component/doubled_legs/spawned_double_legs = new doubled_legs_type(src)
			R_leg = spawned_double_legs.R_stored_leg
			R_leg.forceMove(src)
			L_leg = spawned_double_legs.L_stored_leg
			L_leg.forceMove(src)
			R_leg.color = mech_colour ? mech_colour : pick(use_colours)
			L_leg.color = mech_colour ? mech_colour : pick(use_colours)
		//Иначе спавн стандартный
		else
			R_leg.color = mech_colour ? mech_colour : pick(use_colours)
			R_leg.side = RIGHT
			R_leg.setup_side()
	if(!L_leg)
		var/legstype = pick(typesof(/obj/item/mech_component/propulsion)-/obj/item/mech_component/propulsion)
		L_leg = new legstype(src)
		//Если ноги сдвоенные по умолчанию, мы спавним его держателя, а уже держателя ставим в меха и коннектим к меху, рандомно его крася
		if(L_leg.should_have_doubled_owner)
			qdel(R_leg)
			R_leg = null
			qdel(L_leg)
			L_leg = null
			var/doubled_legs_type = pick(typesof(/obj/item/mech_component/doubled_legs)-/obj/item/mech_component/doubled_legs)
			var/obj/item/mech_component/doubled_legs/spawned_double_legs = new doubled_legs_type(src)
			R_leg = spawned_double_legs.R_stored_leg
			R_leg.forceMove(src)
			L_leg = spawned_double_legs.L_stored_leg
			L_leg.forceMove(src)
			R_leg.color = mech_colour ? mech_colour : pick(use_colours)
			L_leg.color = mech_colour ? mech_colour : pick(use_colours)
		else
		//Иначе спавн стандартный
			L_leg.color = mech_colour ? mech_colour : pick(use_colours)
			L_leg.side = LEFT
			L_leg.setup_side()
	. = ..()

// Used for spawning/debugging.
/mob/living/exosuit/premade/random/normal

/mob/living/exosuit/premade/random/boring/Initialize(mapload, obj/structure/heavy_vehicle_frame/source_frame)
	return..(mapload, source_frame, using_boring_colours = TRUE)

/mob/living/exosuit/premade/random/extra/Initialize(mapload, obj/structure/heavy_vehicle_frame/source_frame)
	return..(mapload, source_frame, super_random = TRUE)
