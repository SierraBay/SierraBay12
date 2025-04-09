//Melee! As a general rule I would recommend using regular objects and putting logic in them.
/obj/item/mech_equipment/mounted_system/melee
	name = "mechete"
	desc = "That thing was too big to be called a machete. Too big, too thick, too heavy, and too rough, it was more like a large hunk of iron."
	restricted_hardpoints = list(HARDPOINT_LEFT_HAND, HARDPOINT_RIGHT_HAND)
	restricted_software = list(MECH_SOFTWARE_UTILITY)
	heat_generation = 20

/obj/item/material/hatchet/machete/mech
	w_class = ITEM_SIZE_GARGANTUAN
	slot_flags = 0
	default_material = MATERIAL_STEEL
	base_parry_chance = 0 //Irrelevant for exosuits, revise if this changes
	max_force = 35 // If we want to edit the force, use this number! The one below is prone to be changed when anything material gets modified.
	force_multiplier = 0.75 // Equals 20 AP with 45 force with hardness 60 (Steel)
	unbreakable = TRUE //Else we need a whole system for replacement blades
	attack_cooldown_modifier = 10

/obj/item/mech_equipment/mounted_system/melee/mechete/need_combat_skill()
	return TRUE

/obj/item/material/hatchet/machete/mech/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	. = ..()
	if (.)
		do_attack_effect(target, "smash")
		if (target.mob_size < user.mob_size) //Damaging attacks overwhelm smaller mobs
			target.throw_at(get_edge_target_turf(target,get_dir(user, target)),1, 1)

/obj/item/material/hatchet/machete/mech/attack_self(mob/living/user)
	. = ..()
	if (user.a_intent != I_HURT)
		return
	var/obj/item/mech_equipment/mounted_system/melee/mechete/MC = loc
	if (istype(MC))
		//SPIN BLADE ATTACK GO!
		var/mob/living/exosuit/E = MC.owner
		if (E)
			E.setClickCooldown(1.35 SECONDS)
			E.visible_message(SPAN_DANGER("\The [E] swings \the [src] back, preparing for an attack!"), blind_message = SPAN_DANGER("You hear the loud hissing of hydraulics!"))
			playsound(E, 'sound/mecha/mech_punch_fast.ogg', 35, 1)
			if (do_after(E, 1.2 SECONDS, get_turf(user), DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS) && E && MC)
				for (var/mob/living/M in orange(1, E))
					M.use_weapon(src, E)
				E.spin(0.65 SECONDS, 0.125 SECONDS)
				playsound(E, 'sound/mecha/mechstep01.ogg', 40, 1)

/obj/item/mech_equipment/mounted_system/melee/mechete
	icon_state = "mech_blade"
	holding_type = /obj/item/material/hatchet/machete/mech

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
