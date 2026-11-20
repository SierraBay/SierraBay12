#define SKRELL_MODEL_EMPTY_CONTEXT "*"
#define SKRELL_MODEL_SMOOTHING 0.05
#define SKRELL_MODEL_ALPHABET_SIZE 30

/// Letter model behind the look grade: it counts which letter follows each pair of
/// letters in example words, then tells how likely a letter is after two others.
/// The chance mixes what followed the last two letters, the last letter and no letter
/// at all (context_shares); SKRELL_MODEL_SMOOTHING keeps unseen letters above zero.
/datum/skrell_name_model
	/// Per context length 0, 1, 2: list(context = list(letter = weight)).
	var/list/letter_weights = list(list(), list(), list())
	/// Per context length 0, 1, 2: list(context = total weight).
	var/list/context_totals = list(list(), list(), list())
	/// How much each context length counts in the mix.
	var/list/context_shares = list(0.1, 0.3, 0.6)


/// Counts every letter of the word, and its end, with the given weight.
/datum/skrell_name_model/proc/add_word(word, weight)
	var/padded = "^^[word]$"
	for(var/position = 3 to length(padded))
		var/letter = copytext(padded, position, position + 1)
		for(var/context_length = 0 to 2)
			var/context = context_length ? copytext(padded, position - context_length, position) : SKRELL_MODEL_EMPTY_CONTEXT
			add_weight(context_length, context, letter, weight)


/datum/skrell_name_model/proc/add_weight(context_length, context, letter, weight)
	var/list/contexts = letter_weights[context_length + 1]
	var/list/weights = contexts[context]
	if(!weights)
		weights = list()
		contexts[context] = weights
	weights[letter] += weight
	var/list/totals = context_totals[context_length + 1]
	totals[context] += weight


/// Chance of the letter coming after history, the two characters before it.
/datum/skrell_name_model/proc/get_chance(history, letter)
	. = 0
	for(var/context_length = 0 to 2)
		var/context = context_length ? copytext(history, -context_length) : SKRELL_MODEL_EMPTY_CONTEXT
		var/list/weights = letter_weights[context_length + 1][context]
		var/seen = weights?[letter] || 0
		var/total = context_totals[context_length + 1][context] || 0
		. += context_shares[context_length + 1] * (seen + SKRELL_MODEL_SMOOTHING) / (total + SKRELL_MODEL_SMOOTHING * SKRELL_MODEL_ALPHABET_SIZE)

#undef SKRELL_MODEL_EMPTY_CONTEXT
#undef SKRELL_MODEL_SMOOTHING
#undef SKRELL_MODEL_ALPHABET_SIZE
