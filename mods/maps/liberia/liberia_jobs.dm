// Submap datum and archetype.
/datum/job/submap/merchant
	title = "Merchant"

	info = "Вы свободные торговцы, которых в поисках выгоды занесло в неизведанные дали. Путешествуйте, торгуйте, make profit! \
	\
	Посещать неизведанные обьекты крайне небезопасно. Вы торговцы, а не мусорщики, ваша смерть не принесет прибыли, не лезьте куда не надо."
	total_positions = 1
	spawn_positions = 1
	supervisors = "невидимой рукой рынка"
	selection_color = "#515151"
	ideal_character_age = 30
	minimal_player_age = 7
	create_record = 0
	outfit_type = /singleton/hierarchy/outfit/job/liberia/merchant/leader
	whitelisted_species = null
	blacklisted_species = list(SPECIES_VOX, SPECIES_ALIEN, SPECIES_GOLEM, ) // SPECIES_MANTID_GYNE, SPECIES_MANTID_ALATE, SPECIES_MONARCH_WORKER, SPECIES_MONARCH_QUEEN Not yet... not yet...
	allowed_branches = list(
		/datum/mil_branch/civilian
	)
	allowed_ranks = list(
		/datum/mil_rank/civ/civ
	)
	latejoin_at_spawnpoints = 1

	access = list(
		access_merchant
	)

	announced = FALSE
	min_skill = list(
		SKILL_FINANCE = SKILL_ADEPT,
		SKILL_PILOT	  = SKILL_BASIC
	)
	give_psionic_implant_on_join = FALSE
	skill_points = 24
	economic_power = 11

	account_allowed = TRUE

/datum/job/submap/merchant/equip(mob/living/carbon/human/H)
	setup_away_account(H)
	return ..()

/datum/job/submap/merchant_trainee/is_position_available()
	. = ..()
	if(. && requires_supervisor)
		for(var/mob/M in GLOB.player_list)
			if(!M.client || !M.mind || !M.mind.assigned_job || M.mind.assigned_job.title != requires_supervisor)
				continue
			var/datum/job/submap/merchant/merchant_job = M.mind.assigned_job
			if(istype(merchant_job) && merchant_job.owner == owner)
				return TRUE
		return FALSE

/datum/job/submap/merchant_trainee
	title = "Merchant Assistant"

	var/requires_supervisor = "Merchant"
	total_positions = 5
	spawn_positions = 5
	supervisors = "Торговцем"
	selection_color = "#515151"
	ideal_character_age = 20
	minimal_player_age = 0
	create_record = 0
	whitelisted_species = null
	blacklisted_species = list(SPECIES_VOX, SPECIES_ALIEN, SPECIES_GOLEM, ) // SPECIES_MANTID_GYNE, SPECIES_MANTID_ALATE, SPECIES_MONARCH_WORKER, SPECIES_MONARCH_QUEEN Not yet... not yet...
	alt_titles = list(
		"Merchant Security" = /singleton/hierarchy/outfit/job/liberia/merchant/security,
		"Merchant Engineer" = /singleton/hierarchy/outfit/job/liberia/merchant/engineer,
		"Merchant Medical" = /singleton/hierarchy/outfit/job/liberia/merchant/doctor
	)
	outfit_type = /singleton/hierarchy/outfit/job/liberia/merchant
	allowed_branches = list(
		/datum/mil_branch/civilian
	)
	allowed_ranks = list(
		/datum/mil_rank/civ/civ
	)
	latejoin_at_spawnpoints = 1
	access = list(
		access_merchant
	)
	announced = FALSE
	min_skill = list(
		SKILL_FINANCE = SKILL_BASIC
	)

	max_skill = list(
		SKILL_COMBAT  = SKILL_MAX,
	    SKILL_WEAPONS = SKILL_MAX
	)
	required_role = list(
		"Merchant"
	)

	give_psionic_implant_on_join = FALSE

	economic_power = 4
	skill_points = 24

	account_allowed = TRUE

/datum/job/submap/merchant_trainee/equip(mob/living/carbon/human/H)
	setup_away_account(H)
	outfit_type =  H.mind.role_alt_title!="Merchant Assistant" ? alt_titles[H.mind.role_alt_title] : outfit_type
	. = ..()

// Spawn points.
/obj/effect/submap_landmark/spawnpoint/liberia
	name = "Merchant"

/obj/effect/submap_landmark/spawnpoint/liberia/trainee
	name = "Merchant Assistant"

/obj/effect/submap_landmark/spawnpoint/liberia/security
 	name = "Merchant Security"

/obj/effect/submap_landmark/spawnpoint/liberia/engineer
 	name = "Merchant Engineer"

/obj/effect/submap_landmark/spawnpoint/liberia/doctor
 	name = "Merchant Medical"

/singleton/hierarchy/outfit/job/liberia/merchant
	name = OUTFIT_JOB_NAME("Merchant Assistant")
	uniform = /obj/item/clothing/under/suit_jacket/tan
	shoes = /obj/item/clothing/shoes/brown
//	pda_type = /obj/item/modular_computer/pda
	id_types = list(/obj/item/card/id/liberia/merchant)

/datum/job/submap/merchant/proc/setup_money_briefcase(mob/living/carbon/human/H)
	var/money_in_briefcase = 4 * rand(75, 100) * economic_power

	var/culture_mod =   0
	var/culture_count = 0
	for(var/token in H.cultural_info)
		var/singleton/cultural_info/culture = H.get_cultural_value(token)
		if(culture && !isnull(culture.economic_power))
			culture_count++
			culture_mod += culture.economic_power
	if(culture_count)
		culture_mod /= culture_count
	money_in_briefcase *= culture_mod

	money_in_briefcase *= GLOB.using_map.salary_modifier
	money_in_briefcase *= 1 + 2 * H.get_skill_value(SKILL_FINANCE)/(SKILL_MAX - SKILL_MIN)
	money_in_briefcase = round(money_in_briefcase)

/singleton/hierarchy/outfit/job/liberia/merchant/post_equip(mob/living/carbon/human/H)
	..()
	var/obj/item/storage/secure/briefcase/sec_briefcase = new(H)
	for(var/obj/item/briefcase_item in sec_briefcase)
		qdel(briefcase_item)
	for(var/i=money_in_briefcase, i>0, i--)
		new /obj/item/spacecash/bundle/c1000 (sec_briefcase)
	H.equip_to_slot_or_del(sec_briefcase, slot_l_hand)

/singleton/hierarchy/outfit/job/liberia/merchant/security
	name = OUTFIT_JOB_NAME("Merchant Security")
	uniform = /obj/item/clothing/under/syndicate/tacticool
	suit = /obj/item/clothing/suit/armor/pcarrier/light
	shoes = /obj/item/clothing/shoes/jackboots
	id_pda_assignment = "Merchant Security"

/singleton/hierarchy/outfit/job/liberia/merchant/engineer
	name = OUTFIT_JOB_NAME("Merchant Engineer")
	uniform = /obj/item/clothing/under/rank/engineer
	shoes = /obj/item/clothing/shoes/jackboots
	id_pda_assignment = "Merchant Engineer"

/singleton/hierarchy/outfit/job/liberia/merchant/doctor
	name = OUTFIT_JOB_NAME("Merchant Medical")
	uniform = /obj/item/clothing/under/color/white
	suit = /obj/item/clothing/suit/storage/toggle/labcoat
	shoes = /obj/item/clothing/shoes/dress
	id_pda_assignment = "Merchant Medical"

/singleton/hierarchy/outfit/job/liberia/merchant/leader
	name = OUTFIT_JOB_NAME("Merchant Leader - liberia")
	uniform = /obj/item/clothing/under/suit_jacket/charcoal
	shoes = /obj/item/clothing/shoes/laceup
	id_types = list(/obj/item/card/id/liberia/merchant/leader)

/obj/item/card/id/liberia/merchant
	desc = "An identification card issued to Merchants."
	job_access_type = /datum/job/submap/merchant_trainee
	color = COLOR_OFF_WHITE
	detail_color = COLOR_BEIGE

/obj/item/card/id/liberia/merchant/leader
	desc = "An identification card issued to Merchant Leaders, indicating their right to sell and buy goods."
	job_access_type = /datum/job/submap/merchant
