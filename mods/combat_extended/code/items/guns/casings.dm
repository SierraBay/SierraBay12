/*
	COMBAT_EXTENDED: спрайты гильз (`code/ammo_sprites.dm`), типы из
	`code/modules/projectiles/ammunition/bullets.dm`, затем `mods/guns/code/modded.dm`,
	`mods/guns/code/ammo.dm`, `mods/psionics/code/equipment/null_ammo.dm` и
	`mods/utility_items/code/sniper_smoke.dm`. Как устроена папка `code/items/`: README, раздел
	"Числа предметов".

	Гильза калибра задаёт `icon`, `icon_state`, `spent_icon`, `ce_sprite_caliber`, цвет FMJ и коробку.
	Подтип без своего спрайта (`ce_tinted_tip`) лежит на спрайте FMJ своего калибра с кончиком в свой
	цвет, и своей коробки у него нет: `ce_box_sprite` сброшен. Кор задаёт таким подтипам свои
	`icon_state` из кор файла, поэтому FMJ им прописан заново. Цвета, которые ещё не выбраны:
	`CE_AMMO_COLOR_UNCHOSEN`.

	Патроны 12g остаются на кор спрайтах. Здесь у них только коробка. У типа без своей коробки она
	общая, `12g_base`, со слоем патронов `12g_shells` в цвет типа. Сборный патрон из `shell-base`,
	`shell-hull` и `shell-band` (`ce_tinted_tip` у гильзы 12g) пока не нужен ни одному типу.

	9x19 AP (`/obj/item/ammo_casing/pistol/small/ap`) задан в самом `mods/guns/code/modded.dm`:
	модпак подключается позже мода, и его `icon_state` перекрыл бы значение отсюда.
*/

/obj/item/ammo_casing/pistol
	// 10mm Auto.
	icon = CE_AMMO_ICON
	icon_state = "10mm_fmj"
	spent_icon = "10mm-spent"
	ce_sprite_caliber = "10mm"
	ce_ammo_color = CE_AMMO_COLOR_FMJ
	ce_box_sprite = "10mm_fmj"

/obj/item/ammo_casing/pistol/rubber
	icon_state = "10mm_fmj"
	ce_tinted_tip = TRUE
	ce_ammo_color = CE_AMMO_COLOR_RUBBER
	ce_box_sprite = null

/obj/item/ammo_casing/pistol/practice
	icon_state = "10mm_fmj"
	ce_tinted_tip = TRUE
	ce_ammo_color = CE_AMMO_COLOR_PRACTICE
	ce_box_sprite = null

/obj/item/ammo_casing/pistol/small
	// 9x19.
	icon_state = "7mm_fmj"
	spent_icon = "7mm-spent"
	ce_sprite_caliber = "7mm"
	ce_box_sprite = "7mm_fmj"

/obj/item/ammo_casing/pistol/small/rubber
	icon_state = "7mm_fmj"
	ce_tinted_tip = TRUE
	ce_ammo_color = CE_AMMO_COLOR_RUBBER
	ce_box_sprite = null

/obj/item/ammo_casing/pistol/small/practice
	icon_state = "7mm_fmj"
	ce_tinted_tip = TRUE
	ce_ammo_color = CE_AMMO_COLOR_PRACTICE
	ce_box_sprite = null

/obj/item/ammo_casing/pistol/magnum
	// .44 Magnum.
	icon_state = "15mmP_fmj"
	spent_icon = "15mmP-spent"
	ce_sprite_caliber = "15mmP"
	ce_box_sprite = "15mmP_fmj"

// Старинный ~10mm (`pistol/throwback`) только FMJ: спрайт и коробка 10mm Auto, своего блока нет.

/obj/item/ammo_casing/gyrojet
	// Своей гильзы у гироджета нет: живая гильза 14.5 с кончиком. Стреляной не бывает, пистолет
	// удаляет гильзы при выстреле.
	icon = CE_AMMO_ICON
	icon_state = "14mmR_fmj"
	spent_icon = "14mmR-spent"
	ce_sprite_caliber = "14mmR"
	ce_tinted_tip = TRUE
	ce_ammo_color = CE_AMMO_COLOR_UNCHOSEN

/obj/item/ammo_casing/flechette
	// 4mm.
	icon = CE_AMMO_ICON
	icon_state = "4mm_fmj"
	spent_icon = "4mm-spent"
	ce_sprite_caliber = "4mm"
	ce_ammo_color = CE_AMMO_COLOR_FMJ
	ce_box_sprite = "4mm_fmj"

/obj/item/ammo_casing/shotgun
	// Слаг. Подтипы без своей коробки задают общую ниже.
	ce_box_sprite = "12g_slug"

/obj/item/ammo_casing/shotgun/pellet
	ce_box_sprite = "12g_buckshot"

/obj/item/ammo_casing/shotgun/flechette
	// Цвет держателя флешетт.
	ce_ammo_color = COLOR_BLUE
	ce_box_sprite = "12g_base"
	ce_box_tint_sprite = "12g_shells"

/obj/item/ammo_casing/shotgun/blank
	ce_ammo_color = CE_AMMO_COLOR_UNCHOSEN
	ce_box_sprite = "12g_base"
	ce_box_tint_sprite = "12g_shells"

/obj/item/ammo_casing/shotgun/practice
	ce_ammo_color = CE_AMMO_COLOR_PRACTICE
	ce_box_sprite = "12g_base"
	ce_box_tint_sprite = "12g_shells"

/obj/item/ammo_casing/shotgun/beanbag
	ce_box_sprite = "12g_rubber"

/obj/item/ammo_casing/shotgun/stunshell
	ce_box_sprite = "12g_stun"

/obj/item/ammo_casing/shotgun/flash
	// Цвет держателя сигнальных.
	ce_ammo_color = COLOR_PALE_YELLOW
	ce_box_sprite = "12g_base"
	ce_box_tint_sprite = "12g_shells"

/obj/item/ammo_casing/rifle
	// 5.56x45.
	icon = CE_AMMO_ICON
	icon_state = "5mmR_fmj"
	spent_icon = "5mmR-spent"
	ce_sprite_caliber = "5mmR"
	ce_ammo_color = CE_AMMO_COLOR_FMJ
	ce_box_sprite = "5mmR_fmj"

/obj/item/ammo_casing/rifle/practice
	icon_state = "5mmR_fmj"
	ce_tinted_tip = TRUE
	ce_ammo_color = CE_AMMO_COLOR_PRACTICE
	ce_box_sprite = null

/obj/item/ammo_casing/shell
	// 14.5x114. Особый снаряд, FMJ у калибра нет: обычный на спрайте FMJ, APDS на спрайте AP. Ящик
	// один на оба, без типа.
	icon = CE_AMMO_ICON
	icon_state = "14mmR_fmj"
	spent_icon = "14mmR-spent"
	ce_sprite_caliber = "14mmR"
	ce_ammo_color = CE_AMMO_COLOR_FMJ
	ce_box_sprite = "14mmR"

/obj/item/ammo_casing/shell/apds
	icon_state = "14mmR_ap"
	ce_ammo_color = CE_AMMO_COLOR_AP

/obj/item/ammo_casing/rifle/military
	// 7.62x39, штатный. Ослабленный (`/light`) тот же FMJ: свой тип у него только в числах.
	icon_state = "7mmR_fmj"
	spent_icon = "7mmR-spent"
	ce_sprite_caliber = "7mmR"
	ce_box_sprite = "7mmR_fmj"

/obj/item/ammo_casing/rifle/military/practice
	icon_state = "7mmR_fmj"
	ce_tinted_tip = TRUE
	ce_ammo_color = CE_AMMO_COLOR_PRACTICE
	ce_box_sprite = null

/obj/item/ammo_casing/pistol/emp
	icon_state = "10mm_fmj"
	ce_tinted_tip = TRUE
	ce_ammo_color = CE_AMMO_COLOR_EMP
	ce_box_sprite = null

/obj/item/ammo_casing/pistol/small/emp
	icon_state = "7mm_fmj"
	ce_tinted_tip = TRUE
	ce_ammo_color = CE_AMMO_COLOR_EMP
	ce_box_sprite = null

/obj/item/ammo_casing/shotgun/emp
	ce_ammo_color = CE_AMMO_COLOR_EMP
	ce_box_sprite = "12g_base"
	ce_box_tint_sprite = "12g_shells"

/obj/item/ammo_casing/nt28mm
	// 5.7x28.
	icon = CE_AMMO_ICON
	icon_state = "5.7mmP_fmj"
	spent_icon = "5.7mmP-spent"
	ce_sprite_caliber = "5.7mmP"
	ce_ammo_color = CE_AMMO_COLOR_FMJ
	ce_box_sprite = "5.7mmP_fmj"

/obj/item/ammo_casing/pistol/nullglass
	// Нульглас 10mm Auto.
	ce_tinted_tip = TRUE
	ce_ammo_color = CE_AMMO_COLOR_UNCHOSEN
	ce_box_sprite = null

/obj/item/ammo_casing/shotgun/manstopper
	ce_box_sprite = "12g_manstopper"

/obj/item/ammo_casing/shotgun/dragon
	// Цвет держателя Dragon breath.
	ce_ammo_color = COLOR_ORANGE
	ce_box_sprite = "12g_base"
	ce_box_tint_sprite = "12g_shells"

/obj/item/ammo_casing/pistol/magnum/nullglass
	// Нульглас .44 Magnum.
	ce_tinted_tip = TRUE
	ce_ammo_color = CE_AMMO_COLOR_UNCHOSEN
	ce_box_sprite = null

/obj/item/ammo_casing/shell/smoke_tracer
	// Трассер 14.5 лежит в том же ящике.
	ce_tinted_tip = TRUE
	ce_ammo_color = CE_AMMO_COLOR_UNCHOSEN
