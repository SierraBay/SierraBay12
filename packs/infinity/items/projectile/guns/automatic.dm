/obj/item/gun/projectile/automatic/bullpup_rifle/light
	firemodes = list(
		list(
			mode_name="semi auto", burst=1, fire_delay=null,
			use_launcher=null, one_hand_penalty=6,
			burst_accuracy=null, dispersion=null
		),
		list(
			mode_name="2-round bursts", burst=2, fire_delay=null,
			use_launcher=null, one_hand_penalty=7,
			burst_accuracy=list(0,-1), dispersion=list(0.0, 0.6)
		),
		list(
			mode_name="fire grenades", burst=null, fire_delay=null,
			use_launcher=1, one_hand_penalty=10,
			burst_accuracy=null, dispersion=null
		),
		list(
			mode_name="full auto", burst=1, fire_delay=2, burst_delay=2,
			use_launcher=null, one_hand_penalty=7,
			burst_accuracy = list(0,-1,-1), dispersion=list(0.2, 0.6, 1.2),
			autofire_enabled=1
		)
	)


/obj/item/gun/projectile/sniper/garand
	firemodes = list(
		list(
			mode_name="semi auto", burst=1, fire_delay=6,
			one_hand_penalty=8, burst_accuracy=null,
			dispersion=null
		)
	)


/obj/item/gun/projectile/sniper/semistrip
	firemodes = list(
		list(
			mode_name="semi auto", burst=1, fire_delay=2,
			one_hand_penalty=8, burst_accuracy=null,
			dispersion=null
		)
	)
