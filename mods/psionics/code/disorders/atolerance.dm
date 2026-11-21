/singleton/psi_disorder/atolerance
	id =          "atolerance"
	name =        "Синдром атолерации"
	group =       "green"
	description = "Псионик не признает своего потенциала и не желает его использовать. Жертвы травматического пробуждения или те, кто были пробуждены с помощью наркотиков, страдают этим недостатком."

/singleton/psi_disorder/atolerance/blocks_power(mob/living/owner)
	if(prob(35))
		to_chat(owner, SPAN_WARNING("Что?"))
		return TRUE
	return FALSE
