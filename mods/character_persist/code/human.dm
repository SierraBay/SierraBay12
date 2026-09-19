/mob/living/carbon/human
	/// Ckey of the prefs slot this body was spawned from. Used if the player SSD's.
	var/character_persist_ckey
	/// Character slot index this body was spawned from.
	var/character_persist_slot
	/// True after a successful persist save this round. Prevents double increment on cryo+roundend.
	var/character_persist_saved
	/// Extra thalers to deposit after the roundstart account is created.
	var/character_persist_bonus_money
	/// Absolute bank balance restored after setup_account when set (skips stacked shift bonuses).
	var/odyssey_account_money
	/// Roster/corpse identity for Odyssey body persist.
	var/odyssey_corpse_key
	/// True while this body was spawned from Odyssey corpse save; skips death persist hooks.
	var/odyssey_corpse_restored
