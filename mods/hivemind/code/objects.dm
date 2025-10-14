//Hivemind special objects stored here, like projectiles, wreckages or artifacts


//toxic shot, turret's ability use it
/obj/item/projectile/goo
	name = "toxic goo"
	icon = 'mods/hivemind/icons/hivemind_obj.dmi'
	icon_state = "goo_proj"
	damage = 15
	damage_type = DAMAGE_BURN
	step_delay = 2


/obj/item/projectile/goo/on_hit(atom/target, blocked = 0)
	. = ..()
	if(istype(target, /mob/living) && !istype(target, /mob/living/silicon) && !blocked)
		var/mob/living/L = target
		L.apply_damage(10, DAMAGE_TOXIN)
	if(!(locate(/obj/decal/cleanable/spiderling_remains) in target.loc))
		var/obj/decal/cleanable/spiderling_remains/goo = new /obj/decal/cleanable/spiderling_remains(target.loc)
		goo.name = "green goo"
		goo.desc = "An unidentifiable liquid. It smells awful."

/obj/item/projectile/goo/weak
	name = "weakened electrolyzed goo"
	damage = 10
	damage_type = DAMAGE_BURN
