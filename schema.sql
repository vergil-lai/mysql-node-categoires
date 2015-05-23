-- 无限分类表结构
-- 作者：Vergil <vergil@vip.163.com>

CREATE TABLE IF NOT EXISTS  `category` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) unsigned NOT NULL DEFAULT '0',
  `level` smallint(5) unsigned NOT NULL DEFAULT '1',
  `name` varchar(60) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8

CREATE TABLE IF NOT EXISTS `category_node_index` (
  `id` int(10) unsigned NOT NULL,
  `node_index` varchar(500) NOT NULL,
  PRIMARY KEY (`id`),
  FULLTEXT KEY `idx_node_index` (`node_index`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8
