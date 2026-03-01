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

// MACHINERY EVENT-DRIVEN CONTRACTS
/// From /datum/gas_mixture update sites. Args after implicit `source`: (reason_flags)
#define COMSIG_GASMIX_UPDATED "comsig_gasmix_updated"
/// From /area power usage updates. Args after implicit `source`: (chan, used_value, oneoff_value)
#define COMSIG_AREA_POWER_USAGE_CHANGED "comsig_area_power_usage_changed"
/// From /obj/meteor lifecycle. Args after implicit `source`: (obj/meteor/meteor_ref)
#define COMSIG_METEOR_SPAWNED "comsig_meteor_spawned"
/// From /obj/meteor lifecycle. Args after implicit `source`: (obj/meteor/meteor_ref)
#define COMSIG_METEOR_DESPAWNED "comsig_meteor_despawned"

// Gasmix update reason flags.
#define GASMIX_UPDATE_MERGE     FLAG_01
#define GASMIX_UPDATE_REMOVE    FLAG_02
#define GASMIX_UPDATE_REACT     FLAG_03
#define GASMIX_UPDATE_EQUALIZE  FLAG_04
#define GASMIX_UPDATE_ADJUST    FLAG_05

// Generic machinery wake reasons.
#define MACHINERY_WAKE_POWER    FLAG_01
#define MACHINERY_WAKE_ATMOS    FLAG_02
#define MACHINERY_WAKE_UI       FLAG_03
#define MACHINERY_WAKE_TARGET   FLAG_04
