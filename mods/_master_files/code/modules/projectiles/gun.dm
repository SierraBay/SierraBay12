/*
	COMBAT_EXTENDED — стрельба из-за щита (`mods/combat_extended/code/shields.dm`). Из стойки
	«укрыться» стреляет только мастер, и выстрел раскрывает его голову и руку с оружием.
*/

/obj/item/gun/Fire(atom/target, mob/living/user, clickparams, pointblank = 0, reflex = 0)
	if(ishuman(user))
		var/mob/living/carbon/human/shooter = user
		if(shooter.ce_shield_blocks_firing())
			return
	return ..()


/*
	COMBAT_EXTENDED — выстрел при обезоруживании бросают два броска мода до обезоруживания
	(`mods/combat_extended/code/disarm_gunfire.dm`). Бросок Bay второй раз ружьё не стреляет.
*/
/obj/item/gun/on_disarm_attempt(mob/target, mob/attacker)
	if(ce_disarm_gunfire_enabled)
		return 0
	return ..()


/*
	COMBAT_EXTENDED — выстрел в упор помечает снаряд: по тому, в кого целились, он не промахивается
	и летит без разброса (`mods/combat_extended/code/projectile_hits.dm`).
*/
/obj/item/gun/process_point_blank(obj/projectile, mob/user, atom/target)
	. = ..()
	var/obj/item/projectile/shot = projectile
	if(istype(shot))
		shot.ce_point_blank = TRUE


/*
	COMBAT_EXTENDED — снаряд, которому оружие посчитало точность, помечается выстрелом из оружия:
	в броске попадания он гасит `ce_gun_accuracy_points` шанса провала
	(`mods/combat_extended/code/projectile_hits.dm`). И запоминает дугу разброса от отдачи, которая
	накопилась у стрелка к этому выстрелу (`mods/combat_extended/code/recoil_spread.dm`). До кор
	версии оружие в прицеле берёт точность прицела, только если стрелок постоял на месте
	(`mods/combat_extended/code/scopes.dm`).
*/
/obj/item/gun/process_accuracy(obj/projectile, mob/living/user, atom/target, burst, held_twohanded)
	ce_settle_scope_accuracy(user)
	. = ..()
	var/obj/item/projectile/shot = projectile
	if(istype(shot))
		shot.ce_gun_shot = TRUE
		shot.ce_recoil_arc = user.ce_get_recoil_arc()


/*
	COMBAT_EXTENDED — после выстрела: стрелок из стойки «укрыться» раскрывается
	(`mods/combat_extended/code/shields.dm`), а отдача даёт ему стаки разброса
	(`mods/combat_extended/code/recoil_spread.dm`), и кольцо разброса на курсоре расширяется по ним
	(`mods/combat_extended/code/spread_ring.dm`).
*/
/obj/item/gun/handle_post_fire(mob/user, atom/target, pointblank = 0, reflex = 0, obj/projectile)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/shooter = user
		shooter.ce_note_shot()
	if(isliving(user))
		ce_build_recoil(user)
	if(iscarbon(user))
		user.update_mouse_pointer()


/*
	COMBAT_EXTENDED — у другого режима огня другой разброс: кольцо разброса держащего оружие
	пересчитывается (`mods/combat_extended/code/spread_ring.dm`).
*/
/obj/item/gun/switch_firemodes()
	. = ..()
	var/mob/living/carbon/holder = loc
	if(istype(holder))
		holder.update_mouse_pointer()


/*
	COMBAT_EXTENDED — кнопка прицела (`mods/combat_extended/code/scopes.dm`): оружию с прицелом её
	даёт `Initialize()`, а нажатие смотрит в прицел, как глагол `Use Scope`. Без прицела кнопка
	оружия работает как в кор коде.
*/
/obj/item/gun/Initialize()
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	ce_add_scope_action()

/obj/item/gun/ui_action_click(mob/living/user)
	if(!ce_has_scope_action())
		return ..()
	toggle_scope(user, scope_zoom)
