/obj/item/material/twohanded/sledgehammer	// Someone thinks that crossbows and summer go well together.
	icon = 'mods/fd_assets/icons/obj/melee_physical.dmi'
	item_icons = list(
		slot_l_hand_str = 'mods/fd_assets/icons/onmob/lefthand.dmi',
		slot_r_hand_str = 'mods/fd_assets/icons/onmob/righthand.dmi',
		)
	icon_state = "breacher0"
	base_icon = "breacher"
	name = "sledgehammer"
	desc = "A huge sledgehammer that can punch through walls and is especially good at pork chops. Holding it in your hands, you get obsessive thoughts."

	max_force = 70			//for wielded
	w_class = ITEM_SIZE_LARGE
	force_multiplier = 1.4
	throwforce = 15
	hitsound = 'sound/weapons/genhit3.ogg'
	unwielded_force_divisor = 0.3
	attack_cooldown_modifier = 9
	default_material = MATERIAL_TITANIUM
	sharp = FALSE
	edge = FALSE
	attack_verb = list("attacked", "smited", "cleaved", "whacked", "slammed")
	applies_material_colour = 0
	worth_multiplier = 34
	base_parry_chance = 5
	slowdown_general = 0.1
	wielded_parry_bonus = 20
	unbreakable = TRUE	// go ahead, try it

//	have_stances = FALSE
//	melee_strikes = list(/decl/combo_strike/precise_strike, /decl/combo_strike/blunt_strike)
//	fail_chance = 50

/obj/item/material/twohanded/sledgehammer/shatter()
	return

/obj/item/material/twohanded/sledgehammer/afterattack(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(!proximity) return
	if(A && wielded)
		if(istype(A,/obj/structure/window)) //windows
			var/obj/structure/window/W = A
			if(src.in_use)
				return
			src.in_use = 1
			if(!do_after(user, 10, src))
				src.in_use = 0
				to_chat(user, "<span class='danger'>You must be still to smash \the [W]!</span>")
				return
			src.in_use = 0
			W.shatter()
			user.do_attack_animation(src)
			return

		else if(istype(A,/obj/structure/grille))
			if(src.in_use)
				return
			src.in_use = 1
			if(!do_after(user, 20, src))
				src.in_use = 0
				to_chat(user, "<span class='danger'>You must be still to smash \the [A]!</span>")
				return
			src.in_use = 0
			A.Destroy()
			user.do_attack_animation(src)
			return

		else if(istype(A,/obj/machinery/suit_storage_unit)) //suit storage unit
			var/obj/machinery/suit_storage_unit/S = A
			if(src.in_use)
				return
			src.in_use = 1
			if(!do_after(user, 20, src))
				src.in_use = 0
				to_chat(user, "<span class='danger'>You must be still to smash \the [A]!</span>")
				return
			src.in_use = 0
			if(!S.isopen)
				to_chat(user, "<span class='danger'>You critically damaged and made \the [A] open up.</span>")
				user.do_attack_animation(src)
				playsound(src, 'sound/weapons/smash.ogg', 50, 0)
				S.islocked = FALSE
				S.isopen = TRUE
				S.update_icon()
			return

		else if(istype(A,/obj/machinery/door/airlock)) //airlocks
			if(prob(40))
				var/obj/machinery/door/airlock/S = A
				to_chat(user, "<span class='danger'>You critically damaged \the [A]!</span>")
				user.do_attack_animation(src)
				if(S.health_current <= 0)
					S.health_current = 0
				else
					S.health_current /= 4
			return

		else if(istype(A,/obj/machinery/door/firedoor)) //firedoor
			if(src.in_use)
				return
			if(A.density)
				src.in_use = 1
				if(!do_after(user, 20, src))
					src.in_use = 0
					to_chat(user, "<span class='danger'>You must be still to smash \the [A]!</span>")
					return
				src.in_use = 0
				to_chat(user, "<span class='danger'>You smash through \the [A]!</span>")
				qdel(A)
			return

		else if(istype(A,/obj/structure/wall_frame)) //wallframe
			A.Destroy()

		else if(istype(A,/turf/simulated/wall) && !istype(A,/turf/simulated/wall/invincible)) //walls
			if(!user.skill_check(SKILL_HAULING, SKILL_TRAINED))
				to_chat(user, "<span class='danger'>You are too weak to smash \the [A]!</span>")
				return
			if(src.in_use)
				return
			src.in_use = 1
			var/timer = A.health_max / (user.get_skill_value(SKILL_COMBAT) + 5)
			if(timer <= 10)
				timer = 10
			if(!do_after(user, timer, src))
				src.in_use = 0
				to_chat(user, "<span class='danger'>You must be still to smash \the [A]!</span>")
				return
			src.in_use = 0
			to_chat(user, "<span class='danger'>You smash through \the [A]!</span>")
			user.do_attack_animation(src)
			A.kill_health()
			return

		else if(istype(A,/mob/living/carbon)) //leto i arbaleti
			var/mob/living/target = A
			if(user.a_intent == I_GRAB)
				var/dam = 3 * (user.get_skill_value(SKILL_COMBAT) * user.get_skill_value(SKILL_HAULING))
				visible_message("<span class='warning'>[user] raises \the [src] above \The [target].</span>")
				if(src.in_use)
					return
				src.in_use = 1
				if(!do_after(user, 50, src))
					src.in_use = 0
					to_chat(user, "<span class='danger'>You must be still to smash [target]!</span>")
					return
				src.in_use = 0
				target.apply_damage(dam, DAMAGE_BRUTE)
				visible_message("<span class='warning'>[user] smash \The [target] with .</span>")
			return
	. = ..()
