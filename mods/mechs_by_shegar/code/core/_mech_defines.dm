//Болты кабины меха
#define BOLTS_DESTROYED 0 //Болты разрушены, мех больше не может запирать свою кабину
#define BOLTS_NOMINAL 1 //Всё нормально

//Классы тарана меха. Влияет на урон от тарана
#define BASIC_BUMP 1
#define MEDIUM_BUMP 2
#define HARD_BUMP 3

//Пассажирка меха
#define MECH_DROP_ALL_PASSENGERS 1 //Сброс всех пассажиров на мехе
#define MECH_DROP_ANY_PASSENGER 2  //Сброс любого одного пассажира с меха

//Рендеринг меха.
#define MECH_BACK_LAYER 4
#define BIGGEST_POSSIBLE_SPEED 30


/proc/in_this_mech(mob/living/A, mob/living/exosuit/B)
	if(istype(B, /mob/living/exosuit))
		if(B.pilots.Find(A))
			return TRUE
	return FALSE
