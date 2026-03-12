//MOBS
#define COMSIG_MOB_LAYING_UPDATED "mob_laying_updated" //Отправляется ПОСЛЕ того как изменится положение персонажа (Даже если оно не поменялось в итоге)
#define COMSIG_MOB_LAYING_PRE_UPDATED "mob_laying_pre_updated" //Отправляется ПЕРЕД тем как изменится положение персонажа (Даже если оно не поменялось в итоге)
#define COMSIG_MOB_LAYING_PRE_CHANGED "mob_laying_pre_changed" //Отправляется ПЕРЕД тем как положение персонажа изменяется на НОВОЕ
#define COMSIG_MOB_LAYING_CHANGED "mob_laying_changed" //Отправляется после того как положение персонажа изменяется на НОВОЕ
#define COMSIG_MOB_EQUIPED_SMTHG "mob_equiped_something" //Моб что-то надел/экипировал в слот
//ITEMS
#define COMSIG_ITEM_PICKUPED "item_pickuped" //Данный предмет подобрали
#define COMSIG_MOVABLE_LOC_CHANGED "movable_loc_changed" //переменная loc обьекта изменилась. Перс сделал шаг, предмет убрали из кармана в сумку - чё угодно
//VISION CONE
#define COMSIG_ITEM_EQUIPPED "item_equipped"
#define COMSIG_ITEM_DROPPED "item_dropped"

#define COMSIG_CABINE_OPEN "cabine_open"
#define COMSIG_CABINE_CLOSED "cabine_closed"

// ATMOS
#define COMSIG_GASMIX_UPDATED "gasmix_updated" // Газовая смесь была изменена и пересчитала значения.
#define COMSIG_TURF_RETURN_AIR_CHANGED "turf_return_air_changed" // Точка, которую turf возвращает через return_air(), могла измениться.

// POWER
#define COMSIG_AREA_POWER_USAGE_CHANGED "area_power_usage_changed" // В area изменилось непрерывное или oneoff-потребление энергии.
