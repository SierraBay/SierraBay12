/obj/item/projectile/psi
	name = "psionic projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "dark_pellet"
	damage = 20
	distance_falloff = 1
	penetration_modifier = 1.0
	damage_type = DAMAGE_BRUTE
	damage_flags = DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP
	miss_sounds = list('sound/weapons/guns/miss1.ogg','sound/weapons/guns/miss2.ogg','sound/weapons/guns/miss3.ogg','sound/weapons/guns/miss4.ogg')
	ricochet_sounds = list('sound/weapons/guns/ricochet1.ogg', 'sound/weapons/guns/ricochet2.ogg',
							'sound/weapons/guns/ricochet3.ogg', 'sound/weapons/guns/ricochet4.ogg')
	impact_sounds = list(BULLET_IMPACT_MEAT = SOUNDS_BULLET_MEAT, BULLET_IMPACT_METAL = SOUNDS_BULLET_METAL)

/obj/item/projectile/psi/strong
	damage = 25
	icon_state = "plasma_bolt"
	color = "#c40eed"
	var/explosion_power = EX_ACT_HEAVY
	var/explosion_area = 5

/obj/item/projectile/psi/strong/on_hit(atom/target, blocked = 0)
	explosion(get_turf(target), EX_ACT_LIGHT = explosion_power)
	..()

/obj/item/projectile/psi/strong_piercing
	damage = 40
	icon_state = "plasma_bolt"
	color = "#c40eed"
	var/explosion_power = EX_ACT_DEVASTATING
	var/explosion_area = 5
	var/exploded_inwall = FALSE
	var/delay = 4

	armor_penetration = 100
	penetrating = 2
	penetration_modifier = 1.1
	var/proximity_detonation = FALSE //should we explode near our target, and not inside of it?
	var/exploded = FALSE

/obj/item/projectile/psi/strong_piercing/Bump(atom/A as mob|obj|turf|area, forced=0)
	..()
	if(exploded)
		return

	exploded = TRUE
	if(istype(A,/obj/shield))
		explosion(get_turf(A), EX_ACT_HEAVY = explosion_power, EX_ACT_LIGHT = explosion_area)
		qdel(src)
		return

	sleep(delay)

	if(src && !exploded_inwall)
		explosion(get_turf(src), EX_ACT_HEAVY = explosion_power, EX_ACT_LIGHT = explosion_area)
		qdel(src)

/obj/item/projectile/psi/strong_piercing/Destroy()
	if(src && !exploded_inwall && !istype(loc,/atom/movable))
		exploded = TRUE
		exploded_inwall = TRUE
		explosion(get_turf(src), EX_ACT_HEAVY = explosion_power, EX_ACT_LIGHT = explosion_area)
	..()

/obj/item/gun/energy/psigun
	name = "psychokinetic gun"
	desc = "Result of Manifestation and Energistics combinated factors."
	icon = 'icons/obj/psychic_powers.dmi'
	icon_state = "gun"
	fire_sound = 'sound/weapons/Taser.ogg'
	fire_sound_text = "energy blast"

	var/maintain_cost = 10
	var/mob/living/owner

	max_shots = 20 //Determines the capacity of the weapon's power cell. Specifying a cell_type overrides this value.
	projectile_type = /obj/item/projectile/psi

	self_recharge = 1	//if set, the weapon will recharge itself

/obj/item/gun/energy/psigun/New()
	owner = usr
	if(!istype(owner))
		qdel(src)
		return
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/gun/energy/psigun/Destroy()
	if(istype(owner) && owner.psi)
		LAZYREMOVE(owner.psi.manifested_items, src)
		UNSETEMPTY(owner.psi.manifested_items)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/gun/energy/psigun/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/gun/energy/psigun/use_before(mob/living/M, mob/living/user, target_zone)
	if(M.do_psionics_check(max(force, maintain_cost), user))
		to_chat(user, SPAN_DANGER("\The [src] flickers violently out of phase!"))
		return 1
	. = ..()

/obj/item/gun/energy/psigun/afterattack(atom/target, mob/living/user, proximity)
	if(target.do_psionics_check(max(force, maintain_cost), user))
		to_chat(user, SPAN_DANGER("\The [src] flickers violently out of phase!"))
		return
	. = ..(target, user, proximity)

/obj/item/gun/energy/psigun/special_check(mob/user)

	if(!isliving(user))
		return 0
	if(!user.IsAdvancedToolUser())
		return 0

	var/mob/living/M = user
	if(!safety() && world.time > last_safety_check + 5 MINUTES && !user.skill_check(SKILL_WEAPONS, SKILL_BASIC))
		if(prob(30))
			toggle_safety()
			return 1
	if(MUTATION_FERAL in M.mutations)
		to_chat(M, SPAN_DANGER("Твои пальцы слишком большие!"))
		return 0
	if(M.psi)
		var/hilo_rank = M.psi.get_rank(PSI_ENERGISTICS)
		if(hilo_rank <= PSI_RANK_LATENT)
			to_chat(M, SPAN_DANGER("Не стреляет!"))
			return 0
	if((MUTATION_CLUMSY in M.mutations) && prob(40)) //Clumsy handling
		var/obj/P = consume_next_projectile()
		if(P)
			if(process_projectile(P, user, user, pick(BP_L_FOOT, BP_R_FOOT)))
				handle_post_fire(user, user)
				user.visible_message(
					SPAN_DANGER("\The [user] shoots \himself in the foot with \the [src]!"),
					SPAN_DANGER("You shoot yourself in the foot with \the [src]!")
					)
				M.unequip_item()
		else
			handle_click_empty(user)
		return 0
	return 1

/obj/item/gun/energy/psigun/dropped()
	..()
	qdel(src)

/obj/item/gun/energy/psigun/Process()
	if(istype(owner))
		owner.psi.spend_power(maintain_cost)
	if(!owner || owner.do_psionics_check(maintain_cost, owner) || loc != owner || (owner.l_hand != src && owner.r_hand != src))
		if(isliving(loc))
			var/mob/living/carbon/human/host = loc
			if(istype(host))
				for(var/obj/item/organ/external/organ in host.organs)
					for(var/obj/item/O in organ.implants)
						if(O == src)
							organ.implants -= src
			host.pinned -= src
			host.embedded -= src
			host.drop_from_inventory(src)
		else
			STOP_PROCESSING(SSprocessing, src)

	..()
