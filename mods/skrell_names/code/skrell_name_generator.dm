/// Random words scored for every name; the name is their best combination.
#define SKRELL_NAME_POOL_SIZE 24
// Fields of a pool entry, see make_word_pool().
#define SKRELL_POOL_WORD 1
#define SKRELL_POOL_CLARITY 2
#define SKRELL_POOL_EASE 3
#define SKRELL_POOL_LOOK 4
/// Entries of the syllable table, see build_syllable_table().
#define SKRELL_NAME_SYLLABLE_TABLE_SIZE 5000
/// Lowest clarity of a two-word name.
#define SKRELL_NAME_MIN_CLARITY 0.3
/// Clarity per word above which a word is clear enough.
#define SKRELL_NAME_CLEAR_ENOUGH 0.7
#define SKRELL_NAME_MIN_EASE 0.6
#define SKRELL_NAME_MIN_LOOK 0.35
#define SKRELL_NAME_CLARITY_SHARE 0.3
#define SKRELL_NAME_EASE_SHARE 0.3
#define SKRELL_NAME_LOOK_SHARE 0.4
/// Look of a typical Skrell word.
#define SKRELL_NAME_TYPICAL_LOOK 0.85
/// Look multiplier for a word without Q, X, Z, rr, uu, ii, oo or an apostrophe.
#define SKRELL_NAME_UNMARKED_LOOK 0.8
/// Share of the game's words, against lore names, in the look model.
#define SKRELL_NAME_GAME_LOOK_SHARE 0.5
/// The game's words weigh as much as this many random game words.
#define SKRELL_NAME_GAME_TRAINING_WORDS 12000
#define SKRELL_NAME_SEPARATOR_CHANCE 30
#define SKRELL_NAME_HYPHEN_CHANCE 20
#define SKRELL_NAME_CAPITAL_AFTER_APOSTROPHE_CHANCE 30

/// Makes Skrell names that look like the game's own random ones, are easy to say and
/// have one obvious Russian spelling, so players write them the same way in chat.
///
/// make_name() works in three steps:
/// 1. make_word_pool() makes SKRELL_NAME_POOL_SIZE random words with make_word(), from the
///    game's syllables, eased versions of them and syllables of lore names. Each word gets
///    three grades from 0 to 1:
///    - clarity, get_reading(): the share of Russian players who would write the word's
///      usual spelling. The word is read in letter groups, mostly Q and X are unclear, and
///      the shares of all groups are multiplied;
///    - ease, get_ease(): how easy the word is to say. Consonant runs, long vowel runs,
///      repeated sounds and length cost points;
///    - look, get_look(): how close the word is to the game's two-syllable words and the
///      lore names, by letter models (/datum/skrell_name_model) trained on both in
///      Initialize(). A human name gets 0, a typical Skrell word about 0.85.
///    Words too unclear or too hard to say are dropped right away.
/// 2. Every combination of pool words is a candidate name (next_combination()). Its
///    clarity is the product of its words', its ease the lowest and its look the average.
///    get_combination_score() drops candidates that do not fit the name field or miss a
///    minimum, and scores the rest. Clarity counts as full from SKRELL_NAME_CLEAR_ENOUGH
///    per word, or plain names without Q would win just for being clear.
/// 3. The best candidate is the name. Grading each word once and then combining the
///    grades is much cheaper than grading whole names.
/singleton/skrell_name_generator
	/// The game's own syllables, kept as they are, with how often each is picked.
	var/list/game_syllables = list(
		"vol" = 3, "qil" = 3, "zix" = 3, "qix" = 3, "quum" = 2, "qoo" = 1.5, "zaoo" = 1.5,
		"xuq" = 1.5, "xrim" = 1, "qrr" = 1, "qr" = 0.7, "xuqm" = 0.3, "qu-uu" = 0.4
	)
	/// The game's syllables with a vowel added or a cluster eased.
	var/list/eased_syllables = list(
		"qerr" = 3, "qirr" = 1.5, "qarr" = 1.5, "qorr" = 1.5, "qurr" = 1, "qri" = 2, "qra" = 2,
		"qro" = 1, "qel" = 1.5, "qila" = 1.5, "qili" = 1, "qa" = 2, "qe" = 1, "qi" = 2,
		"qua" = 1.5, "qui" = 0.7, "quu" = 1, "qoa" = 1.5, "qixi" = 1, "qixa" = 0.7, "xi" = 2,
		"xa" = 1.5, "xo" = 1, "xu" = 0.5, "xil" = 1.5, "xim" = 1.5, "xum" = 1, "xul" = 1,
		"xri" = 0.7, "zi" = 1.5, "za" = 1.5, "zu" = 1, "zo" = 0.7, "zao" = 1, "zoa" = 1,
		"zixa" = 0.7, "zixi" = 1, "vola" = 1.5, "voli" = 1, "vo" = 1, "vix" = 1, "lix" = 1,
		"rix" = 1, "rim" = 1, "lim" = 0.7, "il" = 1, "ix" = 1, "ox" = 0.5, "uum" = 0.7
	)
	/// Syllables of the hand-written lore names (Qerr'Balak, Krri'gli, Mero'tol...).
	var/list/lore_syllables = list(
		"kerr" = 2, "terr" = 1.5, "sorr" = 1, "morr" = 1.5, "harr" = 0.5, "arr" = 1,
		"gloa" = 1.5, "moa" = 1, "roa" = 1.5, "voal" = 1.5, "xoal" = 1, "mero" = 1, "tol" = 1.5,
		"tal" = 1.5, "ta" = 1.5, "lak" = 1, "bal" = 1, "ri" = 2, "tri" = 1, "kri" = 1,
		"krri" = 1, "gli" = 1, "glo" = 1, "yii" = 0.7, "lana" = 1, "la" = 2, "mi" = 1.5,
		"ra" = 1.5, "mira" = 1, "sora" = 1, "so" = 1, "vuu" = 1, "tib" = 0.5, "go" = 1,
		"kal" = 0.7, "kel" = 1, "lo" = 1.5, "me" = 1, "gox" = 0.7, "mox" = 0.7, "vux" = 1,
		"zuum" = 1, "xiq" = 0.7, "tor" = 1, "oa" = 0.7, "lis" = 0.7, "val" = 1, "kor" = 0.7,
		"loa" = 1
	)
	/// Share of the game, eased and lore syllables in new words.
	var/list/syllable_list_shares = list(0.3, 0.4, 0.3)
	/// All syllables, each repeated by its weight, so a pick() is a weighted pick.
	var/list/syllable_table

	/// Lore names the look model learns from.
	var/list/lore_words = list(
		"qerr'balak", "qerr'valis", "qerr'vallis", "qorr'gloa", "qo'rria", "xi'krri'oal",
		"talamira", "ri'qora", "roa'sora", "qrri'terr", "tri'sorr", "ro'moxi", "sora'terr",
		"mi'tor'qi", "qoa'lo", "qerr'voal", "qala'oa", "yii'talana", "krri'gli", "tibrivuu",
		"go'kal", "qon'prri", "harr'kelm", "qorr'moa", "gloa'morr", "mo'glar", "xaq",
		"moglar", "qerr-skria", "xilvuxix", "qrri-zuumqix", "qrri-vuxix", "mero'ta",
		"toglo'i", "keloa", "xiqarr", "mero'tol", "goxo'i", "me'kerr", "qi'kerr", "me'xoal",
		"qerr-katish", "malish-katish", "kanin-katish", "talum-katish", "raskinta-katish"
	)
	/// Human names that set the bottom of the look scale.
	var/list/human_names = list(
		"john", "mary", "michael", "anna", "peter", "olga", "ivan", "natalia", "alexander",
		"elena", "james", "sarah", "dmitry", "maria", "sergey", "tatiana", "william", "emma",
		"nikolai", "svetlana", "robert", "linda", "andrei", "irina", "thomas", "laura", "pavel",
		"yulia", "george", "sophia"
	)
	var/datum/skrell_name_model/game_model
	var/datum/skrell_name_model/lore_model
	/// Average look log chance of a human name.
	var/look_floor
	/// Average look log chance of a lore name or a two-syllable game word.
	var/look_ceiling
	/// Log chance of a letter after two others under both look models, as
	/// list("^qe" = log chance). Bounded by the alphabet cubed.
	var/list/look_log_chances = list()

	// How Russian players write a letter or letter group: list(letters used, share of
	// players writing the usual spelling, its sounds). The shares are estimates based
	// on how the server's Russian lore text spells Skrell names: Qerr as Kverr, Qon'prri
	// as Kon'prri, Xaq as Ksaku. Sounds are ASCII: j is the Russian short i, Z, S and C
	// are zh, sh and ch.

	/// Q before a vowel.
	var/list/q_before_vowel = list(
		"e" = list(2, 0.75, "kve"),
		"a" = list(2, 0.65, "kva"),
		"i" = list(2, 0.45, "kvi"),
		"o" = list(2, 0.58, "ko")
	)
	/// Qu before a vowel.
	var/list/qu_before_vowel = list(
		"a" = list(3, 0.7, "kva"),
		"e" = list(3, 0.7, "kve"),
		"i" = list(3, 0.6, "kvi"),
		"o" = list(3, 0.6, "kvo")
	)
	/// Q before u, before oo, at the end of a word and before a consonant.
	var/list/q_other = list(
		"u" = list(1, 0.6, "k"),
		"oo" = list(3, 0.45, "koo"),
		"end" = list(1, 0.65, "k"),
		"consonant" = list(1, 0.6, "k")
	)
	/// X at the end of a word, at the start before a vowel, after a letter before a vowel,
	/// and before a consonant.
	var/list/x_readings = list(
		"end" = list(1, 0.95, "ks"),
		"start" = list(1, 0.82, "ks"),
		"vowel" = list(1, 0.9, "ks"),
		"consonant" = list(1, 0.6, "ks")
	)
	/// Letter pairs read as one sound, and vowel pairs read two ways.
	var/list/letter_pairs = list(
		"kh" = list(2, 0.9, "h"), "sh" = list(2, 0.95, "S"), "ch" = list(2, 0.7, "C"),
		"zh" = list(2, 0.95, "Z"), "th" = list(2, 0.5, "t"), "ph" = list(2, 0.9, "f"),
		"ts" = list(2, 0.55, "ts"), "tz" = list(2, 0.8, "c"), "ck" = list(2, 1, "k"),
		"gh" = list(2, 0.6, "g"), "oo" = list(2, 0.75, "oo"), "ou" = list(2, 0.6, "ou"),
		"ia" = list(2, 0.55, "ia"), "iu" = list(2, 0.6, "iu"), "ie" = list(2, 0.5, "ie")
	)
	/// A vowel and i before a consonant or the end, as in Goxo'i.
	var/list/vowel_before_i = list(
		"a" = list(2, 0.6, "ai"),
		"o" = list(2, 0.6, "oi"),
		"u" = list(2, 0.65, "ui"),
		"e" = list(2, 0.35, "ei")
	)
	/// Ei at the start of a word or after a vowel.
	var/list/ei_at_start = list(2, 0.6, "ej")
	/// Y before a vowel.
	var/list/y_before_vowel = list(
		"a" = list(2, 0.55, "ja"),
		"u" = list(2, 0.55, "ju"),
		"o" = list(2, 0.6, "jo"),
		"e" = list(2, 0.4, "je"),
		"i" = list(2, 0.7, "ji")
	)
	/// E twice, e at the start of a word or after a vowel, e after a consonant.
	var/list/e_readings = list(
		"double" = list(2, 0.6, "ee"),
		"start" = list(1, 0.85, "e"),
		"consonant" = list(1, 0.88, "e")
	)
	/// Other letters with more than one spelling.
	var/list/other_readings = list(
		"final_l" = list(1, 0.94, "l"),
		"soft_c" = list(1, 0.5, "s"),
		"hard_c" = list(1, 0.85, "k"),
		"y_after_vowel" = list(1, 0.8, "j"),
		"y" = list(1, 0.5, "i"),
		"h" = list(1, 0.9, "h"),
		"j" = list(1, 0.5, "dZ"),
		"w" = list(1, 0.6, "v")
	)
	/// Letters with one spelling, filled by fill_plain_letters(): list(letter = list(1, 1, letter)).
	var/list/plain_letters
	var/list/separators = list("'" = TRUE, "-" = TRUE, "." = TRUE, " " = TRUE)
	/// Vowels, both as letters and as sounds.
	var/list/vowels = list("a" = TRUE, "e" = TRUE, "i" = TRUE, "o" = TRUE, "u" = TRUE, "y" = TRUE)

	/// Two consonant sounds that end a Russian word easily.
	var/list/easy_final_pairs = list(
		"ks" = TRUE, "sk" = TRUE, "st" = TRUE, "rk" = TRUE, "rt" = TRUE, "rm" = TRUE,
		"rs" = TRUE, "rn" = TRUE, "rl" = TRUE, "rg" = TRUE, "rd" = TRUE, "lk" = TRUE,
		"lt" = TRUE, "lm" = TRUE, "ls" = TRUE, "nk" = TRUE, "nt" = TRUE, "ns" = TRUE,
		"ps" = TRUE, "ms" = TRUE, "kt" = TRUE, "zm" = TRUE, "sm" = TRUE
	)
	/// Penalty against ease by the number of consonant sounds in a row.
	var/list/start_cluster_penalties = list(0, 0, 0.2, 0.6)
	var/list/middle_cluster_penalties = list(0, 0, 0.1, 0.4, 0.8)
	var/list/end_cluster_penalties = list(0, 0.15, 0.5)
	/// Other penalties against ease.
	var/list/ease_penalties = list(
		"no_vowel" = 0.6,
		"three_vowels" = 0.15,
		"four_vowels" = 0.4,
		"tripled_letter" = 0.5,
		"kv_before_consonant" = 0.25,
		"ksks" = 0.3,
		"doubled_vowels" = 0.1
	)

	/// Three letters in a row, two of Q, X and Z together, or a syllable said twice (Volvol).
	var/regex/bad_shape_pattern
	/// A word with any of these looks Skrell.
	var/regex/skrell_mark_pattern
	var/regex/separator_pattern


// Setup, on first use: the syllable table and the look models.

/singleton/skrell_name_generator/Initialize()
	..()
	bad_shape_pattern = regex(@"(.)\1\1|[qxz][qxz]|([a-z]{2,})['-]?\2")
	skrell_mark_pattern = regex(@"[qxz]|rr|uu|ii|oo|'")
	separator_pattern = regex(@"['.-]")
	fill_plain_letters()
	build_syllable_table()
	var/list/game_words = get_game_syllable_pairs()
	train_look_models(game_words)
	look_floor = get_average_look_logp(human_names)
	look_ceiling = get_average_look_logp(lore_words + game_words)


/singleton/skrell_name_generator/proc/fill_plain_letters()
	plain_letters = list()
	var/letters = "abdfgiklmnoprstuvz"
	for(var/position = 1 to length(letters))
		var/letter = copytext(letters, position, position + 1)
		plain_letters[letter] = list(1, 1, letter)


/// Fills syllable_table so that each syllable appears by its weight within its list
/// and by the share of its list.
/singleton/skrell_name_generator/proc/build_syllable_table()
	syllable_table = list()
	var/list/syllable_lists = list(game_syllables, eased_syllables, lore_syllables)
	for(var/index = 1 to length(syllable_lists))
		var/list/syllables = syllable_lists[index]
		var/list_weight = 0
		for(var/syllable in syllables)
			list_weight += syllables[syllable]
		var/copies_per_weight = SKRELL_NAME_SYLLABLE_TABLE_SIZE * syllable_list_shares[index] / list_weight
		for(var/syllable in syllables)
			for(var/copy = 1 to round(syllables[syllable] * copies_per_weight, 1))
				syllable_table += syllable


/// Every two-syllable word of the game's own Skrell name generator.
/singleton/skrell_name_generator/proc/get_game_syllable_pairs()
	RETURN_TYPE(/list)
	var/datum/language/skrell/language = all_languages[LANGUAGE_SKRELLIAN]
	var/regex/word_syllable = regex(@"^[a-z'-]+$")
	var/list/syllables = list()
	for(var/syllable in language.syllables)
		if(word_syllable.Find(syllable))
			syllables += syllable
	. = list()
	for(var/first in syllables)
		for(var/second in syllables)
			. += first + second


/// Trains game_model on the game's two-syllable words and lore_model on lore_words.
/singleton/skrell_name_generator/proc/train_look_models(list/game_words)
	game_model = new
	lore_model = new
	if(length(game_words))
		var/word_weight = SKRELL_NAME_GAME_TRAINING_WORDS / length(game_words)
		for(var/word in game_words)
			game_model.add_word(word, word_weight)
	for(var/word in lore_words)
		lore_model.add_word(word, 1)


// Making a name: the word pool and the best combination of its words.

/// A new Skrell name of word_count words, or null if no combination passed.
/singleton/skrell_name_generator/proc/make_name(word_count = 2)
	if(word_count < 1)
		return
	var/list/pool = make_word_pool(word_count)
	if(length(pool) < word_count)
		return
	var/list/indices = list()
	for(var/index = 1 to word_count)
		indices += index
	var/best_name
	var/best_score = -1
	do
		var/score = get_combination_score(pool, indices)
		if(!isnull(score) && score > best_score)
			best_score = score
			best_name = get_combination_name(pool, indices)
	while(next_combination(indices, length(pool)))
	return best_name


/// Random words that could be part of a word_count-word name:
/// list(list(word, clarity, ease, look), ...). Words that differ only by an
/// apostrophe or a hyphen are kept once.
/singleton/skrell_name_generator/proc/make_word_pool(word_count)
	RETURN_TYPE(/list)
	. = list()
	var/min_word_clarity = SKRELL_NAME_MIN_CLARITY ** (word_count / 2)
	var/list/seen_words = list()
	for(var/index = 1 to SKRELL_NAME_POOL_SIZE)
		var/word = make_word()
		var/letters_only = lowertext(replacetext(replacetext(word, "'", ""), "-", ""))
		if(seen_words[letters_only] || !is_good_shape(word))
			continue
		seen_words[letters_only] = TRUE
		var/list/reading = get_reading(word)
		var/ease = get_ease(reading[2])
		if(reading[1] < min_word_clarity || ease < SKRELL_NAME_MIN_EASE)
			continue
		. += list(list(word, reading[1], ease, get_look(word)))


/// Moves indices to the next combination of length(indices) out of pool_size, in
/// lexicographic order. FALSE after the last one.
/singleton/skrell_name_generator/proc/next_combination(list/indices, pool_size)
	var/count = length(indices)
	for(var/position = count to 1 step -1)
		if(indices[position] < pool_size - count + position)
			indices[position]++
			for(var/later = position + 1 to count)
				indices[later] = indices[later - 1] + 1
			return TRUE
	return FALSE


/// Score of the name made of the pool words at indices, or null if it does not fit
/// the name field, is too hard to read or say, or too little Skrell.
/singleton/skrell_name_generator/proc/get_combination_score(list/pool, list/indices)
	var/word_count = length(indices)
	var/name_length = word_count - 1
	var/clarity = 1
	var/ease = 1
	var/look = 0
	for(var/index in indices)
		var/list/entry = pool[index]
		name_length += length(entry[SKRELL_POOL_WORD])
		clarity *= entry[SKRELL_POOL_CLARITY]
		ease = min(ease, entry[SKRELL_POOL_EASE])
		look += entry[SKRELL_POOL_LOOK]
	look /= word_count
	if(name_length > MAX_NAME_LEN || clarity < SKRELL_NAME_MIN_CLARITY ** (word_count / 2) || ease < SKRELL_NAME_MIN_EASE || look < SKRELL_NAME_MIN_LOOK)
		return null
	var/clear_enough = SKRELL_NAME_CLEAR_ENOUGH ** word_count
	return SKRELL_NAME_CLARITY_SHARE * min(1, clarity / clear_enough) + SKRELL_NAME_EASE_SHARE * ease + SKRELL_NAME_LOOK_SHARE * look


/// The name made of the pool words at indices.
/singleton/skrell_name_generator/proc/get_combination_name(list/pool, list/indices)
	var/list/words = list()
	for(var/index in indices)
		var/list/entry = pool[index]
		words += entry[SKRELL_POOL_WORD]
	return jointext(words, " ")


// Making one word.

/// TRUE for a word of 3 to 13 letters with one separator at most and no bad_shape_pattern.
/singleton/skrell_name_generator/proc/is_good_shape(word)
	var/lower_word = lowertext(word)
	var/separator_count = 0
	for(var/position = 1 to length(lower_word))
		var/letter = copytext(lower_word, position, position + 1)
		if(letter == "'" || letter == "-")
			separator_count++
	var/letter_count = length(lower_word) - separator_count
	if(letter_count < 3 || letter_count > 13 || separator_count > 1)
		return FALSE
	return !bad_shape_pattern.Find(lower_word)


/// A random word of one to three syllables, sometimes split by an apostrophe or a hyphen.
/singleton/skrell_name_generator/proc/make_word()
	var/roll = rand()
	var/syllable_count = roll < 0.08 ? 1 : (roll < 0.62 ? 2 : 3)
	var/list/parts = list()
	for(var/index = 1 to syllable_count)
		parts += pick_syllable(index == 1)
	if(syllable_count == 1 && length(parts[1]) < 4)
		parts += pick_syllable(FALSE)
	var/word = jointext(parts, null)
	if(length(parts) > 1 && !findtext(word, "'") && !findtext(word, "-") && prob(SKRELL_NAME_SEPARATOR_CHANCE))
		word = join_with_separator(parts)
	return capitalize(word)


/// Joins the parts with one apostrophe or hyphen between two of them, like Qerr'vola.
/singleton/skrell_name_generator/proc/join_with_separator(list/parts)
	var/cut = rand(1, length(parts) - 1)
	var/separator = prob(SKRELL_NAME_HYPHEN_CHANCE) ? "-" : "'"
	var/right = jointext(parts.Copy(cut + 1), null)
	if(separator == "-" || prob(SKRELL_NAME_CAPITAL_AFTER_APOSTROPHE_CHANCE))
		right = capitalize(right)
	return jointext(parts.Copy(1, cut + 1), null) + separator + right


/// A weighted random syllable; a word does not start with a vowel (Uum, Ix).
/singleton/skrell_name_generator/proc/pick_syllable(first)
	var/syllable = pick(syllable_table)
	for(var/attempt = 1 to 20)
		if(!first || !vowels[copytext(syllable, 1, 2)])
			return syllable
		syllable = pick(syllable_table)
	return syllable


// Clarity: reading a word the way Russian players would, by the tables at the top.

/// list(share of Russian players who would write the word's usual spelling, its sounds)
/singleton/skrell_name_generator/proc/get_reading(word)
	RETURN_TYPE(/list)
	var/lower_word = lowertext(word)
	var/word_length = length(lower_word)
	var/clarity = 1
	var/sounds = ""
	var/position = 1
	while(position <= word_length)
		var/list/group = read_letter_group(lower_word, position)
		position += group[1]
		clarity *= group[2]
		sounds += group[3]
	return list(clarity, sounds)


/// The letter group of a lowercase word at position: list(letters used, share of
/// players writing the usual spelling, its sounds).
/singleton/skrell_name_generator/proc/read_letter_group(word, position)
	RETURN_TYPE(/list)
	var/letter = copytext(word, position, position + 1)
	var/next = copytext(word, position + 1, position + 2)
	var/after_next = copytext(word, position + 2, position + 3)
	var/previous = position > 1 ? copytext(word, position - 1, position) : ""
	var/at_start = !previous || separators[previous]
	var/at_end = !next || separators[next]
	if(separators[letter])
		return list(1, 1, letter)
	if(letter == "q")
		return read_q(next, after_next, at_end)
	if(letter == "x")
		return read_x(next, at_start, at_end)
	if(letter_pairs[letter + next])
		return letter_pairs[letter + next]
	if(vowel_before_i[letter] && next == "i" && !vowels[after_next])
		return (letter == "e" && (at_start || vowels[previous])) ? ei_at_start : vowel_before_i[letter]
	if(letter == "y" && y_before_vowel[next])
		return y_before_vowel[next]
	if(letter == "e")
		return e_readings[next == "e" ? "double" : ((at_start || vowels[previous]) ? "start" : "consonant")]
	return read_consonant(letter, next, previous, at_start, at_end)


/// Reading of a Q, from q_before_vowel, qu_before_vowel or q_other.
/singleton/skrell_name_generator/proc/read_q(next, after_next, at_end)
	RETURN_TYPE(/list)
	if(next == "u")
		return qu_before_vowel[after_next] || q_other["u"]
	if(next == "o" && after_next == "o")
		return q_other["oo"]
	return q_before_vowel[next] || q_other[at_end ? "end" : "consonant"]


/// Reading of an X, from x_readings.
/singleton/skrell_name_generator/proc/read_x(next, at_start, at_end)
	RETURN_TYPE(/list)
	if(at_end)
		return x_readings["end"]
	if(vowels[next])
		return x_readings[at_start ? "start" : "vowel"]
	return x_readings["consonant"]


/// Reading of any other letter, from plain_letters or other_readings.
/singleton/skrell_name_generator/proc/read_consonant(letter, next, previous, at_start, at_end)
	RETURN_TYPE(/list)
	if(letter == "l" && (at_end || !vowels[next]))
		return other_readings["final_l"]
	if(plain_letters[letter])
		return plain_letters[letter]
	if(letter == "c")
		return other_readings[(next == "e" || next == "i" || next == "y") ? "soft_c" : "hard_c"]
	if(letter == "y")
		return other_readings[(vowels[previous] && !at_start) ? "y_after_vowel" : "y"]
	return other_readings[letter] || list(1, 1, letter)


// Ease: penalties for hard-to-say sounds, taken off 1.

/// How easy a word is to say for a Russian reader, from 0 to 1, judged by its sounds.
/singleton/skrell_name_generator/proc/get_ease(sounds)
	var/penalty = 0
	var/letter_count = 0
	for(var/part in splittext(sounds, separator_pattern))
		if(!part)
			continue
		letter_count += length(part)
		penalty += get_part_penalty(part)
	penalty += get_length_penalty(letter_count)
	if(count_doubled_vowels(sounds) >= 2)
		penalty += ease_penalties["doubled_vowels"]
	return max(0, 1 - penalty)


/// Penalty for a very short or long word, by its number of sounds.
/singleton/skrell_name_generator/proc/get_length_penalty(letter_count)
	switch(letter_count)
		if(0 to 2)
			return 0.4
		if(10 to 11)
			return 0.1
		if(12 to 13)
			return 0.25
		if(14 to INFINITY)
			return 0.5
	return 0


/// Penalty for one part of a word between apostrophes or hyphens.
/singleton/skrell_name_generator/proc/get_part_penalty(part)
	if(!has_vowel(part))
		return ease_penalties["no_vowel"]
	var/part_length = length(part)
	var/penalty = 0
	var/run_start = 1
	for(var/position = 1 to part_length)
		var/is_vowel = is_vowel_at(part, position)
		if(position < part_length && is_vowel_at(part, position + 1) == is_vowel)
			continue
		var/run = copytext(part, run_start, position + 1)
		if(is_vowel)
			penalty += get_vowel_run_penalty(length(run))
		else
			penalty += get_cluster_penalty(run, run_start == 1, position == part_length)
		run_start = position + 1
	return penalty + get_pattern_penalty(part)


/singleton/skrell_name_generator/proc/has_vowel(sounds)
	for(var/position = 1 to length(sounds))
		if(is_vowel_at(sounds, position))
			return TRUE
	return FALSE


/singleton/skrell_name_generator/proc/is_vowel_at(sounds, position)
	return vowels[copytext(sounds, position, position + 1)] ? TRUE : FALSE


/singleton/skrell_name_generator/proc/get_vowel_run_penalty(vowel_count)
	if(vowel_count >= 4)
		return ease_penalties["four_vowels"]
	if(vowel_count == 3)
		return ease_penalties["three_vowels"]
	return 0


/// Penalty for consonant sounds in a row; a doubled sound like rr counts once.
/singleton/skrell_name_generator/proc/get_cluster_penalty(run, at_start, at_end)
	var/sounds = collapse_doubles(run)
	var/sound_count = length(sounds)
	if(at_start)
		if(sound_count == 3 && copytext(run, 1, 2) == "s")
			return 0
		return start_cluster_penalties[min(sound_count, length(start_cluster_penalties))]
	if(at_end)
		if(sound_count == 2 && easy_final_pairs[sounds])
			return 0
		return end_cluster_penalties[min(sound_count, length(end_cluster_penalties))]
	return middle_cluster_penalties[min(sound_count, length(middle_cluster_penalties))]


/singleton/skrell_name_generator/proc/collapse_doubles(run)
	. = ""
	var/run_length = length(run)
	var/position = 1
	while(position <= run_length)
		var/sound = copytext(run, position, position + 1)
		. += sound
		position += copytext(run, position + 1, position + 2) == sound ? 2 : 1


/singleton/skrell_name_generator/proc/get_pattern_penalty(part)
	. = 0
	if(has_tripled_sound(part))
		. += ease_penalties["tripled_letter"]
	if(has_kv_before_consonant(part))
		. += ease_penalties["kv_before_consonant"]
	if(findtextEx(part, "ksks"))
		. += ease_penalties["ksks"]


/singleton/skrell_name_generator/proc/has_tripled_sound(sounds)
	for(var/position = 1 to length(sounds) - 2)
		var/sound = copytext(sounds, position, position + 1)
		if(copytext(sounds, position + 1, position + 2) == sound && copytext(sounds, position + 2, position + 3) == sound)
			return TRUE
	return FALSE


/singleton/skrell_name_generator/proc/has_kv_before_consonant(sounds)
	var/position = findtextEx(sounds, "kv")
	while(position)
		if(!vowels[copytext(sounds, position + 2, position + 3)])
			return TRUE
		position = findtextEx(sounds, "kv", position + 1)
	return FALSE


/// Pairs of the same vowel sound, counted without overlaps.
/singleton/skrell_name_generator/proc/count_doubled_vowels(sounds)
	. = 0
	var/sounds_length = length(sounds)
	var/position = 1
	while(position < sounds_length)
		var/sound = copytext(sounds, position, position + 1)
		if(vowels[sound] && copytext(sounds, position + 1, position + 2) == sound)
			.++
			position += 2
		else
			position++


// Look: how close a word is to the game's words and lore names.

/// How Skrell the word looks: 0 for a human name, about 0.85 for a typical Skrell word.
/singleton/skrell_name_generator/proc/get_look(word)
	var/look = (get_look_logp(word) - look_floor) / (look_ceiling - look_floor) * SKRELL_NAME_TYPICAL_LOOK
	if(!skrell_mark_pattern.Find(lowertext(word)))
		look *= SKRELL_NAME_UNMARKED_LOOK
	return clamp(look, 0, 1)


/// Average log chance per letter of the word under the game and lore models.
/singleton/skrell_name_generator/proc/get_look_logp(word)
	var/padded = "^^[lowertext(word)]$"
	var/total = 0
	for(var/position = 3 to length(padded))
		total += get_log_chance(copytext(padded, position - 2, position + 1))
	return total / (length(padded) - 2)


/// Log chance of the last letter of a three-letter trigram after the first two.
/singleton/skrell_name_generator/proc/get_log_chance(trigram)
	. = look_log_chances[trigram]
	if(!isnull(.))
		return
	var/history = copytext(trigram, 1, 3)
	var/letter = copytext(trigram, 3, 4)
	var/game_chance = game_model.get_chance(history, letter)
	var/lore_chance = lore_model.get_chance(history, letter)
	. = log(SKRELL_NAME_GAME_LOOK_SHARE * game_chance + (1 - SKRELL_NAME_GAME_LOOK_SHARE) * lore_chance)
	look_log_chances[trigram] = .


/singleton/skrell_name_generator/proc/get_average_look_logp(list/words)
	var/total = 0
	for(var/word in words)
		total += get_look_logp(word)
	return total / length(words)

#undef SKRELL_NAME_POOL_SIZE
#undef SKRELL_POOL_WORD
#undef SKRELL_POOL_CLARITY
#undef SKRELL_POOL_EASE
#undef SKRELL_POOL_LOOK
#undef SKRELL_NAME_SYLLABLE_TABLE_SIZE
#undef SKRELL_NAME_MIN_CLARITY
#undef SKRELL_NAME_CLEAR_ENOUGH
#undef SKRELL_NAME_MIN_EASE
#undef SKRELL_NAME_MIN_LOOK
#undef SKRELL_NAME_CLARITY_SHARE
#undef SKRELL_NAME_EASE_SHARE
#undef SKRELL_NAME_LOOK_SHARE
#undef SKRELL_NAME_TYPICAL_LOOK
#undef SKRELL_NAME_UNMARKED_LOOK
#undef SKRELL_NAME_GAME_LOOK_SHARE
#undef SKRELL_NAME_GAME_TRAINING_WORDS
#undef SKRELL_NAME_SEPARATOR_CHANCE
#undef SKRELL_NAME_HYPHEN_CHANCE
#undef SKRELL_NAME_CAPITAL_AFTER_APOSTROPHE_CHANCE
