
//////////////////////////
//Movable Screen Objects//
//   By RemieRichards	//
//////////////////////////


//Movable Screen Object
//Not tied to the grid, places it's center where the cursor is

/obj/screen/movable
	var/snap2grid = FALSE
	var/moved = FALSE

//Snap Screen Object
//Tied to the grid, snaps to the nearest turf

/obj/screen/movable/snap
	snap2grid = TRUE


/obj/screen/movable/MouseDrop(over_object, src_location, over_location, src_control, over_control, params)
	var/list/PM = params2list(params)

	//No screen-loc information? abort.
	if(!PM || !PM["screen-loc"])
		return

	//Split screen-loc up into X+Pixel_X and Y+Pixel_Y
	var/list/screen_loc_params = splittext(PM["screen-loc"], ",")

	//Split X+Pixel_X up into list(X, Pixel_X)
	var/list/screen_loc_X = splittext(screen_loc_params[1],":")
	screen_loc_X[1] = encode_screen_X(text2num(screen_loc_X[1]), usr)
	//Split Y+Pixel_Y up into list(Y, Pixel_Y)
	var/list/screen_loc_Y = splittext(screen_loc_params[2],":")
	screen_loc_Y[1] = encode_screen_Y(text2num(screen_loc_Y[1]), usr)

	if(snap2grid) //Discard Pixel Values
		screen_loc = "[screen_loc_X[1]],[screen_loc_Y[1]]"

	else //Normalise Pixel Values (So the object drops at the center of the mouse, not 16 pixels off)
		var/pix_X = text2num(screen_loc_X[2]) - 16
		var/pix_Y = text2num(screen_loc_Y[2]) - 16
		screen_loc = "[screen_loc_X[1]]:[pix_X],[screen_loc_Y[1]]:[pix_Y]"

/obj/screen/movable/proc/encode_screen_X(X, mob/viewer)
	// [SIERRA-EDIT]
	var/view = viewer.client ? get_view_size_x(viewer.client.view) : get_view_size_x(world.view)
	var/x_center = floor(view / 2) + 1 // finding our x center of view

	if(X > x_center)      // we are on the right side of the view
		. = "EAST-[view - X]"
	else if(X < x_center) // we are on the left side of the view
		. = "WEST+[X-1]"
	else                  // we are on the center of the view
		. = "CENTER"
	// [/SIERRA-EDIT]

/obj/screen/movable/proc/decode_screen_X(X, mob/viewer)
	// [SIERRA-EDIT]
	var/view = viewer.client ? get_view_size_x(viewer.client.view) : get_view_size_x(world.view)
	var/x_center = floor(view / 2) + 1 // finding our x center of view
	//Find EAST/WEST implementations
	if(findtext(X,"EAST-"))
		var/num = text2num(copytext(X,6)) //Trim EAST-
		if(!num)
			num = 0
		. = view - num
	else if(findtext(X,"WEST+"))
		var/num = text2num(copytext(X,6)) //Trim WEST+
		if(!num)
			num = 0
		. = num+1
	else if(findtext(X,"CENTER"))
		. = x_center
	// [/SIERRA-EDIT]

/obj/screen/movable/proc/encode_screen_Y(Y, mob/viewer)
	// [SIERRA-EDIT]
	var/view = viewer.client ? get_view_size_y(viewer.client.view) : get_view_size_y(world.view)
	var/y_center = floor(view / 2) + 1 // finding our y center of view

	if(Y > y_center)      // we are on the right side of the view
		. = "NORTH-[view - Y]"
	else if(Y < y_center) // we are on the left side of the view
		. = "SOUTH+[Y - 1]"
	else                  // we are on the center of the view
		. = "CENTER"
	// [/SIERRA-EDIT]

/obj/screen/movable/proc/decode_screen_Y(Y, mob/viewer)
	// [SIERRA-EDIT]
	var/view = viewer.client ? get_view_size_y(viewer.client.view) : get_view_size_y(world.view)
	var/y_center = floor(view / 2) + 1 // finding our y center of view

	if(findtext(Y,"NORTH-"))
		var/num = text2num(copytext(Y,7)) //Trim NORTH-
		if(!num)
			num = 0
		. = view - num
	else if(findtext(Y,"SOUTH+"))
		var/num = text2num(copytext(Y,7)) //Time SOUTH+
		if(!num)
			num = 0
		. = num+1
	else if(findtext(Y,"CENTER"))
		. = y_center
	// [/SIERRA-EDIT]

//Debug procs
/client/proc/test_movable_UI()
	set category = "Debug"
	set name = "Spawn Movable UI Object"

	var/obj/screen/movable/M = new()
	M.SetName("Movable UI Object")
	M.icon_state = "block"
	M.maptext = "Movable"
	M.maptext_width = 64

	var/screen_l = input(usr,"Where on the screen? (Formatted as 'X,Y' e.g: '1,1' for bottom left)","Spawn Movable UI Object") as text
	if(!screen_l)
		return

	M.screen_loc = screen_l

	screen += M


/client/proc/test_snap_UI()
	set category = "Debug"
	set name = "Spawn Snap UI Object"

	var/obj/screen/movable/snap/S = new()
	S.SetName("Snap UI Object")
	S.icon_state = "block"
	S.maptext = "Snap"
	S.maptext_width = 64

	var/screen_l = input(usr,"Where on the screen? (Formatted as 'X,Y' e.g: '1,1' for bottom left)","Spawn Snap UI Object") as text
	if(!screen_l)
		return

	S.screen_loc = screen_l

	screen += S
