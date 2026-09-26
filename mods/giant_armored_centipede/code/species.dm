/singleton/species/nabber
	natural_armour_values = list(
		melee  = ARMOR_MELEE_RESISTANT, // Хитин не мясо, а потому, он должен гасить урон оружием
		bullet = 1.5*ARMOR_BALLISTIC_SMALL, // Хитин бронированный и кое-как должен защищать
		bomb   = ARMOR_BOMB_PADDED,
		energy = ARMOR_ENERGY_RESISTANT, // Хитин это изолятор
		bio    = ARMOR_BIO_SHIELDED,
		rad    = 0.5*ARMOR_RAD_MINOR
		)

	siemens_coefficient = 0.8 // Хитин это изолятор
	weaken_mod = 0.9 // Нет ног, меньше времени на вставание
	stun_mod = 0.9 // Нет ног, меньше времени на вставание

/obj/item/organ/internal/eyes/insectoid/nabber/additional_flash_effects(intensity) // Первый слеп флешкой ослепит, но не даст спамить
	if(!eyes_shielded)
		eyes_shielded = !eyes_shielded
		to_chat(owner, SPAN_DANGER("Your reflexes blocks your vision, protecting from bright flashes!"))
		innate_flash_protection = FLASH_PROTECTION_MAJOR
		owner.overlay_fullscreen("eyeshield", /obj/screen/fullscreen/blind)
		owner.update_icons()
		refresh_action_button()
		take_internal_damage(max(0, 1 * (intensity)))
		return -1

/datum/unarmed_attack/nabber
	attack_verb = list("mauled", "slashed", "struck", "pierced")
	attack_noun = list("forelimb")
	damage = 15
	shredding = TRUE
	sharp = TRUE
	edge = TRUE
	delay = 20
	eye_attack_text = "a forelimb"
	eye_attack_text_victim = "a forelimb"
	attack_name = "forelimb slash"


/singleton/species/nabber/disarm_attackhand(mob/living/carbon/human/attacker, mob/living/carbon/human/target)
	if(attacker.pulling_punches || target.lying || attacker == target)
		return ..(attacker, target)
	if(world.time < attacker.last_attack + 20)
		return 0
	attacker.last_attack = world.time
	var/turf/T = get_step(get_turf(target), get_dir(get_turf(attacker), get_turf(target)))
	playsound(target.loc, 'sound/weapons/pushhiss.ogg', 50, 1, -1)
	if(!T.density)
		step(target, get_dir(get_turf(attacker), get_turf(target)))
		target.visible_message(SPAN_CLASS("danger", "[pick("[target] was sent flying backward!", "[target] staggers back from the impact!")]"))
		target.Weaken(3)
	else
		target.turf_collision(T, target.throw_speed / 2)
	if(prob(50))
		target.set_dir(GLOB.reverse_dir[target.dir])

/singleton/species/nabber/arm_swap(mob/living/carbon/human/H, forced) // Мутация дикости оч хорошо подходит под ГБСа. Там уже есть нужные проверки и впринципе удобная фича.
	. = ..()
	if(!H.pulling_punches)
		H.mutations |= MUTATION_FERAL
	else
		H.mutations &= ~MUTATION_FERAL

/singleton/species/nabber/handle_post_spawn(mob/living/carbon/human/H)
	..()
	H.pass_flags |= PASS_FLAG_TABLE
