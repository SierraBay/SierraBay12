/obj/item/crafting_holder/Initialize(ml, singleton/crafting_stage/initial_stage, obj/item/target, obj/item/tool, mob/user)
	. = ..()
	name = "каркас [target.name]"

/obj/item/material/small_blade
	name = "лезвие ножа"
	desc = "Лезвие ножа. Непригоден для использования в качестве оружия без рукояти."

/obj/item/material/large_blade
	name = "большой клинок"
	desc = "Большой, тяжелый клинок. Непригоден для использования в качестве оружия без рукояти."

/obj/item/material/butterflyhandle
	name = "скрытая рукоять ножа"
	desc = "Пластелиновая рукоять с винтовым креплением для клинка."

/obj/item/cannonframe
	name = "рама пневматической пушки"
	desc = "Полуфабрикат пневматической пушки."

/obj/item/weapon_frame
	name = "рама для оружия"
	desc = "Возможно, когда-нибудь это будет оружием."

/obj/item/rail_assembly
	name = "рельсовая сборка"
	desc = "Два параллельных стержня, плотно прилегающих друг к другу в виде рельса."

/obj/item/makeshift_barrel
	name = "самодельный ствол для оружия"
	desc = "Полый ствол, сделанный из двух банок, плотно сваренных между собой. Это никак не может быть безопасным."

/obj/item/farmbot_arm_assembly
	name = "Бак для воды/рука робота в сборе"
	desc = "Бак для воды с постоянно прикрепленной к нему рукой робота."
