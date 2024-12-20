/obj/item/mech_equipment/mounted_system/melee/mechete
	heat_generation = 20

/obj/item/mech_equipment/mounted_system/melee/mechete/need_combat_skill()
	return TRUE

/obj/item/material/hatchet/machete/mech
	var/obj/item/mech_equipment/mounted_system/melee/holder

/obj/item/material/hatchet/machete/mech/Initialize()
	. = ..()
	holder = loc

/obj/item/material/hatchet/machete/mech/use_before(atom/A, mob/user, click_params)
	holder.owner.add_heat(holder.heat_generation)
	if (!istype(A, /mob/living))
		return ..()

	if (user.a_intent == I_HURT)
		user.visible_message(SPAN_DANGER("\The [user] swings \the [src] at \the [A]!"))
		playsound(user, 'sound/mecha/mechmove03.ogg', 35, 1)
		return ..()
