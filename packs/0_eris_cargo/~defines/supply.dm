// Data packets - inventories and offers
#define GOODS_DATA(nam, randList, price) list("name" = nam, "amount_range" = randList, "price" = price)
#define GOODS_DEFAULT GOODS_DATA(null, null, null)
#define CUSTOM_GOODS_NAME(nam) GOODS_DATA(nam, null, null)
#define CUSTOM_GOODS_AMOUNT_RANGE(randList) GOODS_DATA(null, randList, null)
#define CUSTOM_GOODS_PRICE(price) GOODS_DATA(null, null, price)

GLOBAL_LIST_EMPTY(trade_factions) /// Datums of all factions currently in the game

// Trade categories for the sake of standardization
#define TRADE_CAT_WEAPONS "Weapons"
#define TRADE_CAT_ARTILLERY "Ship Munitions"
#define TRADE_CAT_AMMO "Ammunition"
#define TRADE_CAT_ARMOR "Armor"
#define TRADE_CAT_EQUIPMENT "Equipment"
#define TRADE_CAT_CLOTHING "Clothing"
#define TRADE_CAT_SPACESUIT "Space Suits"
#define TRADE_CAT_VOIDSUIT "Void Suits"
#define TRADE_CAT_TOOLS "Tools"
#define TRADE_CAT_RESEARCH "Research"
#define TRADE_CAT_COMPONENTS "Stock Parts and Components"
#define TRADE_CAT_MATERIALS "Materials"
#define TRADE_CAT_RIG "RIG"
#define TRADE_CAT_RIG_MODULES "RIG Modules"
#define TRADE_CAT_MEDICAL "Medical"
#define TRADE_CAT_MEDKIT "Medical Kits"
#define TRADE_CAT_CHEMICAL "Chemical"
#define TRADE_CAT_CHEMCARTS "Dispenser Cartridges"
#define TRADE_CAT_GALLEY "Galley"

// As in - faction is a part of us
#define FACTION_STATE_PROTECTORATE 4
// Allied status
#define FACTION_STATE_ALLY 3
// Good diplomatic standing between the factions
#define FACTION_STATE_FRIEND 2
// Trading partnerse or just good relations
#define FACTION_STATE_WELCOMING 1
#define FACTION_STATE_NEUTRAL 0
// Just don't like them
#define FACTION_STATE_ANIMOSITY -1
// Rivals, but not deadly kind of
#define FACTION_STATE_RIVAL -2
// Enemies, but not necessarily currently in a conflict
#define FACTION_STATE_ENEMY -3
// In a state of open war
#define FACTION_STATE_WAR -4

/proc/TradeRelationsColor(relations)
	switch(relations)
		if(FACTION_STATE_PROTECTORATE)
			return "#1fedba"
		if(FACTION_STATE_ALLY)
			return "#00bd00"
		if(FACTION_STATE_FRIEND)
			return "#76db76"
		if(FACTION_STATE_WELCOMING)
			return "#aef2ae"
		if(FACTION_STATE_NEUTRAL)
			return "#ffffff"
		if(FACTION_STATE_ANIMOSITY)
			return "#ede3b4"
		if(FACTION_STATE_RIVAL)
			return "#ff9661"
		if(FACTION_STATE_ENEMY)
			return "#fa4820"
		if(FACTION_STATE_WAR)
			return "#bd0000"
		else
			return null
