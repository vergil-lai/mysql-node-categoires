-- 无限分类存储过程
-- 由于MySQL的触发器不能操作本表，所以不能把删除操作写成触发器
-- 这样跟之前定义的insert和update操作的行为不一直，有待解决
-- 作者：Vergil <vergil@vip.163.com>
DROP PROCEDURE IF EXISTS `delete_category_procedure`;

DELIMITER $$

-- 删除节点及所有子节点
CREATE PROCEDURE `delete_category_procedure`(IN parent_id INT)
BEGIN
	DECLARE parent_node_index VARCHAR(500);

	SELECT `node_index` INTO parent_node_index FROM `category_node_index` WHERE `id` = parent_id;
	DELETE FROM `category` WHERE `id` IN (
		SELECT `id` FROM `category_node_index` WHERE LOCATE(parent_node_index, `node_index`) > 0 
	);
	DELETE FROM `category_node_index` WHERE LOCATE(parent_node_index, `node_index`) > 0 ;
END;

DELIMITER ;
