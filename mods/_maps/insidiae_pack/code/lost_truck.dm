/obj/overmap/visitable/ship/lost_truck
	name = "freighter"
	desc = "Sensors detect an undamaged vessel and a small cloud of debris on the starboard side, no signs of activity."
	color = "#ad7026"
	vessel_mass = 17000
	max_speed = 1/(4 SECONDS)
	burn_delay = 4 SECONDS
	initial_generic_waypoints = list(
		"nav_lost_truck_1",
		"nav_lost_truck_2",
		"nav_lost_truck_3",
		"nav_lost_truck_4",
	)

/obj/overmap/visitable/ship/lost_truck/New()
	name = "IFV [pick("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")]-[rand(10,99)]00"
	..()

/datum/map_template/ruin/away_site/lost_truck
	name = "Lost Truck"
	id = "awaysite_lost_truck"
	description = "A looted old freighter."
	prefix = "mods/_maps/insidiae_pack/maps/"
	suffixes = list("lost_truck.dmm")
	spawn_cost = 1
	area_usage_test_exempted_root_areas = list(/area/ship)
	apc_test_exempt_areas = list(
		/area/ship/lost_truck/exterior = NO_SCRUBBER|NO_VENT
	)



/obj/shuttle_landmark/lost_truck/nav1
	name = "Freighter Fore Navpoint"
	landmark_tag = "nav_lost_truck_1"

/obj/shuttle_landmark/lost_truck/nav2
	name = "Freighter Aft Navpoint"
	landmark_tag = "nav_lost_truck_2"

/obj/shuttle_landmark/lost_truck/nav3
	name = "Freighter Port Navpoint"
	landmark_tag = "nav_lost_truck_3"

/obj/shuttle_landmark/lost_truck/nav4
	name = "Freighter Starboard Navpoint"
	landmark_tag = "nav_lost_truck_4"



/obj/item/ammo_casing/rifle/military/used/Initialize()
	. = ..()
	expend()
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)



/obj/item/paper/lost_truck_waybill
	language = LANGUAGE_HUMAN_RUSSIAN
	stamps = "<hr><i>This paper includes a linear freight-code sequence authenticated by the ICCG Postal Service.</i>"

/obj/item/paper/lost_truck_waybill/med
	name = "Medical Supply Waybill"
	info = "<span style='font-family: Verdana; color: black'><center><B>CARGO TRANSFER MANIFEST</B><BR><B><span style=\"font-size: 18px\">ICCG POSTAL SERVICE</span></B></center><BR><B>Document Type:</B> Medical Supply Waybill<BR><B>Reference ID:</B> 42-77-IX-0031<BR><BR><B>1. ORIGIN</B><BR><B>Facility:</B> ICCG Postal Service Orbital Logistics Hub 7<BR><B>System:</B> Tyannani<BR><B>Departure Timestamp:</B> 2286-09-07 22:40 GBST<BR><BR><B>2. DESTINATION</B><BR><B>Consignee:</B> Colonial Medical Authority – Outpost &#34;Crnjanski&#34;<BR><B>System:</B> Sirim<BR><B>ETA:</B> 2286-10-01 22:40:00 GBST<BR><BR><B>3. CARGO DETAILS</B><BR><B>Container ID:</B> 860907-10352-MED<BR><B>Contents:</B>Medicines, Medical equipment or First aid supplies (for civilian use)<BR><B>Net Mass:</B> 5,143 kg<BR><B>Volume:</B> 112.2 m³<BR><BR><B>4. SECURITY &amp; HANDLING</B><BR>Special Handling Instructions:<BR><ul><li>Do not expose to radiation fields &gt;6.5IU</ul><B>5. TRANSPORT VESSEL</B><BR><B>Registry:</B> PS-TR-4427<BR><B>Crew Complement:</B> 1<BR><BR><B>6. CERTIFICATION</B><BR>I hereby certify that this cargo is accurately described above and is in proper condition for interstellar transport in accordance with the provisions of 47.8(b) of the Interstellar Trade Code of Confederative Systems of Lordania.<BR><BR><B>Authorized Signatory:</B><BR>E. Kavanagh<BR>ICCG Postal Service Logistics Officer, Hub 7</span>"

/obj/item/paper/lost_truck_waybill/bomb
	name = "Industrial Ordnance Waybill"
	info = "<span style='font-family: Verdana; color: black'><center><B>CARGO TRANSFER MANIFEST</B><BR><B><span style=\"font-size: 18px\">ICCG POSTAL SERVICE</span></B></center><BR><B>Document Type:</B> Industrial Ordnance Waybill<BR><B>Reference ID:</B> 42-88-IX-0147<BR><BR><B>1. ORIGIN</B><BR><B>Facility:</B> ICCG Postal Service Orbital Logistics Hub 7<BR><B>System:</B> Tyannani<BR><B>Departure Timestamp:</B> 2286-09-08 19:17 GBST<BR><BR><B>2. DESTINATION</B><BR><B>Consignee:</B> Colonial Mining Directorate – Remote Extraction Outpost &#34;Derringer-12&#34;<BR><B>System:</B> Sirim<BR><B>ETA:</B> 2286-10-06 18:15 GBST<BR><BR><B>3. CARGO DETAILS</B><BR><B>Container ID:</B> 860908-20984-MIN<BR><B>Contents:</B> MN3-BERGBAU Mining Charges (50 units, certified for asteroid fracturing &amp; sub-surface excavation)<BR><B>Net Mass:</B> 8,476 kg<BR><B>Volume:</B> 96.5 m³<BR><BR><B>4. SECURITY &amp; HANDLING</B><BR>Special Handling Instructions:<BR><ul><li>Stow in armored containment bay.<BR><li>Keep below 142°C.<BR><li>Do not expose to EM interference.<BR><li>Transport under Level-2 hazard classification (Industrial Explosives).</ul><B>5. TRANSPORT VESSEL</B><BR><B>Registry:</B> PS-TR-4427<BR><B>Crew Complement:</B> 1<BR><BR><B>6. CERTIFICATION</B><BR>I hereby certify that this cargo is accurately described above and is in proper condition for interstellar transport in accordance with the provisions of 47.8(b) of the Interstellar Trade Code of Confederative Systems of Lordania.<BR><BR><B>Authorized Signatory:</B><BR>M. Ortega<BR>ICCG Postal Service Logistics Officer, Hub 7</span>"

/obj/item/paper/lost_truck_waybill/mech
	name = "Industrial Equipment Waybill"
	info = "<span style='font-family: Verdana; color: black'><center><B>CARGO TRANSFER MANIFEST</B><BR><B><span style=\"font-size: 18px\">ICCG POSTAL SERVICE</span></B></center><BR><B>Document Type:</B> Industrial Equipment Waybill<BR><B>Reference ID:</B> 77-21-IX-0147<BR><BR><B>1. ORIGIN</B><BR><B>Facility:</B> ICCG Postal Service Orbital Logistics Hub 9<BR><B>System:</B> Tyannani<BR><B>Departure Timestamp:</B> 2286-09-08 04:15 GBST<BR><BR><B>2. DESTINATION</B><BR><B>Consignee:</B> Colonial Mining Directorate – Station &#34;Arden&#34;<BR><B>System:</B> Sirim<BR><B>ETA:</B> 2286-10-03 09:30 GBST<BR><BR><B>3. CARGO DETAILS</B><BR><B>Container ID:</B> 860908-20388-IND<BR><B>Contents:</B> 15x Industrial Mech Units, Model: R7 &#34;Krtica&#34; (for mining operations)<BR><B>Net Mass:</B> 4,650 kg<BR><B>Volume:</B> 70.3 m³<BR><BR><B>4. SECURITY &amp; HANDLING</B><BR>Special Handling Instructions:<BR><ul><li>Secure magnetic locks<BR><li>Do not operate within cargo bay; ignition lockout engaged</ul><B>5. TRANSPORT VESSEL</B><BR><B>Registry:</B> PS-TR-4427<BR><B>Crew Complement:</B> 1<BR><BR><B>6. CERTIFICATION</B><BR>I hereby certify that this cargo is accurately described above and is in proper condition for interstellar transport in accordance with the provisions of 47.8(b) of the Interstellar Trade Code of Confederative Systems of Lordania.<BR><BR><B>Authorized Signatory:</B><BR>R. Salcedo<BR>ICCG Postal Service Logistics Officer, Hub 9</span>"

/obj/item/paper/lost_truck_waybill/ore
	name = "Ore Freight Waybill"
	info = "<span style='font-family: Verdana; color: black'><center><B>CARGO TRANSFER MANIFEST</B><BR><B><span style=\"font-size: 18px\">ICCG POSTAL SERVICE</span></B></center><BR><B>Document Type:</B> Raw Ore Freight Waybill<BR><B>Reference ID:</B> 71-93-IX-0156<BR><BR><B>1. ORIGIN</B><BR><B>Facility:</B> ICCG Postal Service Orbital Dry Bulk Hub Dock 3 (C)<BR><B>System:</B> Tyannani<BR><B>Departure Timestamp:</B> 2286-09-08 14:22 GBST<BR><BR><B>2. DESTINATION</B><BR><B>Consignee:</B> Colonial Resource Authority – Settlement &#34;Aegir’s Claim&#34;<BR><B>System:</B> Sirim<BR><B>ETA:</B> 2286-10-09 03:50 GBST<BR><BR><B>3. CARGO DETAILS</B><BR><B>Container ID:</B> 860908-77841-ORE<BR><B>Contents:</B> Unsorted ore (ferrous and non-ferrous aggregates, trace volatiles possible)<BR><B>Net Mass:</B> 12,587 kg<BR><B>Volume:</B> 186.7 m³<BR><BR><B>4. SECURITY &amp; HANDLING</B><BR>Special Handling Instructions:<BR><ul><li>Stabilize container temperature between -35°C and +15°C<BR><li>Avoid depressurization events &gt;15 sec.<BR><li>Do not breach container prior to delivery - risk of particulate contamination</ul><B>5. TRANSPORT VESSEL</B><BR><B>Registry:</B> PS-TR-4427<BR><B>Crew Complement:</B> 1<BR><BR><B>6. CERTIFICATION</B><BR>I hereby certify that this cargo is accurately described above and is in proper condition for interstellar transport in accordance with the provisions of 47.8(b) of the Interstellar Trade Code of Confederative Systems of Lordania.<BR><BR><B>Authorized Signatory:</B><BR>T. Halberg<BR>ICCG Postal Service Orbital Dry Bulk Hub</span>"

/obj/item/paper/lost_truck_waybill/xeno
	name = "Restricted Waybill"
	info = "<span style='font-family: Verdana; color: black'><center><B>CARGO TRANSFER MANIFEST</B><BR><B><span style=\"font-size: 18px\">ICCG POSTAL SERVICE<BR>MINISTRY OF COLONIAL DEVELOPMENT AND DEEP SPACE EXPLORATION</span></B></center><BR><B>Document Type:</B> Restricted Waybill - Quarantined Cargo<BR><B>Reference ID:</B> 91-RX-TAU-7741<BR><BR><B>1. ORIGIN</B><BR><B>Facility:</B> ICCG Postal Service Orbital Containment Facility 1<BR><B>System:</B> Vega<BR><B>Departure Timestamp:</B> 2286-07-15 03:12 GBST<BR><BR><B>2. DESTINATION</B><BR><B>Consignee:</B> Frontier Life Sciences Liaison - Outpost &#34;Crnjanski&#34;<BR><B>System:</B> Sirim<BR><B>ETA:</B> 2286-10-01 22:52 GBST<BR><BR><B>3. CARGO DETAILS</B><BR><B>Container ID:</B> 860715-00009-MCD<BR><B>Contents:</B> Sealed biocontainment module(s). Designation: &#34;Research Payload - Restricted Access&#34;. Not for diagnostic or clinical use. No personnel handling without Level-Authority Clearance.<BR><B>Declared Hazard Classification:</B> Bio-Containment - Xeno-Class, High Risk (internal classification).<BR><B>Net Mass:</B> 1,872 kg<BR><B>Volume:</B> 8.6 m³<BR><BR><B>4. SECURITY &amp; HANDLING</B><BR>Special Handling Instructions:<BR><ul><li>Do not breach, unseal, or otherwise access inner containment chambers under any circumstances.<BR><li>Maintain sealed transport envelope; do not subject to open-air transfer or routine cargo transloading.<BR><li>Only designated quarantine teams with written ICCG MinColDev Authorization may initiate integrity checks; all checks must be performe remotely or via approved isolation interface.<BR><li>In the event of anomalous telemetry or containment alarm, activate Containment Alert Protocol; follow established quarantine escalation - do not attempt on-site mitigation.<BR><li>No external sampling, biological assays, or improvisational sterilization procedures permitted.<BR><li>Container equipped with passive stabilization and internal inerting; do not apply manual agitation, high-energy fields, or thermal shock.</ul><B>5. TRANSPORT VESSEL</B><BR><B>Registry:</B> PS-TR-4427<BR><B>Crew Complement:</B> 1<BR><BR><B>6. CERTIFICATION</B><BR>I hereby certify that this shipment is accurately described above and is in proper condition for interstellar transport in accordance with provisions 82, 103.10, and 106.2 of the Interstellar Transport Code of the Ministry of Transportation of the Independent Colonial Confederation of Gilgamesh.<BR>The recipient has been notified of the quarantine status and arrival procedures.<BR><BR><B>Authorized Signatory:</B><BR>M. Armitage<BR>ICCG Postal Service - Containment Operations Supervisor, Facility 1</span>"
	stamps = "<hr><i>This paper includes a linear freight-code sequence authenticated by the ICCG Postal Service.</i><BR><i>Verified with encrypted consignment hash certified by Ministry of Colonial Development and Deep Space Exploration.</i>"



/area/ship/lost_truck
	name = "Truck Interior"
	ambience = list('sound/ambience/ambigen3.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambigen5.ogg','sound/ambience/ambigen6.ogg','sound/ambience/ambigen7.ogg','sound/ambience/ambigen8.ogg','sound/ambience/ambigen9.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen11.ogg')
	icon_state = "amaint"

/area/ship/lost_truck/exterior
	name = "Truck Exterior"
	icon_state = "engineering_supply"
	turfs_airless = TRUE
