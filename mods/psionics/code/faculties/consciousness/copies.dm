/proc/get_adjacent_open_turfs(atom/center)
	var/list/hand_back = list()
	// Inlined get_open_turf_in_dir, just to be fast
	var/turf/new_turf = get_step(center, NORTH)
	if(istype(new_turf) && !new_turf.density)
		hand_back += new_turf
	new_turf = get_step(center, SOUTH)
	if(istype(new_turf) && !new_turf.density)
		hand_back += new_turf
	new_turf = get_step(center, EAST)
	if(istype(new_turf) && !new_turf.density)
		hand_back += new_turf
	new_turf = get_step(center, WEST)
	if(istype(new_turf) && !new_turf.density)
		hand_back += new_turf
	return hand_back

/singleton/psionic_power/consciousness/copies
	name =            "Non-Existing Copies"
	cost =            50
	cooldown =        100
	use_melee =       TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Выберите рот на синем интенте, и затем нажмите по себе, чтобы создать сразу несколько копий самого себя."
	var/amount = 1

/singleton/psionic_power/consciousness/copies/invoke(mob/living/user, mob/living/carbon/human/target)
	var/con_rank_user = user.psi.get_rank(PSI_CONSCIOUSNESS)
	switch(con_rank_user)
		if(PSI_RANK_OPERANT)
			amount = 3
		if(PSI_RANK_MASTER)
			amount = 4
		if(PSI_RANK_GRANDMASTER)
			amount = 6

	if(user.zone_sel.selecting != BP_MOUTH)
		return FALSE

	if(user.a_intent != I_DISARM)
		return FALSE

	if(target != user)
		return FALSE

	. = ..()
	if(.)
		if(do_after(user, 10))
			to_chat(user, SPAN_WARNING("Я разделяю своё подсознание на [amount] копий"))
			for(var/i = 1 to amount)
				var/mob/living/simple_animal/hostile/mirror_shade/MS = new(pick(get_adjacent_open_turfs(user)), user)
				MS.CopyOverlays(user, TRUE)
				MS.icon = null
			return TRUE

/obj/item/natural_weapon/punch/holo
	damtype = DAMAGE_PAIN

/mob/living/simple_animal/hostile/mirror_shade

	name = "Mirror Shade"
	turns_per_move = 2
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	movement_cooldown = 0
	maxHealth = 20
	health = 20
	harm_intent_damage = 5
	natural_weapon = /obj/item/natural_weapon/punch/holo
	a_intent = I_HURT
	status_flags = CANPUSH
	blood_color = null

	var/mob/living/carbon/human/owner

/mob/living/simple_animal/hostile/mirror_shade/Initialize(mapload, mob/set_owner)
	. = ..()
	if(set_owner)
		owner = set_owner
		friends += owner
		name = owner.name
	QDEL_IN(src, 30 SECONDS)

/mob/living/simple_animal/hostile/mirror_shade/examine(mob/user)
	if(!QDELETED(owner))
		/// Technically suspicious, but these have 30 seconds of lifetime so it's probably fine.
		return owner.examine(user)
	return ..()

/mob/living/simple_animal/hostile/mirror_shade/Destroy()
	animate(src, 1 SECOND, alpha = 0, easing = BOUNCE_EASING)
	owner = null
	visible_message(SPAN_WARNING("[src] пропадает!"))
	return ..()
