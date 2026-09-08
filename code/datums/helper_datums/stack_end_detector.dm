/**
 * Stack End Detector
 *
 * Detects if the code stack has exited, indicating a stack overflow.
 * Works by storing a canary datum in a local variable of the proc being monitored.
 * If that proc's stack frame is destroyed (e.g. by stack overflow), BYOND will
 * garbage collect the canary, and the weak reference will no longer resolve.
 *
 * Ported from tgstation/tgstation#56008
 */

/datum/stack_end_detector
	var/weakref/_WF
	var/datum/stack_canary/_canary

/datum/stack_end_detector/proc/prime_canary()
	_canary = new
	_WF = weakref(_canary)
	return _canary

/datum/stack_end_detector/proc/check()
	return !!_WF.resolve()

/datum/stack_canary
	/// Exists so the compiler doesn't optimize away the local variable holding this datum.
	var/use_me

/datum/stack_canary/proc/use_variable()
	use_me = TRUE
