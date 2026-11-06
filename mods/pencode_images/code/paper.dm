// Paper counts free space on the text with HTML stripped, so an <img> tag would cost nothing.
// Charge each image the length of its link, as if the [img] pencode stayed on the page.
/obj/item/paper/update_space(new_text)
	. = ..()
	free_space -= pencode_image_links_length(new_text)
