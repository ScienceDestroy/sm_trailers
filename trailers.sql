CREATE TABLE IF NOT EXISTS `player_trailers` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) DEFAULT NULL,
    `trailer` varchar(50) DEFAULT NULL,
    `plate` varchar(50) DEFAULT NULL,
    `stored` boolean DEFAULT TRUE,
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`),
    KEY `plate` (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;