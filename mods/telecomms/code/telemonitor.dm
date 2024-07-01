/obj/machinery/computer/telecomms/monitor/interface_interact(mob/user)
	interact(user)
	return TRUE

/obj/machinery/computer/telecomms/monitor/interact(mob/user)
	attack_hand(user)

///obj/machinery/computer/telecomms/monitor/OnTopic(mob/user, list/href_list, datum/topic_state/state)
	//Topic(state, href_list)
