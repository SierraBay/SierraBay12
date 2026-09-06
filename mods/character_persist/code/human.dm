/mob/living/carbon/human
	/// Ckey of the prefs slot this body was spawned from. Used if the player SSD's.
	var/character_persist_ckey
	/// Character slot index this body was spawned from.
	var/character_persist_slot
	/// True after a successful persist save this round. Prevents double increment on cryo+roundend.
	var/character_persist_saved
	/// Extra thalers to deposit after the roundstart account is created.
	var/character_persist_bonus_money
