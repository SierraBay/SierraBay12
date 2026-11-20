/// Extra item fields shared by the world lane and the doll lane.
/// Guns, cells, magazines and modular-computer disks. Name, color and desc when they differ from the type.


/proc/odyssey_charge_num(value, max_charge)
	if (!isnum(value))
		value = text2num(value)
	if (!isnum(value))
		return 0
	if (isnum(max_charge) && max_charge > 0)
		return clamp(value, 0, max_charge)
	return max(value, 0)


/proc/odyssey_serialize_magazine_ammo(obj/item/ammo_magazine/AM)
	var/list/rounds = list()
	if (!istype(AM))
		return rounds
	for (var/obj/item/ammo_casing/AC in AM.stored_ammo)
		if (istype(AC))
			rounds += "[AC.type]"
	return rounds


/proc/odyssey_apply_magazine_ammo(obj/item/ammo_magazine/AM, list/rounds)
	if (!istype(AM))
		return
	var/list/old = list()
	if (!islist(AM.stored_ammo))
		AM.stored_ammo = list()
	for (var/obj/item/ammo_casing/AC in AM.stored_ammo)
		old += AC
	AM.stored_ammo.Cut()
	for (var/obj/item/ammo_casing/AC in old)
		qdel(AC)
	if (islist(rounds))
		for (var/ammo_text in rounds)
			var/path = odyssey_resolve_path(ammo_text)
			if (!ispath(path, /obj/item/ammo_casing))
				continue
			AM.stored_ammo += new path(AM)
	AM.update_icon()


/proc/odyssey_write_item_extras(obj/item/I, list/entry)
	if (!istype(I) || !islist(entry))
		return
	if (I.name != initial(I.name) && !entry["name"])
		entry["name"] = I.name
	if (I.color && I.color != initial(I.color))
		entry["color"] = "[I.color]"
	if (I.desc && I.desc != initial(I.desc))
		entry["desc"] = I.desc
	if (istype(I, /obj/item/cell))
		var/obj/item/cell/C = I
		entry["cell_charge"] = C.charge
	if (istype(I, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/AM = I
		entry["ammo"] = odyssey_serialize_magazine_ammo(AM)
	if (istype(I, /obj/item/gun/energy))
		var/obj/item/gun/energy/EG = I
		if (EG.power_supply)
			entry["cell_charge"] = EG.power_supply.charge
	if (istype(I, /obj/item/gun/projectile))
		var/obj/item/gun/projectile/PG = I
		var/list/gun = list("jammed" = !!PG.is_jammed)
		gun["chambered"] = istype(PG.chambered) ? "[PG.chambered.type]" : null
		var/list/loaded = list()
		for (var/obj/item/ammo_casing/AC in PG.loaded)
			if (istype(AC))
				loaded += "[AC.type]"
		gun["loaded"] = loaded
		if (istype(PG.ammo_magazine))
			gun["magazine"] = list(
				"type" = "[PG.ammo_magazine.type]",
				"ammo" = odyssey_serialize_magazine_ammo(PG.ammo_magazine)
			)
		else
			gun["magazine"] = null
		entry["gun"] = gun
	if (istype(I, /obj/item/modular_computer))
		var/obj/item/modular_computer/comp = I
		if (istype(comp.hard_drive))
			entry["computer_programs"] = odyssey_serialize_hdd_files(comp.hard_drive)
		if (istype(comp.portable_drive))
			entry["portable_drive"] = odyssey_serialize_portable_drive(comp.portable_drive)


/proc/odyssey_apply_projectile_gun(obj/item/gun/projectile/G, list/gun)
	if (!istype(G) || !islist(gun))
		return
	G.is_jammed = !!gun["jammed"]
	if (istype(G.chambered))
		qdel(G.chambered)
		G.chambered = null
	if (gun["chambered"])
		var/chamber_path = odyssey_resolve_path(gun["chambered"])
		if (ispath(chamber_path, /obj/item/ammo_casing))
			G.chambered = new chamber_path(G)
	var/list/old_loaded = list()
	if (!islist(G.loaded))
		G.loaded = list()
	for (var/obj/item/ammo_casing/AC in G.loaded)
		old_loaded += AC
	G.loaded.Cut()
	for (var/obj/item/ammo_casing/AC in old_loaded)
		qdel(AC)
	if (islist(gun["loaded"]))
		for (var/ammo_text in gun["loaded"])
			var/path = odyssey_resolve_path(ammo_text)
			if (!ispath(path, /obj/item/ammo_casing))
				continue
			G.loaded += new path(G)
	if (isnull(gun["magazine"]))
		if (istype(G.ammo_magazine))
			qdel(G.ammo_magazine)
			G.ammo_magazine = null
	else if (islist(gun["magazine"]))
		var/list/mag = gun["magazine"]
		var/mag_path = odyssey_resolve_path(mag["type"])
		if (!istype(G.ammo_magazine) || (ispath(mag_path) && G.ammo_magazine.type != mag_path))
			if (istype(G.ammo_magazine))
				qdel(G.ammo_magazine)
			if (!ispath(mag_path, /obj/item/ammo_magazine))
				mag_path = G.magazine_type
			if (ispath(mag_path, /obj/item/ammo_magazine))
				G.ammo_magazine = new mag_path(G)
		if (istype(G.ammo_magazine))
			odyssey_apply_magazine_ammo(G.ammo_magazine, mag["ammo"])
	G.update_icon()


/proc/odyssey_apply_item_computer(obj/item/modular_computer/comp, list/entry)
	if (!istype(comp) || !islist(entry))
		return
	if (("computer_programs" in entry) && istype(comp.hard_drive))
		odyssey_apply_hdd_files(comp.hard_drive, entry["computer_programs"])
	if (!("portable_drive" in entry))
		return
	if (istype(comp.portable_drive))
		qdel(comp.portable_drive)
		comp.portable_drive = null
	if (!islist(entry["portable_drive"]))
		comp.update_verbs()
		return
	var/list/data = entry["portable_drive"]
	var/path = odyssey_resolve_path(data["type"])
	if (!ispath(path, /obj/item/stock_parts/computer/hard_drive/portable))
		path = /obj/item/stock_parts/computer/hard_drive/portable
	var/obj/item/stock_parts/computer/hard_drive/portable/D = new path(comp)
	if (data["name"])
		D.SetName(data["name"])
	if (!isnull(data["read_only"]))
		D.read_only = !!data["read_only"]
	odyssey_apply_hdd_files(D, data["files"])
	comp.portable_drive = D
	comp.update_verbs()


/proc/odyssey_read_item_extras(obj/item/I, list/entry)
	if (!istype(I) || !islist(entry))
		return
	if (entry["name"])
		I.SetName(entry["name"])
	if (entry["color"])
		I.color = entry["color"]
	if (entry["desc"])
		I.desc = entry["desc"]
	if (!isnull(entry["cell_charge"]) && istype(I, /obj/item/cell))
		var/obj/item/cell/C = I
		C.charge = odyssey_charge_num(entry["cell_charge"], C.maxcharge)
		C.update_icon()
	if (("ammo" in entry) && istype(I, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/AM = I
		odyssey_apply_magazine_ammo(AM, entry["ammo"])
	if (!isnull(entry["cell_charge"]) && istype(I, /obj/item/gun/energy))
		var/obj/item/gun/energy/EG = I
		if (EG.power_supply)
			EG.power_supply.charge = odyssey_charge_num(entry["cell_charge"], EG.power_supply.maxcharge)
			EG.update_icon()
	if (islist(entry["gun"]) && istype(I, /obj/item/gun/projectile))
		odyssey_apply_projectile_gun(I, entry["gun"])
	if (istype(I, /obj/item/modular_computer))
		odyssey_apply_item_computer(I, entry)


/proc/odyssey_apply_console_portable_drive(obj/machinery/computer/modular/C, list/data)
	if (!istype(C) || !islist(data))
		return
	if (istype(C.portable_drive))
		qdel(C.portable_drive)
		C.portable_drive = null
	var/path = odyssey_resolve_path(data["type"])
	if (!ispath(path, /obj/item/stock_parts/computer/hard_drive/portable))
		path = /obj/item/stock_parts/computer/hard_drive/portable
	var/obj/item/stock_parts/computer/hard_drive/portable/D = new path(C)
	if (data["name"])
		D.SetName(data["name"])
	if (!isnull(data["read_only"]))
		D.read_only = !!data["read_only"]
	odyssey_apply_hdd_files(D, data["files"])
	C.portable_drive = D
