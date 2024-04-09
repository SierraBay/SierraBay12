/obj/submap_landmark/joinable_submap/providence
	name = "IPV Providence"
	archetype = /singleton/submap_archetype/providence

/singleton/submap_archetype/providence
	descriptor = "IPV Providence"
	map = "IPV Providence"
	crew_jobs = list(
		/datum/job/submap/providence/trucker
	)

/datum/job/submap/providence/trucker
	title = "Pilot Freelancer"
	total_positions = 1
	supervisors = "nobody but yourself"
	info = "It's a best job in your entire life"
	outfit_type = /singleton/hierarchy/outfit/pilot_freelancer
	loadout_allowed = TRUE
	min_skill = list(
		SKILL_EVA = SKILL_TRAINED,
		SKILL_HAULING = SKILL_TRAINED,
		SKILL_PILOT = SKILL_TRAINED,
		SKILL_DEVICES = SKILL_BASIC,
		SKILL_MEDICAL = SKILL_BASIC
	)

/singleton/hierarchy/outfit/pilot_freelancer
	name = "Pilot freelancer"

	uniform = /obj/item/clothing/under/mbill
	suit = /obj/item/clothing/suit/storage/toggle/brown_jacket
	head = /obj/item/clothing/head/cowboy_hat
	back = /obj/item/storage/backpack/satchel/pocketbook/gray
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/dutyboots
	backpack_contents = list(/obj/item/device/flashlight/flare=2,/obj/item/device/radio/hailing=1)

/obj/submap_landmark/spawnpoint/providence/trucker
	name = "Pilot Freelancer"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE
