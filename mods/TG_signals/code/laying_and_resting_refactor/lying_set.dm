//Функция вызывается когда персонаж изменяет своё положение, ложится или встаёт
/mob/proc/set_lying(new_status = TRUE)
	var/actually_new = FALSE
	SEND_SIGNAL(src, COMSIG_MOB_LAYING_PRE_UPDATED, src)
	if(lying != new_status)
		actually_new = TRUE
		SEND_SIGNAL(src, COMSIG_MOB_LAYING_PRE_CHANGED, src)
	lying = new_status
	if(actually_new)
		SEND_SIGNAL(src, COMSIG_MOB_LAYING_CHANGED, src)
	SEND_SIGNAL(src, COMSIG_MOB_LAYING_UPDATED, src)
	if(lying && ishuman(src))
		var/mob/living/carbon/human/human = src
		human.drop_grabs()

/mob/living/lay_down()
	set name = "Rest"
	set category = "IC"
	resting = !resting
	UpdateLyingBuckledAndVerbStatus()
	to_chat(src, SPAN_NOTICE("You are now [resting ? "resting" : "getting up"]"))
