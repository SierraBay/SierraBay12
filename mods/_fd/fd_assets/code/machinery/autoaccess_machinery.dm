/obj/machinery/alarm/auto_access/LateInitialize()
	..()
	inherit_access_from_area()

/obj/machinery/alarm/auto_access/proc/inherit_access_from_area()
	var/area/current_area = get_area(src)
	if(current_area)
		req_access = current_area.req_access

/obj/machinery/alarm/auto_access/unlocked
	locked = 0

/obj/machinery/power/apc/auto_access/LateInitialize()
	..()
	inherit_access_from_area()

/obj/machinery/power/apc/auto_access/proc/inherit_access_from_area()
	var/area/current_area = get_area(src)
	if(current_area)
		req_access = current_area.req_access

/obj/machinery/power/apc/auto_access/high
	cell_type = /obj/item/cell/high

/obj/machinery/power/apc/auto_access/super
	cell_type = /obj/item/cell/super

/obj/machinery/power/apc/auto_access/hyper
	cell_type = /obj/item/cell/hyper

/obj/machinery/power/apc/auto_access/critical
	cell_type = /obj/item/cell/high
	is_critical = 1

/obj/machinery/power/apc/auto_access/unlocked
	locked = 0
