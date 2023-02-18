CREATE TABLE IF NOT EXISTS `donation_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `donation_players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(50) NOT NULL,
  `donation_type` int(11) DEFAULT 0,
  `server` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ckey_index` (`ckey`),
  KEY `FK_players_donation_types` (`donation_type`),
  CONSTRAINT `FK_players_donation_types` FOREIGN KEY (`donation_type`) REFERENCES `donation_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `points_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `datetime` datetime NOT NULL,
  `change` float NOT NULL,
  `comment` text DEFAULT NULL,
  `server` varchar(32) NOT NULL,
  KEY `Primary Key` (`id`),
  KEY `FK_points_transactions_players` (`player`),
  KEY `FK_points_transactions_points_transactions_types` (`type`),
  CONSTRAINT `FK_points_transactions_players` FOREIGN KEY (`player`) REFERENCES `erro_player` (`id`),
  CONSTRAINT `FK_points_transactions_points_transactions_types` FOREIGN KEY (`type`) REFERENCES `points_transactions_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `points_transactions_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(32) DEFAULT NULL,
  KEY `Primary Key` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `store_players_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player` int(11) NOT NULL,
  `transaction` int(11) DEFAULT NULL,
  `obtaining_date` datetime DEFAULT NULL,
  `item_path` varchar(200) NOT NULL,
  `server` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_store_players_items_players` (`player`),
  KEY `FK_store_players_items_points_transactions` (`transaction`),
  CONSTRAINT `FK_store_players_items_players` FOREIGN KEY (`player`) REFERENCES `erro_player` (`id`),
  CONSTRAINT `FK_store_players_items_points_transactions` FOREIGN KEY (`transaction`) REFERENCES `points_transactions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
