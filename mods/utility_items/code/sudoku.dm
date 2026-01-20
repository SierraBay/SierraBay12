/datum/computer_file/program/sudoku
	filename = "sudoku"
	filedesc = "Sudoku"
	program_icon_state = "game"
	program_menu_icon = "script"
	extended_desc = "A game of numbers, logic, and deduction. Popular for centuries to keep the mind sharp."
	size = 5
	requires_ntnet = FALSE
	available_on_ntnet = TRUE
	nanomodule_path = /datum/nano_module/program/sudoku/
	usage_flags = PROGRAM_ALL

/datum/nano_module/program/sudoku
	var/list/grid = null
	var/building = 0
	var/list/solution = list()

	var/cheated = 0

	var/list/boxes = list(//Most efficient way i could think to do this
	"11" = list(1,2,3,10,11,12,19,20,21),
	"12" = list(4,5,6,13,14,15,22,23,24),
	"13" = list(7,8,9,16,17,18,25,26,27),
	"21" = list(28,29,30,37,38,39,46,47,48),
	"22" = list(31,32,33,40,41,42,49,50,51),
	"23" = list(34,35,36,43,44,45,52,53,54),
	"31" = list(55,56,57,64,65,66,73,74,75),
	"32" = list(58,59,60,67,68,69,76,77,78),
	"33" = list(61,62,63,70,71,72,79,80,81)
	)
	var/message = ""//Error or informational message shown on screen.
	var/lastmessage = ""
	var/messagesent = 0
	var/list/clues = list("Easy" = 36,"Medium"=31,"Hard"=26,"Robust"=17)
	var/lastuser = null
	var/wongame = 0
	var/datum/computer_file/sudoku

	var/newdifficulty = "Easy"//The selected difficulty mode for generating the next grid

	var/collapse = 0
	var/width = 900

/datum/nano_module/program/sudoku/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 0)
	var/list/data = host.initial_data(program)

	if (!grid)
		create_grid()
	data["grid"] = grid
	data["src"] = "\ref[src]"
	data["collapse"] = collapse
	data["message"] = message
	data["difficulty"] = newdifficulty
	if (message != lastmessage)
		lastmessage = message
		messagesent = world.time
	else if ((world.time - messagesent) > 100)//Make sure that messages show onscreen for at least 10 seconds
		message = ""//Displays for one refresh only
	lastuser = user

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mods-sudoku.tmpl", "Sudoku", width, 557)
		//if(host.update_layout()) // This is necessary to ensure the status bar remains updated along with rest of the UI.
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(0)



/datum/nano_module/program/sudoku/Topic(href, list/href_list)
	..()


	if(href_list["save"])//This is called with every keypress
		save_grid(href_list)
		return//No refreshing for every input
	else if (href_list["check"])
		save_grid(href_list)
		check_validity()
	else if (href_list["hint"])//Reveals one tile
		var/response = alert(usr,"Are you sure you want a hint? This will reveal the correct number for one tile. But you'll lose the pride of having figured it out yourself..","Ask for a hint","Help me","I can do it myself")
		if (response == "Help me")
			solver(1)
		else
			return
	else if (href_list["solve"])
		solver(81)
	else if (href_list["clear"])
		var/response = alert(usr,"Are you sure you want to clear the grid? This will remove all the numbers you've typed in. The starting clues will remain.","Clear board","Clear it","Wait no!")
		if (response == "Clear it")
			clear_grid(0)
		else
			return
	else if (href_list["purge"])
		clear_grid(1)
	else if (href_list["difficulty"])
		newdifficulty = href_list["difficulty"]
	else if (href_list["newgame"])
		var/response = alert(usr,"Are you sure you want to start a new game? All progress on this one will be lost. Be sure to pick your desired difficulty first.","New Puzzle","Start Anew","Wait no!")
		if (response == "Start Anew")
			advanced_populate_grid(clues[newdifficulty])
		else
			return
	else if (href_list["collapse"])
		collapse = !collapse
		set_width(usr)
		return

	if (usr)
		ui_interact(usr)

/datum/nano_module/program/sudoku/proc/set_width(mob/user)
	if (collapse)
		width = 400
	else
		width = 900

	var/datum/nanoui/ui = SSnano.get_open_ui(user, src, "main")
	if (ui)
		ui.close()
		ui_interact(user, force_open = 1)

/datum/nano_module/program/sudoku/proc/save_grid(list/inputdata)
	var/i = 1
	for (i = 1, i <= 81, i++)
		var/list/cell = grid[i]
		var/v = text2num(inputdata["[i]"])
		if (inputdata["[i]"] == "" || (v > 0 && v < 10))
			cell["value"] = inputdata["[i]"]

/datum/nano_module/program/sudoku/proc/create_grid()
	if (grid)
		grid.Cut()
	grid = list()

	var/n = 81
	var/list/numbers = list()
	while (n)
		n--
		numbers += rand(1,9)
	var/row = 1
	var/column = 0
	n = 1//reuse this
	for (var/a in numbers)
		var/list/number = list()
		number["value"] = ""
		//if (prob(20))
			//number["static"] = 1

		column++
		if (column > 9)
			row++
			column = 1

		number["id"] = "[row][column]"
		number["row"] = row
		number["column"] = column
		number["index"] = n
		number["tried"] = list()//used in grid generation
		n++
		grid.Add(list(number))

		var/box = ""
		switch (row)
			if (1 to 3)
				box += "1"
			if (4 to 6)
				box += "2"
			if (7 to 9)
				box += "3"

		switch (column)
			if (1 to 3)
				box += "1"
			if (4 to 6)
				box += "2"
			if (7 to 9)
				box += "3"

		number["box"] = box

	advanced_populate_grid()



/datum/nano_module/program/sudoku/proc/id_num(index)
	var/row = 1
	var/column = 1

	if (index <= 9)
		column = index
	else
		while (index > 9)
			index -= 9
			row++
		column = index



	return "[row][column]"





//Clears the grid:
//With an input of 0, clears all user input and restores the grid to just the generated clues
//With input of 1, clears every cell, grid becomes empty
/datum/nano_module/program/sudoku/proc/clear_grid(full = 0)
	for (var/t in grid)
		var/list/tile = t
		if (full || !tile["static"])
			tile["value"] = ""
			tile["static"] = 0
			tile["highlight"] = 0
	if (full)
		cheated = 0
		wongame = 0


/*********
* HELPERS
*********/
//This proc checks the validity of the current boardstate
//It will analyse all the tiles in sequence, and halt if it finds an invalid one.
//Tiles will be checked for conflicts along the row, border and 3x3 box
/datum/nano_module/program/sudoku/proc/check_validity()

	//This result will be returned at the end
	. = 0
	//Return var of 0 is normal, that means the game is unfinished and the boardstate is valid
	//Any return var > zero indicates invalid, with that number being the index of the first invalid tile
	//Return var of -1 indicates all tiles filled and boardstate valid. IE: Game over, you win!

	var/empty = 0
	var/conflict = 0
	for (var/t in grid)
		var/list/tile = t
		if (tile["static"])
			continue
		var/v = tile["value"]
		var/i = tile["index"]
		if (!v)
			empty++
			continue

		var/list/group
		group = get_row(i)
		for (var/n in group)
			if(n == v)//CONFLICT
				conflict = i
				break

		group = get_column(i)
		for (var/n in group)
			if(n == v)//CONFLICT
				conflict = i
				break

		group = get_box(i)
		for (var/n in group)
			if(n == v)//CONFLICT
				conflict = i
				break

		if (conflict)
			break

	if (conflict)
		message = "Error: Invalid tile found! The problem is highlighted"
		highlight(list(conflict))
		.=conflict

	else if (empty > 0)
		message = "Everything looks fine so far! You have [empty] tiles left to fill"
		highlight()


	//If we havent found any conflict and all tiles are filled, then the user has won the game.
	else if (empty == 0)
		message = "Congratulations! You win the game!"
		if (!wongame)
			playsound(get_turf(usr), 'mods/utility_items/sounds/magic_light.ogg', 50, 1)
		wongame = 1
		.=-1




//Attempts to solve the board using simple single-tile logic. This will solvve most easier boards
//May implement split timelines for solving boards where the answer isnt simple
//Number of steps indicates how many tiles to solve. Passing 1 can serve as a hint function
/datum/nano_module/program/sudoku/proc/solver(steps = 81)
	if (check_validity() != 0) //Can't build on quicksand. The boardstate must be valid before we attempt to progress
		return

	var/done = 0
	var/list/emptytiles = list()


	for (var/t in grid)
		var/list/tile = t
		var/v = tile["value"]

		if (v)//Already has a valid value, next tile
			continue

		emptytiles += text2num(tile["index"])



	if(LAZYLEN(emptytiles))
		while (steps > 0 && !done)

			if (LAZYLEN(emptytiles) <= 0 )
				done = 1//If we get here then the solver has won the game.
			var/i = pick_n_take(emptytiles)
			var/list/tile = grid[i]
			tile["value"] = solution[i]//Solution is the pre-saved correct solution for the puzzle
			tile["static"] = 1
			steps--
			cheated++//Cheated var indicates the user had help
			message = "A tile has been revealed for you. You've now had [cheated] hints"
			highlight(list(i))


//Returns all possible values for a tile
//If this ever returns nothing then the game is in an unwinnable state, a mistake has been made
/datum/nano_module/program/sudoku/proc/get_options(index)
	. = list(1,2,3,4,5,6,7,8,9)
	. -= get_row(index)
	. -= get_column(index)
	. -= get_box(index)


//Returns all tiles in the same row as index, excluding index
/datum/nano_module/program/sudoku/proc/get_row(index)
	var/list/tile = grid[index]
	//We get the row number from this

	var/rowstart = (((tile["row"]-1)*9) + 1)//Index of the first tile on the row we want

	var/i
	var/list/indices = list()
	for (i = 0, i <= 8, i++)
		indices += rowstart+i

	indices -= index

	return get_tile_values(indices)

//Returns all tiles in the same row as index, excluding index
/datum/nano_module/program/sudoku/proc/get_column(index)
	var/list/tile = grid[index]
	//We get the row number from this

	var/columnstart = tile["column"]//Index of the first tile on the row we want
	var/i
	var/list/indices = list()
	for (i = 0, i <= 8, i++)
		indices += columnstart+(i*9)

	indices -= index


	return get_tile_values(indices)

/datum/nano_module/program/sudoku/proc/get_box(index)
	var/list/tile = grid[index]
	var/list/temp = boxes[tile["box"]]
	var/list/boxind = temp.Copy()
	boxind -= index
	return get_tile_values(boxind)


//Takes a list of indexes, returns the grid tiles with those indexes.
/datum/nano_module/program/sudoku/proc/get_tiles(list/indexes)
	. = list()
	for (var/i in indexes)
		. += list(grid[i])

/datum/nano_module/program/sudoku/proc/get_tile_values(list/indexes)
	. = list()
	for (var/i in indexes)
		var/list/tile = grid[i]
		. += tile["value"]




//A not so simple grid builder which uses a backtracking algorithm.
//Attempts to build the grid linearly with random numbers, backtracking and trying again whenever a
//collision is found
/datum/nano_module/program/sudoku/proc/advanced_populate_grid(clues = 36)
	set background = 1
	if (building)
		return

	building = 1
	clear_grid(1)
	var/iterations = 0
	var/i = 1
	for (i = 1, i <= 81, i++)
		var/list/tile = grid[i]
		iterations++

		var/list/tried = tile["tried"]
		var/list/options = get_options(i)

		options.Remove(tried)//The list of tried numbers is used when we backtrack

		//So long as we have any options left, we'll pick a random one and keep going
		if (LAZYLEN(options) > 0)
			tile["value"] = pick(options)
			tile["static"] = 1
		else
			//If there are no valid, non-colliding numbers for this tile, then things get interesting.
			var/list/prev = grid[i-1]//Get the previous tile
			var/list/t = prev["tried"]
			t += prev["value"]//The value for the previous tile is now blacklisted
			prev["value"] = ""
			//grid[i-1] = prev

			//Now we wipe our own tried list since we're stepping back. How we've branched forward
			//from this point is no longer relevant
			tile["tried"] = list()
			//And finally we set i back two decrements, so in the next cycle of the loop
			//it will look at the previous cell
			i -= 2
		if (iterations == 100)
			iterations = 0
			sleep(1)

	//Now we copy over the solution
	solution = list()
	for (var/t in grid)
		var/list/tile = t
		solution += tile["value"]



	//And finally we start removing stuff until we have only the clues left
	var/toremove = 81 - clues
	var/list/filledtiles = list()
	for (i = 1, i <= 81, i++)
		filledtiles += i
	while (toremove > 0)
		i = pick_n_take(filledtiles)
		toremove--
		var/list/tile = grid[i]
		tile["value"] = ""
		tile["static"] = 0
		tile["tried"] = list()//to prevent any cheating


	building = 0


//Highlights all indices in the list. Unhighlights every other cell
/datum/nano_module/program/sudoku/proc/highlight(list/indices)
	if (!indices)
		indices = list()
	for (var/i = 1, i <= 81, i++)
		var/list/tile = grid[i]
		if (LAZYLEN(indices) && (i in indices))
			tile["highlight"] = 1
		else
			tile["highlight"] = 0
