/obj/item/material/armblade
	melee_strikes = list(/singleton/combo_strike/swipe_strike/sword_slashes, /singleton/combo_strike/swipe_strike/mixed_combo)
	lunge_dist = 4

/obj/item/material/armblade/resolve_attackby(atom/atom, mob/living/user, click_params)
	if(!isnull(melee_strike) && !user.skill_check(SKILL_COMBAT, SKILL_EXPERIENCED) && prob(src.fail_chance))
		return 1

	..()

/obj/item/material/armblade/claws
	melee_strikes = list(/singleton/combo_strike/precise_strike/fast_attacks)

/obj/item/material/armblade/wrist
	melee_strikes = list(/singleton/combo_strike/precise_strike/fast_attacks, /singleton/combo_strike/swipe_strike/harrying_strike)

/obj/item/crowbar/brace_jack
	melee_strikes = list(/singleton/combo_strike/swipe_strike/blunt_swing/mixed_combo, /singleton/combo_strike/swipe_strike/polearm_slash/hammer, /singleton/combo_strike/circle_strike/blunt)
	fail_chance = 30

/obj/item/melee/baton/cattleprod
	melee_strikes = list(/singleton/combo_strike/swipe_strike/polearm_mixed)
	lunge_delay = 10 SECONDS
	fail_chance = 30
	lunge_dist = 2

/obj/item/melee/baton/cattleprod/AltClick(mob/user)
	if(melee_strikes)
		swap_stances(user)

	..()

/obj/item/melee/cultblade
	melee_strikes = list(/singleton/combo_strike/swipe_strike/sword_slashes, /singleton/combo_strike/swipe_strike/mixed_combo)
	lunge_dist = 3

/obj/item/melee/energy/sword
	melee_strikes = list(/singleton/combo_strike/swipe_strike/sword_slashes, /singleton/combo_strike/swipe_strike/mixed_combo)
	fail_chance = 40

/obj/item/melee/energy/sword/AltClick(mob/user)
	if(melee_strikes)
		swap_stances(user)

	..()

/obj/item/melee/energy/blade
	melee_strikes = list(/singleton/combo_strike/swipe_strike/sword_slashes, /singleton/combo_strike/swipe_strike/mixed_combo)
	fail_chance = 60
	lunge_dist = 4

/obj/item/melee/energy/blade/AltClick(mob/user)
	if(melee_strikes)
		swap_stances(user)

	..()

/obj/item/material/harpoon
	melee_strikes = list(/singleton/combo_strike/swipe_strike/polearm_mixed)

/obj/item/material/hatchet
	melee_strikes = list(/singleton/combo_strike/precise_strike/fast_attacks)
	fail_chance = 20
	lunge_dist = 2

/obj/item/material/hatchet/machete
	melee_strikes = list(/singleton/combo_strike/precise_strike/fast_attacks, /singleton/combo_strike/swipe_strike/mixed_combo)
	fail_chance = 40
	lunge_dist = 4

/obj/item/material/hatchet/machete/mech
	melee_strikes = list(/singleton/combo_strike/swipe_strike/polearm_slash, /singleton/combo_strike/swipe_strike/mixed_combo)
	lunge_dist = 0

/obj/item/material/knife/combat
	melee_strikes = list(/singleton/combo_strike/precise_strike/fast_attacks, /singleton/combo_strike/swipe_strike/harrying_strike)
	fail_chance = 40
	lunge_dist = 2

/obj/item/material/knife/kitchen/cleaver
	melee_strikes = list(/singleton/combo_strike/swipe_strike/harrying_strike, /singleton/combo_strike/swipe_strike/mixed_combo)
	fail_chance = 30
	lunge_dist = 1

/obj/item/material/knife/unathi
	melee_strikes = list(/singleton/combo_strike/swipe_strike/harrying_strike, /singleton/combo_strike/swipe_strike/mixed_combo)
	fail_chance = 60
	lunge_dist = 2

/obj/item/material/knife/ritual
	melee_strikes = list(/singleton/combo_strike/swipe_strike/harrying_strike, /singleton/combo_strike/swipe_strike/mixed_combo)
	fail_chance = 60
	lunge_dist = 2

/obj/item/mop
	melee_strikes = list(/singleton/combo_strike/swipe_strike/blunt_swing/mixed_combo, /singleton/combo_strike/swipe_strike/blunt_swing/wide)

#ifdef MODPACK_SAUNA_PROPS
/obj/item/mop/broom
	melee_strikes = null
#endif

/obj/item/material/scythe
	melee_strikes = list(/singleton/combo_strike/swipe_strike/polearm_mixed, /singleton/combo_strike/swipe_strike/polearm_slash)
	fail_chance = 70

/obj/item/material/sword
	melee_strikes = list(/singleton/combo_strike/swipe_strike/sword_slashes, /singleton/combo_strike/swipe_strike/mixed_combo)
	fail_chance = 70
	lunge_dist = 3

/obj/item/shovel
	melee_strikes = list(/singleton/combo_strike/swipe_strike/blunt_swing/mixed_combo, /singleton/combo_strike/swipe_strike/blunt_swing/wide)
	fail_chance = 30

/obj/item/material/twohanded/baseballbat
	melee_strikes = list(/singleton/combo_strike/swipe_strike/blunt_swing/mixed_combo, /singleton/combo_strike/swipe_strike/blunt_swing/wide)
	fail_chance = 40
	lunge_delay = 10 SECONDS
	lunge_dist = 2

/obj/item/material/twohanded/spear
	melee_strikes = list(/singleton/combo_strike/swipe_strike/polearm_mixed, /singleton/combo_strike/swipe_strike/polearm_slash, /singleton/combo_strike/swipe_strike/polearm_wide)
	fail_chance = 60
	lunge_delay = 10 SECONDS
	lunge_dist = 4

/obj/item/material/twohanded/fireaxe
	melee_strikes = list(/singleton/combo_strike/swipe_strike/polearm_slash, /singleton/combo_strike/swipe_strike/polearm_wide)
	fail_chance = 60
