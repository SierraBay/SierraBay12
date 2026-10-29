/datum/computer_file/program/mars
	filename = "mars"
	filedesc = "МАРС"
	extended_desc = "Мессенджер Авторизованной Радиосвязи Сьерры. Департаментские чаты и личные сообщения вместо гарнитуры. Работает, пока устройство включено и есть NTNet."
	program_icon_state = "command"
	program_key_state = "med_key"
	program_menu_icon = "comment"
	size = 2
	processing_size = 0
	requires_ntnet = TRUE
	requires_ntnet_feature = NTNET_COMMUNICATION
	network_destination = "MARS relay"
	available_on_ntnet = TRUE
	nanomodule_path = /datum/nano_module/program/mars
	ui_header = "ntnrc_idle.gif"
	usage_flags = PROGRAM_ALL | PROGRAM_NO_KILL
	category = PROG_UTIL
	var/username = "Абонент"
	var/account_id = "guest"
	var/job_title = "Гражданский"
	var/datum/mars_channel/open_channel
	var/list/last_seen = list()
	var/unread_total = 0
	var/muted = FALSE
	var/show_contacts = FALSE
	var/show_settings = FALSE
	var/avatar_id = "letter"
	var/icon/avatar_photo
	var/avatar_stamp = 0
	var/stored_login = ""
	var/stored_password = ""
	var/login_error = ""
	var/logged_in = FALSE

/datum/computer_file/program/mars/on_startup(mob/living/user, datum/extension/interactive/ntos/new_host)
	. = ..()
	if(!mars_network)
		mars_network = new
	mars_network.setup_channels()
	mars_network.register_client(src)
	try_login()

/datum/computer_file/program/mars/on_shutdown(forced = FALSE)
	if(mars_network)
		mars_network.unregister_client(src)
	open_channel = null
	if(!logged_in)
		stored_login = ""
		stored_password = ""
	logged_in = FALSE
	. = ..()

/datum/computer_file/program/mars/Destroy()
	if(mars_network)
		mars_network.unregister_client(src)
	open_channel = null
	logged_in = FALSE
	return ..()

/datum/computer_file/program/mars/process_tick()
	..()
	if(logged_in)
		refresh_identity()
	if(open_channel && !mars_network.channel_is_online(open_channel))
		open_channel = null
	recalc_unread()
	ui_header = unread_total ? "ntnrc_new.gif" : "ntnrc_idle.gif"

/datum/computer_file/program/mars/proc/is_online()
	if(!logged_in)
		return FALSE
	if(!computer || program_state == PROGRAM_STATE_KILLED)
		return FALSE
	if(!computer.get_ntnet_status(NTNET_COMMUNICATION))
		return FALSE
	return TRUE

/datum/computer_file/program/mars/proc/get_user()
	var/atom/host = computer?.get_physical_host()
	if(!host)
		return null
	return get_holder_of_type(host, /mob)

/datum/computer_file/program/mars/proc/get_id_email_login()
	var/atom/raw_host = computer?.get_physical_host()
	if(!istype(raw_host, /atom/movable))
		return null
	var/atom/movable/host = raw_host
	var/obj/item/card/id/id = host.GetIdCard()
	if(!id)
		var/mob/holder = get_holder_of_type(host, /mob)
		if(holder)
			id = holder.GetIdCard()
	if(!id || !id.associated_email_login)
		return null
	var/list/id_login = id.associated_email_login.Copy()
	if(!id_login["login"])
		return null
	return id_login

/datum/computer_file/program/mars/proc/find_email_account(login)
	if(!login || !ntnet_global)
		return null
	for(var/datum/computer_file/data/email_account/account in ntnet_global.email_accounts)
		if(!account || !account.can_login)
			continue
		if(account.login == login)
			return account
	return null

/datum/computer_file/program/mars/proc/try_login()
	login_error = ""
	var/list/id_login = get_id_email_login()
	var/use_login = stored_login
	var/use_pass = stored_password
	if(!use_login && id_login)
		use_login = id_login["login"]
	if(!use_pass && id_login)
		use_pass = id_login["password"]
	if(!use_login)
		logged_in = FALSE
		return FALSE
	var/datum/computer_file/data/email_account/account = find_email_account(use_login)
	if(!account)
		login_error = "Неверный логин"
		logged_in = FALSE
		return FALSE
	if(account.suspended)
		login_error = "Аккаунт заблокирован"
		logged_in = FALSE
		return FALSE
	if(use_pass != account.password)
		login_error = "Неверный пароль"
		logged_in = FALSE
		return FALSE
	stored_login = use_login
	stored_password = use_pass
	account_id = account.login
	if(account.fullname && account.fullname != "N/A")
		username = account.fullname
	else
		username = account.login
	if(account.assignment && account.assignment != "N/A")
		job_title = account.assignment
	else
		job_title = "Экипаж"
	logged_in = TRUE
	login_error = ""
	if(mars_network)
		mars_network.update_profile(src)
	return TRUE

/datum/computer_file/program/mars/proc/log_out()
	logged_in = FALSE
	open_channel = null
	show_contacts = FALSE
	show_settings = FALSE
	stored_login = ""
	stored_password = ""
	login_error = ""
	username = "Абонент"
	account_id = "guest"
	job_title = "Гражданский"
	unread_total = 0

/datum/computer_file/program/mars/proc/refresh_identity()
	if(!logged_in)
		return
	var/datum/computer_file/data/email_account/account = find_email_account(stored_login)
	if(!account || account.suspended || account.password != stored_password)
		log_out()
		login_error = "Сессия сброшена. Войдите снова."
		return
	var/old_id = account_id
	var/old_name = username
	var/old_job = job_title
	account_id = account.login
	if(account.fullname && account.fullname != "N/A")
		username = account.fullname
	else
		username = account.login
	if(account.assignment && account.assignment != "N/A")
		job_title = account.assignment
	else
		job_title = "Экипаж"
	if(mars_network && (old_id != account_id || old_name != username || old_job != job_title))
		mars_network.update_profile(src)

/datum/computer_file/program/mars/proc/can_see_channel(datum/mars_channel/channel)
	if(!channel)
		return FALSE
	if(channel.direct)
		return (account_id in channel.participant_ids)
	var/atom/host = computer?.get_physical_host()
	return mars_network.can_access_channel(host, channel)

/datum/computer_file/program/mars/proc/get_key_labels()
	var/list/names = list("Common", "Entertainment")
	var/atom/host = computer?.get_physical_host()
	for(var/obj/item/device/encryptionkey/key in mars_get_host_keys(host))
		for(var/ch_name in key.channels)
			names |= ch_name
	return jointext(names, ", ")

/datum/computer_file/program/mars/proc/recalc_unread()
	unread_total = 0
	if(!mars_network)
		return
	for(var/id in mars_network.channels)
		var/datum/mars_channel/channel = mars_network.channels[id]
		if(!can_see_channel(channel))
			continue
		var/seen = last_seen[id] || 0
		var/delta = channel.message_seq - seen
		if(delta > 0)
			unread_total += delta

/datum/computer_file/program/mars/proc/mark_seen(datum/mars_channel/channel)
	if(!channel)
		return
	last_seen[channel.id] = channel.message_seq
	recalc_unread()

/datum/computer_file/program/mars/proc/receive_message(datum/mars_channel/channel, datum/computer_file/program/mars/sender, rendered)
	var/list/listeners = get_listeners()
	for(var/mob/living/listener in listeners)
		to_chat(listener, rendered)
	if(sender == src)
		return
	if(open_channel == channel && program_state == PROGRAM_STATE_ACTIVE)
		mark_seen(channel)
	else
		recalc_unread()
	if(muted || !computer)
		return
	var/atom/host = computer.get_physical_host()
	if(istype(host, /obj/item/modular_computer/pda))
		var/obj/item/modular_computer/pda/pda = host
		pda.receive_notification("[channel.title]: [sender.username]")
	else
		computer.visible_notification("[channel.title]: [sender.username]")
		computer.audible_notification("sound/machines/twobeep.ogg")

/datum/computer_file/program/mars/proc/get_listeners()
	var/list/out = list()
	var/atom/host = computer?.get_physical_host()
	if(!host)
		return out
	var/mob/holder = get_holder_of_type(host, /mob)
	if(holder)
		out += holder
		return out
	for(var/mob/living/nearby in hearers(1, host))
		out += nearby
	return out

/datum/computer_file/program/mars/proc/send_text(text)
	if(!open_channel || !is_online())
		return FALSE
	if(!can_see_channel(open_channel))
		return FALSE
	text = sanitize(text, 512)
	if(!text)
		return FALSE
	return mars_network.post(open_channel, src, text)

/datum/computer_file/program/mars/proc/send_failure_reason()
	if(!is_online())
		return "МАРС: нет связи с ретранслятором."
	if(!open_channel)
		return "МАРС: канал не выбран."
	if(!mars_network.channel_is_online(open_channel))
		return "МАРС: канал «[open_channel.title]» недоступен — сервер связи отдела выключен или перегружен."
	if(!can_see_channel(open_channel))
		return "МАРС: нет доступа к каналу."
	return "МАРС: не удалось отправить."

/datum/computer_file/program/mars/proc/collect_sendable_files()
	var/list/out = list()
	if(!computer)
		return out
	var/list/disks = list(computer.get_component(PART_HDD), computer.get_component(PART_DRIVE))
	for(var/obj/item/stock_parts/computer/hard_drive/disk in disks)
		for(var/datum/computer_file/file in computer.get_all_files(FALSE, disk))
			if(file.unsendable || file.hidden)
				continue
			out |= file
	return out

/datum/computer_file/program/mars/proc/find_sendable_file(filename)
	for(var/datum/computer_file/file in collect_sendable_files())
		if(file.filename == filename)
			return file
	return null

/datum/computer_file/program/mars/proc/send_file_to_open_channel(mob/user)
	if(!open_channel || !is_online())
		computer.show_error(user, send_failure_reason())
		return TRUE
	if(!can_see_channel(open_channel))
		computer.show_error(user, send_failure_reason())
		return TRUE
	var/list/choices = list()
	for(var/datum/computer_file/file in collect_sendable_files())
		choices["[file.filename].[file.filetype] ([file.size]GQ)"] = file.filename
	if(!length(choices))
		computer.show_error(user, "МАРС: на диске нет файлов для отправки.")
		return TRUE
	var/picked = input(user, "Файл для отправки в «[open_channel.title]» (макс. 32GQ):", "МАРС") as null|anything in choices
	if(!picked || !open_channel)
		return TRUE
	var/datum/computer_file/file = find_sendable_file(choices[picked])
	if(!istype(file))
		computer.show_error(user, "МАРС: файл не найден.")
		return TRUE
	if(file.size > 32)
		computer.show_error(user, "МАРС: файл больше 32GQ.")
		return TRUE
	if(!mars_network.post(open_channel, src, null, "отправляет файл", file))
		computer.show_error(user, send_failure_reason())
		return TRUE
	mark_seen(open_channel)
	computer.visible_notification("Файл [file.filename].[file.filetype] отправлен.")
	return TRUE

/datum/computer_file/program/mars/proc/save_channel_file(file_uid, mob/user)
	if(!open_channel || !computer)
		return FALSE
	file_uid = text2num(file_uid)
	var/datum/computer_file/attachment
	for(var/list/entry in open_channel.messages)
		var/datum/computer_file/candidate = entry["file"]
		if(istype(candidate) && candidate.uid == file_uid)
			attachment = candidate
			break
	if(!attachment)
		computer.show_error(user, "МАРС: вложение уже недоступно.")
		return FALSE
	var/datum/computer_file/copy = attachment.clone()
	if(computer.get_file(copy.filename))
		copy.filename = "[copy.filename]_[copy.uid]"
	if(!computer.create_file(copy))
		computer.show_error(user, "МАРС: нет места на диске.")
		qdel(copy)
		return FALSE
	computer.visible_notification("Сохранено: [copy.filename].[copy.filetype].")
	return TRUE

/datum/computer_file/program/mars/Topic(href, href_list)
	if(..())
		return TOPIC_HANDLED

	if(href_list["PRG_edit_login"])
		var/newlogin = sanitize(input(usr, "Адрес почты NTNet:", "МАРС", stored_login) as text|null, 100)
		if(newlogin != null)
			stored_login = newlogin
			login_error = ""
		return TOPIC_HANDLED

	if(href_list["PRG_edit_password"])
		var/newpass = sanitize(input(usr, "Пароль:", "МАРС") as text|null, 100)
		if(newpass != null)
			stored_password = newpass
			login_error = ""
		return TOPIC_HANDLED

	if(href_list["PRG_login"])
		if(try_login())
			computer.visible_notification("МАРС: вход выполнен.")
		return TOPIC_HANDLED

	if(href_list["PRG_logout"])
		log_out()
		computer.visible_notification("МАРС: выход выполнен.")
		return TOPIC_HANDLED

	if(!logged_in)
		return TOPIC_HANDLED

	if(href_list["PRG_back"])
		open_channel = null
		show_contacts = FALSE
		show_settings = FALSE
		return TOPIC_HANDLED

	if(href_list["PRG_contacts"])
		show_contacts = TRUE
		show_settings = FALSE
		open_channel = null
		return TOPIC_HANDLED

	if(href_list["PRG_settings"])
		show_settings = TRUE
		show_contacts = FALSE
		open_channel = null
		return TOPIC_HANDLED

	if(href_list["PRG_avatar"])
		var/new_avatar = href_list["PRG_avatar"]
		if(new_avatar in mars_ui_avatars())
			if(new_avatar == "photo")
				if(!capture_avatar_photo())
					computer.show_error(usr, "МАРС: некого снимать. Возьмите устройство в руки.")
					return TOPIC_HANDLED
			else
				avatar_id = new_avatar
				if(mars_network)
					mars_network.update_profile(src)
		return TOPIC_HANDLED

	if(href_list["PRG_photo"])
		if(capture_avatar_photo())
			computer.visible_notification("Снимок для МАРС обновлён.")
		else
			computer.show_error(usr, "МАРС: некого снимать. Возьмите устройство в руки.")
		return TOPIC_HANDLED

	if(href_list["PRG_filephoto"])
		if(apply_disk_photo(href_list["PRG_filephoto"]))
			computer.visible_notification("Аватар МАРС взят с диска.")
		else
			computer.show_error(usr, "МАРС: на устройстве нет такого фото.")
		return TOPIC_HANDLED

	if(href_list["PRG_mute"])
		muted = !muted
		computer.visible_notification(muted ? "Уведомления МАРС выключены." : "Уведомления МАРС включены.")
		return TOPIC_HANDLED

	if(href_list["PRG_open"])
		show_contacts = FALSE
		show_settings = FALSE
		var/datum/mars_channel/channel = mars_network.channels[href_list["PRG_open"]]
		if(channel && can_see_channel(channel))
			open_channel = channel
			mark_seen(channel)
		return TOPIC_HANDLED

	if(href_list["PRG_dm"])
		show_contacts = FALSE
		show_settings = FALSE
		var/target_id = href_list["PRG_dm"]
		var/target_name = target_id
		for(var/datum/computer_file/program/mars/other in mars_network.clients)
			if(other.account_id == target_id)
				target_name = other.username
				break
		refresh_identity()
		open_channel = mars_network.get_or_create_dm(account_id, username, target_id, target_name)
		if(open_channel)
			mark_seen(open_channel)
		return TOPIC_HANDLED

	if(href_list["PRG_send"])
		if(!open_channel)
			return TOPIC_HANDLED
		var/mob/user = usr
		var/message = sanitize(input(user, "Сообщение в «[open_channel.title]»:", "МАРС") as text|null, 512)
		if(!message || !open_channel)
			return TOPIC_HANDLED
		if(!send_text(message))
			computer.show_error(user, send_failure_reason())
		else
			mark_seen(open_channel)
		return TOPIC_HANDLED

	if(href_list["PRG_sendfile"])
		send_file_to_open_channel(usr)
		return TOPIC_HANDLED

	if(href_list["PRG_savefile"])
		save_channel_file(href_list["PRG_savefile"], usr)
		return TOPIC_HANDLED

/datum/computer_file/program/mars/proc/mars_ui_avatars()
	return list(
		"letter" = list("name" = "Инициал", "color" = "#2a6ebd", "glyph" = ""),
		"photo" = list("name" = "Снимок", "color" = "#445566", "glyph" = "*")
	)

/datum/computer_file/program/mars/proc/publish_avatar()
	avatar_stamp++
	if(mars_network)
		mars_network.update_profile(src)

/datum/computer_file/program/mars/proc/avatar_asset_name(account_id, stamp)
	return "mars_av_[md5("[account_id]-[stamp]")].png"

/datum/computer_file/program/mars/proc/capture_avatar_photo()
	var/mob/holder = get_user()
	if(!istype(holder))
		return FALSE
	avatar_photo = getFlatIcon(holder, SOUTH)
	if(!avatar_photo)
		return FALSE
	avatar_id = "photo"
	publish_avatar()
	return TRUE

/datum/computer_file/program/mars/proc/collect_photo_files()
	var/list/out = list()
	if(!computer)
		return out
	var/list/disks = list(computer.get_component(PART_HDD), computer.get_component(PART_DRIVE))
	for(var/obj/item/stock_parts/computer/hard_drive/disk in disks)
		for(var/datum/computer_file/binary/photo/photo_file in computer.get_all_files(FALSE, disk))
			if(photo_file.photo?.img)
				out |= photo_file
	return out

/datum/computer_file/program/mars/proc/find_photo_file(filename)
	if(!computer || !filename)
		return null
	var/datum/computer_file/binary/photo/photo_file = computer.get_file(filename)
	if(istype(photo_file) && photo_file.photo?.img)
		return photo_file
	photo_file = computer.get_file(filename, computer.get_component(PART_DRIVE))
	if(istype(photo_file) && photo_file.photo?.img)
		return photo_file
	return null

/datum/computer_file/program/mars/proc/apply_disk_photo(filename)
	var/datum/computer_file/binary/photo/photo_file = find_photo_file(filename)
	if(!photo_file)
		return FALSE
	avatar_photo = icon(photo_file.photo.img)
	if(!avatar_photo)
		return FALSE
	avatar_id = "photo"
	publish_avatar()
	return TRUE

/datum/computer_file/program/mars/proc/mars_avatar_entry(account_id, fallback_name, mob/user)
	var/list/catalog = mars_ui_avatars()
	var/id = avatar_id
	var/icon/photo = avatar_photo
	var/stamp = avatar_stamp
	if(account_id && mars_network?.profiles[account_id])
		var/list/profile = mars_network.profiles[account_id]
		id = profile["id"]
		photo = profile["photo"]
		stamp = profile["stamp"]
	if(!(id in catalog))
		id = "letter"
	var/list/spec = catalog[id]
	var/list/out = list(
		"av_color" = spec["color"],
		"glyph" = spec["glyph"],
		"photo_src" = null
	)
	if(!out["glyph"] || id == "letter")
		out["glyph"] = mars_initial(fallback_name)
	if(id == "photo" && photo && user)
		var/fname = avatar_asset_name(account_id, stamp)
		send_rsc(user, photo, fname)
		out["photo_src"] = fname
	return out

/datum/computer_file/program/mars/proc/mars_fill_avatar(list/target, account_id, fallback_name, mob/user)
	var/list/entry = mars_avatar_entry(account_id, fallback_name, user)
	target["av_color"] = entry["av_color"]
	target["glyph"] = entry["glyph"]
	target["photo_src"] = entry["photo_src"]

/datum/computer_file/program/mars/proc/mars_initial(name)
	return uppertext(copytext_char("[name]", 1, 2))

/datum/computer_file/program/mars/proc/mars_preview(text)
	text = "[text]"
	if(length_char(text) <= 52)
		return text
	return "[copytext_char(text, 1, 52)]..."

/datum/nano_module/program/mars
	name = "МАРС"

/datum/nano_module/program/mars/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	var/list/data = list()
	if(program)
		data = program.get_header_data()

	var/datum/computer_file/program/mars/client = program
	if(!istype(client))
		return
	if(!mars_network)
		return

	client.refresh_identity()
	data["logged_in"] = client.logged_in
	data["stored_login"] = client.stored_login
	data["stored_password"] = stars(client.stored_password, 0)
	data["login_error"] = client.login_error
	if(!client.logged_in)
		ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
		if(!ui)
			ui = new(user, src, ui_key, "mods-mars.tmpl", "МАРС", 540, 700, state = state)
			ui.auto_update_layout = 1
			ui.set_initial_data(data)
			ui.open()
			ui.set_auto_update(1)
		return

	data["username"] = client.username
	data["job"] = client.job_title
	data["login"] = client.stored_login
	data["muted"] = client.muted
	data["unread"] = client.unread_total
	data["online"] = client.is_online()
	data["keys"] = client.get_key_labels()
	client.mars_fill_avatar(data, client.account_id, client.username, user)

	if(client.open_channel)
		var/datum/mars_channel/channel = client.open_channel
		data["title"] = channel.title
		data["channel_id"] = channel.id
		data["direct"] = channel.direct
		data["color"] = channel.color
		data["chan_initial"] = client.mars_initial(channel.title)
		data["chan_photo_src"] = null
		if(channel.direct)
			var/partner_id = client.account_id
			var/partner_name = channel.title
			for(var/pid in channel.participant_ids)
				if(pid != client.account_id)
					partner_id = pid
					partner_name = pid
					if(mars_network.profiles[pid])
						var/list/profile = mars_network.profiles[pid]
						partner_name = profile["name"] || pid
					break
			var/list/head = list()
			client.mars_fill_avatar(head, partner_id, partner_name, user)
			data["color"] = head["av_color"]
			data["chan_initial"] = head["glyph"]
			data["chan_photo_src"] = head["photo_src"]
		var/list/messages = list()
		for(var/list/entry in channel.messages)
			var/list/row = list(
				"time" = entry["time"],
				"author" = entry["author"],
				"text" = entry["text"],
				"own" = (entry["account"] == client.account_id)
			)
			var/datum/computer_file/attachment = entry["file"]
			if(istype(attachment))
				row["file_name"] = attachment.filename
				row["file_type"] = attachment.filetype
				row["file_size"] = attachment.size
				row["file_uid"] = attachment.uid
				var/datum/computer_file/binary/photo/photo_file = attachment
				if(istype(photo_file) && photo_file.photo?.img)
					var/fname = "mars_att_[attachment.uid].png"
					send_rsc(user, photo_file.photo.img, fname)
					row["file_photo"] = fname
			client.mars_fill_avatar(row, entry["account"], entry["author"], user)
			messages.Add(list(row))
		data["messages"] = messages
		client.mark_seen(channel)
	else if(client.show_contacts)
		data["contacts_view"] = TRUE
		var/list/contacts = list()
		var/list/seen = list()
		for(var/datum/computer_file/program/mars/other in mars_network.clients)
			if(other == client || !other.is_online())
				continue
			if(seen[other.account_id])
				continue
			seen[other.account_id] = TRUE
			var/list/row = list(
				"id" = other.account_id,
				"name" = other.username,
				"job" = other.job_title
			)
			client.mars_fill_avatar(row, other.account_id, other.username, user)
			contacts.Add(list(row))
		data["contacts"] = contacts
	else if(client.show_settings)
		data["settings_view"] = TRUE
		var/list/avatars = list()
		var/list/avatar_map = client.mars_ui_avatars()
		for(var/id in avatar_map)
			var/list/spec = avatar_map[id]
			var/list/row = list(
				"id" = id,
				"name" = spec["name"],
				"av_color" = spec["color"],
				"glyph" = spec["glyph"] || client.mars_initial(client.username),
				"selected" = (id == client.avatar_id),
				"photo_src" = null
			)
			if(id == "letter" || !row["glyph"])
				row["glyph"] = client.mars_initial(client.username)
			if(id == "photo" && client.avatar_photo)
				var/fname = client.avatar_asset_name(client.account_id, client.avatar_stamp)
				send_rsc(user, client.avatar_photo, fname)
				row["photo_src"] = fname
			avatars.Add(list(row))
		data["avatars"] = avatars
		var/list/disk_photos = list()
		for(var/datum/computer_file/binary/photo/photo_file in client.collect_photo_files())
			var/fname = "mars_file_[md5("[photo_file.filename]")].png"
			send_rsc(user, photo_file.photo.img, fname)
			disk_photos.Add(list(list(
				"filename" = photo_file.filename,
				"photo_src" = fname
			)))
		data["disk_photos"] = disk_photos
	else
		var/list/chats = list()
		for(var/id in mars_network.channels)
			var/datum/mars_channel/channel = mars_network.channels[id]
			if(!client.can_see_channel(channel))
				continue
			if(channel.direct && !length(channel.messages))
				continue
			var/seen_count = client.last_seen[id] || 0
			var/last_text = "Нет сообщений"
			var/last_author = ""
			if(length(channel.messages))
				var/list/last = channel.messages[length(channel.messages)]
				var/datum/computer_file/last_file = last["file"]
				if(istype(last_file))
					last_text = "файл: [last_file.filename].[last_file.filetype]"
				else
					last_text = client.mars_preview(last["text"])
				last_author = last["author"]
			var/list/row = list(
				"id" = channel.id,
				"title" = channel.title,
				"direct" = channel.direct,
				"av_color" = channel.color,
				"glyph" = client.mars_initial(channel.title),
				"photo_src" = null,
				"unread" = max(0, channel.message_seq - seen_count),
				"last" = last_text,
				"last_author" = last_author
			)
			if(channel.direct)
				for(var/pid in channel.participant_ids)
					if(pid != client.account_id)
						var/pname = pid
						if(mars_network.profiles[pid])
							var/list/profile = mars_network.profiles[pid]
							pname = profile["name"] || pid
						client.mars_fill_avatar(row, pid, pname, user)
						break
			chats.Add(list(row))
		data["chats"] = chats

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-mars.tmpl", "МАРС", 540, 700, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
