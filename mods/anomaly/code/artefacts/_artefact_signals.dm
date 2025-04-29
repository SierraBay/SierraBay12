/obj/item/artefact/proc/deploy_signals()
	RegisterSignal(current_user, COMSIG_MOB_BUMPED, PROC_REF(user_bumped_at_atom))

/obj/item/artefact/proc/undeploy_signals()
	UnregisterSignal(current_user, COMSIG_MOB_BUMPED)
