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
	///Внешний бронеэлемент, который навешивается на каждую часть готового меха. null — без брони
	var/external_armor_type = /obj/item/mech_external_armor/civil
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
		//Ноги, которые подтип уже взял из своего держателя, остаются при нём: второй держатель оставил бы первый пустым
		if(!R_leg.doubled_owner || R_leg.doubled_owner != L_leg.doubled_owner)
			var/obj/item/mech_component/doubled_legs/spawned_double_legs = new R_leg.doubled_owner_type (src)
			qdel(R_leg)
			qdel(L_leg)
			R_leg = spawned_double_legs.R_stored_leg
			L_leg = spawned_double_legs.L_stored_leg
		R_leg.forceMove(src)
		R_leg.decal = decal
		R_leg.prebuild()
		R_leg.side = RIGHT
		R_leg.setup_side()
		L_leg.forceMove(src)
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
	//Готовый мех получает броню и на те части, на которые её потом не навесить
	if(external_armor_type)
		for(var/obj/item/mech_component/part in list(head, body, R_arm, L_arm, R_leg, L_leg))
			part.install_external_armour(new external_armor_type(part))

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
		var/headtype = pick(get_fabricated_part_types(/obj/item/mech_component/sensors))
		head = new headtype(src)
		head.color = mech_colour ? mech_colour : pick(use_colours)
	if(!body)
		var/bodytype = pick(get_fabricated_part_types(/obj/item/mech_component/chassis))
		body = new bodytype(src)
		body.color = mech_colour ? mech_colour : pick(use_colours)
	if(!R_arm)
		var/armstype = pick(get_fabricated_part_types(/obj/item/mech_component/manipulators))
		R_arm = new armstype(src)
		R_arm.color = mech_colour ? mech_colour : pick(use_colours)
		R_arm.side = RIGHT
		R_arm.setup_side()
	if(!L_arm)
		var/armstype = pick(get_fabricated_part_types(/obj/item/mech_component/manipulators))
		L_arm = new armstype(src)
		L_arm.color = mech_colour ? mech_colour : pick(use_colours)
		L_arm.side = LEFT
		L_arm.setup_side()
	if(!R_leg)
		put_random_leg(RIGHT, mech_colour, use_colours)
	if(!L_leg)
		put_random_leg(LEFT, mech_colour, use_colours)
	. = ..()

///Типы частей подтипа `part_type`, которые печатает фабрикатор мехов: из них собран случайный мех. Части
///готовых мехов — эскадрона смерти, СБ, наёмников, ОБР — фабрикатор не печатает, и случайному меху они не достаются
/mob/living/exosuit/premade/random/proc/get_fabricated_part_types(part_type)
	RETURN_TYPE(/list)
	var/static/list/fabricated_types
	if(!fabricated_types)
		fabricated_types = list()
		for(var/datum/design/item/mechfab/design as anything in subtypesof(/datum/design/item/mechfab))
			var/build_path = initial(design.build_path)
			if(ispath(build_path, /obj/item/mech_component))
				fabricated_types |= build_path
	. = list()
	for(var/fabricated_type in fabricated_types)
		if(ispath(fabricated_type, part_type))
			. += fabricated_type

///Случайная нога на сторону `side`. Сдвоенные ноги — гусеницы и паучьи — фабрикатор печатает держателем, сразу
///парой: держатель заменяет обе ноги
/mob/living/exosuit/premade/random/proc/put_random_leg(side, mech_colour, list/use_colours)
	var/legs_type = pick(get_fabricated_part_types(/obj/item/mech_component/propulsion) + get_fabricated_part_types(/obj/item/mech_component/doubled_legs))
	if(ispath(legs_type, /obj/item/mech_component/doubled_legs))
		QDEL_NULL(R_leg)
		QDEL_NULL(L_leg)
		var/obj/item/mech_component/doubled_legs/holder = new legs_type(src)
		R_leg = holder.R_stored_leg
		L_leg = holder.L_stored_leg
		R_leg.color = mech_colour ? mech_colour : pick(use_colours)
		L_leg.color = mech_colour ? mech_colour : pick(use_colours)
		return
	var/obj/item/mech_component/propulsion/leg = new legs_type(src)
	leg.color = mech_colour ? mech_colour : pick(use_colours)
	leg.side = side
	leg.setup_side()
	if(side == RIGHT)
		R_leg = leg
	else
		L_leg = leg

// Used for spawning/debugging.
/mob/living/exosuit/premade/random/normal

/mob/living/exosuit/premade/random/boring/Initialize(mapload, obj/structure/heavy_vehicle_frame/source_frame)
	return..(mapload, source_frame, using_boring_colours = TRUE)

/mob/living/exosuit/premade/random/extra/Initialize(mapload, obj/structure/heavy_vehicle_frame/source_frame)
	return..(mapload, source_frame, super_random = TRUE)
