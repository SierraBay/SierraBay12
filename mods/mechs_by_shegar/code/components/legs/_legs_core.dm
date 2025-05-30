/obj/item/mech_component/propulsion
	name = "powerloader leg"
	pixel_y = 12
	icon_state = "loader_leg"
	var/side = LEFT
	var/move_delay = 5
	var/turn_delay = 5
	//Некоторые ноги выглядят ужасно в раздельном состоянии. Влияет на установку и спавн.
	var/cant_be_differents = FALSE
	var/obj/item/robot_parts/robot_component/actuator/motivator
	power_use = 50
	var/max_fall_damage = 90

	var/mech_turn_sound = 'sound/mecha/mechmove01.ogg'
	var/mech_step_sound = 'sound/mecha/mechstep01.ogg'
	///////////////BUMP///////////////

	///Сила тарана, выступает модификатором урона от тарана
	var/bump_type = BASIC_BUMP
	///Мех может НЕ таранить если захочет?
	var/bump_safety = TRUE
	var/collision_coldown = 7

	///////////////BUMP///////////////


	///////////////STRAFE///////////////

	///Может ли мех ходить при помощи стрейфа. Крайне полезная фича, используйте если знаете что делаете.
	var/can_strafe = FALSE
	///Влияет на эффективность стрейфа, используйте когда мир будет к нему готов.
	var/good_in_strafe = FALSE

	///////////////STRAFE///////////////


	///////////////SPEED///////////////

	///Максимальная возможная скорость движения ног. Указывается в виде КД до следующего шага.
	var/max_speed = 5
	///Текущая скорость движения меха
	var/current_speed
	///Минимальная возможная скорость движения меха
	var/min_speed = 10
	///Номинальное ускорение меха. Итоговое ускорение меха расчитывается в mech.dm на 79 строке.
	var/acceleration = 0.1
	///Как сильно замедляются ноги при диогональном повороте на 45 градусов
	var/turn_diogonal_slowdown = 0.5
	///Как сильно замедляются ноги при обычном повороте на 90 градусов
	var/turn_slowdown = 0.5
	///КД, спустя которое мех полностью теряет ускорение если он не двигался
	var/lost_speed_colldown = 1 SECONDS
	///Используется для спавна в рандомных мехах мехов с сдвоенными ногами (Траки или паучьи.)
	var/should_have_doubled_owner = FALSE
	///Путь до управленца двухконечностей. Используется в премейдах.
	var/doubled_owner_type

	///////////////SPEED///////////////

/obj/item/mech_component/propulsion/Initialize()
	. = ..()
	setup_side()

/obj/item/mech_component/propulsion/proc/setup_side()
	if(side == RIGHT)
		icon_state = "[initial(icon_state)]_right"
		name = "right [initial(name)]"
	else if(side == LEFT)
		icon_state = "[initial(icon_state)]_left"
		name = "left [initial(name)]"

/obj/item/mech_component/propulsion/Destroy()
	QDEL_NULL(motivator)
	. = ..()

/obj/item/mech_component/propulsion/show_missing_parts(mob/user)
	if(!motivator)
		to_chat(user, SPAN_WARNING("It is missing an actuator."))

/obj/item/mech_component/propulsion/ready_to_install()
	return motivator

/obj/item/mech_component/propulsion/update_components()
	motivator = locate() in src
	update_parts_images()
	if(owner)
		owner.calculate_max_speed()
		owner.calculate_acceleration() //Обновился компонент -вероятно нам надавали. Обновимся

/obj/item/mech_component/propulsion/use_tool(obj/item/thing, mob/living/user, list/click_params)
	if(istype(thing,/obj/item/robot_parts/robot_component/actuator))
		if(motivator)
			to_chat(user, SPAN_WARNING("\The [src] already has an actuator installed."))
			return TRUE
		if(install_component(thing, user))
			motivator = thing
			update_parts_images()
			return TRUE
	else
		return ..()

/obj/item/mech_component/propulsion/prebuild()
	motivator = new(src)
	update_parts_images()

//Часть меха рабочая(Актуатор на месте)
/obj/item/mech_component/propulsion/proc/is_active()
	if(!motivator)
		return FALSE
	return TRUE

/obj/item/mech_component/propulsion/proc/can_move_on(turf/location, turf/target_loc)
	if(!location) //Unsure on how that'd even work
		return 0
	if(!istype(location))
		return 1 // Inside something, assume you can get out.
	if(!istype(target_loc))
		return 0 // What are you even doing.
	return 1

/obj/item/mech_component/propulsion/get_damage_string()
	if(!motivator || !motivator.is_functional())
		return SPAN_DANGER("disabled")
	return ..()

/obj/item/mech_component/propulsion/return_diagnostics(mob/user)
	..()
	if(motivator)
		to_chat(user, SPAN_NOTICE(" Actuator Integrity: <b>[round((((motivator.max_dam - motivator.total_dam) / motivator.max_dam)) * 100)]%</b>"))
	else
		to_chat(user, SPAN_WARNING(" Actuator Missing or Non-functional."))

//Expand here if the legs increase, reduce or otherwise affect fall damage for exosuit
/obj/item/mech_component/propulsion/proc/handle_vehicle_fall()
	if(max_fall_damage > 0)
		var/mob/living/exosuit/E = loc
		if(istype(E)) //route it through exosuit for proper handling
			E.apply_damage(rand(0, max_fall_damage), DAMAGE_BRUTE, BP_R_LEG) //Any leg is good, will damage us correctly

/obj/item/mech_component/propulsion/update_parts_images()
	var/list/parts_to_show = list()
	if(motivator)
		parts_to_show += motivator
	internal_parts_list_images = make_item_radial_menu_choices(parts_to_show)
