///Может ли снаряд пройти через броню
//FALSE - не пускаем через себя
//TRUE - пускаем
/obj/item/mech_external_armor/proc/react_at_damage(obj/item/projectile/input_projectile)
	if(can_go_through(input_projectile))
		return TRUE
	else
		damage_armour(input_projectile)
		return FALSE


/obj/item/mech_external_armor/proc/can_go_through(obj/item/projectile/input_projectile)
	if(input_projectile.damage_flags & DAMAGE_FLAG_LASER)
		if(input_projectile.mech_armor_penetration > armors["laser"])
			return TRUE
		else
			return FALSE
	else if(input_projectile.damage_flags & DAMAGE_FLAG_BULLET)
		if(input_projectile.mech_armor_penetration > armors["bullet"])
			return TRUE
		else
			return FALSE
	return TRUE


/obj/item/mech_external_armor/proc/damage_armour(obj/item/projectile/input_projectile)
	if(!input_projectile.mech_armor_damage)
		return FALSE
	current_health -= input_projectile.mech_armor_damage
	current_health = clamp(current_health, 0, max_health)
	if(!current_health)
		destroy_armour()

//Броня отцепляется
/obj/item/mech_external_armor/proc/deinstall_armour(mob/living/user)

//Броня отваливается
/obj/item/mech_external_armor/proc/destroy_armour()
	owner.installed_armor = null
	owner.owner.on_update_icon() //Обновим спрайт меха от потери брони
	forceMove(get_turf(owner))
	owner = null
	icon_state = broken_icon_state
