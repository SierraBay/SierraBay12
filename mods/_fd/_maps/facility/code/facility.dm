/obj/overmap/visitable/sector/facility
	name = "Research Facility"
	desc = "This looks like under-(space?)-ground base. Station-wide distress beacon transmitting their codes."
	icon_state = "station"
	instant_contact = TRUE

	initial_generic_waypoints = list(
		"facility_1"
	)

/datum/map_template/ruin/away_site/facility
	name = "Facility"
	id = "facility"
	description = "Abandoned research facility."
	prefix = "mods/_fd/_maps/facility/maps/"
	suffixes = list("facility.dmm")
	spawn_cost = 2
	//generate_mining_by_z = 1
	area_usage_test_exempted_root_areas = list(/area/map_template/facility)
	apc_test_exempt_areas = list(
		/area/map_template/facility = NO_SCRUBBER|NO_VENT
	)

/obj/shuttle_landmark/facility
	name = "Abandoned Research Facility Hangar"
	landmark_tag = "facility_1"
	base_area = /area/map_template/facility/hangar
	base_turf = /turf/simulated/floor/plating

/////////////      A C C E S S       /////////////

/var/const/access_facility_sec = "ACCESS_FACILITY_SEC" //access for facility security wing
/datum/access/facility_sec
	id = access_facility_sec
	desc = "facility security"
	region = ACCESS_REGION_NONE

/var/const/access_facility_lab = "ACCESS_FACILITY_LAB" //access for facility laboratory
/datum/access/facility_lab
	id = access_facility_lab
	desc = "facility laboratory"
	region = ACCESS_REGION_NONE

/var/const/access_facility_exit = "ACCESS_FACILITY_EXIT" //access for facility laboratory
/datum/access/facility_exit
	id = access_facility_exit
	desc = "facility exit"
	region = ACCESS_REGION_NONE

/obj/item/card/id/facility
	name = "Facility Access Card"
	registered_name = "Facility Access Card"
	access = list(access_maint_tunnels)

/obj/item/card/id/facility/sec
	registered_name = "Facility Security Wing"
	color = "#9E0003"
	detail_color = "#ffee00"
	access = list(access_facility_sec)

/obj/item/card/id/facility/lab
	registered_name = "Facility Laboratory"
	color = "#420039"
	detail_color = "#00eeff"
	access = list(access_facility_lab)

/obj/item/card/id/facility/exit
	registered_name = "Facility Exit"
	color = "#41CC29"
	detail_color = "#D12858"
	access = list(access_facility_exit)

////////////////////////////	R A N D O M   ///////////////////////////////

/obj/random/facility
	name = "random facility item"
	icon = 'mods/_fd/random_rooms/icons/landmarks.dmi'
	var/how_many = 1

// modificated spawn code for HOW MANY var... Im so tired... No one wants to play DL with me after work, and moreover, they come up with more and more games to go to... I just want to be happy. That's why I'm doing this. At least you can play something, thinking that someone else is playing with you.
/obj/random/facility/spawn_item()
	if(prob(spawn_nothing_percentage))
		return

	if(isnull(loc))
		return

	for(how_many, how_many >= 0, how_many--)
		var/build_path = pickweight(spawn_choices())
		var/atom/A = new build_path(src.loc)
		if(pixel_x || pixel_y)
			A.pixel_x = pixel_x
			A.pixel_y = pixel_y
		return A
/*
	for(how_many, how_many >= 0, how_many--)
		var/atom/A = new build_path(src.loc)
		if(pixel_x || pixel_y)
			A.pixel_x = pixel_x
			A.pixel_y = pixel_y
		return A
*/

/obj/random/facility/hallway_room
	name = "random hallway room"
	desc = "RANDOM ROOM WROOM."
	icon = 'mods/_fd/random_rooms/icons/landmarks.dmi'
	icon_state = "radnomstuff-green"
	spawn_nothing_percentage = 30

/obj/random/facility/hallway_room/spawn_choices()
	return list(/obj/spawner/room/facility/hallway/room = 100)


/obj/random/facility/clothing
	name = "random facility clothing"
	icon_state = "armor-grey"

/obj/random/facility/clothing/spawn_choices()
	return list(/obj/random/clothing = 9,
				/obj/random/accessory = 8,
				/obj/random/backpack = 8,
				/obj/random/gloves = 9,
				/obj/random/glasses = 9,
				/obj/random/hat = 9,
				/obj/random/shoes = 9,
				/obj/random/suit = 9)

/obj/random/facility/mercenary
	name = "random facility mercenary 100"
	icon_state = "hostilemob-red"

/obj/random/facility/mercenary/low
	name = "random facility mercenary 20"
	icon_state = "hostilemob-red-low"
	spawn_nothing_percentage = 80

/obj/random/facility/mercenary/high
	name = "random facility mercenary 85"
	icon_state = "hostilemob-red-cluster"
	spawn_nothing_percentage = 15

/obj/random/facility/mercenary/medium
	name = "random facility mercenary 50"
	icon_state = "hostilemob-red-cluster-low"
	spawn_nothing_percentage = 50

/obj/random/facility/mercenary/spawn_choices()
	return list(/mob/living/simple_animal/hostile/human/syndicate/facility/melee = 5,
				/mob/living/simple_animal/hostile/human/syndicate/facility/ranged1 = 3,
				/mob/living/simple_animal/hostile/human/syndicate/facility/ranged2 = 2,
				/mob/living/simple_animal/hostile/human/syndicate/facility/ranged3 = 4,
				/mob/living/simple_animal/hostile/human/syndicate/facility/ranged4 = 5)


//	G U N S

/obj/random/facility/gun
	name = "Random Common Gun"
	desc = "This is a random gun."
	icon = 'mods/_fd/random_rooms/icons/landmarks.dmi'
	icon_state = "gun-grey-low"
	spawn_nothing_percentage = 60

/obj/random/facility/gun/spawn_choices()
	return list(/obj/item/gun/projectile/pistol/sec/lethal = 3,
				/obj/item/gun/projectile/pistol/holdout = 2)

/obj/random/facility/gun/uncommon
	name = "Random Uncommon Gun"
	icon_state = "gun-blue"
	spawn_nothing_percentage = 70

/obj/random/facility/gun/uncommon/spawn_choices()
	return list(/obj/item/gun/projectile/shotgun/pump = 3,
				/obj/item/gun/projectile/revolver = 2,
				/obj/item/gun/projectile/shotgun/doublebarrel = 3,
				/obj/item/gun/projectile/sniper/garand = 3,
				/obj/item/gun/projectile/pistol/magnum_pistol = 2)

/obj/random/facility/gun/rare
	name = "Random Rare Gun"
	icon_state = "gun-red"
	spawn_nothing_percentage = 80

/obj/random/facility/gun/rare/spawn_choices()
	return list(/obj/item/gun/projectile/shotgun/pump/combat = 3,
				/obj/item/gun/projectile/revolver/rsh21 = 3,
				/obj/item/gun/projectile/automatic/sec_smg = 3,
				/obj/item/gun/energy/laser = 3,
				/obj/item/gun/magnetic/railgun = 3,
				/obj/item/gun/energy/xray = 3,
				/obj/item/gun/energy/xray/pistol = 1)

/obj/random/facility/gun/legendary
	name = "Random Rare Gun"
	icon_state = "gun-orange"
	spawn_nothing_percentage = 90

/obj/random/facility/gun/legendary/spawn_choices()
	return list(/obj/item/gun/projectile/automatic/shotgun = 3,
				/obj/item/gun/magnetic/railgun/tcc = 3,
				/obj/item/gun/energy/pulse_rifle/carbine = 3,
				/obj/item/gun/projectile/automatic/assault_rifle = 3,
				/obj/item/gun/energy/pulse_rifle/pistol = 1,
				/obj/item/gun/projectile/automatic/bullpup_rifle = 3,
				/obj/item/gun/projectile/pistol/gyropistol = 1,
				/obj/item/gun/energy/sniperrifle = 2)


/obj/random/facility/ammo
	name = "Random Ammunition"
	icon_state = "ammo-grey"
	how_many = 3

/obj/random/facility/ammo/spawn_choices()
	return list(/obj/item/storage/box/ammo/shotgunammo = 3,
				/obj/item/storage/box/ammo/shotgunshells = 3,
				/obj/item/storage/box/ammo/flechetteshells = 2,
				/obj/item/ammo_magazine/pistol = 2,
				/obj/item/ammo_magazine/smg_top = 3,
				/obj/item/ammo_magazine/gyrojet = 2,
				/obj/item/ammo_magazine/magnum = 2,
				/obj/item/ammo_magazine/speedloader/rifle = 2,
				/obj/item/ammo_magazine/mil_rifle = 3,
				/obj/item/ammo_magazine/rifle = 3)


/*
			F A C I L I T Y		E N E M I E S	//////////////////////////
*/

/singleton/hierarchy/outfit/facility/mercenary
	name = "Facility Mercenary"
	suit = /obj/item/clothing/suit/armor/pcarrier
	uniform = /obj/item/clothing/under/syndicate/combat
	mask = /obj/item/clothing/mask/gas/half
	head = /obj/item/clothing/head/beret
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/thick
	glasses = /obj/item/clothing/glasses/sunglasses
	l_ear = /obj/item/device/radio/headset/syndicate/alt
	id_slot = slot_wear_id
	id_types = list(/obj/item/card/id/syndicate)
	id_pda_assignment = "Mercenary"
	id_desc = "Mercenary"

/obj/landmark/corpse/facility/mercenary
	name = "Facility Mercenary"
	corpse_outfits = list(/singleton/hierarchy/outfit/facility/mercenary)

/mob/living/simple_animal/hostile/human/syndicate/facility
	name = "\improper Unknown Mercenary"
	desc = "Unknown mercenary. His goals are unknown, as is his motive, his eyes are covered with dark glasses, and his face is obscured by a mask. Who knows who he's hired by or what's on his mind, but one thing is clear - he's not going to talk to you."
	icon_state = "mercenary"
	icon_living = "mercenary"
	icon_dead = "mercenary_dead"
	icon_gib = "mercenary_gib"
	turns_per_move = 1
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	grab_resist = 80
	maxHealth = 70
	health = 70
	flash_vulnerability = 0
	harm_intent_damage = 5
	natural_weapon = /obj/item/natural_weapon/punch
	can_escape = TRUE
	a_intent = I_HURT
	corpse = /obj/landmark/corpse/facility/mercenary
	unsuitable_atmos_damage = 5
	environment_smash = 1
	pry_time = 0 SECONDS
	pry_desc = "open"
	faction = "mercenary"
	status_flags = CANPUSH
	armor = list(			// Values for normal getarmor() checks
				"melee" = 10,
				"bullet" = 30,
				"laser" = 20,
				"energy" = 20,
				"bomb" = 10,
				"bio" = 100,
				"rad" = 20
				)
	heat_resist = 0.6
	cold_resist = 0.6
	shock_resist = 0.8
	water_resist = 1.0
	poison_resist = 0.3
	thick_armor = TRUE
	return_damage_min = 3
	return_damage_max = 10

/mob/living/simple_animal/hostile/human/syndicate/facility/death(gibbed, deathmessage = "bites through the edge of the collar, breaking the capsule inside and dies!", show_dead_message)
	icon_state = icon_dead
	update_icon()
	density = FALSE
	adjustBruteLoss(maxHealth) //Make sure dey dead.
	walk_to(src,0)
	return ..(gibbed,deathmessage,show_dead_message)

/mob/living/simple_animal/hostile/human/syndicate/facility/melee
	icon_state = "mercenary_melee"
	icon_living = "mercenary_melee"
	natural_weapon = /obj/item/material/hatchet/machete/facility
	weapon1 = /obj/item/material/hatchet/machete
	maxHealth = 160
	health = 160
	speed = -6
	move_speed = 0.5
	taser_kill = 0
	status_flags = 0

/mob/living/simple_animal/hostile/human/syndicate/facility/melee/use_tool(obj/item/O as obj, mob/user as mob)
	SHOULD_CALL_PARENT(FALSE)
	if(O.force)
		if(prob(80))
			var/damage = O.force
			if (O.damtype == DAMAGE_PAIN)
				damage = 0
			health -= damage
			visible_message("<span class='danger'>\The [src] has been attacked with \the [O] by \the [user].</span>")
		else
			visible_message("<span class='danger'>\The [src] professionally blocks the [O] with his machete!</span>")
		//user.do_attack_animation(src)
	else
		to_chat(usr, "<span class='warning'>\The [src] doesn't give you a chance to hit him with \the [O].You need something better.</span>")
		visible_message("<span class='warning'>\The [user] trying to attack \the [src] with \the [O], but it completely blocks the attack.</span>")

/mob/living/simple_animal/hostile/human/syndicate/facility/bullet_act(obj/item/projectile/Proj)
	if(!Proj)	return
	if(prob(80))
		src.health -= Proj.damage
	else
		visible_message("<span class='danger'>\The [src] masterfully evades \the [Proj] with his movements!</span>")
	return 0

/mob/living/simple_animal/hostile/human/syndicate/facility/ranged1
	ranged = 1
	health = 70
	maxHealth = 70
	taser_kill = 0
	icon_state = "mercenary_ranged1"
	icon_living = "mercenary_ranged1"
	casingtype = /obj/item/ammo_casing/pistol/used
	projectilesound = 'sound/weapons/gunshot/gunshot_strong.ogg'
	projectiletype = /obj/item/projectile/bullet/pistol
	needs_reload = TRUE
	reload_max = 15
	reload_count = 0
	reload_time = 3 SECONDS

	weapon1 = /obj/item/gun/projectile/pistol/military/broken

/mob/living/simple_animal/hostile/human/syndicate/facility/ranged2
	ranged = 1
	health = 65
	maxHealth = 65
	taser_kill = 0
	icon_state = "mercenary_ranged2"
	icon_living = "mercenary_ranged2"
	casingtype = /obj/item/ammo_casing/pistol/used
	projectilesound = 'sound/weapons/gunshot/gunshot2.ogg'
	projectiletype = /obj/item/projectile/bullet/pistol/strong
	needs_reload = TRUE
	reload_max = 25
	reload_count = 0
	reload_time = 5 SECONDS

	weapon1 = /obj/item/gun/projectile/automatic/sec_smg/lethal/broken

/mob/living/simple_animal/hostile/human/syndicate/facility/ranged3
	ranged = 1
	rapid = 1
	icon_state = "mercenary_ranged3"
	icon_living = "mercenary_ranged3"
	casingtype = null
	projectilesound = 'sound/weapons/Laser.ogg'
	projectiletype = /obj/item/projectile/beam

	weapon1 = /obj/item/gun/energy/retro/broken

/mob/living/simple_animal/hostile/human/syndicate/facility/ranged4
	ranged = 1
	rapid = 1
	icon_state = "mercenary_ranged4"
	icon_living = "mercenary_ranged4"
	casingtype = null
	projectilesound = 'sound/weapons/Laser.ogg'
	projectiletype = /obj/item/projectile/beam/midlaser

	weapon1 = /obj/item/gun/energy/laser/broken

/obj/item/material/hatchet/machete/facility
	name = "mercenary machete"
	force = 20
	force_multiplier = 1
	max_force = 20
	armor_penetration = 80

/obj/item/gun/projectile/pistol/military/broken
	jam_chance = 100
	desc = "Its broken."

/obj/item/gun/projectile/automatic/sec_smg/lethal
	magazine_type = /obj/item/ammo_magazine/smg_top

/obj/item/gun/projectile/automatic/sec_smg/lethal/broken
	jam_chance = 100
	desc = "Its broken."

/obj/item/gun/energy/gun/broken
	desc = "Its broken."
	charge_cost = 120
	max_shots = 2
	recharge_time = 30

/obj/item/gun/energy/retro/broken
	desc = "Its broken."
	charge_cost = 120
	max_shots = 2
	recharge_time = 30

/obj/item/gun/energy/laser/broken
	desc = "Its broken."
	charge_cost = 120
	max_shots = 2
	recharge_time = 30
