/obj/item/organ/internal/augment/active/polytool/surgical
	name = "surgical toolset"
	action_button_name = "Deploy Surgical Tool"
	desc = "Part of Zeng-Hu Pharmaceutical's line of biomedical augmentations, this device contains the full set of tools any surgeon would ever need."
	icon_state = "multitool_medical"
	paths = list(
		/obj/item/bonesetter/finger,
		/obj/item/cautery/finger,
		/obj/item/circular_saw/finger,
		/obj/item/hemostat/finger,
		/obj/item/retractor/finger,
		/obj/item/scalpel/finger,
		/obj/item/surgicaldrill/finger
	)
// Если вы вдруг захотите сделать инструменты в этом наборе особенными - воспользуйтесь тем что ниже. Эти обьекты были созданы
//лишь для прописания item_state, дабы show_radial_menu работало адекватно
/obj/item/bonesetter/finger
	item_state = "bone setter"
/obj/item/cautery/finger
	item_state = "cautery"
/obj/item/circular_saw/finger
	item_state = "saw"
/obj/item/hemostat/finger
	item_state = "hemostat"
/obj/item/retractor/finger
	item_state = "retractor"
/obj/item/scalpel/finger
	item_state = "scalpel"
/obj/item/surgicaldrill/finger
	item_state = "drill"
