
--
-- Это могло бы быть структурой, но оно вызывает много конфликтов с текущей
--
-- CREATE TABLE IF NOT EXISTS `store_donation_types` (
--   `id` int(11) NOT NULL AUTO_INCREMENT,
--   `type` varchar(32) NOT NULL,
--   PRIMARY KEY (`id`),
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- CREATE TABLE IF NOT EXISTS `store_donation_players` (
--   `id` int(11) NOT NULL AUTO_INCREMENT,
--   `ckey` varchar(50) NOT NULL,
--   `donation_type` int(11) NOT NULL DEFAULT 0,
--   `server` varchar(32) NOT NULL,
--   `date_start` datetime NOT NULL,
--   `date_end` datetime NOT NULL,
--   `date` datetime NOT NULL,
--   `is_valid` boolean NOT NULL DEFAULT true,
--   PRIMARY KEY (`id`),
--   UNIQUE KEY `ckey_index` (`ckey`),
--   KEY `FK_store_donation_types` (`donation_type`),
--   CONSTRAINT `FK_store_donation_types` FOREIGN KEY (`donation_type`) REFERENCES `store_donation_types` (`id`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `budget`
(
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`date` datetime DEFAULT now() NOT NULL,
	`ckey` varchar(32) NOT NULL,
	`amount` int(10) UNSIGNED NOT NULL,
	`source` varchar(32) NOT NULL,
	`date_start` datetime DEFAULT now() NOT NULL,
	`date_end` datetime DEFAULT (now() + INTERVAL 1 MONTH),
	`is_valid` boolean DEFAULT true NOT NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `store_points_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(50) NOT NULL,
  `type` int(11) NOT NULL,
  `change` int(11) NOT NULL,
  `source` varchar(32) DEFAULT NULL,
  `date` datetime DEFAULT now() NOT NULL,
  `is_valid` boolean NOT NULL DEFAULT true,
  PRIMARY KEY (`id`),
  KEY `FK_points_transactions_points_transactions_types` (`type`),
  CONSTRAINT `FK_points_transactions_points_transactions_types` FOREIGN KEY (`type`) REFERENCES `store_points_transaction_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `store_points_transaction_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `store_players_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(50) NOT NULL,
  `transaction` int(11) DEFAULT NULL,
  `obtaining_date` datetime DEFAULT NULL,
  `item_path` varchar(200) NOT NULL,
  `server` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_store_items_points_transactions` (`transaction`),
  CONSTRAINT `FK_store_items_points_transactions` FOREIGN KEY (`transaction`) REFERENCES `store_points_transactions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
