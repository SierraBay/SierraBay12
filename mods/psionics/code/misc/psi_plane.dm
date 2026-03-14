/*
# =============================================================================
# Эффект затухания для объектов пси-плана (glow для клиента)
# =============================================================================
*/
/atom/proc/glow_for_client(client/C, duration = 80)
	if(!C) return
	var/image/I = image(icon, loc, icon_state)
	I.alpha = 0
	I.layer = layer + 1
	I.color = "#c8d5e2" // серый оттенок, можно заменить на другой
	C.images += I
	animate(I, alpha = 200, time = duration/2)
	animate(I, alpha = 0, time = duration/2)
	spawn(duration)
		C.images -= I
// =============================================================================
// Psionic Plane
//
// Объекты и мобы на псионическом плане невидимы для не-псиоников.
// Только активные (не-подавленные) псионики могут их видеть и с ними взаимодействовать.
//
// Использование:
//   Унаследуйте от /obj/psi_plane или /mob/living/psi_plane.
//   Или вручную выставьте invisibility = INVISIBILITY_PSI_PLANE на любом атоме
//   и добавьте проверку can_perceive_psi_plane() в нужных proc'ах взаимодействия.
// =============================================================================

// Уровень невидимости: между INVISIBILITY_LEVEL_TWO (45) и INVISIBILITY_OVERMAP (50).
// Не-псионики (see_invisible = SEE_INVISIBLE_LIVING = 25) не видят эти объекты.
// Псионики получают see_invisible = SEE_INVISIBLE_PSI_PLANE через update_living_sight().
#define INVISIBILITY_PSI_PLANE  47
#define SEE_INVISIBLE_PSI_PLANE INVISIBILITY_PSI_PLANE

/**
 * Возвращает TRUE, если mob способен воспринимать псионический план.
 * Требует активный (не-подавленный) psi complexus.
 */
/atom/proc/can_perceive_psi_plane(mob/user)
	if(!user || !isliving(user))
		return FALSE
	var/mob/living/L = user
	return (L.psi && !L.psi.suppressed)

// =============================================================================
// Базовый тип для объектов псионического плана
// =============================================================================

/**
 * Базовый тип для /obj на псионическом плане.
 * Невидим и некликабелен для не-псиоников.
 * Блокирует взаимодействие через can_touch(), attack_hand(), attackby().
 */
/obj/psi_plane
	invisibility = INVISIBILITY_PSI_PLANE

// Не-псионики проходят сквозь плотные объекты псионического плана.
/obj/psi_plane/CanPass(atom/movable/mover, turf/target, height=1.5, air_group=0)
	if(!air_group && height > 0 && density && isliving(mover))
		var/mob/living/L = mover
		if(!L.psi || L.psi.suppressed)
			return TRUE
	return ..()  // стандартный density-чек

/obj/psi_plane/can_touch(mob/user, check_silicon = TRUE)
	if(!can_perceive_psi_plane(user))
		return FALSE
	return ..()

/obj/psi_plane/attack_hand(mob/user)
	if(!can_perceive_psi_plane(user))
		return
	return ..()
/*
/obj/psi_plane/attackby(obj/item/item, mob/user, params)
	if(!can_perceive_psi_plane(user))
		return
	return ..()
*/

/obj/psi_plane/monolith
	name = "ПСИ КАМЕНЬ"
	icon = 'icons/obj/structures/monolith.dmi'
	desc = "An obviously artifical structure of unknown origin. The symbols '𒁀𒀝 𒋢𒌦 𒉡 𒋺𒂊' are engraved on the base." //for the sake of the reader, "BAKU SUUN NU TAKE"
	icon_state = "jaggy1"
	anchored = TRUE
	density = TRUE
// =============================================================================
// Базовый тип для мобов псионического плана
// =============================================================================

/**
 * Базовый тип для /mob/living на псионическом плане.
 * Невидим и некликабелен для не-псиоников.
 */
/mob/living/psi_plane
	invisibility = INVISIBILITY_PSI_PLANE

// Не-псионики проходят сквозь мобов псионического плана.
/mob/living/psi_plane/CanPass(atom/movable/mover, turf/target, height=1.5, air_group=0)
	if(!air_group && height > 0 && isliving(mover))
		var/mob/living/L = mover
		if(!L.psi || L.psi.suppressed)
			return TRUE
	return ..()  // стандартный density-чек

/mob/living/psi_plane/attack_hand(mob/user)
	if(!can_perceive_psi_plane(user))
		return
	return ..()
/*
/mob/living/psi_plane/attackby(obj/item/item, mob/user, params)
	if(!can_perceive_psi_plane(user))
		return
	return ..()
*/
