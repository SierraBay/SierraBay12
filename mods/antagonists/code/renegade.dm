/datum/antagonist/renegade
	role_text = "Renegade"
	role_text_plural = "Renegades"
	blacklisted_jobs = list(/datum/job/ai, /datum/job/submap)
	restricted_jobs = list(/datum/job/officer, /datum/job/warden, /datum/job/captain, /datum/job/hop, /datum/job/hos, /datum/job/chief_engineer, /datum/job/rd, /datum/job/cmo)
	welcome_text = "У вас плохое предчувствие. Сегодня что-то пойдёт не так. Но вы к этому готовы и собираетесь пережить эту смену."
	antag_text = {"\
	<p>Вы -<b>дейтерантагонист</b>! Ваша цель <b>выжить</b> до конца раунда любыми способами.</p> \
	<p>Предавай друзей, договаривайся с врагами и держи своё оружие при себе. \
	Вы здесь не для того, чтобы искать проблемы. <i>Они</i> находят <i>вас</i>, просто убейте их.</p> \
	<p>Помните, что вы - дейтерантагонист. Перед тем как делать что-то экстраординарное, уточните у администрации.</p>
	"}

	id = MODE_RENEGADE
	flags = ANTAG_SUSPICIOUS | ANTAG_IMPLANT_IMMUNE | ANTAG_RANDSPAWN | ANTAG_VOTABLE
	hard_cap = 3
	hard_cap_round = 5

	initial_spawn_req = 1
	initial_spawn_target = 3
	antaghud_indicator = "hud_renegade"
	skill_setter = /datum/antag_skill_setter/station/renegade

/datum/antagonist/renegade/create_objectives(datum/mind/player)

	if(!..())
		return

	var/datum/objective/survive/survive = new
	survive.owner = player
	player.objectives |= survive

/datum/antagonist/renegade/spawn_guns = list(/obj/item/selection/renegade) // Yep. This counts as gun.


/obj/item/selection/renegade
	name = "Personal luggage"
	desc = "A very suspicious secure box with no name or ID number on it. Without a doubt a contraband. Get rid on it!"
	selection_options = list(
		"Random energy weapon" = /obj/random/renegade/energy,
		"Random projectile weapon" = /obj/random/renegade/ballistic,
		"Random melee weapon" = /obj/random/renegade/melee,
		"Random restricted augment (CBM)" = /obj/random/renegade/augment
	)

/obj/random/renegade/energy
	name = "Random Renegade Energy Weapon"
	desc = "This is a random energy weapon."
	icon = 'icons/obj/guns/energy_gun.dmi'
	icon_state = "energyshock100"

/obj/random/renegade/energy/spawn_choices()
	return list(/obj/item/gun/energy/retro,
				/obj/item/gun/energy/gun,
				/obj/item/gun/energy/crossbow,
				/obj/item/gun/energy/pulse_rifle/pistol,
				/obj/item/gun/energy/xray/pistol,
				/obj/item/gun/energy/toxgun,
				/obj/item/gun/energy/incendiary_laser)

/obj/random/renegade/ballistic
	name = "Random Renegade Ballitic Weapon"
	desc = "This is a random ballistic weapon. It's always a Magnum"
	icon = 'icons/obj/guns/pistol.dmi'
	icon_state = "secguncomp"

/obj/random/renegade/ballistic/spawn_choices()
	return list(/obj/item/gun/projectile/automatic,
				/obj/item/gun/projectile/automatic/machine_pistol,
				/obj/item/gun/projectile/automatic/sec_smg,
				/obj/item/gun/projectile/revolver,
				/obj/item/gun/projectile/pistol/sec/lethal,
				/obj/item/gun/projectile/pistol/holdout,
				/obj/item/gun/projectile/revolver,
				/obj/item/gun/projectile/revolver/medium,
				/obj/item/gun/projectile/shotgun/doublebarrel/sawn,
				/obj/item/gun/projectile/pistol/magnum_pistol,
				/obj/item/gun/projectile/pistol/bobcat,
				/obj/item/gun/projectile/pistol/optimus,
				/obj/item/gun/projectile/pistol/m22f,
				/obj/item/gun/projectile/pistol/m19,
				/obj/item/gun/projectile/revolver/holdout,
				/obj/item/gun/projectile/pistol/throwback,
				/obj/item/gun/projectile/pistol/magnum_pistol)

/obj/random/renegade/melee
	name = "Random Renegade Melee Weapon"
	desc = "This is a random melee weapon for real man."
	icon = 'icons/obj/weapons/melee_physical.dmi'
	icon_state = "katana"

/obj/random/renegade/melee/spawn_choices()
	return list(/obj/item/melee/energy/sword,
				/obj/item/cane/concealed,
				/obj/item/circular_saw,
				/obj/item/scalpel/laser,
				/obj/item/melee/baton/loaded,
				/obj/item/material/knife/folding/tacticool)

/obj/random/renegade/augment
	name = "Random Renegade Augmentation"
	desc = "This is a random CBM module."
	icon = 'icons/obj/tools/augment_implanter.dmi'
	icon_state = "augment_implanter"

/obj/random/renegade/augment/spawn_choices()
	return list(/obj/item/device/augment_implanter/popout_shotgun,
				/obj/item/device/augment_implanter/powerfist,
				/obj/item/device/augment_implanter/wrist_blade)
