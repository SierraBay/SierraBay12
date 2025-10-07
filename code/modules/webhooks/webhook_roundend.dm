/singleton/webhook/roundend
	id = WEBHOOK_ROUNDEND

// Data expects three numerical fields: "survivors", "escaped", "ghosts"
/singleton/webhook/roundend/get_message(list/data)
	. = ..()
	var/desc = "A round of **[SSticker.mode ? SSticker.mode.name : "Unknown"]** has ended.\n"
	if(data)
		var/dead_count = GLOB.crew_death_count
		if(data["surviving_total"] > 0)

			var/s_was =      "was"
			var/s_survivor = "survivor"

			if(data["surviving_total"] != 1)
				s_was = "were"
				s_survivor = "survivors"

			desc += "There [s_was] **[data["surviving_total"]] [s_survivor], [dead_count] dead ([data["escaped_total"]] escaped)** and **[data["ghosts"]] ghosts.**"
		else
			desc += "There were **no survivors** ([dead_count] dead and [data["ghosts"]] ghosts)."

	.["embeds"] = list(list(
		"title" = "Round [game_id] is ending.",
		"description" = desc,
		"color" = COLOR_WEBHOOK_DEFAULT
	))
