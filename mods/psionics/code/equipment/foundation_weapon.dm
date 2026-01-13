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
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = ITEM_SIZE_HUGE
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_BACKPACK_STORAGE
	use_sound = 'sound/effects/storage/briefcase.ogg'

/obj/item/storage/briefcase/foundation/disrupts_psionics()
	return FALSE

/obj/item/storage/briefcase/foundation/New()
	..()
	new /obj/item/gun/projectile/revolver/foundation(src)
	new /obj/item/ammo_magazine/speedloader/magnum/nullglass(src)
	new /obj/item/ammo_magazine/speedloader/magnum/nullglass(src)
	new /obj/item/storage/firstaid/sleekstab(src)
	new /obj/item/implanter/psi(src)
	new /obj/item/implanter/psi(src)
	new /obj/item/implantcase/explosive(src)
	new /obj/item/implantcase/explosive(src)
	new /obj/item/implantcase/tracking(src)
	new /obj/item/implantcase/tracking(src)
	new /obj/item/implanter(src)
	new /obj/item/implantpad(src)
	new /obj/item/device/scanner/reagent/adv(src)

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

/obj/item/grenade/chem_grenade/nullgas
	name = "null gas grenade"
	desc = "Powdered nullglass. Use with face protection only!"
	stage = 2
	path = 1


/obj/item/grenade/chem_grenade/nullgas/Initialize()
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/B2 = new(src)
	B1.reagents.add_reagent(/datum/reagent/phosphorus, 40)
	B1.reagents.add_reagent(/datum/reagent/potassium, 40)
	B1.reagents.add_reagent(/datum/reagent/nullglass, 40)
	B2.reagents.add_reagent(/datum/reagent/sugar, 40)
	B2.reagents.add_reagent(/datum/reagent/nullglass, 80)
	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)
	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"

/datum/reagent/nullglass
	name = "Grinded nullglass"
	description = "Grinded down and specially prepaired for use via aerosol, this nullglass are Foundation's last resort against rouge psionics."
	taste_description = "broken glass"
	taste_mult = 10
	reagent_state = SOLID
	touch_met = 5 // Get rid of it quickly
	color = "#ff6088"

/datum/reagent/nullglass/affect_touch(mob/living/carbon/M, removed)
	var/eyes_covered = 0
	var/mouth_covered = 0
	var/partial_mouth_covered = 0
	var/stun_probability = 50
	var/no_pain = 0
	var/obj/item/eye_protection = null
	var/obj/item/face_protection = null
	var/obj/item/partial_face_protection = null

	var/permeability = GET_TRAIT_LEVEL(M, /singleton/trait/general/permeable_skin)
	var/effective_strength = 5 + (3 * permeability)

	var/list/protection
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		protection = list(H.head, H.glasses, H.wear_mask)
		if(!H.can_feel_pain())
			no_pain = 1 //TODO: living-level can_feel_pain() proc
	else
		protection = list(M.wear_mask)
	if(M.psi)
		M.psi.backblast(rand(15,20))
	for(var/obj/item/I in protection)
		if(I)
			if(I.body_parts_covered & EYES)
				eyes_covered = 1
				eye_protection = I.name
			if((I.body_parts_covered & FACE) && !(I.item_flags & ITEM_FLAG_FLEXIBLEMATERIAL))
				mouth_covered = 1
				face_protection = I.name
			else if(I.body_parts_covered & FACE)
				partial_mouth_covered = 1
				partial_face_protection = I.name

	if(eyes_covered)
		if(!mouth_covered)
			to_chat(M, SPAN_WARNING("Your [eye_protection] protects your eyes from the nullglass dust!"))
	else
		to_chat(M, SPAN_WARNING("The nullglass dust gets in your eyes!"))
		M.mod_confused(2)
		if(mouth_covered)
			M.eye_blurry = max(M.eye_blurry, effective_strength * 3)
			M.eye_blind = max(M.eye_blind, effective_strength)
		else
			M.eye_blurry = max(M.eye_blurry, effective_strength * 5)
			M.eye_blind = max(M.eye_blind, effective_strength * 2)
			M.apply_damage(2, DAMAGE_BRUTE, BP_EYES)
	if(mouth_covered)
		to_chat(M, SPAN_WARNING("Your [face_protection] protects you from the nullglass dust!"))
	else if(!no_pain)
		if(partial_mouth_covered)
			to_chat(M, SPAN_WARNING("Your [partial_face_protection] partially protects you from the nullglass dust!"))
			stun_probability *= 0.5
		to_chat(M, SPAN_DANGER("Your lungs starts tearing with thousands of tiny shards!"))
		M.apply_damage(4, DAMAGE_BRUTE, BP_LUNGS)
		if(M.stunned > 0  && !M.lying)
			M.Weaken(4)
		if(prob(stun_probability))
			M.custom_emote(2, "[pick("coughs!","coughs hysterically!","splutters!")]")
			M.Stun(3)

/datum/reagent/nullglass/affect_ingest(mob/living/carbon/M, removed)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.can_feel_pain())
			return
	if(M.metabolized.get_reagent_amount(type) == metabolism)
		to_chat(M, SPAN_DANGER("You feel like your insides are teared apart!"))
	else
		M.apply_damage(2 * removed, DAMAGE_BRUTE, BP_STOMACH)
