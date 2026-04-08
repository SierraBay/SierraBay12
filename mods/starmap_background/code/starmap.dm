// STARMAP_BACKGROUND MOD
// Adds an interactive SVG star map to the Background preference tab.
// Clicking a system sets TAG_HOMEWORLD, TAG_FACTION and TAG_CULTURE on the character.
// Requires faction_background_grouping (for the .faction var on location singletons).

// Inject prefs_dark.css into every datum/browser panel (Character Slots, etc.)
// get_setup_styles() is called inside get_header() and embedded in <head>.
/datum/browser/proc/get_setup_styles(mob/user)
	if(user)
		send_rsc(user, 'mods/starmap_background/html/prefs_dark.css', "prefs_dark.css")
	return "<link rel='stylesheet' type='text/css' href='prefs_dark.css'>"

// Inject dark theme CSS + DOM enhancements into the character setup browser window.
// This branch builds the HTML directly in open_setup_window, so we override that proc.
/datum/preferences/open_setup_window(mob/user)
	if(!SScharacter_setup.initialized)
		return
	send_rsc(user, 'html/browser/common.css', "common.css")
	send_rsc(user, 'mods/starmap_background/html/prefs_dark.css', "prefs_dark.css")
	var/content = {"<!DOCTYPE html>
<html>
	<meta charset="UTF-8">
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		<link rel='stylesheet' type='text/css' href='common.css'>
		<link rel='stylesheet' type='text/css' href='prefs_dark.css'>
		<script>window.addEventListener('load',function(){
var c=document.getElementById('content');
if(c){var cn=c.querySelector('center');if(cn){cn.id='cmd-bar';}}
var t=document.querySelector('.uiTitle');
if(t){t.innerHTML=t.innerHTML+'<span class=\"cursor\"> _</span>';}
});</script>
	</head>
	<body scroll=auto>
		<div class='uiWrapper'>
			<div class='uiTitleWrapper'><div class='uiTitle'><tt>Character Setup</tt></div></div>
			<div class='uiContent'>
	<script type='text/javascript'>
		function update_content(data){
			var sy=document.documentElement.scrollTop||document.body.scrollTop;
			document.getElementById('content').innerHTML = data;
			var c=document.getElementById('content');
			if(c){var cn=c.querySelector('center');if(cn){cn.id='cmd-bar';}}
			document.documentElement.scrollTop=sy;
			document.body.scrollTop=sy;
		}
		// \[SIERRA-ADD]
		function setJobLevel(source, title, level)
		{
			window.location.href = "byond://?src=" + source + ";set_job=" + title + ";inc_level=" + level;
			return 1;
		}
		// \[/SIERRA-ADD]
	</script>
	<div id='content'>[get_content(user)]</div>
			</div>
		</div>
	</body>
</html>
	"}
	winshow(user, "preferences_window", TRUE)
	show_browser(user, content, "window=preferences_browser")
	onclose(user, "preferences_window", src)
	refresh_preview_map_visibility()
	refresh_preview_map_contents()

// Base human cultures don't have faction set in the base code.
// Extend them here so culture auto-select by faction works.
/singleton/cultural_info/culture/human
	faction = FACTION_SOL_CENTRAL

// ============================================================
//  System Key -> Homeworld names mapping
// ============================================================

var/global/list/STARMAP_HOMEWORLD_MAP
var/global/STARMAP_SVG_CACHE

// Lazy initializer — called on first use if startup hook didn't fire.
/proc/ensure_starmap_homeworld_map()
	if(STARMAP_HOMEWORLD_MAP)
		return
	STARMAP_HOMEWORLD_MAP = list(
		// --- SCG / ЦПСС ---
		// rect13-88-93 = Sol, rect13-88-65 = Alpha Centauri (both map to "Sol" pool)
		"Sol"            = list("Earth", "Mars", "Luna", "Venus", "Ceres",
		                        "Kuiper, Belt", "Kuiper, Interdust", "Pluto"),
		"AlphaCentauri"  = list("Quig"),           // Quig on Tiamant, Alpha Centauri (4 ly)
		"Helios"     = list("Eos"),
		"TauCeti"    = list("Ceti Epsilon"),
		"Galilei"    = list("Gaia"),           // Galilei system = Gaia planet
		"Nyx"        = list("Brinkburn", "Kaldark", "Roanok", "Yuklit", "Casser"),
		"Yuklid"     = list("Yuklid V"),
		"Lordania"   = list("Lordania", "Kingston"),  // Kingston is in the Lordania system (40 ly)
		"Gessshire"  = list("Lorriman"),       // confirmed: Gessshire system = Lorriman colony
		"Gavil"      = list("Tersten"),        // confirmed: Gavil system = Tersten colony
		"Lucinaer"   = list("Cinu"),           // confirmed: Lucinaer system = Cinu colony
		"Mirania"    = list("Mirania"),
		"Copernicus" = list("Brahe", "Iolaus"),
		"GCepheus"   = list("Tadmor"),         // Gamma Cephei = Tadmor (SCG frontier, 45 ly)
		"IAndromeda" = list("Saffar"),         // Upsilon Andromedae = Saffar (SCG frontier, 44 ly)
		// --- GCC / ГКК ---
		"Gilgamesh"  = list("Novaya Zemlya", "Terra"),
		"Sestris"    = list("Amelia"),
		"Bratis"     = list("Amelia"),         // Union of Sestris and Bratis - shares Amelia homeworld
		"Altair"     = list("Qabil"),          // Altair system = Qabil (GCC, ICCG passport)
		"Ursa"       = list("Magnitka"),       // Ursa system = Magnitka (independent)
		"Denebola"   = list("Valy"),           // Denebola system = Valy planet
		"Tyannani"   = list("Penglai"),        // Tyannani system = Penglai (confirmed in lore)
		"Visser"     = list("Providence"),     // Visser system = Providence (confirmed in lore)
		"Klaudof"    = list("Avalon"),         // Klaudof system = Avalon (independent kingdom)
		// --- Note: Putkari (Baroda), Pirx, Castilla, Foster's World have no SVG rect ---
		// --- PU ---
		"Kernel"     = list("Root"),           // Kernel system = Root (Positronic Union)
		// --- Non-human ---
		"QerrValis"  = list("Qerrbalak"),
		"QoaLo"      = list("Mi'tor'qi"),
		"HarrKelm"   = list("Talamira"),       // likely: Harr'Kelm = Talamira/Ri'Qora area
		"ZamsiinIr"  = list("Ahdomai"),
		"SiirahnIr"  = list("Ahdomai"),        // second Tajaran system, same homeworld pool
		"UzoEsa"     = list("Moghes"),
		"Vox"        = list("Ark-Dweller", "Shroud-Dweller", "Ship-Dweller"),
		"ANeech"     = list("Birdcage (Colchis Habitat)", "Eremus", "Asranda",
		                    "Zer'een (Saveel)"),
		// Note: Ouere (Unathi), Roa'sora, OtherSkrell have no SVG system rect
	)

// Startup hook as backup (calls the same lazy initializer)
/hook/startup/proc/init_starmap_homeworld_map()
	ensure_starmap_homeworld_map()
	ensure_starmap_homeworld_cult_map()
	return TRUE

// ============================================================
//  Homeworld -> Culture direct mapping
//  Preferred over faction-based guessing in apply_homeworld.
// ============================================================

var/global/list/STARMAP_HOMEWORLD_CULT_MAP

/proc/ensure_starmap_homeworld_cult_map()
	if(STARMAP_HOMEWORLD_CULT_MAP)
		return
	STARMAP_HOMEWORLD_CULT_MAP = list(
		// --- SCG / ЦПСС ---
		HOME_SYSTEM_EARTH      = CULTURE_HUMAN_EARTH,
		HOME_SYSTEM_MARS       = CULTURE_HUMAN_MARTIAN,
		HOME_SYSTEM_LUNA       = CULTURE_HUMAN_LUNAPOOR,
		HOME_SYSTEM_VENUS      = CULTURE_HUMAN_VENUSIAN,
		HOME_SYSTEM_CERES      = CULTURE_HUMAN_BELTER,
		HOME_SYSTEM_KUIPERB    = CULTURE_HUMAN_KUIPERI,
		HOME_SYSTEM_KUIPERD    = CULTURE_HUMAN_KUIPERO,
		HOME_SYSTEM_PLUTO      = CULTURE_HUMAN_PLUTO,
		HOME_SYSTEM_TAU_CETI   = CULTURE_HUMAN_CETIN,
		HOME_SYSTEM_HELIOS     = CULTURE_HUMAN_EOS,
		HOME_SYSTEM_BRAHE      = CULTURE_HUMAN_BRAHE,
		HOME_SYSTEM_IOLAUS     = CULTURE_HUMAN_IOLAUS,
		HOME_SYSTEM_TADMOR     = CULTURE_HUMAN_TADMOR,
		HOME_SYSTEM_SAFFAR     = CULTURE_HUMAN_SPACER,
		HOME_SYSTEM_PIRX       = CULTURE_HUMAN_PIRXL,
		HOME_SYSTEM_FOSTER     = CULTURE_HUMAN_FOSTER,
		HOME_SYSTEM_LORRIMAN   = CULTURE_HUMAN_LORRIMAN,
		HOME_SYSTEM_LORDANIA   = CULTURE_HUMAN_LORDUP,
		HOME_SYSTEM_KINGSTON   = CULTURE_HUMAN_SPACER,
		HOME_SYSTEM_CINU       = CULTURE_HUMAN_SOLCOL,
		HOME_SYSTEM_YUKLID     = CULTURE_HUMAN_SOLCOL,
		HOME_SYSTEM_TERSTEN    = CULTURE_HUMAN_SOLCOL,
		HOME_SYSTEM_QUIG       = CULTURE_HUMAN_SPACER,
		// --- GCC / ГКК ---
		HOME_SYSTEM_TERRA          = CULTURE_HUMAN_CONFED_TERRA,
		HOME_SYSTEM_NOVAYA_ZEMLYA  = CULTURE_HUMAN_CONFED_ZEMLYA,
		HOME_SYSTEM_AMELIA         = CULTURE_HUMAN_CONFED_SESTRIS,
		HOME_SYSTEM_PUTKARI        = CULTURE_HUMAN_CONFED_PUTKARI,
		HOME_SYSTEM_QABIL          = CULTURE_HUMAN_CONFED_ALTAIR,
		HOME_SYSTEM_PENGLAI        = CULTURE_HUMAN_CONFED_PENGLAI,
		HOME_SYSTEM_PROVIDENCE     = CULTURE_HUMAN_CONFED_PROVIDENCE,
		HOME_SYSTEM_VALY           = CULTURE_HUMAN_CONFED_VALY,
		// --- Независимые / Others ---
		HOME_SYSTEM_AVALON             = CULTURE_HUMAN_AVANOBLE,
		HOME_SYSTEM_GAIA               = CULTURE_HUMAN_GAIAN,
		HOME_SYSTEM_MAGNITKA           = CULTURE_HUMAN_MAGNITKA,
		HOME_SYSTEM_MIRANIA            = CULTURE_HUMAN_MIRANIAN,
		HOME_SYSTEM_NYX_BRINKBURN      = CULTURE_HUMAN_NYXIAN,
		HOME_SYSTEM_NYX_KALDARK        = CULTURE_HUMAN_NYXIAN,
		HOME_SYSTEM_NYX_ROANOK         = CULTURE_HUMAN_NYXIAN,
		HOME_SYSTEM_NYX_YUKLIT         = CULTURE_HUMAN_NYXIAN,
		HOME_SYSTEM_NYX_CASSER         = CULTURE_HUMAN_NYXIAN,
	)

// Fix faction for independent/lawless worlds.
// /singleton/cultural_info/location/New() sets faction from ruling_body, but these
// worlds either inherit the wrong ruling_body or have a non-standard one.
// Overriding New() here resets faction to FACTION_OTHER after the parent proc runs.
/singleton/cultural_info/location/human/gaia/New()
	..()
	faction = FACTION_OTHER

/singleton/cultural_info/location/human/magnitka/New()
	..()
	faction = FACTION_OTHER

/singleton/cultural_info/location/avalon/New()
	..()
	faction = FACTION_OTHER

/singleton/cultural_info/location/mirania/New()
	..()
	faction = FACTION_OTHER

/singleton/cultural_info/location/brinkburn/New()
	..()
	faction = FACTION_OTHER

/singleton/cultural_info/location/kaldark/New()
	..()
	faction = FACTION_OTHER

/singleton/cultural_info/location/roanok/New()
	..()
	faction = FACTION_OTHER

/singleton/cultural_info/location/yuklit/New()
	..()
	faction = FACTION_OTHER

/singleton/cultural_info/location/casser/New()
	..()
	faction = FACTION_OTHER

// ============================================================
//  Preference tab datum
// ============================================================

/datum/category_item/player_setup_item/background/starmap
	name = "Star Map"
	sort_order = 0
	// State for inline culture/homeworld/faction/religion selectors
	var/list/sm_tokens     // token -> display label
	var/list/sm_hidden     // token -> TRUE = description hidden
	var/list/sm_expanded   // token -> TRUE = selector list open
	var/list/sm_pages      // token -> current faction page (1/2/3)

/datum/category_item/player_setup_item/background/starmap/New()
	sm_tokens   = ALL_CULTURAL_TAGS
	sm_hidden   = list()
	sm_expanded = list()
	sm_pages    = list()
	for(var/t in sm_tokens)
		sm_hidden[t]   = TRUE
		sm_expanded[t] = FALSE
		sm_pages[t]    = 1
	..()

/datum/category_item/player_setup_item/background/starmap/sanitize_character()
	return

/datum/category_item/player_setup_item/background/starmap/load_character(datum/pref_record_reader/R)
	return

/datum/category_item/player_setup_item/background/starmap/save_character(datum/pref_record_writer/W)
	return

// Returns assoc list: value -> TRUE, of culturally valid options for the current species + token.
/datum/category_item/player_setup_item/background/starmap/proc/sm_get_valid_values(token)
	var/singleton/species/S = preference_species()
	if(!S)
		return list()
	if(S.force_cultural_info[token])
		return list(S.force_cultural_info[token] = TRUE)
	var/list/result = list()
	for(var/cul in S.available_cultural_info[token] || list())
		result[cul] = TRUE
	return result

// Renders the expand/select UI for one token. Returns HTML string.
/datum/category_item/player_setup_item/background/starmap/proc/sm_render_token(token, label)
	var/list/html = list()
	var/singleton/cultural_info/cur_c = SSculture.get_culture(pref.cultural_info[token])
	var/cur_nick = cur_c ? cur_c.get_nickname() : pref.cultural_info[token]
	var/is_open       = sm_expanded[token]
	var/is_desc_shown = !sm_hidden[token]

	// Button styles
	// Header row: [LABEL]  Value      [описание] [изменить]
	var/nick_html    = cur_nick ? cur_nick : "<span style='color:#3a4a5a;font-style:italic'>—</span>"
	var/desc_label   = is_desc_shown ? "▲ скрыть" : "▼ описание"
	var/expand_label = is_open       ? "✕ свернуть" : "✎ изменить"

	var/bs_desc = "display:inline-block;background:#0d2540;border:1px solid #3a7ab8;color:#80c4ff;padding:2px 10px;border-radius:2px;font-size:11px;font-weight:bold;text-decoration:none;margin-left:4px;white-space:nowrap"
	var/bs_edit = "display:inline-block;background:#251800;border:1px solid #a07020;color:#f0c050;padding:2px 10px;border-radius:2px;font-size:11px;font-weight:bold;text-decoration:none;margin-left:4px;white-space:nowrap"

	html += "<div style='background:#0d1624;border:1px solid #1e2e44;border-radius:3px;padding:5px 8px;margin:4px 0 2px'>"
	html += "<div style='display:flex;justify-content:space-between;align-items:center'>"
	html += "<div>"
	html += "<span style='color:#557090;font-size:10px;text-transform:uppercase;letter-spacing:0.8px'>[label]</span> "
	html += "<span style='font-weight:bold;color:#cce8ff;font-size:12px'>[nick_html]</span>"
	html += "</div>"
	html += "<div style='white-space:nowrap'>"
	if(cur_c)
		html += "<a href='byond://?src=\ref[src];sm_toggle_[token]=1' style='[bs_desc]'>[desc_label]</a>"
	html += "<a href='byond://?src=\ref[src];sm_expand_[token]=1' style='[bs_edit]'>[expand_label]</a>"
	html += "</div>"
	html += "</div>"
	html += "</div>"

	// Description block — only shown after player clicks [описание]
	if(cur_c && is_desc_shown)
		var/list/details = cur_c.get_text_details()
		html += "<div style='background:#070f1e;border:1px solid #1a3050;border-top:none;border-radius:0 0 3px 3px;padding:6px 9px;font-size:11px;line-height:1.6;color:#90b8cc'>"
		if(LAZYLEN(details))
			html += "<div style='color:#4a8aaa;font-size:10px;margin-bottom:5px;border-bottom:1px solid #0f2030;padding-bottom:4px'>[jointext(details, " &bull; ")]</div>"
		if(cur_c.description)
			html += cur_c.description
		html += "</div>"

	// Selector list (when expanded)
	if(is_open)
		var/list/valid = sm_get_valid_values(token)
		html += "<div style='background:#080f1c;border:1px solid #1e3050;padding:5px 8px;margin:2px 0 4px;border-radius:3px;font-size:11px'>"

		if(token == TAG_CULTURE || token == TAG_HOMEWORLD)
			// Faction-grouped view with pagination (ЦПСС / ГКК / Остальные)
			var/list/grouped = list(FACTION_SOL_CENTRAL=list(), FACTION_INDIE_CONFED=list(), "Others"=list())
			for(var/V in valid)
				var/singleton/cultural_info/vc = SSculture.get_culture(V)
				var/fact = (vc && vc.faction) ? vc.faction : "Others"
				if(fact != FACTION_SOL_CENTRAL && fact != FACTION_INDIE_CONFED)
					fact = "Others"
				grouped[fact] += V
			var/list/pnames = list("ЦПСС", "ГКК", "Остальные")
			var/list/pkeys  = list(FACTION_SOL_CENTRAL, FACTION_INDIE_CONFED, "Others")
			var/p = sm_pages[token] || 1
			// Tabs
			html += "<div style='font-size:10px;margin-bottom:4px;color:#667'>"
			for(var/i=1; i<=3; i++)
				var/tab_name = pnames[i]
				if(i == p)
					html += "<span style='font-weight:bold;color:#6aadff'>[tab_name]</span>"
				else
					html += "<a href='byond://?src=\ref[src];sm_page_[token]=[i]'>[tab_name]</a>"
				if(i < 3) html += " | "
			html += "</div>"
			// Values
			var/list/vals = grouped[pkeys[p]]
			if(!LAZYLEN(vals))
				html += "<span style='color:#444'><i>Нет вариантов для выбранной расы.</i></span>"
			else
				for(var/V in vals)
					var/sanitized = html_encode(replacetext(V, "+", "PLUS"))
					var/singleton/cultural_info/vc = SSculture.get_culture(V)
					if(vc)
						if(pref.cultural_info[token] == V)
							html += "[SPAN_CLASS("linkOn", "[vc.get_nickname()]")] "
						else
							html += "<a href='byond://?src=\ref[src];sm_set_[token]=[sanitized]'>[vc.get_nickname()]</a> "
		else
			// Flat list for Faction and Religion
			if(!LAZYLEN(valid))
				html += "<span style='color:#444'><i>Нет вариантов для выбранной расы.</i></span>"
			else
				for(var/V in valid)
					var/sanitized = html_encode(replacetext(V, "+", "PLUS"))
					var/singleton/cultural_info/vc = SSculture.get_culture(V)
					if(vc)
						if(pref.cultural_info[token] == V)
							html += "[SPAN_CLASS("linkOn", "[vc.get_nickname()]")] "
						else
							html += "<a href='byond://?src=\ref[src];sm_set_[token]=[sanitized]'>[vc.get_nickname()]</a> "
		html += "</div>"

	return jointext(html, null)

/datum/category_item/player_setup_item/background/starmap/content()
	var/cur_home    = pref.cultural_info[TAG_HOMEWORLD]
	var/cur_faction = pref.cultural_info[TAG_FACTION]
	var/cur_culture = pref.cultural_info[TAG_CULTURE]

	// Faction-based badge color
	var/fc = "#888"
	var/fb = "#222"
	if(cur_faction == FACTION_SOL_CENTRAL)
		fc = "#4a90d9"; fb = "#0f2044"
	else if(cur_faction == FACTION_INDIE_CONFED)
		fc = "#d94a4a"; fb = "#3a0f0f"

	var/home_html    = cur_home    ? "<b>[cur_home]</b>"    : "<span style='color:#555;font-style:italic'>none</span>"
	var/faction_html = cur_faction ? "<b>[cur_faction]</b>" : "<span style='color:#555;font-style:italic'>none</span>"
	var/culture_html = cur_culture ? "<b>[cur_culture]</b>" : "<span style='color:#555;font-style:italic'>none</span>"

	var/s_card   = "background:#101020;border:1px solid #2a2a40;padding:5px 7px;margin:1px 0"
	var/s_label  = "color:#7a9ab0;font-size:10px;text-transform:uppercase;background:none;border:none;padding:0;margin:0"
	var/s_badge  = "padding:1px 6px;border-radius:2px;border:1px solid;color:#cce0ff;background:none"
	var/s_btn    = "display:inline-block;background:#0f2044;border:1px solid #4A90D9;color:#6aadff;padding:2px 10px;border-radius:2px;text-decoration:none"

	. = list(
		"<div style='[s_card]'>",
		"<span style='color:#8ab;font-size:12px'><b>&#9733; STAR MAP</b></span>",
		"<hr style='border:none;border-top:1px solid #222;margin:3px 0'>",
		"<table width='100%' cellpadding='3' cellspacing='0'><tr>",
		"<td width='33%' valign='top'><div style='[s_label]'>Homeworld</div>",
		"<span style='[s_badge];border-color:[fc];background:[fb]'>[home_html]</span></td>",
		"<td width='33%' valign='top'><div style='[s_label]'>Faction</div>",
		"<span style='[s_badge];border-color:[fc];background:[fb]'>[faction_html]</span></td>",
		"<td width='33%' valign='top'><div style='[s_label]'>Culture</div>",
		"<span style='[s_badge];border-color:#334;background:#161622'>[culture_html]</span></td>",
		"</tr></table>",
		"<div style='margin-top:5px'>",
		"<a href='byond://?src=\ref[src];open_map=1' style='[s_btn]'>&#127760; Open Star Map</a>",
		"</div>",
		"<hr style='border:none;border-top:1px solid #1a2840;margin:6px 0 3px'>",
	)
	// Inline selectors for all cultural tokens (replaces standalone Culture panel)
	for(var/i = 1; i <= length(sm_tokens); i++)
		var/token = sm_tokens[i]
		. += sm_render_token(token, sm_tokens[token])
		if(i < length(sm_tokens))
			. += "<div style='margin:6px 0;display:flex;align-items:center;gap:6px'><div style='flex:1;height:1px;background:linear-gradient(to right,#1a2e44,#0a1420)'></div><span style='color:#22354a;font-size:9px;letter-spacing:1px'>&#9632;</span><div style='flex:1;height:1px;background:linear-gradient(to left,#1a2e44,#0a1420)'></div></div>"
	. += "</div>"  // close smcard
	. = jointext(., null)

/datum/category_item/player_setup_item/background/starmap/OnTopic(href, list/href_list, mob/user)

	if(href_list["open_map"])
		open_starmap_window(user)
		return TOPIC_HARD_REFRESH

	if(href_list["close_map"])
		close_browser(user, "window=starmap")
		return TOPIC_HARD_REFRESH

	// select_system is now handled entirely in JS via popup — JS sends set_homeworld directly.

	if(href_list["set_homeworld"])
		var/home_name = html_decode(replacetext(href_list["set_homeworld"], "PLUS", "+"))
		apply_homeworld(user, home_name)
		open_starmap_window(user)   // refresh map in-place (shows gold ring on new selection)
		return TOPIC_HARD_REFRESH

	// Inline culture/homeworld/faction/religion selectors
	for(var/token in sm_tokens)
		if(href_list["sm_toggle_[token]"])
			sm_hidden[token] = !sm_hidden[token]
			return TOPIC_HARD_REFRESH
		if(href_list["sm_expand_[token]"])
			sm_expanded[token] = !sm_expanded[token]
			return TOPIC_HARD_REFRESH
		if(href_list["sm_page_[token]"])
			sm_pages[token] = text2num(href_list["sm_page_[token]"])
			return TOPIC_HARD_REFRESH
		var/new_val = href_list["sm_set_[token]"]
		if(!isnull(new_val))
			var/decoded = html_decode(replacetext(new_val, "PLUS", "+"))
			pref.cultural_info[token] = decoded
			// Homeworld change: also auto-set faction and culture if possible
			if(token == TAG_HOMEWORLD)
				apply_homeworld(user, decoded)
			return TOPIC_HARD_REFRESH

	return ..()

// Explicitly refresh the preference panel.
// TOPIC_REFRESH alone does not propagate when Topic() is called from an external browse() window.
/datum/category_item/player_setup_item/background/starmap/proc/refresh_prefs(mob/user)
	if(user && user.client && user.client.prefs)
		user.client.prefs.update_setup_window(user)

// Apply homeworld: sets TAG_HOMEWORLD, and tries to auto-select the matching culture and faction.
// Priority:
//   1. Direct homeworld→culture map (STARMAP_HOMEWORLD_CULT_MAP) — picks homeworld-specific culture.
//   2. Faction-based fallback — finds first available culture matching loc.faction.
// Independent/lawless worlds always set TAG_FACTION = FACTION_OTHER.
/datum/category_item/player_setup_item/background/starmap/proc/apply_homeworld(mob/user, home_name)
	pref.cultural_info[TAG_HOMEWORLD] = home_name
	var/singleton/cultural_info/loc = SSculture.get_culture(home_name)
	var/singleton/species/S = preference_species()
	if(!S)
		return
	var/list/avail = S.force_cultural_info[TAG_CULTURE] ? \
	                 list(S.force_cultural_info[TAG_CULTURE]) : \
	                 (S.available_cultural_info[TAG_CULTURE] || list())

	// 1. Direct homeworld→culture mapping (most accurate, homeworld-specific)
	ensure_starmap_homeworld_cult_map()
	var/mapped_cult = STARMAP_HOMEWORLD_CULT_MAP[home_name]
	if(mapped_cult && (mapped_cult in avail))
		pref.cultural_info[TAG_CULTURE] = mapped_cult
		if(loc && loc.faction)
			pref.cultural_info[TAG_FACTION] = loc.faction
		return

	// 2. Fallback: faction-based matching (non-human species, unmapped homeworlds)
	if(!loc)
		return
	var/home_faction = loc.faction
	// Independent/unrecognized worlds → FACTION_OTHER
	if(!home_faction || (home_faction != FACTION_SOL_CENTRAL && home_faction != FACTION_INDIE_CONFED))
		pref.cultural_info[TAG_FACTION] = FACTION_OTHER
		return
	// Standard SCG / GCC world — find first matching culture
	var/matched_cult
	for(var/cult in avail)
		var/singleton/cultural_info/c = SSculture.get_culture(cult)
		if(c && c.faction == home_faction)
			matched_cult = cult
			break
	if(!matched_cult)
		return
	pref.cultural_info[TAG_FACTION] = home_faction
	var/cur_cult = pref.cultural_info[TAG_CULTURE]
	var/singleton/cultural_info/cc = SSculture.get_culture(cur_cult)
	if(!cc || cc.faction != home_faction)
		pref.cultural_info[TAG_CULTURE] = matched_cult

// Return a plain numeric list of homeworld names available for the current species
/datum/category_item/player_setup_item/background/starmap/proc/get_available_homeworlds()
	var/singleton/species/S = preference_species()
	if(!S)
		return list()
	var/list/result = list()
	if(S.force_cultural_info[TAG_HOMEWORLD])
		result += S.force_cultural_info[TAG_HOMEWORLD]
	else
		for(var/home in (S.available_cultural_info[TAG_HOMEWORLD] || list()))
			result |= list(home)
	return result

// Build assoc list: system_key -> TRUE for systems with >=1 available homeworld
/datum/category_item/player_setup_item/background/starmap/proc/get_available_systems()
	ensure_starmap_homeworld_map()
	var/list/avail  = get_available_homeworlds()
	var/list/result = list()
	if(!STARMAP_HOMEWORLD_MAP)
		return result
	for(var/sys_key in STARMAP_HOMEWORLD_MAP)
		var/list/candidates = STARMAP_HOMEWORLD_MAP[sys_key]
		if(LAZYLEN(candidates & avail))
			result[sys_key] = TRUE
	return result

/datum/category_item/player_setup_item/background/starmap/proc/open_starmap_window(mob/user)
	if(!user || !user.client)
		return

	var/list/avail_systems = get_available_systems()
	var/list/avail_hw      = get_available_homeworlds()
	var/cur_home           = pref.cultural_info[TAG_HOMEWORLD] || ""
	var/ref_str            = "\ref[src]"

	// Find which system key the current homeworld belongs to (for gold highlight)
	var/cur_system_key = ""
	if(cur_home && STARMAP_HOMEWORLD_MAP)
		for(var/sys_key in STARMAP_HOMEWORLD_MAP)
			if(cur_home in STARMAP_HOMEWORLD_MAP[sys_key])
				cur_system_key = sys_key
				break

	// ---- JS SYSTEM_MAP: SVG rect ID -> system key ----
	var/list/js_lines = list()
	// SCG / ЦПСС
	js_lines += "\"rect13-88-93\":\"Sol\""
	js_lines += "\"rect13-88-65\":\"AlphaCentauri\""
	js_lines += "\"rect13-88-96\":\"Helios\""
	js_lines += "\"rect13-88-60\":\"TauCeti\""
	js_lines += "\"rect13-79-12\":\"Galilei\""
	js_lines += "\"rect13-88-93-9\":\"Nyx\""
	js_lines += "\"rect13-88-073\":\"Gessshire\""
	js_lines += "\"rect13-88-10\":\"Yuklid\""
	js_lines += "\"rect13-88-348\":\"Lordania\""
	js_lines += "\"rect13-88-43\":\"Gavil\""
	js_lines += "\"rect13-88-55\":\"Lucinaer\""
	js_lines += "\"rect13-88-7\":\"Mirania\""
	js_lines += "\"rect13-88-90\":\"Copernicus\""
	js_lines += "\"rect13-79-3-2\":\"GCepheus\""
	js_lines += "\"rect13-79-3-2-3\":\"IAndromeda\""
	js_lines += "\"rect13-88-3\":\"XX168\""
	js_lines += "\"rect13-79-60\":\"Klaudof\""
	js_lines += "\"rect13-79-4-8\":\"Typhonia\""
	// Frontier
	js_lines += "\"rect13-79-6\":\"AlKidr\""
	js_lines += "\"rect13-88-86\":\"Castor\""
	js_lines += "\"rect13-88-82\":\"Pollux\""
	js_lines += "\"rect13-88-62\":\"Cor\""
	js_lines += "\"rect13-88-03\":\"Senavus\""
	js_lines += "\"rect13-88-95\":\"Porrima\""
	// Neutral
	js_lines += "\"rect13-5\":\"Locutus\""
	js_lines += "\"rect13-87\":\"Phiros\""
	// GCC / ГКК
	js_lines += "\"rect13-79-47\":\"Gilgamesh\""
	js_lines += "\"rect13-79-120\":\"Sestris\""
	js_lines += "\"rect13-79-75\":\"Ursa\""
	js_lines += "\"rect13-88-40\":\"Denebola\""
	js_lines += "\"rect13-88-351\":\"Tyannani\""
	js_lines += "\"rect13-88-84\":\"Visser\""
	js_lines += "\"rect13-79-84\":\"Altair\""
	js_lines += "\"rect13-79-06\":\"Bratis\""
	js_lines += "\"rect13-88-88\":\"Chardaan\""
	// PU
	js_lines += "\"rect13-88-76\":\"Kernel\""
	// Skrell
	js_lines += "\"rect13-88-76-4-45\":\"QerrValis\""
	js_lines += "\"rect13-88-76-4-29\":\"QoaLo\""
	js_lines += "\"rect13-88-76-4-32\":\"HarrKelm\""
	// Tajaran
	js_lines += "\"rect13-79-07\":\"ZamsiinIr\""
	js_lines += "\"rect13-79-15\":\"SiirahnIr\""
	// Unathi
	js_lines += "\"rect13-88-5\":\"UzoEsa\""
	// Vox
	js_lines += "\"rect12\":\"Vox\""
	// Resomi
	js_lines += "\"rect13-88-76-4-17\":\"ANeech\""
	var/js_system_map = "{[jointext(js_lines, ",")]}"

	// ---- JS AVAIL: system_key -> 1 (clickable) ----
	var/list/avail_js = list()
	for(var/sys_key in avail_systems)
		avail_js += "\"[sys_key]\":1"
	var/js_avail = "{[jointext(avail_js, ",")]}"

	// ---- JS PLANETS: system_key -> [planet, ...] (only available for this species) ----
	var/list/planets_parts = list()
	for(var/sys_key in avail_systems)
		var/list/reach = STARMAP_HOMEWORLD_MAP[sys_key] & avail_hw
		if(!LAZYLEN(reach))
			continue
		var/list/pstrs = list()
		for(var/p in reach)
			pstrs += "\"[p]\""
		planets_parts += "\"[sys_key]\":\[[jointext(pstrs, ",")]\]"
	var/js_planets = "{[jointext(planets_parts, ",")]}"

	// ---- Load SVG (cached after first read to avoid repeated disk I/O) ----
	if(!STARMAP_SVG_CACHE)
		var/svg_path = "mods/starmap_background/code/starmap.svg"
		STARMAP_SVG_CACHE = fexists(svg_path) ? file2text(svg_path) : "<p style='color:#f66'>SVG not found: [svg_path]</p>"
	var/svg_content = STARMAP_SVG_CACHE

	// Send system info JS (descriptions for tooltip) as RSC resource
	send_rsc(user, 'mods/starmap_background/html/starmap_info.js', "starmap_info.js")

	// ---- Assemble HTML ----
	var/list/html = list()
	html += "<!DOCTYPE html><html><head><meta charset='utf-8'>"
	html += "<script src='starmap_info.js'></script>"
	html += "<style>"
	html += "html,body{margin:0;padding:0;width:100%;height:100%;overflow:hidden;background:#0d0d1a;color:#ccc;font-family:sans-serif}"
	html += "#topbar{position:fixed;top:0;left:0;right:0;height:28px;line-height:28px;padding:0 8px;font-size:12px;background:#111122;border-bottom:1px solid #2a2a3a;z-index:20;box-sizing:border-box}"
	html += "#map_wrap{position:absolute;top:28px;left:0;right:0;bottom:0;overflow:auto;cursor:grab;user-select:none}"
	html += "#map_wrap svg{display:block}"
	html += "a{color:#aaddff;text-decoration:none}"
	// Popup (homeworld selection) styles
	html += "#popup{position:fixed;z-index:110;background:linear-gradient(160deg,#0e1c30,#091320);border:1px solid rgba(0,213,255,0.7);border-radius:4px;padding:0;min-width:150px;max-width:240px;box-shadow:0 0 18px rgba(0,213,255,0.25),0 6px 28px rgba(0,0,0,0.9);pointer-events:all;animation:popIn 0.12s ease-out}"
	html += "@keyframes popIn{from{opacity:0;transform:scale(0.88)}to{opacity:1;transform:scale(1)}}"
	html += ".pop-header{color:#00D5FF;font-size:10px;letter-spacing:1.5px;text-transform:uppercase;font-family:'Consolas','Courier New',monospace;padding:7px 10px 6px;border-bottom:1px solid rgba(0,213,255,0.18)}"
	html += ".pop-worlds{padding:5px}"
	html += ".pop-btn{display:block;background:transparent;border:1px solid #1a3050;color:#7ab8e0;padding:4px 10px;border-radius:2px;text-decoration:none;font-size:11px;margin:3px 0;transition:background 0.07s,border-color 0.07s,color 0.07s}"
	html += ".pop-btn:hover{background:#102040;border-color:#00D5FF;color:#fff}"
	html += ".pop-selected{display:block;background:#1a1200;border:1px solid rgba(255,200,0,0.7);color:gold;padding:4px 10px;border-radius:2px;font-size:11px;font-weight:bold;margin:3px 0}"
	// Info tooltip styles
	html += "#sysinfo{position:fixed;z-index:90;display:none;opacity:0;transition:opacity 0.15s;max-width:290px;pointer-events:none}"
	html += "#sysinfo-inner{background:linear-gradient(160deg,#0a1522,#060e18);border:1px solid rgba(0,213,255,0.45);border-radius:3px;box-shadow:0 0 12px rgba(0,213,255,0.12),0 4px 18px rgba(0,0,0,0.9)}"
	html += ".si-head{color:#00D5FF;font-size:9px;letter-spacing:1.5px;text-transform:uppercase;font-family:'Consolas','Courier New',monospace;padding:5px 9px 4px;border-bottom:1px solid rgba(0,213,255,0.12)}"
	html += ".si-body{padding:7px 9px;font-size:11px;line-height:1.5;color:#9fb8c8;max-height:36vh;overflow-y:auto}"
	html += ".si-body strong{color:#cce0f0}.si-body em{font-style:normal}"
	// Legend transition
	html += "#legend-slide{transition:transform 0.45s cubic-bezier(.7,0,.3,1)}"
	// Available system radar pulse
	html += "@keyframes ringPulse{0%{r:3;opacity:0.5;stroke-width:1.5}100%{r:22;opacity:0;stroke-width:0.3}}"
	html += ".sys-ring{animation:ringPulse 2.8s ease-out infinite;pointer-events:none}"
	html += "</style></head><body>"

	// Top bar
	html += "<div id='topbar'>"
	html += "<span style='font-weight:bold;color:#8ab8d8'>&#9733; STAR MAP</span> &ensp;|&ensp; "
	var/world_label = cur_home ? cur_home : "—"
	html += "World: <span style='font-weight:bold;color:#00D5FF'>[world_label]</span>"
	html += " &ensp;<a href='byond://?src=[ref_str];close_map=1' style='color:#556;font-size:11px'>\[Close\]</a>"
	html += "</div>"

	// SVG map container
	html += "<div id='map_wrap'>[svg_content]</div>"

	// Info tooltip div (populated by JS on hover)
	html += "<div id='sysinfo'><div id='sysinfo-inner'>"
	html += "<div class='si-head'>&#9655; Система</div>"
	html += "<div class='si-body' id='sysinfo-body'></div>"
	html += "</div></div>"

	// Legend SVG (fixed, bottom-right, slide-toggle)
	html += {"<svg id='legend-svg' width='195' height='370' style='position:fixed;left:0;bottom:10px;z-index:9999;pointer-events:none;overflow:visible' xmlns='http://www.w3.org/2000/svg'>
<g id='legend-slide' style='transition:transform 0.3s ease'>
<g font-family='monospace' font-size='13' fill='#ddd' pointer-events='all'>
<rect x='0' y='0' width='195' height='370' fill='#060d18' fill-opacity='0.92' stroke='#00d5ff' stroke-width='1' rx='2'/>
<text x='14' y='22' fill='#00d5ff' font-size='10' letter-spacing='2'>─── ЛЕГЕНДА ───</text>
<text x='14' y='44' fill='#88ccdd' font-size='11' font-weight='bold'>Фракции</text>
<rect x='14' y='51' width='13' height='13' fill='#0091fb'/><text x='34' y='62' font-size='11'>ЦПСС</text>
<rect x='14' y='70' width='13' height='13' fill='#ea002f'/><text x='34' y='81' font-size='11'>ГКК</text>
<rect x='14' y='89' width='13' height='13' fill='#8357fb'/><text x='34' y='100' font-size='11'>Таяра</text>
<rect x='14' y='108' width='13' height='13' fill='#d4d43a'/><text x='34' y='119' font-size='11'>Скреллы</text>
<rect x='14' y='127' width='13' height='13' fill='#c3c3c3'/><text x='34' y='138' font-size='11'>Резоми</text>
<rect x='14' y='146' width='13' height='13' fill='#006f33'/><text x='34' y='157' font-size='11'>АФ</text>
<rect x='14' y='165' width='13' height='13' fill='#ff6a00'/><text x='34' y='176' font-size='11'>Воксы</text>
<rect x='14' y='184' width='13' height='13' fill='#03ec1e'/><text x='34' y='195' font-size='11'>ИПС</text>
<rect x='14' y='203' width='13' height='13' fill='#99ff00'/><text x='34' y='214' font-size='11'>Унати</text>
<text x='14' y='234' fill='#88ccdd' font-size='11' font-weight='bold'>Гейтвеи</text>
<line x1='14' y1='247' x2='42' y2='247' stroke='#6f00ff' stroke-width='2' stroke-dasharray='4,5'/><text x='50' y='251' font-size='11'>Активные</text>
<line x1='14' y1='263' x2='42' y2='263' stroke='#f30000' stroke-width='2' stroke-dasharray='4,5'/><text x='50' y='267' font-size='11'>Закрытые</text>
<line x1='14' y1='279' x2='42' y2='279' stroke='#ff6a00' stroke-width='2' stroke-dasharray='4,5'/><text x='50' y='283' font-size='11'>Нестабильные</text>
<text x='14' y='304' fill='#88ccdd' font-size='11' font-weight='bold'>Обозначения</text>
<rect x='14' y='311' width='13' height='9' fill='rgba(0,213,255,0.35)' stroke='#00D5FF' stroke-width='1'/><text x='34' y='320' font-size='11'>Кликабельная</text>
<rect x='14' y='328' width='13' height='9' fill='rgba(255,200,0,0.35)' stroke='gold' stroke-width='1'/><text x='34' y='337' font-size='11'>Выбранная</text>
<rect x='14' y='345' width='13' height='9' fill='rgba(136,204,255,0.25)' stroke='#88ccff' stroke-width='1'/><text x='34' y='354' font-size='11'>Наведение</text>
</g>
<g id='legend-toggle' cursor='pointer' pointer-events='all'>
<rect x='195' y='150' width='14' height='50' rx='2' fill='#060d18' fill-opacity='0.92' stroke='#00d5ff' stroke-width='1'/>
<text id='legend-arrow' x='202' y='179' text-anchor='middle' font-size='10' fill='#00d5ff' pointer-events='none'>&#9664;</text>
</g>
</g>
</svg>"}

	// JavaScript
	html += "<script>"

	// Data
	html += "var SM=[js_system_map];"
	html += "var AV=[js_avail];"
	html += "var PL=[js_planets];"
	html += "var REF=\"[ref_str]\";"
	html += "var CUR=\"[cur_system_key]\";"
	html += "var CUR_HOME=\"[cur_home]\";"
	html += "var SI=window.SYSINFO||{};"

	// State
	html += "var wrap=document.getElementById('map_wrap');"
	html += "var dragging=false,moved=false,ox=0,oy=0,sl=0,st=0;"
	html += "var scale=1.0,BASE=1000,svg=null,minScale=0.25;"
	html += "var popup=null;"
	html += "var siEl=document.getElementById('sysinfo');"
	html += "var siBody=document.getElementById('sysinfo-body');"
	html += "var siTimer=null;"

	// Info tooltip functions
	html += "function showInfo(sk,e){"
	html += "if(!SI\[sk\])return;"
	html += "siBody.innerHTML=SI\[sk\];"
	html += "siEl.style.display='block';"
	html += "moveInfo(e);"
	html += "clearTimeout(siTimer);"
	html += "siTimer=setTimeout(function(){siEl.style.opacity='1';},10);"
	html += "}"
	html += "function moveInfo(e){"
	html += "var x=e.clientX+18,y=e.clientY+14;"
	html += "var w=siEl.offsetWidth||290,h=siEl.offsetHeight||80;"
	html += "if(x+w>window.innerWidth-8)x=e.clientX-w-14;"
	html += "if(y+h>window.innerHeight-8)y=e.clientY-h-14;"
	html += "if(y<32)y=32;"
	html += "siEl.style.left=x+'px';siEl.style.top=y+'px';"
	html += "}"
	html += "function hideInfo(){"
	html += "siEl.style.opacity='0';"
	html += "clearTimeout(siTimer);"
	html += "siTimer=setTimeout(function(){siEl.style.display='none';},160);"
	html += "}"

	// Popup: dismiss
	html += "function dismissPopup(){"
	html += "if(popup){popup.remove();popup=null;}"
	html += "}"

	// Popup: show near el for system sk
	html += "function showPopup(el,sk){"
	html += "dismissPopup();"
	html += "var planets=PL\[sk\];"
	html += "if(!planets||!planets.length)return;"
	html += "var pop=document.createElement('div');pop.id='popup';"
	html += "var hdr=document.createElement('div');hdr.className='pop-header';"
	html += "hdr.textContent='\\u25b7 '+sk+' system';"
	html += "pop.appendChild(hdr);"
	html += "var lst=document.createElement('div');lst.className='pop-worlds';"
	html += "planets.forEach(function(p){"
	html += "var item=document.createElement('a');"
	html += "if(p===CUR_HOME){"
	html += "item.className='pop-selected';item.textContent='\\u2726 '+p;"
	html += "}else{"
	html += "item.className='pop-btn';item.textContent=p;"
	html += "var enc=encodeURIComponent(p.replace(/\\+/g,'PLUS'));"
	html += "item.href='byond://?src='+REF+';set_homeworld='+enc;"
	html += "}"
	html += "lst.appendChild(item);"
	html += "});"
	html += "pop.appendChild(lst);"
	html += "document.body.appendChild(pop);popup=pop;"
	html += "var r=el.getBoundingClientRect();"
	html += "var pw=pop.offsetWidth||160,ph=pop.offsetHeight||100;"
	html += "var x=r.left+r.width/2-pw/2;"
	html += "var y=r.top-ph-10;"
	html += "if(y<34)y=r.bottom+8;"
	html += "x=Math.max(8,Math.min(window.innerWidth-pw-8,x));"
	html += "pop.style.left=x+'px';pop.style.top=y+'px';"
	html += "}"

	// Legend toggle
	html += "var legendSlide=document.getElementById('legend-slide');"
	html += "var legendArrow=document.getElementById('legend-arrow');"
	html += "var legendOpen=true;"
	html += "document.getElementById('legend-toggle').addEventListener('click',function(){"
	html += "legendOpen=!legendOpen;"
	html += "legendSlide.setAttribute('transform',legendOpen?'translate(0,0)':'translate(-196,0)');"
	html += "legendArrow.innerHTML=legendOpen?'&#9664;':'&#9658;';"
	html += "});"

	// Dismiss popup on outside click or Escape
	html += "document.addEventListener('click',function(e){"
	html += "if(popup&&!popup.contains(e.target))dismissPopup();"
	html += "});"
	html += "document.addEventListener('keydown',function(e){"
	html += "if(e.key==='Escape'){dismissPopup();hideInfo();}"
	html += "});"

	// Drag-to-pan
	html += "wrap.addEventListener('mousedown',function(e){"
	html += "dragging=true;moved=false;"
	html += "ox=e.clientX;oy=e.clientY;sl=wrap.scrollLeft;st=wrap.scrollTop;"
	html += "wrap.style.cursor='grabbing';hideInfo();"
	html += "});"
	html += "document.addEventListener('mouseup',function(){dragging=false;wrap.style.cursor='grab';});"
	html += "document.addEventListener('mousemove',function(e){"
	html += "if(!dragging)return;"
	html += "var dx=e.clientX-ox,dy=e.clientY-oy;"
	html += "if(Math.abs(dx)>4||Math.abs(dy)>4)moved=true;"
	html += "wrap.scrollLeft=sl-dx;wrap.scrollTop=st-dy;"
	html += "});"

	// Wheel zoom (cursor-centered)
	html += "wrap.addEventListener('wheel',function(e){"
	html += "e.preventDefault();if(!svg)return;"
	html += "var f=e.deltaY<0?1.12:0.893;"
	html += "var ns=Math.max(minScale,Math.min(8,scale*f));"
	html += "var r=wrap.getBoundingClientRect();"
	html += "var mx=e.clientX-r.left+wrap.scrollLeft,my=e.clientY-r.top+wrap.scrollTop;"
	html += "var cx=mx/scale,cy=my/scale;"
	html += "scale=ns;var sz=Math.round(BASE*scale);"
	html += "svg.setAttribute('width',sz);svg.setAttribute('height',sz);"
	html += "wrap.scrollLeft=cx*scale-(e.clientX-r.left);"
	html += "wrap.scrollTop=cy*scale-(e.clientY-r.top);"
	html += "},{passive:false});"

	// Init: SVG size + filters + handlers
	html += "window.onload=function(){"
	html += "svg=wrap.querySelector('svg');"
	html += "minScale=wrap.clientWidth/BASE;"
	html += "if(scale<minScale)scale=minScale;"
	html += "if(svg){var isz=Math.round(BASE*scale);svg.setAttribute('width',isz);svg.setAttribute('height',isz);}"
	html += "Object.keys(SM).forEach(function(rid){"
	html += "var sk=SM\[rid\];"
	html += "var el=document.getElementById(rid);"
	html += "if(!el)return;"
	html += "var grp=el.parentNode&&el.parentNode.tagName==='g'?el.parentNode:el;"
	// Gold ring + glow for currently selected system; white ring for other available systems
	html += "if(sk===CUR){"
	html += "grp.style.filter='drop-shadow(0 0 10px gold) brightness(2.2)';"
	html += "var bb=el.getBBox();"
	html += "var circ=document.createElementNS('http://www.w3.org/2000/svg','circle');"
	html += "circ.setAttribute('cx',bb.x+bb.width/2);"
	html += "circ.setAttribute('cy',bb.y+bb.height/2);"
	html += "circ.setAttribute('r',bb.height/2+2);"
	html += "circ.setAttribute('fill','none');"
	html += "circ.setAttribute('stroke','gold');"
	html += "circ.setAttribute('stroke-width','2');"
	html += "circ.classList.add('sys-ring');"
	html += "grp.appendChild(circ);"
	html += "}else if(AV\[sk\]){"
	html += "var bb=el.getBBox();"
	html += "var circ=document.createElementNS('http://www.w3.org/2000/svg','circle');"
	html += "circ.setAttribute('cx',bb.x+bb.width/2);"
	html += "circ.setAttribute('cy',bb.y+bb.height/2);"
	html += "circ.setAttribute('r',bb.height/2+2);"
	html += "circ.setAttribute('fill','none');"
	html += "circ.setAttribute('stroke','#fff');"
	html += "circ.setAttribute('stroke-width','1.5');"
	html += "circ.classList.add('sys-ring');"
	html += "grp.appendChild(circ);"
	html += "}"
	// Info tooltip on hover (all systems with descriptions)
	html += "el.addEventListener('mouseenter',function(e){"
	html += "showInfo(sk,e);"
	html += "});"
	html += "el.addEventListener('mousemove',function(e){if(!dragging)moveInfo(e);});"
	html += "el.addEventListener('mouseleave',function(){"
	html += "hideInfo();"
	html += "grp.style.filter=sk===CUR?'drop-shadow(0 0 10px gold) brightness(2.2)':'';"
	html += "});"
	// Click: homeworld selection (available systems only)
	html += "if(!AV\[sk\])return;"
	html += "el.style.cursor='pointer';"
	html += "el.addEventListener('click',function(e){"
	html += "if(moved)return;"
	html += "e.preventDefault();e.stopPropagation();"
	html += "hideInfo();"
	html += "var planets=PL\[sk\]||\[\];"
	html += "if(planets.length===1){"
	html += "var enc=encodeURIComponent(planets\[0\].replace(/\\+/g,'PLUS'));"
	html += "window.location='byond://?src='+REF+';set_homeworld='+enc;"
	html += "}else if(planets.length>1){"
	html += "showPopup(el,sk);"
	html += "}"
	html += "});"
	html += "});}"

	html += "</script></body></html>"

	show_browser(user, jointext(html, null), "window=starmap;size=1280x900;border=0")

// The standalone Culture panel is now embedded inside the Star Map card.
// Suppress its content so it doesn't render as a separate duplicate block.
/datum/category_item/player_setup_item/background/culture/content()
	return ""

// Override Character Slots dialog to:
//   1. Apply prefs_dark.css for consistent dark styling
//   2. Open without onclose handler so closing the dialog doesn't close the whole setup
/datum/preferences/open_load_dialog(mob/user, details)
	var/list/dat = list()
	dat += "<tt><center>"
	dat += "<b>Select a character slot to load</b><hr>"
	for(var/i = 1 to config.character_slots)
		var/name = slot_names?[get_slot_key(i)]
		if(!name)
			name = "Character [i]"
		if(i == default_slot)
			name = "<b>[name]</b>"
		dat += "<a href='byond://?src=\ref[src];changeslot=[i];[details ? "details=1" : ""];refresh=1'>[name]</a><br>"
	dat += "<hr>"
	dat += "</center></tt>"
	panel = new /datum/browser(user, "Character Slots", "Character Slots", 300, 390, src)
	panel.add_stylesheet("prefs_dark", 'mods/starmap_background/html/prefs_dark.css')
	panel.set_content(jointext(dat, null))
	panel.open(use_onclose = FALSE)
