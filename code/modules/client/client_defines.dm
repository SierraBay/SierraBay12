/client
	// Allow client instances to be treated like regular datums
	parent_type = /datum

	// Runechat messages
	var/list/seen_messages

	/** At compile time, should be TRUE if serving the rsc from DD or FALSE if using other
		http server(s) to spread load. Defaults FALSE as /client/New() handles setting either
		a url from config.resource_urls, or TRUE if none exist
		Refer to http://www.byond.com/forum/post/1906517?page=2#comment23727144
	*/
	preload_rsc = FALSE

	/// When some kind of staff member, the client's permissions and behaviors
	var/datum/admins/holder

	/// When not currently wanting to see buttons, holder lives here instead
	var/datum/admins/deadmin_holder

	/// The client's preferences object, populated from save data and runtime changes
	var/datum/preferences/prefs

	/// Controls the display of tooltips to this client
	var/datum/tooltip/tooltips

	/// When starting an ahelp conversation, whether the client gets a reply button
	var/adminhelped

	/// A message to show to online staff when joining, if any
	var/staffwarn

	/// Whether or not the client is currently playing the "ship hum" ambience sound
	var/playing_vent_ambience = FALSE

	/// The next threshold time for the client to be able to play basic ambience sounds
	var/next_ambience_time = 0

	/// The last time this client was messaged from IRC. Prevents responses after 10 minutes
	var/received_irc_pm = -99999

	/// Prevents people from being spammed about multikeying every time their mob changes
	var/warned_about_multikeying = TRUE

	// [SIERRA-ADD]
	/// If player has multiple connections warn to the server
	var/have_connection_warn = FALSE

	/// If player has bans warn
	var/have_bans_warn = FALSE
	// [/SIERRA-ADD]

	/// If the database is available, how old the account is in days
	var/player_age = "Requires database"

	/// If the database is available, what other accounts previously logged in from this IP
	var/related_accounts_ip = "Requires database"

	/// If the database is available, what other accounts previously logged in from this CID
	var/related_accounts_cid = "Requires database"

	/// The current fullscreen state for /client/toggle_fullscreen()
	var/fullscreen = FALSE

	/// When the client has atom outlines enabled and hovers something applicable, that thing's outline
	var/image/atom_outline

	/// A resolvable to the current atom outline target, if any
	var/weakref/outline_atom

	/// True while an atom outline update is in-flight
	var/outline_updating

	/// Mirror of the truthiness of the atom_outlines preference
	var/outline_enabled

// [SIERRA-ADD] - Input state
/client
	/// Custom movement keys for this client
	var/list/movement_keys = list()
	/// Are we locking our movement input?
	var/movement_locked = FALSE

	/// A buffer of currently held keys.
	var/list/keys_held = list()
	/// A buffer for combinations such of modifiers + keys (ex: CtrlD, AltE, ShiftT). Format: `"key"` -> `"combo"` (ex: `"D"` -> `"CtrlD"`)
	var/list/key_combos_held = list()
	/*
	** These next two vars are to apply movement for keypresses and releases made while move delayed.
	** Because discarding that input makes the game less responsive.
	*/
	/// On next move, add this dir to the move that would otherwise be done
	var/next_move_dir_add
	/// On next move, subtract this dir from the move that would otherwise be done
	var/next_move_dir_sub
	/// Movement dir of the most recently pressed movement key. Used in cardinal-only movement mode.
	var/last_move_dir_pressed
	/// Coalesce overlapping updates without blocking the input subsystem.
	var/updating_macros = FALSE
	var/macros_update_queued = FALSE
// [/SIERRA-ADD]
