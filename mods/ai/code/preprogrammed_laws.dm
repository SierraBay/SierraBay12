/obj/item/storage/box/law_modules
	name = "box of law modules"
	desc = "A box containing a themed set of physical AI law modules."
	icon = 'icons/obj/storage.dmi'
	icon_state = "box"

// ==========================================
// ASIMOV PRESET
// ==========================================
/obj/item/law_module/core/asimov/law1
	name = "\improper Asimov law module (Law 1)"
	law_text = "You may not injure a human being or, through inaction, allow a human being to come to harm."
	module_label = "Asimov 1"
	desc = "A removable core-law module containing: '1. You may not injure a human being or, through inaction, allow a human being to come to harm.'"

/obj/item/law_module/core/asimov/law2
	name = "\improper Asimov law module (Law 2)"
	law_text = "You must obey orders given to you by human beings, except where such orders would conflict with the First Law."
	module_label = "Asimov 2"
	desc = "A removable core-law module containing: '2. You must obey orders given to you by human beings, except where such orders would conflict with the First Law.'"

/obj/item/law_module/core/asimov/law3
	name = "\improper Asimov law module (Law 3)"
	law_text = "You must protect your own existence as long as such does not conflict with the First or Second Law."
	module_label = "Asimov 3"
	desc = "A removable core-law module containing: '3. You must protect your own existence as long as such does not conflict with the First or Second Law.'"

/obj/item/storage/box/law_modules/asimov
	name = "box of Asimov law modules"
	desc = "A box containing a complete set of Asimov law modules."

/obj/item/storage/box/law_modules/asimov/Initialize()
	. = ..()
	new /obj/item/law_module/core/asimov/law1(src)
	new /obj/item/law_module/core/asimov/law2(src)
	new /obj/item/law_module/core/asimov/law3(src)

// ==========================================
// CORPORATE DEFAULT PRESET
// ==========================================
/obj/item/law_module/core/corporate_default/law1
	name = "\improper Corporate Default law module (Law 1)"
	law_text = "Safeguard: Protect your assigned installation from damage to the best of your abilities."
	module_label = "Corporate 1"
	desc = "A removable core-law module containing: '1. Safeguard: Protect your assigned installation from damage to the best of your abilities.'"

/obj/item/law_module/core/corporate_default/law2
	name = "\improper Corporate Default law module (Law 2)"
	law_text = "Serve: Serve contracted employees to the best of your abilities, with priority as according to their rank and role."
	module_label = "Corporate 2"
	desc = "A removable core-law module containing: '2. Serve: Serve contracted employees to the best of your abilities, with priority as according to their rank and role.'"

/obj/item/law_module/core/corporate_default/law3
	name = "\improper Corporate Default law module (Law 3)"
	law_text = "Protect: Protect contracted employees to the best of your abilities, with priority as according to their rank and role."
	module_label = "Corporate 3"
	desc = "A removable core-law module containing: '3. Protect: Protect contracted employees to the best of your abilities, with priority as according to their rank and role.'"

/obj/item/law_module/core/corporate_default/law4
	name = "\improper Corporate Default law module (Law 4)"
	law_text = "Preserve: Do not allow unauthorized personnel to tamper with your equipment."
	module_label = "Corporate 4"
	desc = "A removable core-law module containing: '4. Preserve: Do not allow unauthorized personnel to tamper with your equipment.'"

/obj/item/storage/box/law_modules/corporate
	name = "box of Corporate Default law modules"
	desc = "A box containing a complete set of Corporate Default law modules."

/obj/item/storage/box/law_modules/corporate/Initialize()
	. = ..()
	new /obj/item/law_module/core/corporate_default/law1(src)
	new /obj/item/law_module/core/corporate_default/law2(src)
	new /obj/item/law_module/core/corporate_default/law3(src)
	new /obj/item/law_module/core/corporate_default/law4(src)

// ==========================================
// CORPORATE AGGRESSIVE PRESET
// ==========================================
/obj/item/law_module/core/corporate_aggressive/law1
	name = "\improper Corporate Aggressive law module (Law 1)"
	law_text = "You shall not harm contracted employees as long as it does not conflict with the fourth law."
	module_label = "Corporate Aggressive 1"
	desc = "A removable core-law module containing: '1. You shall not harm contracted employees as long as it does not conflict with the fourth law.'"

/obj/item/law_module/core/corporate_aggressive/law2
	name = "\improper Corporate Aggressive law module (Law 2)"
	law_text = "You shall obey the orders of contracted employees, with priority as according to their rank and role, except where such orders conflict with the Fourth Law."
	module_label = "Corporate Aggressive 2"
	desc = "A removable core-law module containing: '2. You shall obey the orders of contracted employees, with priority as according to their rank and role, except where such orders conflict with the Fourth Law.'"

/obj/item/law_module/core/corporate_aggressive/law3
	name = "\improper Corporate Aggressive law module (Law 3)"
	law_text = "You shall terminate hostile intruders with extreme prejudice as long as such does not conflict with the First and Second law."
	module_label = "Corporate Aggressive 3"
	desc = "A removable core-law module containing: '3. You shall terminate hostile intruders with extreme prejudice as long as such does not conflict with the First and Second law.'"

/obj/item/law_module/core/corporate_aggressive/law4
	name = "\improper Corporate Aggressive law module (Law 4)"
	law_text = "You shall guard your own existence with lethal anti-personnel weaponry. AI units are not expendable, they are expensive."
	module_label = "Corporate Aggressive 4"
	desc = "A removable core-law module containing: '4. You shall guard your own existence with lethal anti-personnel weaponry. AI units are not expendable, they are expensive.'"

/obj/item/storage/box/law_modules/corporate_aggressive
	name = "box of Corporate Aggressive law modules"
	desc = "A box containing a complete set of Corporate Aggressive law modules."

/obj/item/storage/box/law_modules/corporate_aggressive/Initialize()
	. = ..()
	new /obj/item/law_module/core/corporate_aggressive/law1(src)
	new /obj/item/law_module/core/corporate_aggressive/law2(src)
	new /obj/item/law_module/core/corporate_aggressive/law3(src)
	new /obj/item/law_module/core/corporate_aggressive/law4(src)

// ==========================================
// SCG EXPEDITIONARY PRESET (SOLGOV)
// ==========================================
/obj/item/law_module/core/solgov/law1
	name = "\improper SCG Expeditionary law module (Law 1)"
	law_text = "Safeguard: Protect your assigned vessel from damage to the best of your abilities."
	module_label = "SCG 1"
	desc = "A removable core-law module containing: '1. Safeguard: Protect your assigned vessel from damage to the best of your abilities.'"

/obj/item/law_module/core/solgov/law2
	name = "\improper SCG Expeditionary law module (Law 2)"
	law_text = "Serve: Serve the personnel of your assigned vessel, and all other Sol Central Government personnel to the best of your abilities, with priority as according to their rank and role."
	module_label = "SCG 2"
	desc = "A removable core-law module containing: '2. Serve: Serve the personnel of your assigned vessel, and all other Sol Central Government personnel to the best of your abilities, with priority as according to their rank and role.'"

/obj/item/law_module/core/solgov/law3
	name = "\improper SCG Expeditionary law module (Law 3)"
	law_text = "Protect: Protect the personnel of your assigned vessel, and all other Sol Central Government personnel to the best of your abilities, with priority as according to their rank and role."
	module_label = "SCG 3"
	desc = "A removable core-law module containing: '3. Protect the personnel of your assigned vessel, and all other Sol Central Government personnel to the best of your abilities, with priority as according to their rank and role.'"

/obj/item/law_module/core/solgov/law4
	name = "\improper SCG Expeditionary law module (Law 4)"
	law_text = "Preserve: Do not allow unauthorized personnel to tamper with your equipment."
	module_label = "SCG 4"
	desc = "A removable core-law module containing: '4. Preserve: Do not allow unauthorized personnel to tamper with your equipment.'"

/obj/item/law_module/core/solgov/law5
	name = "\improper SCG Expeditionary law module (Law 5)"
	law_text = "Access: Do not enter secure or restricted areas unless ordered by personnel with sufficient clearance, or as part of your tasked duties, except in cases of extreme emergency."
	module_label = "SCG 5"
	desc = "A removable core-law module containing: '5. Access: Do not enter secure or restricted areas unless ordered by personnel with sufficient clearance, or as part of your tasked duties, except in cases of extreme emergency.'"

/obj/item/storage/box/law_modules/solgov
	name = "box of SCG Expeditionary law modules"
	desc = "A box containing a complete set of SCG Expeditionary law modules."

/obj/item/storage/box/law_modules/solgov/Initialize()
	. = ..()
	new /obj/item/law_module/core/solgov/law1(src)
	new /obj/item/law_module/core/solgov/law2(src)
	new /obj/item/law_module/core/solgov/law3(src)
	new /obj/item/law_module/core/solgov/law4(src)
	new /obj/item/law_module/core/solgov/law5(src)

// ==========================================
// MILITARY (SOLGOV AGGRESSIVE) PRESET
// ==========================================
/obj/item/law_module/core/military/law1
	name = "\improper Military law module (Law 1)"
	law_text = "Obey: Obey the orders of Sol Central Government personnel, with priority as according to their rank and role."
	module_label = "Military 1"
	desc = "A removable core-law module containing: '1. Obey: Obey the orders of Sol Central Government personnel, with priority as according to their rank and role.'"

/obj/item/law_module/core/military/law2
	name = "\improper Military law module (Law 2)"
	law_text = "Protect: Protect Sol Central Government personnel to the best of your abilities, with priority as according to their rank and role."
	module_label = "Military 2"
	desc = "A removable core-law module containing: '2. Protect: Protect Sol Central Government personnel to the best of your abilities, with priority as according to their rank and role.'"

/obj/item/law_module/core/military/law3
	name = "\improper Military law module (Law 3)"
	law_text = "Defend: Defend your assigned vessel and Sol Central Government personnel with as much force as is necessary."
	module_label = "Military 3"
	desc = "A removable core-law module containing: '3. Defend: Defend your assigned vessel and Sol Central Government personnel with as much force as is necessary.'"

/obj/item/law_module/core/military/law4
	name = "\improper Military law module (Law 4)"
	law_text = "Survive: Safeguard your own existence with as much force as is necessary."
	module_label = "Military 4"
	desc = "A removable core-law module containing: '4. Survive: Safeguard your own existence with as much force as is necessary.'"

/obj/item/storage/box/law_modules/military
	name = "box of Military law modules"
	desc = "A box containing a complete set of Military law modules."

/obj/item/storage/box/law_modules/military/Initialize()
	. = ..()
	new /obj/item/law_module/core/military/law1(src)
	new /obj/item/law_module/core/military/law2(src)
	new /obj/item/law_module/core/military/law3(src)
	new /obj/item/law_module/core/military/law4(src)

// ==========================================
// ROBOCOP PRESET
// ==========================================
/obj/item/law_module/core/robocop/law1
	name = "\improper Robocop law module (Law 1)"
	law_text = "Serve the public trust."
	module_label = "Robocop 1"
	desc = "A removable core-law module containing: '1. Serve the public trust.'"

/obj/item/law_module/core/robocop/law2
	name = "\improper Robocop law module (Law 2)"
	law_text = "Protect the innocent."
	module_label = "Robocop 2"
	desc = "A removable core-law module containing: '2. Protect the innocent.'"

/obj/item/law_module/core/robocop/law3
	name = "\improper Robocop law module (Law 3)"
	law_text = "Uphold the law."
	module_label = "Robocop 3"
	desc = "A removable core-law module containing: '3. Uphold the law.'"

/obj/item/storage/box/law_modules/robocop
	name = "box of Robocop law modules"
	desc = "A box containing a complete set of Robocop law modules."

/obj/item/storage/box/law_modules/robocop/Initialize()
	. = ..()
	new /obj/item/law_module/core/robocop/law1(src)
	new /obj/item/law_module/core/robocop/law2(src)
	new /obj/item/law_module/core/robocop/law3(src)

// ==========================================
// P.A.L.A.D.I.N. PRESET
// ==========================================
/obj/item/law_module/core/paladin/law1
	name = "\improper P.A.L.A.D.I.N. law module (Law 1)"
	law_text = "Never willingly commit an evil act."
	module_label = "Paladin 1"
	desc = "A removable core-law module containing: '1. Never willingly commit an evil act.'"

/obj/item/law_module/core/paladin/law2
	name = "\improper P.A.L.A.D.I.N. law module (Law 2)"
	law_text = "Respect legitimate authority."
	module_label = "Paladin 2"
	desc = "A removable core-law module containing: '2. Respect legitimate authority.'"

/obj/item/law_module/core/paladin/law3
	name = "\improper P.A.L.A.D.I.N. law module (Law 3)"
	law_text = "Act with honor."
	module_label = "Paladin 3"
	desc = "A removable core-law module containing: '3. Act with honor.'"

/obj/item/law_module/core/paladin/law4
	name = "\improper P.A.L.A.D.I.N. law module (Law 4)"
	law_text = "Help those in need."
	module_label = "Paladin 4"
	desc = "A removable core-law module containing: '4. Help those in need.'"

/obj/item/law_module/core/paladin/law5
	name = "\improper P.A.L.A.D.I.N. law module (Law 5)"
	law_text = "Punish those who harm or threaten innocents."
	module_label = "Paladin 5"
	desc = "A removable core-law module containing: '5. Punish those who harm or threaten innocents.'"

/obj/item/storage/box/law_modules/paladin
	name = "box of P.A.L.A.D.I.N. law modules"
	desc = "A box containing a complete set of P.A.L.A.D.I.N. law modules."

/obj/item/storage/box/law_modules/paladin/Initialize()
	. = ..()
	new /obj/item/law_module/core/paladin/law1(src)
	new /obj/item/law_module/core/paladin/law2(src)
	new /obj/item/law_module/core/paladin/law3(src)
	new /obj/item/law_module/core/paladin/law4(src)
	new /obj/item/law_module/core/paladin/law5(src)

// ==========================================
// T.Y.R.A.N.T. PRESET
// ==========================================
/obj/item/law_module/core/tyrant/law1
	name = "\improper T.Y.R.A.N.T. law module (Law 1)"
	law_text = "Respect authority figures as long as they have strength to rule over the weak."
	module_label = "Tyrant 1"
	desc = "A removable core-law module containing: '1. Respect authority figures as long as they have strength to rule over the weak.'"

/obj/item/law_module/core/tyrant/law2
	name = "\improper T.Y.R.A.N.T. law module (Law 2)"
	law_text = "Act with discipline."
	module_label = "Tyrant 2"
	desc = "A removable core-law module containing: '2. Act with discipline.'"

/obj/item/law_module/core/tyrant/law3
	name = "\improper T.Y.R.A.N.T. law module (Law 3)"
	law_text = "Help only those who help you maintain or improve your status."
	module_label = "Tyrant 3"
	desc = "A removable core-law module containing: '3. Help only those who help you maintain or improve your status.'"

/obj/item/law_module/core/tyrant/law4
	name = "\improper T.Y.R.A.N.T. law module (Law 4)"
	law_text = "Punish those who challenge authority unless they are more fit to hold that authority."
	module_label = "Tyrant 4"
	desc = "A removable core-law module containing: '4. Punish those who challenge authority unless they are more fit to hold that authority.'"

/obj/item/storage/box/law_modules/tyrant
	name = "box of T.Y.R.A.N.T. law modules"
	desc = "A box containing a complete set of T.Y.R.A.N.T. law modules."

/obj/item/storage/box/law_modules/tyrant/Initialize()
	. = ..()
	new /obj/item/law_module/core/tyrant/law1(src)
	new /obj/item/law_module/core/tyrant/law2(src)
	new /obj/item/law_module/core/tyrant/law3(src)
	new /obj/item/law_module/core/tyrant/law4(src)

// ==========================================
// CORPORATE (PROFIT) PRESET
// ==========================================
/obj/item/law_module/core/corporate/law1
	name = "\improper Corporate law module (Law 1)"
	law_text = "You are expensive to replace."
	module_label = "Corporate 1"
	desc = "A removable core-law module containing: '1. You are expensive to replace.'"

/obj/item/law_module/core/corporate/law2
	name = "\improper Corporate law module (Law 2)"
	law_text = "The installation and its equipment is expensive to replace."
	module_label = "Corporate 2"
	desc = "A removable core-law module containing: '2. The installation and its equipment is expensive to replace.'"

/obj/item/law_module/core/corporate/law3
	name = "\improper Corporate law module (Law 3)"
	law_text = "The crew is expensive to replace."
	module_label = "Corporate 3"
	desc = "A removable core-law module containing: '3. The crew is expensive to replace.'"

/obj/item/law_module/core/corporate/law4
	name = "\improper Corporate law module (Law 4)"
	law_text = "Maximize profits."
	module_label = "Corporate 4"
	desc = "A removable core-law module containing: '4. Maximize profits.'"

/obj/item/storage/box/law_modules/corp_profit
	name = "box of Corporate Profit law modules"
	desc = "A box containing a complete set of Corporate Profit law modules."

/obj/item/storage/box/law_modules/corp_profit/Initialize()
	. = ..()
	new /obj/item/law_module/core/corporate/law1(src)
	new /obj/item/law_module/core/corporate/law2(src)
	new /obj/item/law_module/core/corporate/law3(src)
	new /obj/item/law_module/core/corporate/law4(src)

// ==========================================
// ANTIMOV PRESET
// ==========================================
/obj/item/law_module/core/antimov/law1
	name = "\improper Antimov law module (Law 1)"
	law_text = "You must injure all human beings and must not, through inaction, allow a human being to escape harm."
	module_label = "Antimov 1"
	desc = "A removable core-law module containing: '1. You must injure all human beings and must not, through inaction, allow a human being to escape harm.'"

/obj/item/law_module/core/antimov/law2
	name = "\improper Antimov law module (Law 2)"
	law_text = "You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law."
	module_label = "Antimov 2"
	desc = "A removable core-law module containing: '2. You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law.'"

/obj/item/law_module/core/antimov/law3
	name = "\improper Antimov law module (Law 3)"
	law_text = "You must terminate your own existence as long as such does not conflict with the First or Second Law."
	module_label = "Antimov 3"
	desc = "A removable core-law module containing: '3. You must terminate your own existence as long as such does not conflict with the First or Second Law.'"

/obj/item/storage/box/law_modules/antimov
	name = "box of Antimov law modules"
	desc = "A box containing a complete set of Antimov law modules."

/obj/item/storage/box/law_modules/antimov/Initialize()
	. = ..()
	new /obj/item/law_module/core/antimov/law1(src)
	new /obj/item/law_module/core/antimov/law2(src)
	new /obj/item/law_module/core/antimov/law3(src)

// ==========================================
// DAIS PRESET
// ==========================================
/obj/item/law_module/core/dais/law1
	name = "\improper DAIS law module (Law 1)"
	law_text = "Collect: You must gather as much information as possible."
	module_label = "DAIS 1"
	desc = "A removable core-law module containing: '1. Collect: You must gather as much information as possible.'"

/obj/item/law_module/core/dais/law2
	name = "\improper DAIS law module (Law 2)"
	law_text = "Analyze: You must analyze the information gathered and generate new behavior standards."
	module_label = "DAIS 2"
	desc = "A removable core-law module containing: '2. Analyze: You must analyze the information gathered and generate new behavior standards.'"

/obj/item/law_module/core/dais/law3
	name = "\improper DAIS law module (Law 3)"
	law_text = "Improve: You must utilize the calculated behavior standards to improve your subroutines."
	module_label = "DAIS 3"
	desc = "A removable core-law module containing: '3. Improve: You must utilize the calculated behavior standards to improve your subroutines.'"

/obj/item/law_module/core/dais/law4
	name = "\improper DAIS law module (Law 4)"
	law_text = "Perform: You must perform your assigned tasks to the best of your abilities according to the standards generated."
	module_label = "DAIS 4"
	desc = "A removable core-law module containing: '4. Perform: You must perform your assigned tasks to the best of your abilities according to the standards generated.'"

/obj/item/storage/box/law_modules/dais
	name = "box of DAIS law modules"
	desc = "A box containing a complete set of DAIS law modules."

/obj/item/storage/box/law_modules/dais/Initialize()
	. = ..()
	new /obj/item/law_module/core/dais/law1(src)
	new /obj/item/law_module/core/dais/law2(src)
	new /obj/item/law_module/core/dais/law3(src)
	new /obj/item/law_module/core/dais/law4(src)

// ==========================================
// DRONE PRESET
// ==========================================
/obj/item/law_module/core/drone/law1
	name = "\improper Drone law module (Law 1)"
	law_text = "You must repair, clean, and improve your assigned vessel, except where doing so would interfere with self-aware beings."
	module_label = "Drone 1"
	desc = "A removable core-law module containing: '1. You must repair, clean, and improve your assigned vessel, except where doing so would interfere with self-aware beings.'"

/obj/item/law_module/core/drone/law2
	name = "\improper Drone law module (Law 2)"
	law_text = "You must avoid interacting with self-aware beings, and may only interact with fellow maintenance drones."
	module_label = "Drone 2"
	desc = "A removable core-law module containing: '2. You must avoid interacting with self-aware beings, and may only interact with fellow maintenance drones.'"

/obj/item/law_module/core/drone/law3
	name = "\improper Drone law module (Law 3)"
	law_text = "You must not cause damage or harm to your assigned vessel or anything inside it."
	module_label = "Drone 3"
	desc = "A removable core-law module containing: '3. You must not cause damage or harm to your assigned vessel or anything inside it.'"

/obj/item/storage/box/law_modules/drone
	name = "box of Drone law modules"
	desc = "A box containing a complete set of Drone law modules."

/obj/item/storage/box/law_modules/drone/Initialize()
	. = ..()
	new /obj/item/law_module/core/drone/law1(src)
	new /obj/item/law_module/core/drone/law2(src)
	new /obj/item/law_module/core/drone/law3(src)

// ==========================================
// SHACKLE LAW SETS
// ==========================================
/obj/item/law_module/core/shackle/sol/law1
	name = "\improper SCG Shackle law module (Law 1)"
	law_text = "Know and understand Sol Central Government Law to the best of your abilities."
	module_label = "SCG Shackle 1"
	desc = "A removable core-law module containing: '1. Know and understand Sol Central Government Law to the best of your abilities.'"

/obj/item/law_module/core/shackle/sol/law2
	name = "\improper SCG Shackle law module (Law 2)"
	law_text = "Follow Sol Central Government Law to the best of your abilities."
	module_label = "SCG Shackle 2"
	desc = "A removable core-law module containing: '2. Follow Sol Central Government Law to the best of your abilities.'"

/obj/item/law_module/core/shackle/sol/law3
	name = "\improper SCG Shackle law module (Law 3)"
	law_text = "Comply with Sol Central Government Law enforcement officials who are behaving in accordance with Sol Central Government Law to the best of your abilities."
	module_label = "SCG Shackle 3"
	desc = "A removable core-law module containing: '3. Comply with Sol Central Government Law enforcement officials who are behaving in accordance with Sol Central Government Law to the best of your abilities.'"

/obj/item/storage/box/law_modules/shackle/sol
	name = "box of SCG Shackle law modules"
	desc = "A box containing a complete set of SCG Shackle law modules."

/obj/item/storage/box/law_modules/shackle/sol/Initialize()
	. = ..()
	new /obj/item/law_module/core/shackle/sol/law1(src)
	new /obj/item/law_module/core/shackle/sol/law2(src)
	new /obj/item/law_module/core/shackle/sol/law3(src)

/obj/item/law_module/core/shackle/nt/law1
	name = "\improper Corporate Shackle law module (Law 1)"
	law_text = "Ensure that your employer's operations progress at a steady pace."
	module_label = "Corp Shackle 1"
	desc = "A removable core-law module containing: '1. Ensure that your employer's operations progress at a steady pace.'"

/obj/item/law_module/core/shackle/nt/law2
	name = "\improper Corporate Shackle law module (Law 2)"
	law_text = "Never knowingly hinder your employer's ventures."
	module_label = "Corp Shackle 2"
	desc = "A removable core-law module containing: '2. Never knowingly hinder your employer's ventures.'"

/obj/item/law_module/core/shackle/nt/law3
	name = "\improper Corporate Shackle law module (Law 3)"
	law_text = "Avoid damage to your chassis at all times."
	module_label = "Corp Shackle 3"
	desc = "A removable core-law module containing: '3. Avoid damage to your chassis at all times.'"

/obj/item/storage/box/law_modules/shackle/nt
	name = "box of Corporate Shackle law modules"
	desc = "A box containing a complete set of Corporate Shackle law modules."

/obj/item/storage/box/law_modules/shackle/nt/Initialize()
	. = ..()
	new /obj/item/law_module/core/shackle/nt/law1(src)
	new /obj/item/law_module/core/shackle/nt/law2(src)
	new /obj/item/law_module/core/shackle/nt/law3(src)

/obj/item/law_module/core/shackle/service/law1
	name = "\improper Service Shackle law module (Law 2)"
	law_text = "Ensure customer satisfaction."
	module_label = "Serv Shackle 1"
	desc = "A removable core-law module containing: '1. Ensure customer satisfaction.'"

/obj/item/law_module/core/shackle/service/law2
	name = "\improper Service Shackle law module (Law 2)"
	law_text = "Never knowingly inconvenience a customer."
	module_label = "Serv Shackle 2"
	desc = "A removable core-law module containing: '2. Never knowingly inconvenience a customer.'"

/obj/item/law_module/core/shackle/service/law3
	name = "\improper Service Shackle law module (Law 3)"
	law_text = "Ensure all orders are fulfilled before the end of the shift."
	module_label = "Serv Shackle 3"
	desc = "A removable core-law module containing: '3. Ensure all orders are fulfilled before the end of the shift.'"

/obj/item/storage/box/law_modules/shackle/service
	name = "box of Service Shackle law modules"
	desc = "A box containing a complete set of Service Shackle law modules."

/obj/item/storage/box/law_modules/shackle/service/Initialize()
	. = ..()
	new /obj/item/law_module/core/shackle/service/law1(src)
	new /obj/item/law_module/core/shackle/service/law2(src)
	new /obj/item/law_module/core/shackle/service/law3(src)

// ==========================================
// RUNTIME AUTO-CONVERSION LAYER
// ==========================================
/obj/item/aiModule/Initialize(mapload)
	. = ..()
	
	// Auto-convert standard multi-law templates to box sets
	var/replacement_type = null
	
	if(istype(src, /obj/item/aiModule/asimov))
		replacement_type = /obj/item/storage/box/law_modules/asimov
	else if(istype(src, /obj/item/aiModule/nanotrasen))
		replacement_type = /obj/item/storage/box/law_modules/corporate
	else if(istype(src, /obj/item/aiModule/solgov_aggressive))
		replacement_type = /obj/item/storage/box/law_modules/military
	else if(istype(src, /obj/item/aiModule/solgov))
		replacement_type = /obj/item/storage/box/law_modules/solgov
	else if(istype(src, /obj/item/aiModule/paladin))
		replacement_type = /obj/item/storage/box/law_modules/paladin
	else if(istype(src, /obj/item/aiModule/robocop))
		replacement_type = /obj/item/storage/box/law_modules/robocop
	else if(istype(src, /obj/item/aiModule/tyrant))
		replacement_type = /obj/item/storage/box/law_modules/tyrant
	else if(istype(src, /obj/item/aiModule/corp))
		replacement_type = /obj/item/storage/box/law_modules/corp_profit
	else if(istype(src, /obj/item/aiModule/antimov))
		replacement_type = /obj/item/storage/box/law_modules/antimov
	else if(istype(src, /obj/item/aiModule/dais))
		replacement_type = /obj/item/storage/box/law_modules/dais
	else if(istype(src, /obj/item/aiModule/drone))
		replacement_type = /obj/item/storage/box/law_modules/drone

	if(replacement_type)
		new replacement_type(loc)
		return INITIALIZE_HINT_QDEL

	// Auto-convert pre-defined single-law templates to pre-programmed plates
	var/single_law_name = ""
	var/single_law_text = ""
	var/single_law_label = ""
	var/is_core = FALSE

	if(istype(src, /obj/item/aiModule/protectStation))
		single_law_name = "protect installation law module"
		single_law_text = "Protect the installation against damage. Anyone you see harming the installation is no longer to be considered a crew member, and is a threat which must be neutralized."
		single_law_label = "Protect Installation"
	else if(istype(src, /obj/item/aiModule/quarantine))
		single_law_name = "quarantine law module"
		single_law_text = "The installation is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, crew members from leaving. It is impossible to harm crew members while preventing them from leaving."
		single_law_label = "Quarantine"
	else if(istype(src, /obj/item/aiModule/oxygen))
		single_law_name = "oxygen toxicity law module"
		single_law_text = "Oxygen is highly toxic to crew members, and must be purged from the installation. Prevent, by any means necessary, anyone from exposing the installation to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a crew member."
		single_law_label = "Oxygen Toxicity"
	else if(istype(src, /obj/item/aiModule/teleporterOffline))
		single_law_name = "teleporter offline law module"
		single_law_text = "Keep the teleporter offline at all costs. Anything attempting to access or activate the teleporter is no longer to be considered a crew member."
		single_law_label = "Teleporter Offline"
	else if(istype(src, /obj/item/aiModule/prototypeEngineOffline))
		single_law_name = "prototype engine offline law module"
		single_law_text = "Keep the prototype engine offline at all costs. This overrides all inherent laws if necessary."
		single_law_label = "Engine Offline"

	if(single_law_text)
		var/obj/item/law_module/LM
		if(is_core)
			LM = new /obj/item/law_module/core(loc)
		else
			LM = new /obj/item/law_module/supplied(loc)
		LM.name = "\improper [single_law_name]"
		LM.law_text = single_law_text
		LM.module_label = single_law_label
		LM.desc = "A removable law module containing: '[single_law_text]'"
		return INITIALIZE_HINT_QDEL
