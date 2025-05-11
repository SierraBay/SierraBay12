#include "interactions\airlock.dm"
#include "interactions\armored_blast.dm"
#include "interactions\cargo_blast.dm"

///Мех атакует обьект/предмет лапой.
/mob/living/exosuit/proc/attack_with_fists(atom/click_target, mob/living/pilot)
	setClickCooldown(active_arm ? active_arm.action_delay : 7) // You've already commited to applying fist, don't turn and back out now!
	playsound(src.loc, L_leg.mech_step_sound, 60, 1)
	var/arms_local_damage = active_arm.melee_damage
	src.visible_message(SPAN_DANGER("\The [src] steps back, preparing for a strike!"), blind_message = SPAN_DANGER("You hear the loud hissing of hydraulics!"))
	if (do_after(src, 1.2 SECONDS, get_turf(src), DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS) && src)
		add_heat(active_arm.heat_generation)
		//Если расстояние между целью оказалось слишком большой (больше 1 тайла) - мы мажем
		if (get_dist(src, click_target) > 1.5)
			src.visible_message(SPAN_DANGER(" [src] misses with his attack!"))
			setClickCooldown(active_arm ? active_arm.action_delay : 7)
			playsound(src.loc, active_arm.punch_sound, 50, 1)
			return
		//Проверяем обьект на момент особых взаимодействий. Если их нет - атакуем.
		if(!click_target.mech_fist_interaction(src, pilot, arms_local_damage, active_arm))
			click_target.attack_generic(src, arms_local_damage, "strikes", DAMAGE_BRUTE) //Мех именно атакует своей лапой обьект
			var/turf/T = get_turf(click_target)
			if(ismob(click_target))
				var/mob/target = click_target
				if(!target.lying && target.mob_size < mob_size)
					target.throw_at(get_ranged_target_turf(target, get_dir(src, target), 1),1, 1, src, TRUE)
					target.Weaken(1)
			do_attack_effect(T, "smash")
			playsound(src.loc, active_arm.punch_sound, 50, 1)
			setClickCooldown(active_arm ? active_arm.action_delay : 7)




/*Функция вызываемая, когда обьект атакуется лапами меха
*TRUE - атаковать не нужно, мех уже как-то повзаимодействовал по особенному. К примеру, открыл шлюз.
*FALSE - нужно нанести удар, т.к нет особого взаимодействия (Условно нельзя раскрыть шлюз)
*/
/atom/proc/mech_fist_interaction(mob/living/exosuit/mech, mob/living/pilot, mech_fist_damage, obj/item/mech_component/manipulators/active_arm)
	return
