#define EXONET_ACTION_NAME "Enter Exonet"
/obj/item/organ/internal/ecs
	name = "exonet connection port"
	icon = 'mods/ipc_mods/icons/ipc_icons.dmi'
	icon_state = "setup_large"
	organ_tag = BP_EXONET
	parent_organ = BP_HEAD
	status = ORGAN_ROBOTIC
	desc = "The internal port is designed to establish communication between the positronic brain and the computer."
	w_class = ITEM_SIZE_NORMAL
	max_damage = 100
	var/obj/item/modular_computer/ecs/computer
	var/open = FALSE

/obj/item/organ/internal/ecs/first_gen
	name = "exonet connection port"
	desc = "The internal port is designed to establish communication between the positronic brain and the computer. It's a first generation connection port."
	computer = /obj/item/modular_computer/ecs/first

/obj/item/organ/internal/ecs/second_gen
	name = "exonet connection port"
	desc = "The internal port is designed to establish communication between the positronic brain and the computer. It's a second generation connection port."
	computer = /obj/item/modular_computer/ecs/second

/obj/item/organ/internal/ecs/third_gen
	name = "exonet connection port"
	desc = "The internal port is designed to establish communication between the positronic brain and the computer. It's a third generation connection port."
	computer = /obj/item/modular_computer/ecs/third


/obj/item/organ/internal/ecs/Initialize()
	if(ispath(computer))
		computer = new computer(src)
		action_button_name = EXONET_ACTION_NAME
	. = ..()

/obj/item/organ/internal/ecs/refresh_action_button()
	. = ..()
	if(.)
		action.button_icon = 'mods/ipc_mods/icons/ipc_icons.dmi'
		action.button_icon_state = "command"
		if(action.button) action.button.UpdateIcon()

/obj/item/organ/internal/ecs/attack_self(mob/user)
	if(action_button_name == EXONET_ACTION_NAME && owner)
		owner.enter_exonet()
		refresh_action_button()

/obj/item/organ/internal/ecs/Process()
	..()
	if(!owner)
		return
	if(owner.stat == DEAD)
		return
	if(!computer)
		return
	if(computer.battery_module.battery.charge < (computer.battery_module.battery.maxcharge))
		transfer_charge()

/obj/item/organ/internal/ecs/proc/transfer_charge()
	var/obj/item/organ/internal/cell/potato = owner.internal_organs_by_name[BP_CELL]
	var/charge_needed =(computer.battery_module.battery.maxcharge - computer.battery_module.battery.charge)
	if(charge_needed)
		potato.cell.charge -= charge_needed
		computer.battery_module.battery.charge += charge_needed

/obj/item/organ/internal/ecs/use_tool(obj/item/W, mob/user, list/click_params)
	. = ..()
	if(isScrewdriver(W))
		if(open)
			open = FALSE
			to_chat(user, "<span class='notice'>You screw the exonet connection slot panel in place.</span>")
		else
			open = TRUE
			to_chat(user, "<span class='notice'>You unscrew the exonet connection slot panel.</span>")

	if(isCrowbar(W))
		if(open)
			if(computer)
				user.put_in_hands(computer)
				to_chat(user, "<span class='notice'>You remove \the [computer] from \the [src].</span>")
				computer = null
				icon_state = "setup_large-open"

	if (istype(W, /obj/item/modular_computer/ecs))
		if(open)
			if(computer)
				to_chat(user, "<span class ='warning'>There \the [computer] already installed.</span>")
			else if(user.unEquip(W, src))
				computer = W
				to_chat(user, "<span class = 'notice'>You insert \the [computer].</span>")
				icon_state = "setup_large"


/obj/item/organ/internal/ecs/proc/exonet(mob/user)
	if(!computer)
		to_chat(user, "<span class='warning'>You have no exonet connection system installed</span>")
		return
	if(!computer.enabled && computer.screen_on)
		return computer.turn_on(user)
	switch(alert("Open Terminal or interact with it?", "Open Terminal or interact with it?", "Interact", "Terminal", "Emergency Shutdown"))
		if("Interact")
			return computer.ui_interact(user)
		if("Terminal")
			return computer.open_terminal_ecs(user)
		if("Emergency Shutdown")
			return computer.emergency_shutdown(user)


/obj/item/stock_parts/computer/hard_drive/portable/afterattack(mob/living/carbon/human/H, mob/living/user, target_zone, animate = TRUE)
	if(H.is_species(SPECIES_IPC) && ishuman(user) && (user.zone_sel.selecting == BP_MOUTH || user.zone_sel.selecting == BP_HEAD))
		var/obj/item/organ/internal/ecs/T = H.internal_organs_by_name[BP_EXONET]
		if (do_after(user, 10, src))
			user.visible_message( \
				"<span class='notice'>\The [user] install's [src] into [H]'s exonet port.</span>", \
				"<span class='notice'>You have installed [src] into [H]'s exonet port.</span>" \
				)
			T.computer.try_install_component(user, src)

#undef EXONET_ACTION_NAME
