/*
 * The contents of this file were auto-generated using the export feature of adminer.
 */


CREATE TABLE IF NOT EXISTS `erro_ban` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `serverip` text NOT NULL,
  `bantype` text NOT NULL,
  `reason` text NOT NULL,
  `job` text DEFAULT NULL,
  `duration` int(11) NOT NULL,
  `rounds` int(11) DEFAULT NULL,
  `expiration_time` datetime NOT NULL,
  `ckey` text NOT NULL,
  `computerid` text NOT NULL DEFAULT '',
  `ip` text NOT NULL DEFAULT '',
  `a_ckey` text NOT NULL,
  `a_computerid` text NOT NULL DEFAULT '',
  `a_ip` text NOT NULL DEFAULT '',
  `who` text NOT NULL,
  `adminwho` text NOT NULL,
  `edits` text DEFAULT NULL,
  `unbanned` int(11) DEFAULT NULL,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_ckey` text DEFAULT NULL,
  `unbanned_computerid` text DEFAULT NULL,
  `unbanned_ip` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`(768)),
  KEY `ip` (`ip`(768)),
  KEY `computerid` (`computerid`(768))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;


CREATE TABLE IF NOT EXISTS `erro_connection_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime DEFAULT NULL,
  `serverip` text DEFAULT NULL,
  `ckey` text DEFAULT NULL,
  `ip` text DEFAULT NULL,
  `computerid` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`(768))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;


CREATE TABLE IF NOT EXISTS `erro_device_fingerprint` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `last_seen` datetime NOT NULL,
  `ckey` text NOT NULL,
  `ckey_key` varchar(128) NOT NULL,
  `schema_version` varchar(16) NOT NULL DEFAULT 'v2',
  `fingerprint_hash` varchar(64) NOT NULL,
  `computerid_hash` varchar(64) DEFAULT NULL,
  `ip_prefix_hash` varchar(64) DEFAULT NULL,
  `browser_hash` varchar(64) DEFAULT NULL,
  `browser_token_hash` varchar(64) DEFAULT NULL,
  `raw_computerid` text DEFAULT NULL,
  `raw_ip` text DEFAULT NULL,
  `raw_browser_payload` text DEFAULT NULL,
  `byond_version` varchar(32) DEFAULT NULL,
  `byond_build` varchar(32) DEFAULT NULL,
  `risk_score` int(11) NOT NULL DEFAULT 0,
  `flags` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fingerprint_hash` (`fingerprint_hash`),
  KEY `computerid_hash` (`computerid_hash`),
  KEY `ip_prefix_hash` (`ip_prefix_hash`),
  KEY `browser_hash` (`browser_hash`),
  KEY `browser_token_hash` (`browser_token_hash`),
  KEY `ckey` (`ckey`(128)),
  UNIQUE KEY `ckey_fingerprint` (`ckey_key`, `fingerprint_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;


CREATE TABLE IF NOT EXISTS `erro_player` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` text NOT NULL,
  `firstseen` datetime DEFAULT NULL,
  `lastseen` datetime DEFAULT NULL,
  `ip` text DEFAULT NULL,
  `computerid` text DEFAULT NULL,
  `lastadminrank` text DEFAULT NULL,
  `staffwarn` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ckey` (`ckey`(768)) USING HASH,
  KEY `ckey_2` (`ckey`(768)),
  KEY `ip` (`ip`(768)),
  KEY `computerid` (`computerid`(768))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;


CREATE TABLE IF NOT EXISTS `erro_playtime_history` (
  `ckey` varchar(128) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `date` date NOT NULL,
  `time_living` int(11) NOT NULL DEFAULT 0,
  `time_ghost` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`ckey`, `date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;


CREATE TABLE IF NOT EXISTS `library` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` text DEFAULT NULL,
  `title` text DEFAULT NULL,
  `author` text DEFAULT NULL,
  `content` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `title` (`title`(768)),
  KEY `author` (`author`(768)),
  KEY `category` (`category`(768))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;


CREATE TABLE IF NOT EXISTS `whitelist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` text NOT NULL,
  `ackey` text DEFAULT NULL,
  `race` text NOT NULL,
  `date` datetime NOT NULL,
  `date_remove` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`(768)),
  KEY `race` (`race`(768))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
