/obj/item/gun/projectile/revolver/foundation
	name = "\improper Foundation revolver"
	icon = 'icons/obj/guns/foundation.dmi'
	icon_state = "foundation"
	desc = "The CF 'Troubleshooter', a compact plastic-composite weapon designed for concealed carry by Cuchulain Foundation field agents. Smells faintly of copper."
	ammo_type = /obj/item/ammo_casing/pistol/magnum/nullglass

/obj/item/gun/projectile/revolver/foundation/disrupts_psionics()
	return FALSE

/obj/item/storage/briefcase/foundation
	name = "\improper Foundation briefcase"
	desc = "A handsome black leather briefcase embossed with a stylized radio telescope."
	icon_state = "fbriefcase"
	item_state = "fbriefcase"

/obj/item/storage/briefcase/foundation/disrupts_psionics()
	return FALSE

/obj/item/storage/briefcase/foundation/New()
	..()
	new /obj/item/ammo_magazine/speedloader/magnum/nullglass(src)
	new /obj/item/gun/projectile/revolver/foundation(src)
	make_exact_fit()

// V.E.R.I.T.A.S Hello, Global Occult Coalition from SCP, how are you?

/obj/item/clothing/accessory/glassesmod/psi
	name = "psimonitor sights"
	desc = "A device for visualizing psionic auras. Too complex to fit into your glasses."
	icon_state = "psi"
	slot = ACCESSORY_SLOT_HELMET_VISOR
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	toggleable = TRUE
	off_state = "psioff"
	electric = TRUE
	darkness_view = 5
	tint = TINT_MODERATE
	activation_sound = 'sound/items/metal_clicking_4.ogg'
	deactivation_sound = 'sound/items/metal_clicking_4.ogg'
	action_button_name = "Toggle Psionic Monitor"
	icon = 'mods/psionics/icons/foundation/foundation_obj.dmi'

	icon_override = 'mods/psionics/icons/foundation/foundation_obj.dmi'
	accessory_icons = list(
		slot_tie_str = 'mods/psionics/icons/foundation/foundation_onmob.dmi',
		slot_goggles_str = 'mods/psionics/icons/foundation/foundation_onmob.dmi',
		slot_head_str = 'mods/psionics/icons/foundation/foundation_onmob.dmi'
	)

// Веритас делает аналогично "большому" проку для псиоников, но на того, кто надевает очки

/obj/item/clothing/proc/show_veritas()
	if(isliving(src.loc))
		var/mob/living/L = src.loc
		for(var/image/I in SSpsi.all_aura_images)
			L.client.images |= I

/obj/item/clothing/proc/hide_veritas()
	if(isliving(src.loc))
		var/mob/living/L = src.loc
		for(var/thing in SSpsi.all_aura_images)
			L.client.images -= thing

/obj/item/clothing/accessory/glassesmod/psi/activate()
	..()
	if (parent)
		parent.CutOverlays(inv_overlay)
	inv_overlay = null
	inv_overlay = get_inv_overlay()
	if (parent)
		parent.AddOverlays(inv_overlay)
		parent.update_vision()
		parent.show_veritas()

/obj/item/clothing/accessory/glassesmod/psi/deactivate()
	..()
	if (parent)
		parent.CutOverlays(inv_overlay)
	inv_overlay = null
	inv_overlay = get_inv_overlay()
	if (parent)
		parent.AddOverlays(inv_overlay)
		parent.update_vision()
		parent.hide_veritas()

/////////////////////////////////////////////
// Psyk-out grenade
/////////////////////////////////////////////

/datum/effect/smoke_spread/nullgas
	smoke_type = /obj/effect/smoke/nullgas

/obj/effect/smoke/nullgas
	name = "null gas"
	icon_state = "nullgas"
	icon = 'mods/psionics/icons/foundation/nullgas.dmi'

/obj/effect/smoke/nullgas/can_affect(mob/living/carbon/M)
	. = ..()
	if (!.)
		return
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if (H.wear_suit)
			return FALSE

/obj/effect/smoke/nullgas/affect(mob/living/carbon/human/R)
	R.burn_skin(0.75)
	if (R.coughedtime != 1)
		R.coughedtime = 1
		R.emote("gasp")
		addtimer(new Callback(R, TYPE_PROC_REF(/mob/living/carbon, clear_coughedtime)), 2 SECONDS)
	R.updatehealth()
	return

/obj/effect/smoke/nullgas/disrupts_psionics()
	return src


/obj/item/grenade/nullgasbomb
	desc = "It is set to detonate in 2 seconds."
	name = "nullgas bomb"
	icon = 'mods/psionics/icons/foundation/nullgas.dmi'
	icon_state = "nullgrenade"
	det_time = 20
	item_state = "nullgrenade"
	slot_flags = SLOT_BELT
	var/datum/effect/smoke_spread/nullgas
	var/smoke_times = 4

/obj/item/grenade/nullgasbomb/Destroy()
	QDEL_NULL(nullgas)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/grenade/nullgasbomb/detonate(mob/living/user)
	playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
	nullgas = new /datum/effect/smoke_spread/nullgas
	nullgas.attach(src)
	nullgas.set_up(10, 0, get_turf(src))
	START_PROCESSING(SSobj, src)
	for(var/obj/blob/B in view(8,src))
		var/damage = round(30/(get_dist(B,src)+1))
		B.damage_health(damage, DAMAGE_BURN)
		B.update_icon()
	QDEL_IN(src, 8 SECONDS)

/obj/item/grenade/nullgasbomb/Process()
	if(!QDELETED(nullgas) && (smoke_times > 0))
		smoke_times--
		nullgas.start()
		return
	return PROCESS_KILL
