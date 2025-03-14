/**
 * Managed Globals datum. Any defined global vars can be accessed via `GLOB.varname`.
 *
 * New globals can be defined on the global scope (Outside of any class definitions)
 * via the following `GLOBAL_*()` macros
 */

VAR_FINAL/global/datum/globals/GLOB


/datum/globals/Destroy()
	SHOULD_CALL_PARENT(FALSE)
	return QDEL_HINT_LETMELIVE


/datum/globals/VV_hidden(add_var_name)
	var/static/list/result
	if (!result)
		var/datum/temp = new
		result = temp.vars + list()
	if (istext(add_var_name))
		result += add_var_name
		return
	return result.Copy()


/datum/globals/New()
	var/static/already_run
	if (already_run)
		return
	already_run = TRUE
	var/list/priorities = list()
	var/list/initializers = list()
	var/canary = length("[type]/proc/") + 1
	for (var/runnable in typesof(/datum/globals/proc))
		var/name = "[runnable]"
		if (name[canary] != "_")
			continue
		var/inserted = FALSE
		var/priority = text2num(copytext(name, canary + 1, canary + 3))
		var/index = 1
		for (var/entry in priorities)
			if (entry > priority)
				initializers.Insert(index, runnable)
				priorities.Insert(index, priority)
				inserted = TRUE
				break
			++index
		if (!inserted)
			initializers += runnable
			priorities += priority
	for (var/runnable in initializers)
		var/start = world.time
		call(src, runnable)()
		if (world.time == start)
			continue
		log_debug("[runnable] slept!")


/// Hides GLOB.NAME from View Variables. Should not share step 99 with anything else.
#define GLOBAL_PROTECT(NAME) /datum/globals/proc/_99##NAME() { VV_hidden(#NAME) }


/// Defines GLOB.NAME as the constant VALUE
#define GLOBAL_CONST(NAME, VALUE) /datum/globals/var/const/##NAME = ##VALUE


/// Defines GLOB.NAME as an empty variable
#define GLOBAL_VAR(NAME) /datum/globals/var/static/##NAME;

/// Defines GLOB.NAME and an init context to run at init step STEP
#define GLOBAL_VAR_INIT_STEP(NAME, STEP) GLOBAL_VAR(NAME) /datum/globals/proc/_##STEP##NAME()

/// Defines GLOB.NAME and an init context to run at init step 50
#define GLOBAL_VAR_INIT(NAME) GLOBAL_VAR_INIT_STEP(NAME, 50)

/// Defines GLOB.NAME and sets it to VALUE at init step STEP. VALUE may be computed
#define GLOBAL_VAR_AS_STEP(NAME, STEP, VALUE) GLOBAL_VAR_INIT_STEP(NAME, STEP) { ##NAME = ##VALUE; }

/// Defines GLOB.NAME and sets it to VALUE at init step 50. VALUE may be computed
#define GLOBAL_VAR_AS(NAME, VALUE) GLOBAL_VAR_AS_STEP(NAME, 50, VALUE)


/// Defines GLOB.NAME as an empty variable with hint TYPE
#define GLOBAL_TYPED(NAME, TYPE) /datum/globals/var/static##TYPE/##NAME;

/// Defines GLOB.NAME with hint TYPE and an init context to run at init step STEP
#define GLOBAL_TYPED_INIT_STEP(NAME, TYPE, STEP) GLOBAL_TYPED(NAME, TYPE) /datum/globals/proc/_##STEP##NAME()

/// Defines GLOB.NAME with hint TYPE and an init context to run at init step 50
#define GLOBAL_TYPED_INIT(NAME, TYPE) GLOBAL_TYPED_INIT_STEP(NAME, TYPE, 50)

/// Defines GLOB.NAME with hint TYPE and sets it to VALUE at init step STEP. VALUE may be computed
#define GLOBAL_TYPED_AS_STEP(NAME, TYPE, STEP, VALUE) GLOBAL_TYPED_INIT_STEP(NAME, TYPE, STEP) { ##NAME = ##VALUE; }

/// Defines GLOB.NAME with hint TYPE and sets it to VALUE at init step 50. VALUE may be computed
#define GLOBAL_TYPED_AS(NAME, TYPE, VALUE) GLOBAL_TYPED_AS_STEP(NAME, TYPE, 50, VALUE)

/// Defines GLOB.NAME with hint TYPE and argless new's TYPE into it at init step STEP
#define GLOBAL_TYPED_NEW_STEP(NAME, TYPE, STEP) GLOBAL_TYPED_AS_STEP(NAME, TYPE, STEP, new)

/// Defines GLOB.NAME with hint TYPE and argless new's TYPE into it at init step 50
#define GLOBAL_TYPED_NEW(NAME, TYPE) GLOBAL_TYPED_NEW_STEP(NAME, TYPE, 50)


/// Defines GLOB.NAME as an empty variable with hint /list
#define GLOBAL_LIST(NAME) GLOBAL_TYPED(NAME, /list)

/// Defines GLOB.NAME with hint /list and an init context to run at init step STEP
#define GLOBAL_LIST_INIT_STEP(NAME, STEP) GLOBAL_LIST(NAME) /datum/globals/proc/_##STEP##NAME()

/// Defines GLOB.NAME with hint /list and an init context to run at init step 50
#define GLOBAL_LIST_INIT(NAME) GLOBAL_LIST_INIT_STEP(NAME, 50)

/// Defines GLOB.NAME with hint /list and sets it to VALUE at init step STEP. VALUE may be computed
#define GLOBAL_LIST_AS_STEP(NAME, STEP, VALUE) GLOBAL_LIST_INIT_STEP(NAME, STEP) { ##NAME = ##VALUE; }

/// Defines GLOB.NAME with hint /list and sets it to VALUE at init step 50. VALUE may be computed
#define GLOBAL_LIST_AS(NAME, VALUE) GLOBAL_LIST_AS_STEP(NAME, 50, VALUE)

/// Defines GLOB.NAME with hint /list and sets it to list() at init step 0
#define GLOBAL_LIST_EMPTY(NAME) GLOBAL_LIST_AS_STEP(NAME, 0, list())


#if DM_VERSION > 515

/// Defines GLOB.NAME as an empty variable with hint /alist
#define GLOBAL_ALIST(NAME) GLOBAL_TYPED(NAME, /alist)

/// Defines GLOB.NAME with hint /alist and an init context to run at init step STEP
#define GLOBAL_ALIST_INIT_STEP(NAME, STEP) GLOBAL_ALIST(NAME) /datum/globals/proc/_##STEP##NAME()

/// Defines GLOB.NAME with hint /alist and an init context to run at init step 50
#define GLOBAL_ALIST_INIT(NAME) GLOBAL_ALIST_INIT_STEP(NAME, 50)

/// Defines GLOB.NAME with hint /alist and sets it to VALUE at init step STEP. VALUE may be computed
#define GLOBAL_ALIST_AS_STEP(NAME, STEP, VALUE) GLOBAL_ALIST_INIT_STEP(NAME, STEP) { ##NAME = ##VALUE; }

/// Defines GLOB.NAME with hint /alist and sets it to VALUE at init step 50. VALUE may be computed
#define GLOBAL_ALIST_AS(NAME, VALUE) GLOBAL_ALIST_AS_STEP(NAME, 50, VALUE)

/// Defines GLOB.NAME with hint /alist and sets it to alist() at init step 0
#define GLOBAL_ALIST_EMPTY(NAME) GLOBAL_ALIST_AS_STEP(NAME, 0, alist())

#endif


#if DM_VERSION > 514

/// Defines a static init context for TYPE to run at init step STEP. Use src:: to access static vars. TAG must be unique
#define STATIC_INIT_STEP(TYPE, STEP, TAG) /datum/globals/proc/_##STEP##TAG() { \
		call(##TYPE, ##TYPE::__Static##TAG())() \
	} ##TYPE/proc/__Static##TAG()

/// Defines a static init context for TYPE to run at init step 50. Use src:: to access static vars. TAG must be unique
#define STATIC_INIT(TYPE, TAG) STATIC_INIT_STEP(TYPE, 50, TAG)

#endif