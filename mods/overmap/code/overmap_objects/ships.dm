/obj/overmap/visitable/ship
	name = "spacecraft"
	scanner_desc = "Unknown spacefaring vessel."
	var/class = "spacefaring vessel"
	var/decl/ship_contact_class/contact_class = /decl/ship_contact_class

/obj/overmap/visitable/ship/sierra
	scanner_desc = @{"
<center><img src = bluentlogo.png></center></br><b>Property of NanoTrasen Corporation:</b>
[i]Registration[/i]: NSV Sierra
[i]Transponder[/i]: Transmitting (SCI), NanoTrasen
[b]Notice[/b]: A space object with wide of 121.2 meters, length of 214.5 meters and high near 14.3 meters. A Self Indentification Signal classifices \
	the target as NanoTrasen Science Vessel, a property of NanoTrasen Corporation."}
	contact_class = /decl/ship_contact_class/dagon

/obj/overmap/visitable/ship/landable/exploration_shuttle
	scanner_desc = @{"
<center><img src = bluentlogo.png></center></br><b>Property of NanoTrasen Corporation:</b>
[i]Registration[/i]: NSS Charon
[i]Transponder[/i]: Transmitting (CIV), non-hostile
[b]Notice[/b]: NanoTrasen Shuttle"}
	contact_class = /decl/ship_contact_class/nt_sshuttle

/obj/overmap/visitable/ship/landable/guppy
	scanner_desc = @{"
<center><img src = bluentlogo.png></center></br><b>Property of NanoTrasen Corporation:</b>
[i]Registration[/i]: NSS Guppy
[i]Transponder[/i]: Transmitting (CIV), non-hostile
[b]Notice[/b]: NanoTrasen Shuttle"}
	contact_class = /decl/ship_contact_class/nt_sshuttle

/obj/overmap/visitable/ship/landable/merc
	scanner_desc = @{"[i]Registration[/i]: UNKNOWN
[i]Class[/i]: UNKNOWN
[i]Transponder[/i]: None Detected
[b]Notice[/b]: Unregistered vessel"}
	contact_class = /decl/ship_contact_class/shuttle

/obj/overmap/visitable/ship/casino
	scanner_desc = @{"[i]Registration[/i]: Passenger liner
[i]Class[/i]: Small ship (Low Displacement)
[i]Transponder[/i]: Transmitting (CIV), non-hostile
[b]Notice[/b]: Sensors detect an undamaged vessel without any signs of activity"}
	contact_class = /decl/ship_contact_class/ship

/obj/overmap/visitable/ship/errant_pisces
	scanner_desc = @{"[i]Registration[/i]: XCV Ahab's Harpoon
[i]Class[/i]: UNKNOWN
[i]Transponder[/i]: Transmitting (CIV)
[b]Notice[/b]: Sensors detect civilian vessel with unusual signs of life aboard"}


/obj/overmap/visitable/ship/scavver_gantry
	scanner_desc = @{"[i]Registration[/i]: UNKNOWN
[i]Class[/i]: UNKNOWN
[i]Transponder[/i]: None Detected
[b]Notice[/b]: Sensor array detects a medium-sized vessel of irregular shape. Vessel origin is unidentifiable"}

/obj/overmap/visitable/ship/landable/vox_ship
	scanner_desc = @{"[i]Registration[/i]: UNKNOWN
[i]Class[/i]: UNKNOWN
[i]Transponder[/i]: None Detected
[b]Notice[/b]: Sensor array detects a medium-sized vessel of irregular shape. Unknown origin"}

/obj/overmap/visitable/ship/yacht
	scanner_desc = @{"[i]Registration[/i]: Aronai Sieyes
[i]Class[/i]: Small Ship (Low Displacement)
[i]Transponder[/i]: None Detected
[b]Notice[/b]: Many lifeforms lifesigns detected"}
	contact_class = /decl/ship_contact_class/ship

/obj/overmap/visitable/ship/farfleet
	scanner_desc = @{"[i]Registration[/i]: ICCGN Farfleet Reconnaissance Craft
[i]Transponder[/i]: Transmitting (MIL), ICCG
[b]Notice[/b]: Warning! Slight traces of a cloaking device are present. This Craft has ICCGN Farfleet designation. Future scanning of ship internals blocked."}
	contact_class = /decl/ship_contact_class/gagarin

/obj/overmap/visitable/ship/landable/snz
	scanner_desc = @{"[i]Registration[/i]: ICCGN Speedboat
[i]Class[/i]: Shuttle
[i]Transponder[/i]: Transmitting (MIL), ICCG
[b]Notice[/b]: SNZ-350 Speedboat. Space and atmosphere assault craft. The standard mass military production model of the Shipyards of Novaya Zemlya."}
	contact_class = /decl/ship_contact_class/destroyer_escort

/obj/overmap/visitable/ship/liberia
	scanner_desc = @{"[i]Registration[/i]: FTU Liberia
[i]Transponder[/i]: Transmitting (CIV), non-hostile
[b]Notice[/b]: Independent trader vessel "}
	contact_class = /decl/ship_contact_class/merchant

/obj/overmap/visitable/ship/landable/mule
	scanner_desc = @{"[i]Registration[/i]: PRIVATE
[i]Class[/i]: Small Shuttle
[i]Transponder[/i]: Transmitting (CIV), non-hostile
[b]Notice[/b]: Small private vessel"}

/obj/overmap/visitable/ship/patrol
	scanner_desc = @{"
		<center><img src = FleetLogo.png></center><br>
		<i>Registration</i>: SCGDF Multipurpose Patrol Craft<br>
		<i>Transponder</i>: Transmitting (MIL), SCG<br>
		<b>Notice</b>: Nagashino-class Multipurpose Patrol Craft. Fine example of human fleet brilliant technologies with 5th Fleet designation and massive heat footprint."}
	contact_class = /decl/ship_contact_class/nagashino

/obj/overmap/visitable/ship/landable/reaper
	scanner_desc = @{"
		<center><img src = FleetLogo.png></center><br>
		<i>Registration</i>: SCGDF Shuttle<br>
		<i>Class</i>: Shuttle<br>
		<i>Transponder</i>: Transmitting (MIL), SCG<br>
		<b>Notice</b>: A heavily modified military gunboat of particular design. More of the dropship now, scanner detects heavy alteration to the hull of the vessel and no designation"}