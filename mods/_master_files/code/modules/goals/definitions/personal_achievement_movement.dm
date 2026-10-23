/datum/goal/movement/walk/eva/on_completion()
	. = ..()
	SSpayroll.ledger.reward_eva(src)
