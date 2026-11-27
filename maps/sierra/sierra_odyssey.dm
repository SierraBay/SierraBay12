/// Sierra-only types for the Odyssey unique-item and head-locker rules.
/// Registered here so the mod does not name map types that other compiles lack.

/hook/startup/proc/sierra_register_odyssey_types()
	odyssey_register_unique_item_type(/obj/item/folder/envelope/preset/nuke)
	odyssey_register_unique_item_type(/obj/item/device/remote_device)
	odyssey_register_head_closet_type(/obj/structure/closet/secure_closet/captains/sierra)
	odyssey_register_head_closet_type(/obj/structure/closet/secure_closet/hop/sierra)
	odyssey_register_head_closet_type(/obj/structure/closet/secure_closet/hos/sierra)
	odyssey_register_head_closet_type(/obj/structure/closet/secure_closet/CMO_sierra)
	odyssey_register_head_closet_type(/obj/structure/closet/secure_closet/RD_sierra)
	odyssey_register_head_closet_type(/obj/structure/closet/secure_closet/engineering_chief_sierra)
	odyssey_register_head_closet_type(/obj/structure/closet/secure_closet/quartermaster_sierra)
	return TRUE
