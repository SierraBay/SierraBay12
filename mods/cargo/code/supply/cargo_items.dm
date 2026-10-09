/obj/item/card/cargo_account
	name = "cargo account card"
	desc = "A plastic card with a magnetic stripe, containing Cargo account credentials."
	icon = 'icons/obj/tools/card.dmi'
	icon_state = "data_1"
	w_class = ITEM_SIZE_TINY
	var/account_number
	var/account_pin

/obj/item/card/cargo_account/Initialize()
	. = ..()
	ensure_account()

/obj/item/card/cargo_account/proc/ensure_account()
	if(!account_number || !account_pin)
		var/datum/money_account/dept_account = get_supply_department_account()
		if(dept_account)
			account_number = dept_account.account_number
			account_pin = dept_account.remote_access_pin

/obj/item/card/cargo_account/examine(mob/user)
	. = ..()
	ensure_account()
	if(account_number && account_pin)
		to_chat(user, "Printed on the magnetic stripe: Supply Account #[account_number], PIN: [account_pin]")
	else
		to_chat(user, "Printed on the magnetic stripe: Supply Account not configured.")
