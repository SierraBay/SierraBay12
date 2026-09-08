
/obj/machinery/computer/arcade/battle/Initialize()
	. = ..()
	SetupGame()

/obj/machinery/computer/arcade/battle/proc/SetupGame()
	var/name_action
	var/name_part1
	var/name_part2

	name_action = pick("Defeat ", "Annihilate ", "Save ", "Strike ", "Stop ", "Destroy ", "Robust ", "Romance ", "Pwn ", "Own ", "Ban ")

	name_part1 = pick("the Automatic ", "Farmer ", "Lord ", "Professor ", "the Cuban ", "the Evil ", "the Dread King ", "the Space ", "Lord ", "the Great ", "Duke ", "General ")
	name_part2 = pick("Melonoid", "Murdertron", "Sorcerer", "Ruin", "Jeff", "Ectoplasm", "Crushulon", "Uhangoid", "Vhakoid", "Peteoid", "slime", "Griefer", "ERPer", "Lizard Man", "Unicorn", "Bloopers")

	src.enemy_name = replacetext((name_part1 + name_part2), "the ", "")
	src.SetName((name_action + name_part1 + name_part2))


/obj/machinery/computer/arcade/battle/interact(mob/user)
	user.set_machine(src)
	var/dat = "<html><head><style>"
	dat += "body { background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%); color: #e6e6e6; font-family: 'Courier New', monospace; margin: 0; padding: 20px; }"
	dat += ".container { max-width: 600px; margin: 0 auto; background: rgba(0, 0, 0, 0.7); border-radius: 15px; padding: 20px; border: 2px solid #4cc9f0; box-shadow: 0 0 20px rgba(76, 201, 240, 0.5); }"
	dat += ".header { text-align: center; color: #4cc9f0; text-shadow: 0 0 10px rgba(76, 201, 240, 0.8); margin-bottom: 20px; }"
	dat += ".enemy-name { font-size: 24px; color: #f72585; text-shadow: 0 0 8px rgba(247, 37, 133, 0.8); }"
	dat += ".message { background: rgba(255, 255, 255, 0.1); padding: 15px; border-radius: 10px; margin: 15px 0; text-align: center; font-size: 18px; border: 1px solid #f72585; }"
	dat += ".stats { display: flex; justify-content: space-around; margin: 20px 0; }"
	dat += ".stat-box { background: rgba(76, 201, 240, 0.2); padding: 10px; border-radius: 8px; text-align: center; width: 150px; border: 1px solid #4cc9f0; }"
	dat += ".stat-value { font-size: 20px; font-weight: bold; color: #f72585; }"
	dat += ".actions { text-align: center; margin: 20px 0; }"
	dat += ".action-btn { background: linear-gradient(45deg, #f72585, #b5179e); color: white; border: none; padding: 12px 20px; margin: 5px; border-radius: 25px; cursor: pointer; font-size: 16px; font-family: 'Courier New', monospace; transition: all 0.3s; text-decoration: none; display: inline-block; }"
	dat += ".action-btn:hover { transform: scale(1.05); box-shadow: 0 0 15px rgba(247, 37, 133, 0.8); }"
	dat += ".action-btn:disabled { background: #666; cursor: not-allowed; transform: none; box-shadow: none; }"
	dat += ".game-over { background: rgba(247, 37, 133, 0.3); padding: 20px; border-radius: 10px; text-align: center; margin: 20px 0; border: 2px solid #f72585; }"
	dat += ".health-bar { height: 20px; background: #333; border-radius: 10px; margin: 10px 0; overflow: hidden; }"
	dat += ".health-fill { height: 100%; background: linear-gradient(90deg, #ff6b6b, #f72585); border-radius: 10px; transition: width 0.5s; }"
	dat += ".magic-bar { height: 20px; background: #333; border-radius: 10px; margin: 10px 0; overflow: hidden; }"
	dat += ".magic-fill { height: 100%; background: linear-gradient(90deg, #4cc9f0, #4895ef); border-radius: 10px; transition: width 0.5s; }"
	dat += "a { color: #4cc9f0; text-decoration: none; }"
	dat += "a:hover { text-decoration: underline; }"
	dat += "</style></head><body>"
	dat += "<div class='container'>"

	dat += "<div class='header'><h2>ARCADE BATTLE</h2></div>"
	dat += "<div class='enemy-name'><h3>[src.enemy_name]</h3></div>"

	dat += "<div class='message'><h4>[src.temp]</h4></div>"

	dat += "<div class='stats'>"
	dat += "<div class='stat-box'>"
	dat += "<div>PLAYER HP</div>"
	dat += "<div class='stat-value'>[src.player_hp]</div>"
	dat += "<div class='health-bar'><div class='health-fill' style='width: [min(100, src.player_hp * 3.33)]%'></div></div>"
	dat += "</div>"

	dat += "<div class='stat-box'>"
	dat += "<div>MAGIC POWER</div>"
	dat += "<div class='stat-value'>[src.player_mp]</div>"
	dat += "<div class='magic-bar'><div class='magic-fill' style='width: [min(100, src.player_mp * 10)]%'></div></div>"
	dat += "</div>"

	dat += "<div class='stat-box'>"
	dat += "<div>ENEMY HP</div>"
	dat += "<div class='stat-value'>[src.enemy_hp]</div>"
	dat += "<div class='health-bar'><div class='health-fill' style='width: [min(100, src.enemy_hp * 2.22)]%'></div></div>"
	dat += "</div>"
	dat += "</div>"

	dat += "<div class='actions'>"
	if (src.gameover)
		dat += "<a href='byond://?src=\ref[src];newgame=1' class='action-btn'>NEW GAME</a>"
	else
		dat += "<a href='byond://?src=\ref[src];attack=1' class='action-btn'>ATTACK</a> | "
		dat += "<a href='byond://?src=\ref[src];heal=1' class='action-btn'>HEAL</a> | "
		dat += "<a href='byond://?src=\ref[src];charge=1' class='action-btn'>RECHARGE</a>"
	dat += "</div>"

	if (src.gameover)
		dat += "<div class='game-over'>GAME OVER!</div>"
	dat += "</div></body></html>"

	show_browser(user, dat, "window=arcade;size=600x800")
	onclose(user, "arcade")
	return

/obj/machinery/computer/arcade/battle/CanUseTopic(mob/user, datum/topic_state/state, href_list)
	if((blocked || gameover) && href_list && (href_list["attack"] || href_list["heal"] || href_list["charge"]))
		return min(..(), STATUS_UPDATE)
	return ..()

/obj/machinery/computer/arcade/battle/OnTopic(user, href_list)
	set waitfor = 0

	if (href_list["close"])
		close_browser(user, "window=arcade")
		return TOPIC_HANDLED

	if (href_list["attack"])
		src.blocked = 1
		var/attackamt = rand(2,6)
		src.temp = "You attack for [attackamt] damage!"
		playsound(src, pick('mods/newUI/sound/attack1.ogg', 'mods/newUI/sound/attack2.ogg'), 50, 1)
		if(turtle > 0)
			turtle--
		src.enemy_hp -= attackamt

		. = TOPIC_REFRESH
		sleep(10)
		src.arcade_action(user)

	else if (href_list["heal"])
		src.blocked = 1
		var/pointamt = rand(1,3)
		var/healamt = rand(6,8)
		src.temp = "You use [pointamt] magic to heal for [healamt] damage!"
		playsound(src, pick('mods/newUI/sound/heal1.ogg', 'mods/newUI/sound/heal2.ogg'), 50, 1)
		turtle++

		src.player_mp -= pointamt
		src.player_hp += healamt
		src.blocked = 1

		. = TOPIC_REFRESH
		sleep(10)
		src.arcade_action(user)

	else if (href_list["charge"])
		src.blocked = 1
		var/chargeamt = rand(4,7)
		src.temp = "You regain [chargeamt] points"
		playsound(src, pick('mods/newUI/sound/-mana2.ogg', 'mods/newUI/sound/-mana1.ogg'), 50, 1)
		src.player_mp += chargeamt
		if(turtle > 0)
			turtle--

		. = TOPIC_REFRESH
		sleep(10)
		src.arcade_action(user)

	else if (href_list["newgame"]) //Reset everything
		temp = "New Round"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = 0
		turtle = 0
		if(emagged)
			emagged = FALSE
			SetupGame()
		. = TOPIC_REFRESH

/obj/machinery/computer/arcade/battle/proc/arcade_action(user)
	if ((src.enemy_mp <= 0) || (src.enemy_hp <= 0))
		if(!gameover)
			src.gameover = 1
			playsound(src, pick('mods/newUI/sound/e_death.ogg'), 50, 1)
			src.temp = "[src.enemy_name] has fallen! Rejoice!"

			if(emagged)
				new /obj/spawner/newbomb/timer/syndicate(src.loc)
				new /obj/item/clothing/head/collectable/petehat(src.loc)
				log_and_message_admins("has outbombed Cuban Pete and been awarded a bomb.")
				SetupGame()
				emagged = FALSE
			else
				src.prizevend()

	else if (emagged && (turtle >= 4))
		var/boomamt = rand(5,10)
		src.temp = "[src.enemy_name] throws a bomb, exploding you for [boomamt] damage!"
		playsound(src, pick('mods/newUI/sound/gethit1.ogg', 'mods/newUI/sound/gethit2.ogg'), 50, 1)
		src.player_hp -= boomamt

	else if ((src.enemy_mp <= 5) && (prob(70)))
		var/stealamt = rand(2,3)
		src.temp = "[src.enemy_name] steals [stealamt] of your power!"
		playsound(src, pick('mods/newUI/sound/-mana1.ogg', 'mods/newUI/sound/-mana2.ogg'), 50, 1)
		src.player_mp -= stealamt
		interface_interact(user)

		if (src.player_mp <= 0)
			src.gameover = 1
			sleep(10)
			playsound(src, pick('mods/newUI/sound/p_death.ogg'), 50, 1)
			src.temp = "You have been drained! GAME OVER"
			if(emagged)
				explode()
			else

	else if ((src.enemy_hp <= 10) && (src.enemy_mp > 4))
		src.temp = "[src.enemy_name] heals for 4 health!"
		src.enemy_hp += 4
		src.enemy_mp -= 4
		playsound(src, pick('mods/newUI/sound/heal1.ogg', 'mods/newUI/sound/heal2.ogg'), 50, 1)
	else
		var/attackamt = rand(3,6)
		src.temp = "[src.enemy_name] attacks for [attackamt] damage!"
		src.player_hp -= attackamt
		playsound(src, pick('mods/newUI/sound/gethit1.ogg', 'mods/newUI/sound/gethit2.ogg'), 50, 1)

	if ((src.player_mp <= 0) || (src.player_hp <= 0))
		src.gameover = 1
		src.temp = "You have been crushed! GAME OVER"
		interface_interact(user)
		playsound(src, pick('mods/newUI/sound/p_death.ogg'), 50, 1)
		if(emagged)
			explode()
		else

	src.blocked = 0

/obj/machinery/computer/arcade/proc/explode()
	explosion(loc, 3, EX_ACT_HEAVY)
	qdel(src)

/obj/machinery/computer/arcade/battle/emag_act(charges, mob/user)
	if(!emagged)
		temp = "If you die in the game, you die for real!"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = 0
		blocked = 0
		emagged = TRUE

		enemy_name = "Cuban Pete"
		name = "Outbomb Cuban Pete"

		attack_hand(user)
		return 1
