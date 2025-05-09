///Перед установкой части проверим что она не погружена на тележку, а если погружена - разгружаем с тележки
/obj/structure/heavy_vehicle_frame/proc/cart_check(obj/item/mech_component/input_part)
	if(locate(/obj/structure/cart) in get_turf(input_part))
		var/obj/structure/cart/cart = locate(/obj/structure/cart) in get_turf(input_part) //Очевидно что код лопнет если в турфе будет больше чем 1 тележка. Но вот только как это вообще возможно?
		if(cart.load == input_part)
			cart.unload(direction = get_dir(cart, src))
