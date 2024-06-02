/obj/item/mech_component/propulsion
	var/bump_type = BASIC_BUMP
	var/bump_safety = TRUE
	var/can_strafe = FALSE //Может ли мех ходить при помощи стрейфа. Крайне полезная фича, используйте если знаете что делаете.
	var/good_in_strafe = FALSE //Влияет на эффективность стрейфа, используйте когда мир будет к нему готов.
	var/collision_coldown = 7

/obj/item/mech_component/propulsion/powerloader
	max_damage = 100

/obj/item/mech_component/propulsion/light
	max_damage = 80

/obj/item/mech_component/propulsion/spider
	max_damage = 210
	bump_type = MEDIUM_BUMP
	can_strafe = TRUE

/obj/item/mech_component/propulsion/tracks
	max_damage = 250
	bump_type = HARD_BUMP
	bump_safety = FALSE

/obj/item/mech_component/propulsion/combat
	max_damage = 180
	bump_type = MEDIUM_BUMP
	bump_safety = FALSE
	move_delay = 3.5
	turn_delay = 3.5

/obj/item/mech_component/propulsion/heavy
	max_damage = 500
	bump_type = HARD_BUMP
	bump_safety = FALSE
