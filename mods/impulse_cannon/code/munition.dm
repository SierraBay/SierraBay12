/obj/structure/ship_munition
	name = "munitions"
	color = null
	icon = 'mods/impulse_cannon/icons/munitions.dmi'
	w_class = ITEM_SIZE_GARGANTUAN
	density = TRUE

// make a screeching noise to drive people mad
/obj/structure/ship_munition/Move()
	. = ..()
	if(.)
		var/turf/T = get_turf(src)
		if(!isspace(T) && !istype(T, /turf/simulated/floor/carpet))
			playsound(T, pick(move_sounds), 75, 1)

/obj/structure/ship_munition/md_slug
	name = "mass driver slug"
	icon_state = "slug"

/obj/structure/ship_munition/ap_slug
	name = "armor piercing mass driver slug"
	icon_state = "ap"

/obj/structure/ship_munition/disperser_charge
	icon_state = "ammunition1"
	color = null
	desc = "A charge to power the obstruction field disperser with. It looks like artillery shell. This charge does not have a defined purpose."

/obj/structure/ship_munition/disperser_charge/fire
	icon_state = "ammunition4"
	color = null
	desc = "A charge to power the obstruction field disperser with. It looks like artillery shell. This charge is designed to release a localised fire on impact."

/obj/structure/ship_munition/disperser_charge/emp
	icon_state = "ammunition3"
	color = null
	desc = "A charge to power the obstruction field disperser with. It looks like artillery shell. This charge is designed to release a blast of electromagnetic pulse on impact."

/obj/structure/ship_munition/disperser_charge/mining
	icon_state = "ammunition2"
	color = null
	desc = "A charge to power the obstruction field disperser with. It looks like artillery shell. This charge is designed to mine ores on impact."

/obj/structure/ship_munition/disperser_charge/explosive
	icon_state = "ammunition5"
	color = null
	desc = "A charge to power the obstruction field disperser with. It looks like artillery shell. This charge is designed to explode on impact."
