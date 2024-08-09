/obj/machinery/telecomms/server
	var/rawcode = ""	// the code to compile (raw text)
	var/datum/TCS_Compiler/Compiler	// the compiler that compiles and runs the code
	var/autoruncode = 0		// 1 if the code is set to run every time a signal is picked up

/obj/machinery/telecomms/server/New()
	..()
	Compiler = new()
	Compiler.Holder = src
	server_radio = new()

/obj/machinery/telecomms/server/proc/setcode(t)
	if(t)
		if(istext(t))
			rawcode = t

/obj/machinery/telecomms/server/proc/compile()
	if(Compiler)
		return Compiler.Compile(rawcode)

/obj/machinery/telecomms/server/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	if(signal.data["message"])
		if(is_freq_listening(signal))
			if(traffic > 0)
				totaltraffic += traffic // add current traffic to total traffic

			// channel tag the signal
			var/list/data = get_channel_info(signal.frequency)
			signal.data["channel_tag"] = data[1]
			signal.data["channel_color"] = data[2]

			//Is this a test signal? Bypass logging
			if(signal.data["type"] != 4)

				// If signal has a message and appropriate frequency

				update_logs()

				var/datum/comm_log_entry/log = new
				var/mob/M = signal.data["mob"]

				// Copy the signal.data entries we want
				log.parameters["mobtype"] = signal.data["mobtype"]
				log.parameters["job"] = signal.data["job"]
				log.parameters["key"] = signal.data["key"]
				log.parameters["vmessage"] = signal.data["message"]
				log.parameters["vname"] = signal.data["vname"]
				log.parameters["message"] = signal.data["message"]
				log.parameters["name"] = signal.data["name"]
				log.parameters["realname"] = signal.data["realname"]
				log.parameters["language"] = signal.data["language"]

				var/race = "Unknown"
				if(ishuman(M) || isbrain(M))
					race = "Sapient Race"
					log.parameters["intelligible"] = 1
				else if(M.is_species(SPECIES_MONKEY))
					race = "Monkey"
				else if(issilicon(M))
					race = "Artificial Life"
					log.parameters["intelligible"] = 1
				else if(isslime(M))
					race = "Slime"
				else if(isanimal(M))
					race = "Domestic Animal"

				log.parameters["race"] = race

				if(!istype(M, /mob/new_player) && M)
					log.parameters["uspeech"] = M.universal_speak
				else
					log.parameters["uspeech"] = 0

				// If the signal is still compressed, make the log entry gibberish
				if(signal.data["compression"] > 0)
					log.parameters["message"] = Gibberish(signal.data["message"], signal.data["compression"] + 50)
					log.parameters["job"] = Gibberish(signal.data["job"], signal.data["compression"] + 50)
					log.parameters["name"] = Gibberish(signal.data["name"], signal.data["compression"] + 50)
					log.parameters["realname"] = Gibberish(signal.data["realname"], signal.data["compression"] + 50)
					log.parameters["vname"] = Gibberish(signal.data["vname"], signal.data["compression"] + 50)
					log.input_type = "Corrupt File"

				// Log and store everything that needs to be logged
				log_entries.Add(log)
				if(!(signal.data["name"] in stored_names))
					stored_names.Add(signal.data["name"])
				logs++
				signal.data["server"] = src

				// Give the log a name
				var/identifier = num2text( rand(-1000,1000) + world.time )
				log.name = "data packet ([md5(identifier)])"

				// [SIERRA-ADD] - MODPACK_TELECOMMS - (Нельзя переписать функцию так, чтобы родитель не вызывался)
				if(Compiler && autoruncode)
					Compiler.Run(signal)
				// [SIERRA-ADD]

			var/can_send = relay_information(signal, /obj/machinery/telecomms/hub)
			if(!can_send)
				relay_information(signal, /obj/machinery/telecomms/broadcaster)
