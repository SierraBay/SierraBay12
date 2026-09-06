/obj/item/stock_parts/computer/scanner/medical
	name = "medical scanner module"
	desc = "A medical scanner module. It can be used to scan patients and display medical information."
	scan_beam_color = "#4dce62" //[SIERRA-ADD] RND

/obj/item/stock_parts/computer/scanner/medical/do_on_afterattack(mob/user, atom/target, proximity)
	if(!can_use_scanner(user, target, proximity))
		return
	if(!do_scan_animation(user, target)) //[SIERRA-ADD] RND
		return

	var/dat = medical_scan_action(target, user, loc, 1)

	if(dat && driver && driver.using_scanner)
		playsound(src, 'sound/effects/fastbeep.ogg', 20)
		driver.data_buffer = html2pencode(dat)
		SSnano.update_uis(driver.NM)
