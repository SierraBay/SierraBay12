#define TRADE_NONEXPORTABLE 0
#define TRADE_JUNK 0.5
#define TRADE_EXPORTABLE 1
#define TRADE_HOCKABLE 0.7
#define TRADE_CATALOG_EXPORT_CAP 0.45
#define TRADE_VENDOR_EXPORT_CAP 0.4
#define TRADE_SALVAGE_MULT 0.15
#define TRADE_SALVAGE_CAP 2500
#define TRADE_MACHINERY_SALVAGE_MULT 0.05
#define TRADE_MACHINERY_SALVAGE_CAP 50
#define TRADE_WHOLESALE 1.2
#define TRADE_COMMON 1.25
#define TRADE_UNCOMMON 1.4
#define TRADE_RARE 1.5
#define TRADE_POINT_VALUE 15
#define TRADE_HANDLING_FEE 0.2
#define TRADE_EXPORT_LIMIT 200
#define TRADE_ORDER_LIMIT 100
#define TRADE_ENTROPY_LIMIT 30
#define TRADE_BEACON_RANGE 2
#define TRADE_EXPORT_COOLDOWN (2 MINUTES)
#define TRADE_ENTROPY_DECAY_INTERVAL (20 SECONDS)
#define TRADE_INSTABILITY_DURATION (30 SECONDS)
#define TRADE_SAVED_CART_LIMIT 20
#define TRADE_LOG_LIMIT 500
#define TRADE_LOG_PAGE_SIZE 20
#define TRADE_REQUEST_COOLDOWN (10 SECONDS)
#define TRADE_SUPPLY_ACCOUNT department_accounts["Снабжения"]
#define TRADE_TAG_NONEXPORTABLE "nonexportable"
#define TRADE_TAG_JUNK "junk"
#define TRADE_TAG_HOCKABLE "hockable"
#define TRADE_REQUEST "Requested"
#define TRADE_PAID "Awaiting delivery"
#define TRADE_DELIVERED "Delivered"
#define TRADE_CANCELLED "Cancelled"
#define TRADE_PACK_DATA(title, stock_range, target_cost, access) list("name" = title, "amount_range" = stock_range, "target_price" = target_cost, "req_access" = access)
