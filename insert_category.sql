-- 无限分类表触发器
-- 作者 Vergil <vergil@vip.163.com>

DROP TRIGGER IF EXISTS `before_insert_category`;
DROP TRIGGER IF EXISTS `after_insert_category`;

DELIMITER $$

-- BEFORE INSERT 触发器 
-- 顶级分类默认level字段值为1
-- 如果新添加的记录不是顶级分类，那么新level应该为父节点的level + 1
CREATE TRIGGER `before_insert_category` BEFORE INSERT ON `category` FOR EACH ROW
BEGIN
	DECLARE lv SMALLINT;
	DECLARE c SMALLINT;
	IF NEW.parent_id > 0 THEN
		SELECT `level` + 1, COUNT(1) INTO lv, c FROM `category` WHERE `id` = NEW.parent_id;
		IF c = 0 THEN
			-- 父节点不存在，抛出异常
			INSERT INTO `parent_id_not_exists` VALUES(1);
		ELSE
			SET NEW.level = lv;
		END IF;
	END IF;

END;
$$

-- AFTER INSERT触发器
-- 添加记录后，在category_node_index表上添加节点索引
CREATE TRIGGER `after_insert_category` AFTER INSERT ON `category` FOR EACH ROW
BEGIN
	DECLARE parent_node VARCHAR(500);
	IF NEW.parent_id = 0 THEN
		INSERT INTO `category_node_index` VALUES(NEW.id, CONCAT(',0,', NEW.id, ','));
	ELSE
		SELECT `node_index` INTO parent_node FROM `category_node_index` WHERE `id` = NEW.parent_id;
		INSERT INTO `category_node_index` VALUES(NEW.id, CONCAT(parent_node, NEW.id, ','));
	END IF;
END;
$$

DELIMITER ;
