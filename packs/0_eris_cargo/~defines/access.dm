/**
 * Supply faction link access levels
 * These are used by the supply console to determine which factions an user can link to
 */

/**
 * SolGov faction link access level
 */
var/global/const/access_supplylink_solgov = "ACCESS_SUPPLY_LINK_SOLGOV"
/datum/access/supplylink_solgov
	id = access_supplylink_solgov
	desc = "Supply Console - SolGov Link"
	region = ACCESS_REGION_SUPPLY
	access_type = ACCESS_TYPE_NONE

/**
 * TerraGov faction link access level
 */
var/global/const/access_supplylink_terragov = "ACCESS_SUPPLY_LINK_TERRAGOV"
/datum/access/supplylink_terragov
	id = access_supplylink_terragov
	desc = "Supply Console - TerraGov Link"
	region = ACCESS_REGION_SUPPLY
	access_type = ACCESS_TYPE_NONE

/**
 * FTU faction link access level
 */
var/global/const/access_supplylink_ftu = "ACCESS_SUPPLY_LINK_FTU"
/datum/access/supplylink_ftu
	id = access_supplylink_ftu
	desc = "Supply Console - FTU Link"
	region = ACCESS_REGION_SUPPLY
	access_type = ACCESS_TYPE_NONE

/**
 * Nanotrasen faction link access level
 */
var/global/const/access_supplylink_nanotrasen = "ACCESS_SUPPLY_LINK_NANOTRASEN"
/datum/access/supplylink_nanotrasen
	id = access_supplylink_nanotrasen
	desc = "Supply Console - Nanotrasen Link"
	region = ACCESS_REGION_SUPPLY
	access_type = ACCESS_TYPE_NONE

/**
 * DAIS faction link access level
 */
var/global/const/access_supplylink_dais = "ACCESS_SUPPLY_LINK_DAIS"
/datum/access/supplylink_dais
	id = access_supplylink_dais
	desc = "Supply Console - DAIS Link"
	region = ACCESS_REGION_SUPPLY
	access_type = ACCESS_TYPE_NONE

/**
 * Hephaestus faction link access level
 */
var/global/const/access_supplylink_hephaestus = "ACCESS_SUPPLY_LINK_HAEPHAESTUS"
/datum/access/supplylink_hephaestus
	id = access_supplylink_hephaestus
	desc = "Supply Console - Hephaestus Link"
	region = ACCESS_REGION_SUPPLY
	access_type = ACCESS_TYPE_NONE


/**
 * Reborn Christian Church faction link access level
 */
var/global/const/access_supplylink_zeng_hu = "ACCESS_SUPPLY_LINK_ZENG_HU"
/datum/access/supplylink_zeng_hu
	id = access_supplylink_zeng_hu
	desc = "Supply Console - Zeng-Hu Pharmaceuticals Link"
	region = ACCESS_REGION_SUPPLY
	access_type = ACCESS_TYPE_NONE
