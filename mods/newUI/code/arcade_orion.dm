
//////////////////////////
//   ORION TRAIL HERE   //
//////////////////////////

//Orion Trail Events
#define ORION_TRAIL_RAIDERS				"Vox Raiders"
#define ORION_TRAIL_FLUX				"Interstellar Flux"
#define ORION_TRAIL_ILLNESS				"Illness"
#define ORION_TRAIL_BREAKDOWN			"Breakdown"
#define ORION_TRAIL_MUTINY				"Mutiny?"
#define ORION_TRAIL_MUTINY_ATTACK 		"Mutinous Ambush"
#define ORION_TRAIL_MALFUNCTION			"Malfunction"
#define ORION_TRAIL_COLLISION			"Collision"
#define ORION_TRAIL_SPACEPORT			"Spaceport"
#define ORION_TRAIL_DISASTER			"Disaster"
#define ORION_TRAIL_SPACEPORT_RAIDED	"Raided Spaceport"
#define ORION_TRAIL_DERELICT			"Derelict Spacecraft"
#define ORION_TRAIL_CARP				"Carp Migration"
#define ORION_TRAIL_STUCK				"Stuck!"
#define ORION_TRAIL_START				"Start"
#define ORION_TRAIL_GAMEOVER			"Gameover!"


#define ORION_VIEW_MAIN			0
#define ORION_VIEW_SUPPLIES		1
#define ORION_VIEW_CREW			2

/obj/machinery/computer/arcade/orion_trail/proc/newgame(emag = 0)
	SetName("orion trail[emag ? ": Realism Edition" : ""]")
	supplies = list("1" = 1, "2" = 1, "3" = 1, "4" = 60, "5" = 20, "6" = 5000)
	emagged = emag
	distance = 0
	settlers = list("[usr]")
	for(var/i=0; i<3; i++)
		if(prob(50))
			settlers += pick(GLOB.first_names_male)
		else
			settlers += pick(GLOB.first_names_female)
	num_traitors = 0
	event = ORION_TRAIL_START
	port = 0
	view = ORION_VIEW_MAIN

/obj/machinery/computer/arcade/orion_trail/interact(mob/user)
	var/dat = "<html><head><style>"
	dat += "body { background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%); color: #e6e6e6; font-family: 'Courier New', monospace; margin: 0; padding: 20px; }"
	dat += ".container { max-width: 800px; margin: 0 auto; background: rgba(0, 0, 0, 0.7); border-radius: 15px; padding: 20px; border: 2px solid #4cc9f0; box-shadow: 0 0 20px rgba(76, 201, 240, 0.5); }"
	dat += ".header { text-align: center; color: #4cc9f0; text-shadow: 0 0 10px rgba(76, 201, 240, 0.8); margin-bottom: 20px; }"
	dat += ".event-title { font-size: 28px; color: #f72585; text-shadow: 0 0 8px rgba(247, 37, 133, 0.8); margin: 15px 0; }"
	dat += ".event-description { background: rgba(255, 255, 255, 0.1); padding: 15px; border-radius: 10px; margin: 15px 0; text-align: center; font-size: 16px; border: 1px solid #4cc9f0; }"
	dat += ".event-info { background: rgba(247, 37, 133, 0.2); padding: 15px; border-radius: 10px; margin: 15px 0; text-align: center; font-size: 16px; border: 1px solid #f72585; }"
	dat += ".stats { display: flex; justify-content: space-around; margin: 20px 0; flex-wrap: wrap; }"
	dat += ".stat-box { background: rgba(76, 201, 240, 0.2); padding: 15px; border-radius: 10px; text-align: center; width: 180px; margin: 10px; border: 1px solid #4cc9f0; }"
	dat += ".stat-title { font-size: 12px; color: #4cc9f0; margin-bottom: 5px; }"
	dat += ".stat-value { font-size: 16px; font-weight: bold; color: #f72585; }"
	dat += ".actions { text-align: center; margin: 20px 0; }"
	dat += ".action-btn { background: linear-gradient(45deg, #f72585, #b5179e); color: white; border: none; padding: 12px 20px; margin: 8px; border-radius: 25px; cursor: pointer; font-size: 16px; font-family: 'Courier New', monospace; transition: all 0.3s; text-decoration: none; display: inline-block; }"
	dat += ".action-btn:hover { transform: scale(1.05); box-shadow: 0 0 15px rgba(247, 37, 133, 0.8); }"
	dat += ".action-btn:disabled { background: #666; cursor: not-allowed; transform: none; box-shadow: none; }"
	dat += ".action-btnsuppl { background: linear-gradient(45deg, #f72585, #b5179e); color: white; border: none; padding: 4px 8px; margin: 8px; border-radius: 10px; cursor: pointer; font-size: 16px; font-family: 'Courier New', monospace; transition: all 0.3s; text-decoration: none; display: inline-block; }"
	dat += ".action-btnsuppl:hover { transform: scale(1.05); box-shadow: 0 0 8px rgba(247, 37, 133, 0.8); }"
	dat += ".action-btnsuppl:disabled { background: #666; cursor: not-allowed; transform: none; box-shadow: none; }"
	dat += ".game-over { background: rgba(247, 37, 133, 0.3); padding: 20px; border-radius: 10px; text-align: center; margin: 20px 0; border: 2px solid #f72585; }"
	dat += ".health-bar { height: 20px; background: #333; border-radius: 10px; margin: 10px 0; overflow: hidden; }"
	dat += ".health-fill { height: 100%; background: linear-gradient(90deg, #ff6b6b, #f72585); border-radius: 10px; transition: width 0.5s; }"
	dat += ".magic-bar { height: 20px; background: #333; border-radius: 10px; margin: 10px 0; overflow: hidden; }"
	dat += ".magic-fill { height: 100%; background: linear-gradient(90deg, #4cc9f0, #4895ef); border-radius: 10px; transition: width 0.5s; }"
	dat += "a { color: #4cc9f0; text-decoration: none; }"
	dat += "a:hover { text-decoration: underline; }"
	dat += ".supply-item { background: rgba(76, 201, 240, 0.1); padding: 10px; border-radius: 8px; margin: 5px 0; border: 1px solid #4cc9f0; }"
	dat += ".supply-title { font-weight: bold; color: #4cc9f0; }"
	dat += ".crew-member { background: rgba(247, 37, 133, 0.1); padding: 10px; border-radius: 8px; margin: 5px 0; border: 1px solid #f72585; }"
	dat += ".view-tabs { text-align: right; margin: 20px 0; }"
	dat += ".tab-btn { background: rgba(76, 201, 240, 0.2); color: #4cc9f0; border: 1px solid #4cc9f0; padding: 8px 15px; margin: 5px; border-radius: 20px; cursor: pointer; font-size: 14px; font-family: 'Courier New', monospace; transition: all 0.3s; }"
	dat += ".tab-btn:hover { background: rgba(76, 201, 240, 0.4); }"
	dat += ".tab-btn.active { background: linear-gradient(45deg, #f72585, #b5179e); color: white; }"
	dat += "</style></head><body>"
	dat += "<div class='container'>"

	if(isnull(event))
		newgame()
	user.set_machine(src)

	switch(view)
		if(ORION_VIEW_MAIN)
			if(event == ORION_TRAIL_START) //new game? New game.
				dat += "<div class='header'><h1>Orion Trail[emagged ? ": Realism Edition" : ""]</h1></div>"
				dat += "<div class='event-description'>Learn how our ancestors got to Orion, and have fun in the process!</div>"
				dat += "<div class='actions'><a href='byond://?src=\ref[src];continue=1' class='action-btn'>Start New Game</a></div>"
			else
				event_title = event
				dat += "<div class='header'><h1>Orion Trail[emagged ? ": Realism Edition" : ""]</h1></div>"
				dat += "<div class='event-title'>[event_title]</div>"

				switch(event)
					if(ORION_TRAIL_GAMEOVER)
						dat += "<div class='event-description'>Game Over!</div>"
						dat += "<div class='event-info'>[event_desc]</div>"
						dat += "<div class='actions'><a href='byond://?src=\ref[src];continue=1' class='action-btn'>Start New Game</a></div>"
					if(ORION_TRAIL_SPACEPORT)
						dat += "<div class='event-title'>[stops[port]]</div>"
						dat += "<div class='event-description'>[stopblurbs[port]]</div>"
						dat += "<div class='event-info'>Distance to next port: [distance]</div>"
						if(port == 9)
							dat += "<div class='actions'><a href='byond://?src=\ref[src];continue=1' class='action-btn'>Return to the title screen!</a></div>"
						else
							dat += "<div class='actions'>"
							dat += "<a href='byond://?src=\ref[src];continue=1' class='action-btn'>Shove off</a>"
							dat += "<a href='byond://?src=\ref[src];attack=1' class='action-btn'>Raid Spaceport</a>"
							dat += "</div>"
					if(ORION_TRAIL_SPACEPORT_RAIDED)
						dat += "<div class='event-title'>[stops[port]]</div>"
						dat += "<div class='actions'><a href='byond://?src=\ref[src];continue=1' class='action-btn'>Shove off</a></div>"
					if(ORION_TRAIL_RAIDERS)
						dat += "<div class='event-description'>You arm yourselves as you prepare to fight off the vox menace!</div>"
						dat += "<div class='event-info'>[event_info]</div>"
						dat += "<a href='byond://?src=\ref[src];continue=1' class='action-btn'>Continue as normal</a>"
					if(ORION_TRAIL_DERELICT)
						dat += "<div class='event-description'>You come across an unpowered ship drifting slowly in the vastness of space. Sensors indicate there are no lifeforms aboard.</div>"
						dat += "<div class='event-info'>[event_info]</div>"
						dat += "<a href='byond://?src=\ref[src];continue=1' class='action-btn'>Continue as normal</a>"
					if(ORION_TRAIL_ILLNESS)
						dat += "<div class='event-description'>A disease has spread among your crew!</div>"
						dat += "<div class='event-info'>[event_info]</div>"
						dat += "<a href='byond://?src=\ref[src];continue=1;risky=25' class='action-btn'>Continue</a>"
					if(ORION_TRAIL_FLUX)
						dat += "<div class='event-description'>You've entered a turbulent region. Slowing down would be better for your ship but would cost more fuel.</div>"
						dat += "<div class='actions'>"
						dat += "<a href='byond://?src=\ref[src];continue=1;risky=25' class='action-btn'>Continue as normal</a>"
						dat += "<a href='byond://?src=\ref[src];continue=1;slow=1;' class='action-btn'>Take it slow</a>"
						dat += "</div>"
					if(ORION_TRAIL_MALFUNCTION)
						dat += "<div class='event-description'>The ship's computers are malfunctioning! You can choose to fix it with a part or risk something going awry.</div>"
						dat += "<div class='actions'>"
						dat += "<a href='byond://?src=\ref[src];continue=1;risky=25' class='action-btn'>Continue as normal</a>"
						if(supplies["3"] != 0)
							dat += "<a href='byond://?src=\ref[src];continue=1;fix=3' class='action-btn'>Fix using a part.</a>"
						dat += "</div>"
					if(ORION_TRAIL_COLLISION)
						dat += "<div class='event-description'>Something has hit your ship and breached the hull! You can choose to fix it with a part or risk something going awry.</div>"
						dat += "<div class='actions'>"
						dat += "<a href='byond://?src=\ref[src];continue=1;risky=25' class='action-btn'>Continue as normal</a>"
						if(supplies["2"] != 0)
							dat += "<a href='byond://?src=\ref[src];continue=1;fix=2' class='action-btn'>Fix using a part.</a>"
						dat += "</div>"
					if(ORION_TRAIL_BREAKDOWN)
						dat += "<div class='event-description'>The ship's engines broke down! You can choose to fix it with a part or risk something going awry.</div>"
						dat += "<div class='actions'>"
						dat += "<a href='byond://?src=\ref[src];continue=1;risky=25' class='action-btn'>Continue as normal</a>"
						if(supplies["1"] != 0)
							dat += "<a href='byond://?src=\ref[src];continue=1;fix=1' class='action-btn'>Fix using a part.</a>"
						dat += "</div>"
					if(ORION_TRAIL_STUCK)
						dat += "<div class='event-description'>You've ran out of fuel. Your only hope to survive is to get refueled by a passing ship, if there are any.</div>"
						dat += "<div class='event-info'>[event_info]</div>"
						if(supplies["5"] == 0)
							dat += "<div class='actions'><a href='byond://?src=\ref[src];continue=1;food=1' class='action-btn'>Wait</a></div>"
					if(ORION_TRAIL_CARP)
						dat += "<div class='event-description'>You've chanced upon a large carp migration! Known both for their delicious meat as well as their bite, you and your crew arm yourselves for a small hunting trip.</div>"
						dat += "<div class='event-info'>[event_info]</div>"
						dat += "<a href='byond://?src=\ref[src];continue=1' class='action-btn'>Continue as normal</a>"
					if(ORION_TRAIL_MUTINY)
						dat += "<div class='event-description'>You've been hearing rumors of dissenting opinions and missing items from the armory...</div>"
						dat += "<div class='event-info'>[event_info]</div>"
						dat += "<a href='byond://?src=\ref[src];continue=1;risky=25' class='action-btn'>Continue as normal</a>"
					if(ORION_TRAIL_MUTINY_ATTACK)
						dat += "<div class='event-description'>Oh no, some of your crew are attempting to mutiny!!</div>"
						dat += "<div class='event-info'>[event_info]</div>"
						dat += "<a href='byond://?src=\ref[src];continue=1;risky=25' class='action-btn'>Continue as normal</a>"
					if(ORION_TRAIL_DISASTER)
						dat += "<div class='event-description'>[event_desc]</div>"
						dat += "<a href='byond://?src=\ref[src];continue=1;' class='action-btn'>Continue as normal</a>"

				if(event != ORION_TRAIL_START && event != ORION_TRAIL_GAMEOVER)
					dat += "<div class='stats'>"
					dat += "<div class='stat-box'>"
					dat += "<div class='stat-title'>DISTANCE</div>"
					dat += "<div class='stat-value'>[distance]</div>"
					dat += "</div>"
					dat += "<div class='stat-box'>"
					dat += "<div class='stat-title'>FUEL</div>"
					dat += "<div class='stat-value'>[supplies["5"]]</div>"
					dat += "<div class='health-bar'><div class='health-fill' style='width: [min(100, supplies["5"] * 2)]%'></div></div>"
					dat += "</div>"
					dat += "<div class='stat-box'>"
					dat += "<div class='stat-title'>FOOD</div>"
					dat += "<div class='stat-value'>[supplies["4"]]</div>"
					dat += "<div class='health-bar'><div class='health-fill' style='width: [min(100, supplies["4"] * 2)]%'></div></div>"
					dat += "</div>"
					dat += "<div class='stat-box'>"
					dat += "<div class='stat-title'>CREW</div>"
					dat += "<div class='stat-value'>[length(settlers)]</div>"
					dat += "<div class='health-bar'><div class='health-fill' style='width: [min(100, length(settlers) * 10)]%'></div></div>"
					dat += "</div>"
					dat += "</div>"

		if(ORION_VIEW_SUPPLIES)
			dat += "<div class='header'><h1>Supplies</h1></div>"
			dat += "<div class='event-info'>You have [supplies["6"]] [GLOB.using_map.local_currency_name].</div>"
			dat += "<div class='event-description'>View your supplies or buy more when at a spaceport.</div>"
			for(var/i=1; i<6; i++)
				var/amm = (i>3?10:1)
				dat += "<div class='supply-item'>"
				dat += "[supplies["[i]"]] [supply_name["[i]"]] "
				if(event == ORION_TRAIL_SPACEPORT)
					dat += "<a href='byond://?src=\ref[src];buy=[i]' class='.action-btnsuppl'>buy [amm] for [supply_cost["[i]"]]T</a>"
				dat += "</div>"
				if(supplies["[i]"] >= amm && event == ORION_TRAIL_SPACEPORT)
					dat += "<a href='byond://?src=\ref[src];sell=[i]' class='.action-btnsuppl'>sell [amm] for [supply_cost["[i]"]]T</a><br>"
		if(ORION_VIEW_CREW)
			dat += "<div class='header'><h1>Crew</h1></div>"
			dat += "<div class='event-description'>View the status of your crew.</div>"
			for(var/i=1;i<=length(settlers);i++)
				dat += "<div class='crew-member'>[settlers[i]] <a href='byond://?src=\ref[src];kill=[i]' class='action-btn'>Kill</a></div>"

	dat += "<div class='view-tabs'>"
	dat += view == ORION_VIEW_MAIN ? "<span class='tab-btn active'>Main</span>" : "<a href='byond://?src=\ref[src];continue=1' class='tab-btn'>Main</a>"
	dat += view == ORION_VIEW_SUPPLIES ? "<span class='tab-btn active'>Supplies</span>" : "<a href='byond://?src=\ref[src];supplies=1' class='tab-btn'>Supplies</a>"
	dat += view == ORION_VIEW_CREW ? "<span class='tab-btn active'>Crew</span>" : "<a href='byond://?src=\ref[src];crew=1' class='tab-btn'>Crew</a>"
	dat += "</div>"


	dat += "</div></body></html>"
	show_browser(user, dat, "window=arcade;size=600x800")

/obj/machinery/computer/arcade/orion_trail/OnTopic(user, href_list)
	if(href_list["continue"])
		if(view == ORION_VIEW_MAIN)
			var/next_event = null
			if(event == ORION_TRAIL_START)
				event = ORION_TRAIL_SPACEPORT
			if(event == ORION_TRAIL_GAMEOVER)
				event = null
				return TOPIC_REFRESH
			if(!length(settlers))
				event_desc = "You and your crew were killed on the way to Orion, your ship left abandoned for scavengers to find."
				next_event = ORION_TRAIL_GAMEOVER
			if(port == 9)
				win()
				return TOPIC_REFRESH
			var/travel = min(rand(1000,10000),distance)
			if(href_list["fix"])
				var/item = href_list["fix"]
				supplies[item] = max(0, --supplies[item])
			if(href_list["risky"])
				var/risk = text2num(href_list["risky"])
				if(prob(risk))
					next_event = ORION_TRAIL_DISASTER


			if(!href_list["food"])
				var/temp = supplies["5"] - travel/1000 * (href_list["slow"] ? 2 : 1)
				if(temp < 0 && (distance-travel != 0) && isnull(next_event)) //uh oh. Better start a fuel event.
					next_event = ORION_TRAIL_STUCK
					travel -= (temp*-1)*1000/(href_list["slow"] ? 2 : 1)
					temp = 0
				supplies["5"] = temp

				supplies["4"] = round(supplies["4"] - travel/1000 * length(settlers) * (href_list["slow"] ? 2 : 1))
				distance = max(0,distance-travel)
			else
				supplies["4"] -= length(settlers) * 5
				event_info = "You have [supplies["4"]] food left.<BR>"
				next_event = ORION_TRAIL_STUCK

			if(supplies["4"] <= 0)
				next_event = ORION_TRAIL_GAMEOVER
				event_desc = "You and your crew starved to death, never to reach Orion."
				supplies["4"] = 0

			if(distance == 0 && isnull(next_event)) //POOORT!
				port++
				event = ORION_TRAIL_SPACEPORT
				distance = stop_distance[port]
				//gotta set supply costs. The further out the more expensive it'll generally be
				supply_cost = list("1" = rand(500+100*port,1200+100*port), "2" = rand(700+100*port,1000+100*port), "3" = rand(900+50*port,1500+75*port), "4" =  rand(10+50*port,125+50*port), "5" =  rand(75+25*port,200+100*port))
			else //Event? Event.
				generate_event(next_event)
		else
			view = ORION_VIEW_MAIN
		return TOPIC_REFRESH

	else if(href_list["supplies"])
		view = ORION_VIEW_SUPPLIES
		return TOPIC_REFRESH

	else if(href_list["crew"])
		view = ORION_VIEW_CREW
		return TOPIC_REFRESH

	else if(href_list["buy"])
		var/item = href_list["buy"]
		if(supply_cost["[item]"] <= supplies["6"])
			supplies["[item]"] += (text2num(item) > 3 ? 10 : 1)
			supplies["6"] -= supply_cost["[item]"]
		return TOPIC_REFRESH

	else if(href_list["sell"])
		var/item = href_list["sell"]
		if(supplies["[item]"] >= (text2num(item) > 3 ? 10 : 1))
			supplies["6"] += supply_cost["[item]"]
			supplies["[item]"] -= (text2num(item) > 3 ? 10 : 1)
		return TOPIC_REFRESH

	else if(href_list["kill"])
		var/item = text2num(href_list["kill"])
		remove_settler(item)
		return TOPIC_REFRESH

	else if(href_list["attack"])
		supply_cost = list()
		if(prob(17*length(settlers)))
			event_desc = "An empty husk of a station now, all its resources stripped for use in your travels."
			event_info = "You've successfully raided the spaceport!<br>"
			change_resource(null)
			change_resource(null)
		else
			event_desc = "The local police mobilized too quickly, sirens blare as you barely make it away with your ship intact."
			change_resource(null,-1)
			change_resource(null,-1)
			if(prob(50))
				remove_settler(null, "died while you were escaping!")
				if(prob(10))
					remove_settler(null, "died while you were escaping!")
		event = ORION_TRAIL_SPACEPORT_RAIDED
		return TOPIC_REFRESH

/obj/machinery/computer/arcade/orion_trail/proc/change_resource(specific = null, add = 1)
	if(!specific)
		specific = rand(1,6)
	var/cost = (specific < 4 ? rand(1,5) : rand(5,100)) * add
	cost = round(cost)
	if(cost < 0)
		cost = max(cost,supplies["[specific]"] * -1)
	else
		cost = max(cost,1)
	supplies["[specific]"] += cost
	event_info += "You've [add > 0 ? "gained" : "lost"] [abs(cost)] [supply_name["[specific]"]]<BR>"

/obj/machinery/computer/arcade/orion_trail/proc/remove_settler(specific = null, desc = null)
	if(!length(settlers))
		return
	if(!specific)
		specific = rand(1,length(settlers))

	event_info += "The crewmember, [settlers[specific]] [isnull(desc) ? "has died!":"[desc]"]<BR>"
	settlers -= settlers[specific]
	if(num_traitors > 0 && prob(100/max(1,length(settlers)-1)))
		num_traitors--

/obj/machinery/computer/arcade/orion_trail/proc/generate_event(specific = null)
	if(!specific)
		if(prob(20*num_traitors))
			specific = ORION_TRAIL_MUTINY_ATTACK
		else
			specific = pickweight(events)

	switch(specific)
		if(ORION_TRAIL_RAIDERS)
			if(prob(17 * length(settlers)))
				event_info = "You managed to fight them off!<br>"
				if(prob(5))
					remove_settler(null,"died in the firefight!")
				change_resource(rand(4,5))
				change_resource(rand(1,3))
				if(prob(50))
					change_resource(6,1.1)
			else
				event_info = "You couldn't fight them off!<br>"
				if(prob(10*length(settlers)))
					remove_settler(null, "was kidnapped by the Vox!")
				change_resource(null,-1)
				change_resource(null,-0.5)
		if(ORION_TRAIL_DERELICT)
			if(prob(60))
				event_info = "You find resources onboard!"
				change_resource(rand(1,3))
				change_resource(rand(4,5))
			else
				event_info = "You don't find anything onboard..."
		if(ORION_TRAIL_COLLISION)
			event_info = ""
			event_desc = "You've collided with a passing meteor, breaching your hull!"
			if(prob(10))
				event_info = "Your cargo hold was breached!<BR>"
				change_resource(rand(4,5),-1)
			if(prob(5*length(settlers)))
				remove_settler(null,"was sucked out into the void!")
		if(ORION_TRAIL_ILLNESS)
			if(prob(15))
				event_info = ""
				var/num = 1
				if(prob(15))
					num++
				for(var/i=0;i<num;i++)
					remove_settler(null,"has succumbed to an illness.")
			else
				event_info = "Thankfully everybody was able to pull through."
		if(ORION_TRAIL_CARP)
			event_info = ""
			if(prob(100-25*length(settlers)))
				remove_settler(null, "was swarmed by carp and eaten!")
			change_resource(4)

		if(ORION_TRAIL_MUTINY)
			event_info = "Whispers grew more"
			if(num_traitors < length(settlers) - 1 && prob(55)) //gotta have at LEAST one non-traitor.
				num_traitors++
		if(ORION_TRAIL_MUTINY_ATTACK)
			//check to see if they just jump ship
			if(prob(30+(length(settlers)-num_traitors)*20))
				event_info = "The traitors decided to jump ship along with some of your supplies!<BR>"
				change_resource(4,-1 - (0.2 * num_traitors))
				change_resource(5,-1 - (0.1 * num_traitors))
				for(var/i=0;i<num_traitors;i++)
					remove_settler(rand(2,length(settlers)),"decided to up and leave!")
				num_traitors = 0
			else //alright. They wanna fight for the ship.
				event_info = "The traitors are charging you! Prepare your weapons!<BR>"
				var/list/traitors = list()
				for(var/i=0;i<num_traitors;i++)
					traitors += pick((settlers-traitors)-settlers[1])
				var/list/nontraitors = settlers-traitors
				while(length(nontraitors) && length(traitors))
					if(prob(50))
						var/t = rand(1,length(traitors))
						remove_settler(t,"was slain like the traitorous scum they were!")
						traitors -= traitors[t]
					else
						var/n = rand(1,length(nontraitors))
						remove_settler(n,"was slain in defense of the ship!")
						nontraitors -= nontraitors[n]
				settlers = nontraitors
				num_traitors = 0
		if(ORION_TRAIL_DISASTER)
			event_desc = "The [event] proved too difficult for you and your crew!"
			change_resource(4,-1)
			change_resource(pick(1,3),-1)
			change_resource(5,-1)
		if(ORION_TRAIL_STUCK)
			event_info = "You have [supplies["4"]] food left.<BR>"
			if(prob(10))
				event_info += "A passing ship has kindly donated fuel to you and wishes you luck on your journey.<BR>"
				change_resource(5,0.3)
	if(emagged)
		emag_effect(specific)
	event = specific

/obj/machinery/computer/arcade/orion_trail/proc/emag_effect(event)
	switch(event)
		if(ORION_TRAIL_RAIDERS)
			if(istype(usr,/mob/living/carbon))
				var/mob/living/carbon/M = usr
				if(prob(50))
					to_chat(usr, SPAN_WARNING("You hear battle shouts. The tramping of boots on cold metal. Screams of agony. The rush of venting air. Are you going insane?"))
					M.hallucination(50, 50)
				else
					to_chat(usr, SPAN_DANGER("Something strikes you from behind! It hurts like hell and feel like a blunt weapon, but nothing is there..."))
					M.take_organ_damage(10, 0)
			else
				to_chat(usr, SPAN_WARNING("The sounds of battle fill your ears..."))
		if(ORION_TRAIL_ILLNESS)
			if(istype(usr,/mob/living/carbon/human))
				var/mob/living/carbon/human/M = usr
				to_chat(M, SPAN_WARNING("An overpowering wave of nausea consumes over you. You hunch over, your stomach's contents preparing for a spectacular exit."))
				M.vomit()
			else
				to_chat(usr, SPAN_WARNING("You feel ill."))
		if(ORION_TRAIL_CARP)
			to_chat(usr, SPAN_DANGER(" Something bit you!"))
			var/mob/living/M = usr
			M.adjustBruteLoss(10)
		if(ORION_TRAIL_FLUX)
			if(istype(usr,/mob/living/carbon) && prob(75))
				var/mob/living/carbon/M = usr
				M.Weaken(3)
				src.visible_message("A sudden gust of powerful wind slams \the [M] into the floor!", "You hear a large fwooshing sound, followed by a bang.")
				M.take_organ_damage(10, 0)
			else
				to_chat(usr, SPAN_WARNING("A violent gale blows past you, and you barely manage to stay standing!"))
		if(ORION_TRAIL_MALFUNCTION)
			if(supplies["3"])
				return
			src.visible_message("\The [src]'s screen glitches out and smoke comes out of the back.")
			for(var/i=1;i<7;i++)
				supplies["[i]"] = max(0,supplies["[i]"] + rand(-10,10))
		if(ORION_TRAIL_COLLISION)
			if(prob(90) && !supplies["2"])
				var/turf/simulated/floor/F = src.loc
				F.ChangeTurf(/turf/space)
				src.visible_message(SPAN_DANGER("Something slams into the floor around \the [src], exposing it to space!"), "You hear something crack and break.")
			else
				src.visible_message("Something slams into the floor around \the [src] - luckily, it didn't get through!", "You hear something crack.")
		if(ORION_TRAIL_GAMEOVER)
			to_chat(usr, SPAN_DANGER(FONT_LARGE("You're never going to make it to Orion...")))
			var/mob/living/M = usr
			M.visible_message("\The [M] starts rapidly deteriorating.")
			close_browser(M, "window=arcade")
			for(var/i=0;i<10;i++)
				sleep(10)
				M.Stun(5)
				M.adjustBruteLoss(10)
				M.adjustFireLoss(10)
			usr.gib() //So that people can't cheese it and inject a lot of kelo/bicard before losing



/obj/machinery/computer/arcade/orion_trail/emag_act(mob/user)
	if(!emagged)
		newgame(1)
		src.updateUsrDialog()

/obj/machinery/computer/arcade/orion_trail/proc/win()
	src.visible_message("\The [src] plays a triumpant tune, stating 'CONGRATULATIONS, YOU HAVE MADE IT TO ORION.'")
	if(emagged)
		new /obj/item/orion_ship(src.loc)
		log_and_message_admins("made it to Orion on an emagged machine and got an explosive toy ship.")
	else
		prizevend()
	event = null
	src.updateUsrDialog()

#undef ORION_TRAIL_RAIDERS
#undef ORION_TRAIL_FLUX
#undef ORION_TRAIL_ILLNESS
#undef ORION_TRAIL_BREAKDOWN
#undef ORION_TRAIL_MUTINY
#undef ORION_TRAIL_MUTINY_ATTACK
#undef ORION_TRAIL_MALFUNCTION
#undef ORION_TRAIL_COLLISION
#undef ORION_TRAIL_SPACEPORT
#undef ORION_TRAIL_DISASTER
#undef ORION_TRAIL_CARP
#undef ORION_TRAIL_STUCK
#undef ORION_TRAIL_START
#undef ORION_TRAIL_GAMEOVER


#undef ORION_VIEW_MAIN
#undef ORION_VIEW_SUPPLIES
#undef ORION_VIEW_CREW
