/singleton/modpack/mars_messenger
	name = "МАРС"
	desc = "Мессенджер Авторизованной Радиосвязи Сьерры — замена гарнитурной болтовни приложением на КПК, планшетах и компьютерах."
	author = "SierraBay"

/singleton/modpack/mars_messenger/post_initialize()
	if(!mars_network)
		mars_network = new
	mars_network.setup_channels()
