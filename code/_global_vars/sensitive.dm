// MySQL configuration
GLOBAL_REAL_VAR(sqlenabled)   = TRUE
GLOBAL_REAL_VAR(sqladdress)   = "localhost"
GLOBAL_REAL_VAR(sqlport)      = "3306"
GLOBAL_REAL_VAR(sqldb)        = "bay12"
GLOBAL_REAL_VAR(sqllogin)     = "root"
GLOBAL_REAL_VAR(sqlpass)      = "1234"

GLOBAL_REAL_VAR(sqlfdbkdb)    = "test"
GLOBAL_REAL_VAR(sqlfdbklogin) = "root"
GLOBAL_REAL_VAR(sqlfdbkpass)  = ""
GLOBAL_REAL_VAR(sqlfdbkdbutil) = "test"
GLOBAL_REAL_VAR(sqlfdbktableprefix) = "erro_"

var/global/db_version = 0
var/global/DBConnection/dbcon = new
var/global/DBConnection/dbcon_old = new
