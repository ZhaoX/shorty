DROP TABLE IF EXISTS `range_id`;
CREATE TABLE `range_id` (
  `range` int(4) unsigned NOT NULL,
  `id` bigint(32) NOT NULL,
  PRIMARY KEY (`range`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `shorty`;
CREATE TABLE `shorty` (
  `code` varchar(8)  NOT NULL,
  `url` varchar(128)  NOT NULL,
  `ctime` timestamp,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `log`;
CREATE TABLE `log` (
  `id` bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(8)  NOT NULL,
  `url` varchar(128)  NOT NULL,
  `client_ip` char(16)  NOT NULL,
  `atime` timestamp,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
