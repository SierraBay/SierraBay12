/*
	COMBAT_EXTENDED — починка брони хламом.

	Изношенную броню латают тем, что под рукой: жёсткую — листом стали, прутьями или сваркой,
	мягкую — тканью или скотчем. Хлам возвращает HP, но каждая починка навсегда опускает предел,
	до которого броню ещё можно залатать: за каждый возвращённый HP предел теряет `max_loss_mult`
	хлама, умноженный на навык строительства — неумеха теряет больше, мастер меньше. Кривая
	состояния по-прежнему читает HP от исходного максимума, поэтому полного рейтинга залатанная
	броня уже не вернёт — починка возвращает только часть потерянного.

	Чем латать, решает материал брони (`repair_kind` в `armor_materials.dm`), а у брони без своего —
	жёсткость: жёсткую металлом, мягкую тканью. Керамику хламом не латают. Абляционную латают
	отражающими листами — серебром, алюминием, стеклом, сталью, — и лист возвращает ещё и выгоревшее
	покрытие (`laser_heat.dm`). Набор кузнеца (`code/items/tools/blacksmith_kit.dm`) правит любую
	жёсткую броню, керамику в том числе, и предел не опускает, а поднимает.

	Латают вещь, по которой кликнули, надетую или нет. У зональной брони — группу зон прицела, у
	одежды с аксессуарами — аксессуар, закрывающий зону прицела: пластину, наручи или поножи
	плитоноски. У РИГа клик по блоку управления латает деталь в зоне прицела, выпущенную или
	убранную в блок, так что РИГ латают, не надевая (`rig_armor.dm`). Клик разбирают оверрайды
	`use_tool()` одежды и скафандра в `_master_files` и `use_tool()` РИГа в моде hardsuits, а чем
	латать броню, кодекс пишет в самом низу (`ce_get_repair_codex()`).

	Предел, как и HP, у зональной брони свой у каждой группы зон, поэтому потерянное читается и
	пишется только через `ce_get_health_lost()` и `ce_set_health_lost()`.
*/

/// Меньше этого одна починка не возвращает и не поднимает: броня залатана до предела.
#define CE_ARMOR_REPAIR_MIN_HEALTH 1

/datum/extension/armor
	/// HP предела, потерянные на починках. null — броня не латалась.
	var/ce_health_lost
	/// То же у зональной брони, по группам зон: `CE_ARMOR_ZONE_*` -> HP.
	var/list/ce_zone_health_lost


/// Хлам, которым латают броню. Новый хлам — подтип здесь, с причиной у каждого числа.
/singleton/ce_armor_repair
	abstract_type = /singleton/ce_armor_repair
	/// Как хлам называется в кодексе и в подсказке, чем латать броню.
	var/name
	/// Предмет-хлам.
	var/junk_type
	/// Какую броню хлам латает: `CE_ARMOR_REPAIR_METAL`, `CE_ARMOR_REPAIR_FABRIC` или
	/// `CE_ARMOR_REPAIR_ABLATIVE` — броню этого рода, `CE_ARMOR_REPAIR_HARD` — любую жёсткую, какого бы
	/// рода она ни была.
	var/repair_kind
	/// Сколько HP возвращает одна починка — доля максимума HP брони, у зональной — группы зон.
	var/repair_share
	/// Сколько HP предела броня теряет за каждый возвращённый HP при обученном навыке строительства.
	/// При 0.5 броня, изношенная в ноль и залатанная до упора, получает 2/3 прежнего предела, во
	/// второй раз — 4/9.
	var/max_loss_mult = 0.5
	/// На сколько одна починка поднимает предел — доля максимума HP. Выше максимума предел не встанет.
	var/cap_restore_share = 0
	/// Сколько выгоревшего абляционного покрытия возвращает одна починка — доля его запаса. Покрытие
	/// предела не имеет: его хватает, пока есть хлам.
	var/coating_restore_share = 0
	/// Время одной починки. Навык его не сокращает: навык решает, сколько предела съест починка.
	var/repair_time = 3 SECONDS
	var/repair_sound


/// Латает ли хлам эту броню.
/singleton/ce_armor_repair/proc/can_repair(datum/extension/armor/armor)
	if(repair_kind == CE_ARMOR_REPAIR_HARD)
		return armor.is_hard_armor()
	return repair_kind == armor.ce_get_repair_kind()


/// Сколько HP предела съест у этого человека каждый возвращённый HP.
/singleton/ce_armor_repair/proc/get_loss_mult(mob/living/user)
	return max_loss_mult * ce_get_repair_skill_mult(user.get_skill_value(SKILL_CONSTRUCTION))


/// Название с тем, сколько хлама уходит на одну починку, для кодекса.
/singleton/ce_armor_repair/proc/get_codex_name()
	return name


/// Хватит ли хлама на одну починку. Если нет — говорит игроку, чего не хватает.
/singleton/ce_armor_repair/proc/can_use(obj/item/junk, mob/living/user, obj/item/armor_item)
	return TRUE


/// Тратит хлам на одну починку. FALSE — хлама не хватило.
/singleton/ce_armor_repair/proc/use(obj/item/junk, mob/living/user)
	return TRUE


/// Ждёт, пока идёт починка. FALSE — починку прервали.
/singleton/ce_armor_repair/proc/do_repair_delay(mob/living/user, atom/target)
	return do_after(user, repair_time, target, DO_REPAIR_CONSTRUCT)


/// Хлам из стопки: тратит `stack_amount` штук за починку.
/singleton/ce_armor_repair/stack
	abstract_type = /singleton/ce_armor_repair/stack
	var/stack_amount = 1

/singleton/ce_armor_repair/stack/get_codex_name()
	return "[name] ×[stack_amount]"

/singleton/ce_armor_repair/stack/can_use(obj/item/junk, mob/living/user, obj/item/armor_item)
	var/obj/item/stack/stack = junk
	if(stack.can_use(stack_amount))
		return TRUE
	USE_FEEDBACK_STACK_NOT_ENOUGH(stack, stack_amount, "to patch up \the [armor_item].")
	return FALSE

/singleton/ce_armor_repair/stack/use(obj/item/junk, mob/living/user)
	var/obj/item/stack/stack = junk
	return stack.use(stack_amount)


/// Лист стали поверх пробитого места — лучший металлический хлам: лист закрывает дыру целиком.
/singleton/ce_armor_repair/stack/steel
	name = "Steel sheet"
	junk_type = /obj/item/stack/material/steel
	repair_kind = CE_ARMOR_REPAIR_METAL
	repair_share = 0.1
	repair_sound = 'sound/items/Deconstruct.ogg'

/// Прутья стягивают трещины, а не закрывают дыру: пара прутьев возвращает вдвое меньше листа.
/singleton/ce_armor_repair/stack/rods
	name = "Steel rods"
	junk_type = /obj/item/stack/material/rods
	repair_kind = CE_ARMOR_REPAIR_METAL
	stack_amount = 2
	repair_share = 0.05
	repair_sound = 'sound/items/Deconstruct.ogg'

/// Ткань — заплата на мягкую броню, кевларовые вставки в том числе, как лист стали на жёсткую.
/singleton/ce_armor_repair/stack/cloth
	name = "Cloth"
	junk_type = /obj/item/stack/material/cloth
	repair_kind = CE_ARMOR_REPAIR_FABRIC
	repair_share = 0.1
	repair_sound = 'sound/effects/rustle1.ogg'


/// Абляционная броня: покрытие латают отражающим листом, и чем лучше лист отражает луч, тем больше
/// покрытия он возвращает. Лучший — серебро, худший — сталь: она латает подложку, а не покрытие.
/singleton/ce_armor_repair/stack/ablative
	abstract_type = /singleton/ce_armor_repair/stack/ablative
	repair_kind = CE_ARMOR_REPAIR_ABLATIVE
	repair_sound = 'sound/items/Deconstruct.ogg'

/// Серебро — зеркальный металл: лист возвращает четверть покрытия и HP, как лист стали — стальной броне.
/singleton/ce_armor_repair/stack/ablative/silver
	name = "Silver sheet"
	junk_type = /obj/item/stack/material/silver
	repair_share = 0.1
	coating_restore_share = 0.25

/// Алюминий отражает хуже серебра, но и достать его проще.
/singleton/ce_armor_repair/stack/ablative/aluminium
	name = "Aluminium sheet"
	junk_type = /obj/item/stack/material/aluminium
	repair_share = 0.1
	coating_restore_share = 0.2

/// Стекло — основа отражающего слоя, но само держит мало: HP возвращает вдвое меньше металла.
/singleton/ce_armor_repair/stack/ablative/glass
	name = "Glass sheet"
	junk_type = /obj/item/stack/material/glass
	repair_share = 0.05
	coating_restore_share = 0.15
	repair_sound = 'sound/effects/glass_step.ogg'

/// Сталь латает подложку абляционной брони, а покрытия возвращает меньше всех.
/singleton/ce_armor_repair/stack/ablative/steel
	name = "Steel sheet"
	junk_type = /obj/item/stack/material/steel
	repair_share = 0.05
	coating_restore_share = 0.1


/// Сварка заваривает трещины без нового металла: возвращает мало, зато тратит только топливо.
/singleton/ce_armor_repair/welder
	name = "Welding tool"
	junk_type = /obj/item/weldingtool
	repair_kind = CE_ARMOR_REPAIR_METAL
	repair_share = 0.05
	repair_sound = 'sound/items/Welder.ogg'
	/// Топливо на одну починку — как на заварку пробоины скафандра.
	var/fuel_amount = 5

/singleton/ce_armor_repair/welder/get_codex_name()
	return "[name], [fuel_amount] fuel"

/singleton/ce_armor_repair/welder/can_use(obj/item/junk, mob/living/user, obj/item/armor_item)
	var/obj/item/weldingtool/welder = junk
	return welder.can_use(fuel_amount, user, "to patch up \the [armor_item].")

/singleton/ce_armor_repair/welder/use(obj/item/junk, mob/living/user)
	var/obj/item/weldingtool/welder = junk
	return welder.remove_fuel(fuel_amount, user)


/// Скотч не кончается, поэтому и стоит дороже всего: каждый HP скотча съедает HP предела. Из нуля
/// скотч поднимает броню лишь до половины прежнего предела.
/singleton/ce_armor_repair/tape
	name = "Duct tape"
	junk_type = /obj/item/tape_roll
	repair_kind = CE_ARMOR_REPAIR_FABRIC
	repair_share = 0.05
	max_loss_mult = 1
	repair_sound = 'sound/effects/tape.ogg'


/// Набор кузнеца правит любую жёсткую броню, керамику в том числе, и предел не опускает, а
/// поднимает: сперва предел, потом HP до нового предела. Навык ему не важен — съедать нечего.
/singleton/ce_armor_repair/blacksmith_kit
	name = "Blacksmith kit"
	junk_type = /obj/item/ce_blacksmith_kit
	repair_kind = CE_ARMOR_REPAIR_HARD
	repair_share = 0.2
	max_loss_mult = 0
	cap_restore_share = 0.05
	repair_time = 5 SECONDS
	repair_sound = 'sound/items/Ratchet.ogg'

/singleton/ce_armor_repair/blacksmith_kit/can_use(obj/item/junk, mob/living/user, obj/item/armor_item)
	var/obj/item/ce_blacksmith_kit/kit = junk
	if(kit.uses > 0)
		return TRUE
	USE_FEEDBACK_FAILURE("\The [kit] is used up.")
	return FALSE

/singleton/ce_armor_repair/blacksmith_kit/use(obj/item/junk, mob/living/user)
	var/obj/item/ce_blacksmith_kit/kit = junk
	kit.uses--
	if(kit.uses <= 0)
		qdel(kit)
	return TRUE


/**
 * Хлам, которым `tool` латает броню `armor`. Один предмет бывает хламом разного рода — лист стали
 * латает и стальную броню, и абляционную, — поэтому сперва ищется хлам, который эту броню латает.
 * Без брони или если такого нет — любой хлам этого предмета. null — `tool` броню не латает.
 */
/proc/ce_get_armor_repair_junk(obj/item/tool, datum/extension/armor/armor)
	. = null
	for(var/singleton/ce_armor_repair/junk as anything in GET_SINGLETON_SUBTYPE_LIST(/singleton/ce_armor_repair))
		if(!istype(tool, junk.junk_type))
			continue
		if(!armor || junk.can_repair(armor))
			return junk
		if(!.)
			. = junk


/// Множитель потери предела по уровню навыка строительства: у обученного — 1, каждый уровень ниже
/// прибавляет `ce_armor_repair_loss_per_skill`, каждый выше — убавляет.
/proc/ce_get_repair_skill_mult(skill_level)
	return max(0, 1 + (SKILL_BASELINE - skill_level) * ce_armor_repair_loss_per_skill)


/// Доля максимума со знаком, для кодекса: 0.1 — «+10%», -0.025 — «-2.5%».
/proc/ce_format_repair_share(share)
	var/percent = round(share * 100, 0.1)
	return percent >= 0 ? "+[percent]%" : "[percent]%"


/// Группа зон по зоне прицела. Кисти идут с руками, стопы — с ногами, глаза и рот — с головой, как в
/// `ce_armor_zone_groups`. Без прицела — торс.
/proc/ce_get_target_zone_group(zone)
	switch(zone)
		if(BP_L_ARM, BP_R_ARM, BP_L_HAND, BP_R_HAND)
			return CE_ARMOR_ZONE_ARMS
		if(BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT)
			return CE_ARMOR_ZONE_LEGS
		if(BP_HEAD, BP_EYES, BP_MOUTH)
			return CE_ARMOR_ZONE_HEAD
	return CE_ARMOR_ZONE_TORSO


/// HP предела группы зон, потерянные на починках. 0 — группа не латалась.
/datum/extension/armor/proc/ce_get_health_lost(group)
	var/lost = group ? LAZYACCESS(ce_zone_health_lost, group) : ce_health_lost
	return lost || 0


/datum/extension/armor/proc/ce_set_health_lost(group, lost)
	if(!group)
		ce_health_lost = lost
		return
	LAZYSET(ce_zone_health_lost, group, lost)


/// Предел HP группы зон: выше него броню уже не залатать.
/datum/extension/armor/proc/ce_get_health_cap(group)
	return ce_get_health_max(group) - ce_get_health_lost(group)


/// Предел HP группы зон в процентах максимума, для осмотра. 100 — группа не латалась.
/datum/extension/armor/proc/ce_get_health_cap_percent(group)
	var/lost = ce_get_health_lost(group)
	if(!lost)
		return 100
	return round(100 * (1 - lost / ce_get_health_max(group)))


/// Чем латают эту броню: `CE_ARMOR_REPAIR_*`.
/datum/extension/armor/proc/ce_get_repair_kind()
	var/singleton/ce_armor_material/material = ce_get_material()
	if(material.repair_kind)
		return material.repair_kind
	return is_hard_armor() ? CE_ARMOR_REPAIR_METAL : CE_ARMOR_REPAIR_FABRIC


/// Названия хлама, которым эту броню латают, для подсказки игроку.
/datum/extension/armor/proc/ce_get_repair_junk_names()
	RETURN_TYPE(/list)
	. = list()
	for(var/singleton/ce_armor_repair/junk as anything in GET_SINGLETON_SUBTYPE_LIST(/singleton/ce_armor_repair))
		if(junk.can_repair(src))
			. += lowertext(junk.name)


/**
 * Итог одной починки группы зон этим хламом: `list(вернёт HP, потеряно HP предела после неё,
 * вернёт покрытия)`. Сперва хлам поднимает предел на `cap_restore_share` максимума, не выше самого
 * максимума. Потом возвращает HP, и предел опускается на `loss_mult` за каждый, так что до предела
 * броня доходит, когда `HP + вернули = предел - вернули × loss_mult`. Выгоревшее абляционное
 * покрытие хлам возвращает на `coating_restore_share` запаса, предела у покрытия нет. null — группа
 * не изнашивалась и покрытие не выгорало. `loss_mult` — у человека с его навыком, без него — у
 * обученного.
 */
/datum/extension/armor/proc/ce_get_repair_result(singleton/ce_armor_repair/junk, group, loss_mult)
	var/coating = min(ce_get_coating_spent(group), junk.coating_restore_share * ce_get_coating_max(group))
	var/health = ce_get_health(group)
	if(isnull(health))
		return coating > 0 ? list(0, ce_get_health_lost(group), coating) : null
	if(isnull(loss_mult))
		loss_mult = junk.max_loss_mult
	var/health_max = ce_get_health_max(group)
	var/lost = max(0, ce_get_health_lost(group) - junk.cap_restore_share * health_max)
	var/room = health_max - lost - health
	var/restored = clamp(room / (1 + loss_mult), 0, junk.repair_share * health_max)
	return list(restored, lost + restored * loss_mult, coating)


/// Даст ли починка с этим итогом хоть что-то: вернёт HP или покрытие либо поднимет предел.
/datum/extension/armor/proc/ce_is_repair_useful(list/result, group)
	if(!result)
		return FALSE
	return result[1] >= CE_ARMOR_REPAIR_MIN_HEALTH || ce_get_health_lost(group) - result[2] >= CE_ARMOR_REPAIR_MIN_HEALTH || result[3] >= CE_ARMOR_REPAIR_MIN_HEALTH


/// Латает группу зон этим хламом, не тратя его. Возвращает вернувшиеся HP.
/datum/extension/armor/proc/ce_apply_repair(singleton/ce_armor_repair/junk, group, loss_mult)
	var/list/result = ce_get_repair_result(junk, group, loss_mult)
	if(!result)
		return 0
	if(!isnull(ce_get_health(group)))
		ce_set_health(group, ce_get_health(group) + result[1])
		ce_set_health_lost(group, result[2])
	ce_restore_coating(group, result[3])
	return result[1]


/// Можно ли залатать группу зон этим хламом. Если нет — говорит игроку почему.
/datum/extension/armor/proc/ce_check_repair(singleton/ce_armor_repair/junk, group, loss_mult, obj/item/tool, mob/living/user)
	var/obj/item/armor_item = holder
	if(!junk.can_repair(src))
		var/list/names = ce_get_repair_junk_names()
		if(length(names))
			USE_FEEDBACK_FAILURE("\The [tool] won't patch up \the [armor_item]. It can be fixed with: [jointext(names, ", ")].")
		else
			USE_FEEDBACK_FAILURE("\The [armor_item] can't be patched up, only replaced.")
		return FALSE
	if(!ce_is_repair_useful(ce_get_repair_result(junk, group, loss_mult), group))
		USE_FEEDBACK_FAILURE("\The [armor_item] can't be patched up any further.")
		return FALSE
	return TRUE


/// Тратит хлам и латает группу зон. Проверки — в `ce_check_repair()` и в `can_use()` хлама.
/datum/extension/armor/proc/ce_finish_repair(singleton/ce_armor_repair/junk, group, loss_mult, obj/item/tool, mob/living/user)
	var/obj/item/armor_item = holder
	var/armor_label = group ? "[armor_item.name] ([group])" : armor_item.name
	// Сообщения — до траты: стопка и набор, потраченные целиком, удаляются.
	var/self_message = SPAN_NOTICE("You patch up the [armor_label] with \the [tool].")
	var/others_message = SPAN_NOTICE("\The [user] patches up the [armor_label] with \the [tool].")
	if(!junk.use(tool, user))
		return
	ce_apply_repair(junk, group, loss_mult)
	playsound(armor_item, junk.repair_sound, 50, TRUE)
	user.visible_message(others_message, self_message)


/// Название материала брони для кодекса. У материала по умолчанию своего нет — только жёсткость.
/datum/extension/armor/proc/ce_get_material_name()
	var/singleton/ce_armor_material/material = ce_get_material()
	if(material.name)
		return material.name
	return is_hard_armor() ? "generic hard armor" : "generic soft armor"


/**
 * Блок кодекса о починке: материал брони и чем её латают, с числами одной починки при обученном
 * навыке — сколько HP она вернёт и насколько сдвинет предел, в долях максимума. Хлам — по
 * алфавиту: порядок `subtypesof()` ничем не обещан. null — броня не изнашивается или починка
 * выключена.
 */
/datum/extension/armor/proc/ce_get_repair_codex_block(label)
	if(!ce_armor_repair_enabled || !ce_armor_wear_enabled || !ce_can_wear())
		return null
	var/list/lines = list(
		"<b>[label ? "Repair ([label])" : "Repair"]:</b>",
		"Material: [ce_get_material_name()]"
	)
	var/list/junk_lines = list()
	var/skill_matters = FALSE
	for(var/singleton/ce_armor_repair/junk as anything in GET_SINGLETON_SUBTYPE_LIST(/singleton/ce_armor_repair))
		if(!junk.can_repair(src))
			continue
		var/cap_change = junk.cap_restore_share - junk.repair_share * junk.max_loss_mult
		var/coating_text = junk.coating_restore_share > 0 && ce_get_coating_max() > 0 ? ", [ce_format_repair_share(junk.coating_restore_share)] coating" : ""
		junk_lines += "[junk.get_codex_name()] ([ce_format_repair_share(junk.repair_share)], [ce_format_repair_share(cap_change)] max[coating_text])"
		if(junk.max_loss_mult > 0)
			skill_matters = TRUE
	if(!length(junk_lines))
		lines += "Can't be fixed, only replaced."
		return jointext(lines, "<br>")
	lines += "Can be fixed with:"
	lines += sortTim(junk_lines, GLOBAL_PROC_REF(cmp_text_asc))
	if(skill_matters)
		lines += "Construction skill scales the max loss: ×[ce_get_repair_skill_mult(SKILL_MIN)] unskilled to ×[ce_get_repair_skill_mult(SKILL_MAX)] master."
	return jointext(lines, "<br>")


/**
 * Броня, которую латает клик по вещи с прицелом в группу зон `zone_group`: зональная броня самой
 * вещи; иначе её броня или видимый аксессуар, закрывающие эту группу; иначе броня самой вещи.
 * Скрытый аксессуар не латается: его состояния не видно и при осмотре. null — брони нет.
 */
/obj/item/clothing/proc/ce_get_repair_armor(zone_group)
	RETURN_TYPE(/datum/extension/armor)
	var/datum/extension/armor/own_armor = get_extension(src, /datum/extension/armor)
	if(own_armor?.ce_is_zoned())
		return own_armor
	var/zone_parts = ce_armor_zone_groups[zone_group]
	if(own_armor && (body_parts_covered & zone_parts))
		return own_armor
	for(var/obj/item/clothing/accessory/accessory in accessories)
		if(accessory.accessory_flags & ACCESSORY_HIDDEN)
			continue
		var/datum/extension/armor/accessory_armor = get_extension(accessory, /datum/extension/armor)
		if(accessory_armor && (accessory.body_parts_covered & zone_parts))
			return accessory_armor
	return own_armor


/// Блоки кодекса о починке брони самой вещи и её видимых аксессуаров — для самого низа кодекса.
/// Аксессуар под верхней одеждой не виден и здесь: кодекс чужой униформы открывает кто угодно
/// (`concealed_accessories.dm`).
/obj/item/clothing/proc/ce_get_repair_codex()
	var/datum/extension/armor/own_armor = get_extension(src, /datum/extension/armor)
	. = own_armor?.ce_get_repair_codex_block()
	for(var/obj/item/clothing/accessory/accessory in ce_get_accessories_seen_by())
		if(accessory.accessory_flags & ACCESSORY_HIDDEN)
			continue
		var/datum/extension/armor/accessory_armor = get_extension(accessory, /datum/extension/armor)
		. = ce_codex_join(., accessory_armor?.ce_get_repair_codex_block(capitalize(accessory.name)))


/**
 * Латает броню вещи хламом `tool`. TRUE — клик разобран: броня залатана, или игрок узнал, почему нет.
 * FALSE — `tool` не хлам, у вещи нет изношенной брони или выгоревшего покрытия в зоне прицела или
 * починка выключена: клик идёт дальше, например в подсумки плитоноски.
 */
/obj/item/clothing/proc/ce_try_armor_repair(obj/item/tool, mob/living/user)
	if(!ce_armor_repair_enabled || !ce_armor_wear_enabled)
		return FALSE
	if(!ce_get_armor_repair_junk(tool))
		return FALSE
	var/zone_group = ce_get_target_zone_group(user.zone_sel?.selecting)
	var/datum/extension/armor/armor = ce_get_repair_armor(zone_group)
	if(!armor?.ce_can_wear())
		return FALSE
	var/group = armor.ce_is_zoned() ? zone_group : null
	if(isnull(armor.ce_get_health(group)) && armor.ce_get_coating_spent(group) <= 0)
		return FALSE

	var/singleton/ce_armor_repair/junk = ce_get_armor_repair_junk(tool, armor)
	var/obj/item/armor_item = armor.holder
	var/loss_mult = junk.get_loss_mult(user)
	if(!armor.ce_check_repair(junk, group, loss_mult, tool, user) || !junk.can_use(tool, user, armor_item))
		return TRUE
	if(!junk.do_repair_delay(user, ismob(loc) ? loc : ce_get_do_after_target()))
		return TRUE
	// За время починки броню могли износить или залатать, а хлам — потратить.
	if(!armor.ce_check_repair(junk, group, loss_mult, tool, user) || !junk.can_use(tool, user, armor_item))
		return TRUE
	armor.ce_finish_repair(junk, group, loss_mult, tool, user)
	return TRUE


/// Есть ли у скафандра пробоины. Пока есть, сталь, сварка и скотч идут на них, а не на броню.
/obj/item/clothing/suit/space/proc/ce_has_breaches()
	return can_breach && length(breaches)


#undef CE_ARMOR_REPAIR_MIN_HEALTH
